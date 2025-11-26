#import <Foundation/Foundation.h>
#include "CLinusBridge.h"

// Helper function to safely get file descriptor from FileHandle
// Returns -1 if FileHandle is closed or invalid (catches ObjC exceptions)
int clinus_safe_file_descriptor(void *fileHandle) {
    NSFileHandle *fh = (__bridge NSFileHandle *)fileHandle;
    @try {
        return fh.fileDescriptor;
    }
    @catch (NSException *exception) {
        // FileHandle is closed or invalid
        return -1;
    }
}

// Helper function to safely read data from FileHandle
// Returns NULL if operation fails (catches ObjC exceptions)
void *clinus_safe_read_data(void *fileHandle, NSUInteger length) {
    NSFileHandle *fh = (__bridge NSFileHandle *)fileHandle;
    @try {
        NSData *data = [fh readDataOfLength:length];
        // Copy data to a malloc'd buffer that caller must free
        NSUInteger dataLength = data.length;
        void *buffer = malloc(dataLength);
        if (buffer) {
            [data getBytes:buffer length:dataLength];
        }
        return buffer;
    }
    @catch (NSException *exception) {
        // FileHandle operation failed
        return NULL;
    }
}

