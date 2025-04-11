#ifndef _VML_TOOLS_H_
#define _VML_TOOLS_H_

/*
    Problem: when marshalling arrays inside internal call parameters, there's a section of 16 bytes which is included before the actual data, making arrays unusable without offset adjustment
    Solution: use a macro to slip 16 bytes data to pass an array's data
*/
#define VML_MARSHAL_ARRAY(type, var) ((type*)(((unsigned char*)(var))+16))

#endif