#import <Foundation/Foundation.h>
#include "CKalliopeBridge.h"

// Helper function to safely get file descriptor from FileHandle
// Returns -1 if FileHandle is closed or invalid (catches ObjC exceptions)
int ckalliope_safe_file_descriptor(void *fileHandle) {
    NSFileHandle *fh = (__bridge NSFileHandle *)fileHandle;
    @try {
        return fh.fileDescriptor;
    }
    @catch (NSException *exception) {
        // FileHandle is closed or invalid
        return -1;
    }
}

