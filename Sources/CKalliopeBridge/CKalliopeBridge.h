#ifndef CKALLIOPE_BRIDGE_H
#define CKALLIOPE_BRIDGE_H

#include <stdarg.h>
#include <stddef.h>

// Bridge functions to expose GMP va_list variants to Swift
// These functions are needed because the va_list variants are conditionally
// compiled in gmp.h based on _GMP_H_HAVE_VA_LIST, which may not be visible
// to Swift through the modulemap.

// Forward declarations of the underlying GMP functions
// These are declared in gmp.h but conditionally compiled, so we declare them here
// to ensure they're always available for linking
extern int __gmp_vprintf(const char *fmt, va_list ap);
extern int __gmp_vfprintf(void *stream, const char *fmt, va_list ap);
extern int __gmp_vsprintf(char *buf, const char *fmt, va_list ap);
extern int __gmp_vsnprintf(char *buf, size_t size, const char *fmt, va_list ap);
extern int __gmp_vasprintf(char **pp, const char *fmt, va_list ap);
extern int __gmp_vscanf(const char *fmt, va_list ap);
extern int __gmp_vfscanf(void *stream, const char *fmt, va_list ap);
extern int __gmp_vsscanf(const char *s, const char *fmt, va_list ap);

// Bridge functions - these will be implemented in CKalliope.c
int ckalliope_vprintf(const char *fmt, va_list ap);
int ckalliope_vfprintf(void *stream, const char *fmt, va_list ap);
int ckalliope_vsprintf(char *buf, const char *fmt, va_list ap);
int ckalliope_vsnprintf(char *buf, size_t size, const char *fmt, va_list ap);
int ckalliope_vasprintf(char **pp, const char *fmt, va_list ap);

// Formatted input with va_list
int ckalliope_vscanf(const char *fmt, va_list ap);
int ckalliope_vfscanf(void *stream, const char *fmt, va_list ap);
int ckalliope_vsscanf(const char *s, const char *fmt, va_list ap);

// Helper function for redirecting stdin from a file for testing
// Returns 0 on success, -1 on error
int ckalliope_redirect_stdin_from_file(const char *filepath);

// Helper function to restore stdin after redirection
// Returns 0 on success, -1 on error
int ckalliope_restore_stdin(int original_fd);

// Helper function to safely get file descriptor from FileHandle
// Returns -1 if FileHandle is closed or invalid (catches ObjC exceptions)
// fileHandle should be passed as an Unmanaged<FileHandle> (bridged to void*)
int ckalliope_safe_file_descriptor(void *fileHandle);

#endif /* CKALLIOPE_BRIDGE_H */
