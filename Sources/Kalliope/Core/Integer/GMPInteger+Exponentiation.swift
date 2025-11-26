import CKalliope

/// Exponentiation operator for `GMPInteger`.
infix operator **: MultiplicationPrecedence

/// Exponentiation operations for `GMPInteger`.
extension GMPInteger {
    /// Raise this integer to the power of `exponent`.
    ///
    /// Computes `self^exponent`. The case `0^0` yields 1.
    ///
    /// - Parameter exponent: The exponent. Must be non-negative.
    /// - Returns: A new `GMPInteger` equal to `self^exponent`.
    ///
    /// - Requires: This integer must be properly initialized. `exponent` must
    /// be non-negative.
    /// - Guarantees: Returns a new `GMPInteger` with the result. `self` is
    /// unchanged.
    ///   If `exponent` is 0, returns 1 (even if `self` is 0).
    ///
    /// - Note: Wraps `mpz_pow_ui`.
    public func raisedToPower(_ exponent: Int) -> GMPInteger {
        precondition(exponent >= 0, "exponent must be non-negative")
        let result = GMPInteger() // Mutated through pointer below
        __gmpz_pow_ui(
            &result._storage.value,
            &_storage.value,
            CUnsignedLong(exponent)
        )
        return result
    }

    /// Raise an `Int` base to the power of an `Int` exponent.
    ///
    /// - Parameters:
    ///   - base: The base value.
    ///   - exponent: The exponent. Must be non-negative.
    /// - Returns: A new `GMPInteger` equal to `base^exponent`.
    ///
    /// - Requires: `exponent` must be non-negative.
    /// - Guarantees: Returns a new `GMPInteger` with the result. The case `0^0`
    /// yields 1.
    ///
    /// - Note: Wraps `mpz_ui_pow_ui`.
    public static func power(base: Int, exponent: Int) -> GMPInteger {
        precondition(exponent >= 0, "exponent must be non-negative")
        let result = GMPInteger() // Mutated through pointer below
        if base >= 0 {
            __gmpz_ui_pow_ui(
                &result._storage.value,
                CUnsignedLong(base),
                CUnsignedLong(exponent)
            )
        } else {
            // For negative base, compute using absolute value and apply sign
            // based on exponent
            // Handle Int.min specially to avoid arithmetic overflow
            let absBase: CUnsignedLong = base == Int
                .min ? CUnsignedLong(Int.max) + 1 : CUnsignedLong(-base)
            let temp = GMPInteger() // Mutated through pointer below
            __gmpz_ui_pow_ui(
                &temp._storage.value,
                absBase,
                CUnsignedLong(exponent)
            )
            // If exponent is odd, result should be negative
            if exponent % 2 != 0 {
                __gmpz_neg(&result._storage.value, &temp._storage.value)
            } else {
                __gmpz_set(&result._storage.value, &temp._storage.value)
            }
        }
        return result
    }

    /// Raise this integer to the power of `exponent` modulo `modulus`.
    ///
    /// Computes `(self^exponent) mod modulus` efficiently using modular
    /// exponentiation.
    /// Negative exponents are supported if the modular inverse of `self` exists
    /// modulo `modulus`.
    ///
    /// - Parameters:
    ///   - exponent: The exponent. Can be negative if the modular inverse
    /// exists.
    ///   - modulus: The modulus. Must not be zero.
    /// - Returns: A new `GMPInteger` equal to `(self^exponent) mod modulus`.
    ///
    /// - Requires: This integer, `exponent`, and `modulus` must be properly
    /// initialized.
    ///   `modulus` must not be zero. If `exponent` is negative, the modular
    /// inverse of
    ///   `self` must exist modulo `modulus`.
    /// - Guarantees: Returns a new `GMPInteger` with the result. `self` is
    /// unchanged.
    ///   The result satisfies: `0 <= result < |modulus|`.
    ///
    /// - Throws: May cause a division by zero if `exponent` is negative and the
    /// modular
    ///   inverse doesn't exist.
    ///
    /// - Note: Wraps `mpz_powm`.
    public func raisedToPower(
        _ exponent: GMPInteger,
        modulo modulus: GMPInteger
    ) -> GMPInteger {
        precondition(!modulus.isZero, "modulus must not be zero")
        let result = GMPInteger() // Mutated through pointer below
        __gmpz_powm(
            &result._storage.value,
            &_storage.value,
            &exponent._storage.value,
            &modulus._storage.value
        )
        return result
    }

    /// Raise this integer to the power of an `Int` exponent modulo `modulus`.
    ///
    /// - Parameters:
    ///   - exponent: The exponent as an `Int`. Can be negative if the modular
    /// inverse exists.
    ///   - modulus: The modulus. Must not be zero.
    /// - Returns: A new `GMPInteger` equal to `(self^exponent) mod modulus`.
    ///
    /// - Requires: This integer and `modulus` must be properly initialized.
    /// `modulus` must
    ///   not be zero. If `exponent` is negative, the modular inverse must
    /// exist.
    /// - Guarantees: Returns a new `GMPInteger` with the result. `self` is
    /// unchanged.
    ///
    /// - Note: Wraps `mpz_powm_ui`.
    public func raisedToPower(
        _ exponent: Int,
        modulo modulus: GMPInteger
    ) -> GMPInteger {
        precondition(!modulus.isZero, "modulus must not be zero")
        let result = GMPInteger() // Mutated through pointer below
        if exponent >= 0 {
            __gmpz_powm_ui(
                &result._storage.value,
                &_storage.value,
                CUnsignedLong(exponent),
                &modulus._storage.value
            )
        } else {
            // For negative exponent, convert to GMPInteger and use mpz_powm
            let expGMP = GMPInteger(exponent)
            __gmpz_powm(
                &result._storage.value,
                &_storage.value,
                &expGMP._storage.value,
                &modulus._storage.value
            )
        }
        return result
    }

    /// Raise this integer to the power of `exponent` modulo `modulus` using
    /// constant-time algorithm.
    ///
    /// This function is designed for cryptographic applications where
    /// resistance to
    /// side-channel attacks is important. It takes the same time and has the
    /// same cache
    /// access patterns for any two same-size arguments (assuming identical
    /// machine state).
    ///
    /// - Parameters:
    ///   - exponent: The exponent. Must be positive.
    ///   - modulus: The modulus. Must be odd and not zero.
    /// - Returns: A new `GMPInteger` equal to `(self^exponent) mod modulus`.
    ///
    /// - Requires: This integer, `exponent`, and `modulus` must be properly
    /// initialized.
    ///   `exponent` must be positive (`> 0`). `modulus` must be odd and not
    /// zero.
    /// - Guarantees: Returns a new `GMPInteger` with the result computed using
    /// constant-time
    ///   algorithm. `self` is unchanged. The computation time is independent of
    /// the values
    ///   (for same-size inputs).
    ///
    /// - Note: This function is slower than `raisedToPower(_:modulo:)` but
    /// provides
    ///   protection against timing and cache-based side-channel attacks.
    ///
    /// - Note: Wraps `mpz_powm_sec`.
    public func raisedToPowerSecure(
        _ exponent: GMPInteger,
        modulo modulus: GMPInteger
    ) -> GMPInteger {
        precondition(!modulus.isZero, "modulus must not be zero")
        precondition(exponent.isPositive, "exponent must be positive")
        // Check that modulus is odd (we know modulus is not zero from above)
        let two = GMPInteger(2)
        // Safe to force try since two is 2 (non-zero), and we've checked
        // modulus is not zero
        precondition(
            (try! modulus.absoluteValue().modulo(two)).toInt() == 1,
            "modulus must be odd"
        )
        let result = GMPInteger() // Mutated through pointer below
        __gmpz_powm_sec(
            &result._storage.value,
            &_storage.value,
            &exponent._storage.value,
            &modulus._storage.value
        )
        return result
    }

    // MARK: - Operator Overloads

    /// Raise a `GMPInteger` to the power of an `Int`.
    ///
    /// - Parameters:
    ///   - base: The base value.
    ///   - exponent: The exponent. Must be non-negative.
    /// - Returns: A new `GMPInteger` equal to `base^exponent`.
    ///
    /// - Requires: `base` must be properly initialized. `exponent` must be
    /// non-negative.
    /// - Guarantees: Returns a new `GMPInteger` with the result.
    public static func ** (base: GMPInteger, exponent: Int) -> GMPInteger {
        base.raisedToPower(exponent)
    }
}
