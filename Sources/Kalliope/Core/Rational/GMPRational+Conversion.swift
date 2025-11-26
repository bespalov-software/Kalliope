import CKalliope
import Darwin

/// Conversion operations for `GMPRational`.
extension GMPRational {
    /// Convert this rational number to a `Double`.
    ///
    /// The conversion may be approximate if the rational cannot be represented
    /// exactly
    /// as a `Double`. If the value is too large for a `Double`, the result is
    /// system-dependent
    /// (typically infinity).
    ///
    /// - Returns: The value as a `Double`.
    ///
    /// - Requires: This rational must be properly initialized. The denominator
    /// must not be zero.
    /// - Guarantees: Returns a `Double` representing the rational value. The
    /// conversion may
    ///   be approximate. If the value is too large, the result is
    /// system-dependent.
    ///
    /// - Note: Wraps `mpq_get_d`.
    public func toDouble() -> Double {
        __gmpq_get_d(&_storage.value)
    }

    /// Convert this rational number to a string representation in the given
    /// base.
    ///
    /// The format is "num/den" where both numerator and denominator are
    /// represented in
    /// the specified base.
    ///
    /// - Parameter base: The numeric base (radix) for conversion. Must be in
    /// the range 2-62,
    ///   or from -2 to -36. Defaults to 10 (decimal).
    /// - Returns: A string representation in the format "num/den".
    ///
    /// - Requires: This rational must be properly initialized. `base` must be
    /// in the range
    ///   2-62 or -36 to -2.
    /// - Guarantees: Returns a valid string representation. The string can be
    /// parsed back
    ///   using `init(_:base:)` with the same base to recover the original
    /// value.
    ///
    /// - Note: Wraps `mpq_get_str`.
    public func toString(base: Int = 10) -> String {
        precondition(
            base >= 2 && base <= 62 || base >= -36 && base <= -2,
            "base must be in range 2-62 or -36 to -2"
        )

        // Pass NULL to let GMP allocate the buffer
        let cString = __gmpq_get_str(nil, Int32(base), &_storage.value)
        defer {
            // Free the allocated string
            free(cString)
        }

        guard let cString else {
            // Should not happen, but handle gracefully
            return "0/1"
        }

        return String(cString: cString)
    }

    /// Create a rational number from a string representation.
    ///
    /// Parses a string in the format "num/den" or just "num" (denominator
    /// defaults to 1).
    /// The fraction is automatically canonicalized.
    ///
    /// - Parameters:
    ///   - string: The string to parse. Format: "num/den" or "num".
    ///   - base: The numeric base (radix) for parsing. Must be 0 or in the
    /// range 2-62.
    ///     Defaults to 10.
    /// - Returns: A new `GMPRational` if parsing succeeds, `nil` otherwise.
    ///
    /// - Requires: `base` must be 0 or in the range 2-62. `string` must not be
    /// empty.
    /// - Guarantees: If parsing succeeds, returns a valid `GMPRational` with
    /// the canonicalized
    ///   value. If parsing fails, returns `nil`.
    public init?(_ string: String, base: Int = 10) {
        precondition(
            base == 0 || (base >= 2 && base <= 62),
            "base must be 0 or in the range 2-62"
        )
        guard !string.isEmpty else {
            return nil
        }
        _storage = _GMPRationalStorage()
        let result = string.withCString { cString in
            __gmpq_set_str(&_storage.value, cString, Int32(base))
        }
        if result != 0 {
            return nil
        }
        // Check if denominator is zero before canonicalizing (canonicalize
        // crashes on zero denominator)
        let denIsZero = withUnsafeMutablePointer(to: &_storage.value) { qPtr in
            // Access the _mp_den field of the mpq_t structure
            let denPtr = withUnsafeMutablePointer(to: &qPtr.pointee._mp_den) {
                $0
            }
            return __gmpz_cmp_ui(denPtr, 0) == 0
        }
        if denIsZero {
            return nil
        }
        // Canonicalize the result
        __gmpq_canonicalize(&_storage.value)
    }
}
