#!/usr/bin/env python

# Depedency name importer for SCE SDK stubs  

import sys
import re
import subprocess
import yaml

primitives = (bool, str, int, float, type(None))

def is_primitive(obj):
    return isinstance(obj, primitives)

def hex_representer(dumper, data):
    return dumper.represent_int(hex(data).upper().replace('X', 'x'))

removable_variables = ['firmware', 'kernel']

def clean_yaml(obj, variables):
    if(not is_primitive(obj)):
        to_remove = []
        for var in variables:
            if(var in obj):
                del obj[var]
        for e in obj:
            clean_yaml(obj[e], variables)

yaml.add_representer(int, hex_representer)

if len(sys.argv) != 2:
    print(f"Usage: {sys.argv[0]} <yaml_file>")
    sys.exit(1)

yaml_file = sys.argv[1]
try:
    with open(yaml_file, 'r') as file:
        yml_contents = yaml.safe_load(file)    
except FileNotFoundError:
    print(f"File {yaml_file} not found.")
    sys.exit(1)

clean_yaml(yml_contents, removable_variables)

with open(yaml_file, 'w') as file:
    yaml.dump(yml_contents, file, default_flow_style=False, sort_keys=False)
print(f"Results written to {yaml_file}.")
