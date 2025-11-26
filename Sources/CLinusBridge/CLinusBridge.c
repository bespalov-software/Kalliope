// Bridge functions to expose MPFR macros to Swift
// This C target depends on CLinus and provides bridge functions for macros
// that Swift cannot parse directly.

#include "CLinusBridge.h"

// Include stdio.h and stdarg.h first to ensure FILE and va_list are defined
#include <stdio.h>
#include <stdarg.h>

// Include mpfr.h here where we have access to the headers via CLinus dependency
// We need to include it after our header to get the actual macro definitions
// Note: Unlike CKalliopeBridge which uses extern declarations for functions,
// we MUST include mpfr.h here because we need macro values (MPFR_PREC_MIN, MPFR_PREC_MAX)
// which are compile-time constants that must be expanded from the header.
#include <mpfr.h>

// Get MPFR_PREC_MIN constant
mpfr_prec_t clinus_get_prec_min(void) {
    return MPFR_PREC_MIN;
}

// Get MPFR_PREC_MAX constant
mpfr_prec_t clinus_get_prec_max(void) {
    return MPFR_PREC_MAX;
}

// Bridge functions to expose MPFR rounding functions that accept rounding mode
// These wrap mpfr_rint_* functions which take a rounding mode parameter,
// unlike the mpfr_floor/ceil/trunc macros which have fixed rounding modes.
// We cast void* pointers to the proper MPFR types after including mpfr.h

// Floor function with rounding mode parameter
int clinus_mpfr_rint_floor(void *rop, const void *op, int rnd) {
    return mpfr_rint_floor((mpfr_ptr)rop, (mpfr_srcptr)op, (mpfr_rnd_t)rnd);
}

// Ceil function with rounding mode parameter
int clinus_mpfr_rint_ceil(void *rop, const void *op, int rnd) {
    return mpfr_rint_ceil((mpfr_ptr)rop, (mpfr_srcptr)op, (mpfr_rnd_t)rnd);
}

// Trunc function with rounding mode parameter
int clinus_mpfr_rint_trunc(void *rop, const void *op, int rnd) {
    return mpfr_rint_trunc((mpfr_ptr)rop, (mpfr_srcptr)op, (mpfr_rnd_t)rnd);
}

// Bridge functions to expose MPFR va_list variants to Swift
// These ensure the functions are always available regardless of conditional compilation

// Print formatted output to stdout using va_list
int clinus_mpfr_vprintf(const char *fmt, va_list ap) {
    return mpfr_vprintf(fmt, ap);
}

// Print formatted output to FILE* stream using va_list
int clinus_mpfr_vfprintf(void *stream, const char *fmt, va_list ap) {
    return mpfr_vfprintf((FILE *)stream, fmt, ap);
}

// Note: MPFR does not provide vscanf or vfscanf functions.
// Formatted input must be implemented by reading strings and parsing them
// using mpfr_set_str or mpfr_strtofr.

