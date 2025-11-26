import CKalliope
import Darwin

/// Conversion operations for `GMPFloat`.
extension GMPFloat {
    /// Convert this float to a `Double`.
    ///
    /// The conversion may lose precision if this float has more precision than
    /// a `Double`.
    /// If the value is too large for a `Double`, the result is system-dependent
    /// (typically infinity).
    ///
    /// - Returns: The value as a `Double`.
    ///
    /// - Wraps: `mpf_get_d`
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns a `Double` representing the float value. The
    /// conversion may
    ///   lose precision. If the value is too large, the result is
    /// system-dependent.
    public func toDouble() -> Double {
        __gmpf_get_d(&_storage.value)
    }

    /// Convert this float to a `Double` with separate exponent.
    ///
    /// Similar to the standard C `frexp` function. Returns the value as a
    /// mantissa
    /// in the range [0.5, 1) and a separate exponent such that `mantissa *
    /// 2^exponent`
    /// equals the float value.
    ///
    /// - Returns: A tuple `(mantissa: Double, exponent: Int)` where the
    /// mantissa is
    ///   in the range [0.5, 1) and `mantissa * 2^exponent` equals the float
    /// value.
    ///   If the value is zero, returns `(0.0, 0)`.
    ///
    /// - Wraps: `mpf_get_d_2exp`
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: The mantissa is always in the range [0.5, 1) (or 0.0 for
    /// zero),
    ///   and `mantissa * 2^exponent` equals the float value.
    public func toDouble2Exp() -> (mantissa: Double, exponent: Int) {
        var exp: CLong = 0
        let mantissa = __gmpf_get_d_2exp(&exp, &_storage.value)
        return (mantissa: mantissa, exponent: Int(exp))
    }

    /// Convert this float to an unsigned integer.
    ///
    /// Truncates toward zero. If the value is too large or negative, only the
    /// least
    /// significant bits are returned.
    ///
    /// - Returns: The value as a `UInt`, truncated toward zero.
    ///
    /// - Wraps: `mpf_get_ui`
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns a `UInt` representing the truncated value. Use
    /// `fitsInUInt()`
    ///   to check if the conversion is exact.
    public func toUInt() -> UInt {
        UInt(__gmpf_get_ui(&_storage.value))
    }

    /// Convert this float to a signed integer.
    ///
    /// Truncates toward zero. If the value is too large, only the least
    /// significant
    /// bits are returned.
    ///
    /// - Returns: The value as an `Int`, truncated toward zero.
    ///
    /// - Wraps: `mpf_get_si`
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns an `Int` representing the truncated value. Use
    /// `fitsInInt()`
    ///   to check if the conversion is exact.
    public func toInt() -> Int {
        Int(__gmpf_get_si(&_storage.value))
    }

    /// Convert this float to a string representation in the given base.
    ///
    /// - Parameters:
    ///   - base: The numeric base (radix) for conversion. Must be in the range
    /// 2-62,
    ///     or from -2 to -36. Defaults to 10 (decimal).
    ///   - digits: The number of significant digits to output. If 0, outputs
    /// all significant
    ///     digits. Must be non-negative.
    /// - Returns: A string representation of the float in the specified base.
    ///
    /// - Wraps: `mpf_get_str`
    ///
    /// - Requires: This float must be properly initialized. `base` must be in
    /// the range
    ///   2-62 or -36 to -2. `digits` must be non-negative.
    /// - Guarantees: Returns a valid string representation. The string can be
    /// parsed back
    ///   using `init(_:base:)` with the same base to recover the value (within
    /// precision limits).
    public func toString(base: Int = 10, digits: Int = 0) -> String {
        precondition(
            (base >= 2 && base <= 62) || (base >= -36 && base <= -2),
            "base must be in range 2-62 or -36 to -2"
        )
        precondition(digits >= 0, "digits must be non-negative")

        var exp: mp_exp_t = 0
        let absBase = base >= 0 ? base : -base

        // Call mpf_get_str with NULL to allocate buffer
        // Returns pointer to allocated string that we must free
        let cString = __gmpf_get_str(
            nil,
            &exp,
            Int32(absBase),
            size_t(digits),
            &_storage.value
        )
        defer {
            // Free the allocated string
            free(cString)
        }

        guard let cString else {
            // Should not happen, but handle gracefully
            return "0"
        }

        let mantissaString = String(cString: cString)

        // Handle zero case
        if mantissaString == "0" || mantissaString.isEmpty {
            return "0"
        }

        // Format the string with decimal point and exponent
        // The mantissa from GMP has the decimal point before the first digit
        // exp is the exponent in the given base
        if exp == 0 {
            // Value is between 1/base and 1, so format as "0.mantissa"
            return "0.\(mantissaString)"
        } else if exp > 0 {
            // Value >= 1, insert decimal point after exp digits
            if exp >= mantissaString.count {
                // All digits are before decimal point, append zeros if needed
                return mantissaString + String(
                    repeating: "0",
                    count: Int(exp) - mantissaString.count
                )
            } else {
                // Insert decimal point
                let index = mantissaString.index(
                    mantissaString.startIndex,
                    offsetBy: Int(exp)
                )
                return String(mantissaString[..<index]) + "." +
                    String(mantissaString[index...])
            }
        } else {
            // Value < 1/base, format as "0.00...0mantissa" with |exp| zeros
            let zeros = String(repeating: "0", count: Int(-exp))
            return "0.\(zeros)\(mantissaString)"
        }
    }

    /// Check if this float's value fits exactly in a `UInt`.
    ///
    /// - Returns: `true` if the value is non-negative, has no fractional part,
    /// and fits
    ///   in a `UInt`, `false` otherwise.
    ///
    /// - Wraps: `mpf_fits_ulong_p` or `mpf_fits_uint_p` and `mpf_integer_p`
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `toUInt()` would return the
    /// exact value.
    public func fitsInUInt() -> Bool {
        // Must be non-negative, integer, and fit in UInt
        guard !isNegative else { return false }
        guard __gmpf_integer_p(&_storage.value) != 0 else { return false }
        return __gmpf_fits_ulong_p(&_storage.value) != 0
    }

    /// Check if this float's value fits exactly in an `Int`.
    ///
    /// - Returns: `true` if the value has no fractional part and fits in an
    /// `Int`,
    ///   `false` otherwise.
    ///
    /// - Wraps: `mpf_fits_slong_p` or `mpf_fits_sint_p` and `mpf_integer_p`
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `toInt()` would return the
    /// exact value.
    public func fitsInInt() -> Bool {
        // Must be integer and fit in Int
        guard __gmpf_integer_p(&_storage.value) != 0 else { return false }
        return __gmpf_fits_slong_p(&_storage.value) != 0
    }

    /// Check if this float's value fits exactly in a `UInt64`.
    ///
    /// - Returns: `true` if the value is non-negative, has no fractional part,
    /// and fits
    ///   in a `UInt64`, `false` otherwise.
    ///
    /// - Wraps: `mpf_fits_ulong_p` and `mpf_integer_p`
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns `true` if and only if the value can be represented
    /// exactly as a `UInt64`.
    public func fitsInUInt64() -> Bool {
        // Must be non-negative, integer, and fit in UInt64
        guard !isNegative else { return false }
        guard __gmpf_integer_p(&_storage.value) != 0 else { return false }
        // On 64-bit platforms, UInt64 == unsigned long, so we can use the same
        // function
        #if arch(x86_64) || arch(arm64) || arch(arm64_32)
            return __gmpf_fits_ulong_p(&_storage.value) != 0
        #else
            // On 32-bit platforms, need custom check
            return compare(to: GMPFloat(UInt64.max)) <= 0
        #endif
    }

    /// Check if this float's value fits exactly in an `Int64`.
    ///
    /// - Returns: `true` if the value has no fractional part and fits in an
    /// `Int64`,
    ///   `false` otherwise.
    ///
    /// - Wraps: `mpf_fits_slong_p` and `mpf_integer_p`
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns `true` if and only if the value can be represented
    /// exactly as an `Int64`.
    public func fitsInInt64() -> Bool {
        // Must be integer and fit in Int64
        guard __gmpf_integer_p(&_storage.value) != 0 else { return false }
        // On 64-bit platforms, Int64 == signed long, so we can use the same
        // function
        #if arch(x86_64) || arch(arm64) || arch(arm64_32)
            return __gmpf_fits_slong_p(&_storage.value) != 0
        #else
            // On 32-bit platforms, need custom check
            let min = GMPFloat(Int64.min)
            let max = GMPFloat(Int64.max)
            return compare(to: min) >= 0 && compare(to: max) <= 0
        #endif
    }
}
