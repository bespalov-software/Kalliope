#ifndef CLINUS_BRIDGE_H
#define CLINUS_BRIDGE_H

#include <stdarg.h>
#include <stddef.h>

// Forward declare mpfr_prec_t (defined in mpfr.h)
// We can't include mpfr.h directly here because CLinus is a binary target
// The actual definition will be available when linking against CLinus
typedef long mpfr_prec_t;

// Bridge functions to expose MPFR macros to Swift
// MPFR_PREC_MAX is a complex macro that Swift cannot parse directly,
// so we provide C functions to access these values.

// Get MPFR_PREC_MIN constant
mpfr_prec_t clinus_get_prec_min(void);

// Get MPFR_PREC_MAX constant
mpfr_prec_t clinus_get_prec_max(void);

// Bridge functions to expose MPFR rounding functions that accept rounding mode
// These wrap mpfr_rint_* functions which take a rounding mode parameter,
// unlike the mpfr_floor/ceil/trunc macros which have fixed rounding modes.
// We use void* pointers in the header to avoid needing to include mpfr.h types.
// The implementation will cast to the proper types after including mpfr.h

// Floor function with rounding mode parameter
int clinus_mpfr_rint_floor(void *rop, const void *op, int rnd);

// Ceil function with rounding mode parameter
int clinus_mpfr_rint_ceil(void *rop, const void *op, int rnd);

// Trunc function with rounding mode parameter
int clinus_mpfr_rint_trunc(void *rop, const void *op, int rnd);

// Bridge functions to expose MPFR va_list variants to Swift
// These functions are needed because the va_list variants may not be visible
// to Swift through the modulemap, similar to CKalliopeBridge pattern.
//
// Note: MPFR does not have vscanf/vfscanf functions, so we only provide printf bridges
int clinus_mpfr_vprintf(const char *fmt, va_list ap);
int clinus_mpfr_vfprintf(void *stream, const char *fmt, va_list ap);

// Helper function to safely get file descriptor from FileHandle
// Returns -1 if FileHandle is closed or invalid (catches ObjC exceptions)
// fileHandle should be passed as an Unmanaged<FileHandle> (bridged to void*)
int clinus_safe_file_descriptor(void *fileHandle);

#endif /* CLINUS_BRIDGE_H */

