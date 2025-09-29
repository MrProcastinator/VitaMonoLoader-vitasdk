#ifndef _VML_TOOLS_H_
#define _VML_TOOLS_H_

/*
    Problem: sometimes passing pointer to array of structures are passed misaligned
    Solution: use a macro to realign the array according to the situation
*/

#define VML_OFFSET_ARRAY(type, var, offset) ((type*)(((unsigned char*)(var))+offset))

/*
    Problem: when marshalling arrays inside internal call parameters, there's a section of 16 bytes which is included before the actual data, making arrays unusable without offset adjustment
    Solution: use a macro to slip 16 bytes data to pass an array's data
*/

#define VML_MARSHAL_ARRAY(type, var) VML_OFFSET_ARRAY(type, var, 16)

#endif