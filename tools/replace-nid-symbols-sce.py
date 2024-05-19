#!/usr/bin/env python

# Depedency name importer for SCE SDK stubs  

import sys
import re
import subprocess
import yaml

def ishexstring(str):
    return re.search(r'^[a-fA-F0-9]+$', str)

def hex_representer(dumper, data):
    return dumper.represent_int(hex(data).upper().replace('X', 'x'))

yaml.add_representer(int, hex_representer)

if len(sys.argv) != 4:
    print(f"Usage: {sys.argv[0]} <input_file> <output_file> <module_name>")
    sys.exit(1)

module = sys.argv[3]

input_file = sys.argv[1]
try:
    objdump_output = subprocess.check_output(['arm-vita-eabi-objdump', '-D', input_file], universal_newlines=True)
    content = objdump_output.splitlines()
except subprocess.CalledProcessError as e:
    print(f"Error running objdump on {input_file}: {e.output}")
    sys.exit(1)
except FileNotFoundError:
    print(f"File {input_file} not found.")
    sys.exit(1)

function_pattern = re.compile(r'_(\w+)-[0-9]{4}_F[0-9]{2}_([0-9a-fA-F]{8})\.o:\s+file format elf32-littlearm')
var_pattern =      re.compile(r'_(\w+)-[0-9]{4}_V[0-9]{2}_([0-9a-fA-F]{8})\.o:\s+file format elf32-littlearm')

function_results = {}
variable_results = {}

def add_entry(coll, library, symbol, nid):
    if(not library in coll):
        coll[library] = {}
    coll[library][nid] = symbol

def add_missing_entries(entries, library, findings):
    added = 0
    if(library in findings):
        declared_nids = entries.values()
        found_nids = findings[library].keys()
        for found_nid in found_nids:
            if found_nid not in declared_nids:
                entries[findings[library][found_nid]] = found_nid
                added += 1
    return added

def replace_entries(entries, library, findings):
    changed = 0
    old_entries = entries.copy()
    entries.clear()
    for entry in old_entries:
        entry_parts = entry.rsplit('_', 1)
        # Check for nids-extract standard format
        if(len(entry_parts) == 2 and entry_parts[0] == library and ishexstring(entry_parts[1])):
            nid = int(entry_parts[1], 16)
            if(nid in findings[library]):
                entries[findings[library][nid]] = old_entries[entry]
                changed += 1
            else:
                entries[entry] = old_entries[entry]
        else:
            # Unknown format entry
            entries[entry] = old_entries[entry]
    return changed

for i, line in enumerate(content):
    match = function_pattern.search(line)
    if match:
        lib_file = match.group(1)
        nid = match.group(2)
        next_line = content[i + 3]
        if next_line.startswith(f'Disassembly of section .sceStub.text.{lib_file}.'):
            symbol = next_line.strip().replace(f'Disassembly of section .sceStub.text.{lib_file}.', '').split(':')[0]
            add_entry(function_results, lib_file, symbol, int(nid, 16))
            continue

    match = var_pattern.search(line)
    if match:
        lib_file = match.group(1)
        nid = match.group(2)
        # Skip the next 2 lines and read the next line
        next_line = content[i + 3]
        if next_line.startswith(f'Disassembly of section .sceVStub.rodata.{lib_file}.'):
            symbol = next_line.strip().replace(f'Disassembly of section .sceVStub.rodata.{lib_file}.', '').split(':')[0]
            add_entry(variable_results, lib_file, symbol, int(nid, 16))

# Write the dictionary entries to the output file
output_file = sys.argv[2]
try:
    with open(output_file, 'r') as file:
        yml_contents = yaml.safe_load(file)    
except FileNotFoundError:
    print(f"File {output_file} not found.")
    sys.exit(1)

edited = 0

if(yml_contents and "modules" in yml_contents):
    for module in yml_contents["modules"]:
        if("libraries" in yml_contents["modules"][module]):
            for library in yml_contents["modules"][module]["libraries"]:
                if(not "functions" in yml_contents["modules"][module]["libraries"][library]):
                    yml_contents["modules"][module]["libraries"][library]["functions"] = {}
                edited = edited + replace_entries(yml_contents["modules"][module]["libraries"][library]["functions"], library, function_results) > 0
                edited = edited + add_missing_entries(yml_contents["modules"][module]["libraries"][library]["functions"], library, function_results) > 0
                if (len(yml_contents["modules"][module]["libraries"][library]["functions"].keys()) == 0):
                    del yml_contents["modules"][module]["libraries"][library]["functions"]
                if(not "variables" in yml_contents["modules"][module]["libraries"][library]):
                    yml_contents["modules"][module]["libraries"][library]["variables"] = {}
                edited = edited + replace_entries(yml_contents["modules"][module]["libraries"][library]["variables"], library, variable_results) > 0
                edited = edited + add_missing_entries(yml_contents["modules"][module]["libraries"][library]["variables"], library, variable_results) > 0
                if (len(yml_contents["modules"][module]["libraries"][library]["variables"].keys()) == 0):
                    del yml_contents["modules"][module]["libraries"][library]["variables"]

if(edited > 0):
    with open(output_file, 'w') as file:
        yaml.dump(yml_contents, file, default_flow_style=False, sort_keys=False)

    print(f"Results written to {output_file}.")
else:
    print(f"No symbols changed in {output_file}")