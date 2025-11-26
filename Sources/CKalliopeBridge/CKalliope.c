// Bridge functions to expose GMP va_list variants to Swift
// This C target depends on CKalliope and provides bridge functions for va_list variants
// that may not be visible to Swift through the modulemap.

#include "CKalliopeBridge.h"
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>

// We don't need to include gmp.h here since we've declared the __gmp_* functions
// as extern in CKalliopeBridge.h. The linker will resolve them from the CKalliope framework.

// Bridge functions to expose GMP va_list variants to Swift
// These ensure the functions are always available regardless of conditional compilation

int ckalliope_vprintf(const char *fmt, va_list ap) {
    return __gmp_vprintf(fmt, ap);
}

int ckalliope_vfprintf(void *stream, const char *fmt, va_list ap) {
    return __gmp_vfprintf((FILE *)stream, fmt, ap);
}

int ckalliope_vsprintf(char *buf, const char *fmt, va_list ap) {
    return __gmp_vsprintf(buf, fmt, ap);
}

int ckalliope_vsnprintf(char *buf, size_t size, const char *fmt, va_list ap) {
    return __gmp_vsnprintf(buf, size, fmt, ap);
}

int ckalliope_vasprintf(char **pp, const char *fmt, va_list ap) {
    return __gmp_vasprintf(pp, fmt, ap);
}

int ckalliope_vscanf(const char *fmt, va_list ap) {
    return __gmp_vscanf(fmt, ap);
}

int ckalliope_vfscanf(void *stream, const char *fmt, va_list ap) {
    return __gmp_vfscanf((FILE *)stream, fmt, ap);
}

int ckalliope_vsscanf(const char *s, const char *fmt, va_list ap) {
    return __gmp_vsscanf(s, fmt, ap);
}

// Helper function for redirecting stdin from a file for testing
// This function is designed to be thread-safe by avoiding fflush which can deadlock
int ckalliope_redirect_stdin_from_file(const char *filepath) {
    // Use freopen to redirect stdin to the file
    // freopen atomically closes the old stream and opens the new file
    // This is thread-safe as it's an atomic operation on the FILE* stream
    FILE *result = freopen(filepath, "r", stdin);
    if (result == NULL) {
        return -1;
    }
    
    // Ensure stdin was updated correctly (freopen should set stdin = result)
    if (result != stdin) {
        return -1;
    }
    
    // Clear any error flags and ensure we're at the start of the file
    clearerr(stdin);
    rewind(stdin);
    
    return 0;
}

// Helper function to restore stdin after redirection
// This function is designed to be thread-safe by avoiding fflush which can deadlock
int ckalliope_restore_stdin(int original_fd) {
    // Restore the file descriptor first using dup2
    // This makes STDIN_FILENO point back to the original file descriptor
    if (dup2(original_fd, STDIN_FILENO) < 0) {
        return -1;
    }
    
    // Reopen stdin as a FILE* stream from the restored file descriptor
    // Use freopen with NULL to reopen from the current file descriptor
    // This is the POSIX extension that reopens a stream from an existing file descriptor
    // Note: This may not be available on all systems, but it's the standard way
    FILE *result = freopen(NULL, "r", stdin);
    if (result == NULL) {
        return -1;
    }
    
    // Ensure stdin was updated correctly
    if (result != stdin) {
        return -1;
    }
    
    // Clear any error flags
    clearerr(stdin);
    
    return 0;
}

