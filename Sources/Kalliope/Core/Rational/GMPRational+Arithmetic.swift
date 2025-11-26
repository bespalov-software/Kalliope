import CKalliope

/// Arithmetic operations for `GMPRational`.
///
/// This extension provides both immutable (functional) and mutable (in-place)
/// arithmetic operations. All operations support arbitrary precision and handle
/// overflow automatically.
extension GMPRational {
    // MARK: - Immutable Operations (Return New Values)

    /// Add another `GMPRational` to this rational, returning a new value.
    ///
    /// - Parameter other: The rational to add.
    /// - Returns: A new `GMPRational` equal to `self + other`.
    ///
    /// - Requires: Both rationals must be properly initialized.
    /// - Guarantees: Returns a new `GMPRational` with the sum (canonicalized).
    ///   `self` is unchanged. The operation is safe even if `self` and `other`
    ///   are the same variable.
    ///
    /// - Note: Wraps `mpq_add`.
    public func adding(_ other: GMPRational) -> GMPRational {
        let result = GMPRational() // Mutated through pointer below
        __gmpq_add(
            &result._storage.value,
            &_storage.value,
            &other._storage.value
        )
        return result
    }

    /// Subtract another `GMPRational` from this rational, returning a new
    /// value.
    ///
    /// - Parameter other: The rational to subtract.
    /// - Returns: A new `GMPRational` equal to `self - other`.
    ///
    /// - Requires: Both rationals must be properly initialized.
    /// - Guarantees: Returns a new `GMPRational` with the difference
    /// (canonicalized).
    ///   `self` is unchanged. The operation is safe even if `self` and `other`
    ///   are the same variable.
    ///
    /// - Note: Wraps `mpq_sub`.
    public func subtracting(_ other: GMPRational) -> GMPRational {
        let result = GMPRational() // Mutated through pointer below
        __gmpq_sub(
            &result._storage.value,
            &_storage.value,
            &other._storage.value
        )
        return result
    }

    /// Multiply this rational by another, returning a new value.
    ///
    /// - Parameter other: The rational to multiply by.
    /// - Returns: A new `GMPRational` equal to `self * other`.
    ///
    /// - Requires: Both rationals must be properly initialized.
    /// - Guarantees: Returns a new `GMPRational` with the product
    /// (canonicalized).
    ///   `self` is unchanged. The operation is safe even if `self` and `other`
    ///   are the same variable.
    ///
    /// - Note: Wraps `mpq_mul`.
    public func multiplied(by other: GMPRational) -> GMPRational {
        let result = GMPRational() // Mutated through pointer below
        __gmpq_mul(
            &result._storage.value,
            &_storage.value,
            &other._storage.value
        )
        return result
    }

    /// Divide this rational by another, returning a new value.
    ///
    /// - Parameter other: The rational to divide by. Must not be zero.
    /// - Returns: A new `GMPRational` equal to `self / other`.
    ///
    /// - Requires: Both rationals must be properly initialized. `other` must
    /// not be zero.
    /// - Guarantees: Returns a new `GMPRational` with the quotient
    /// (canonicalized).
    ///   `self` is unchanged. The operation is safe even if `self` and `other`
    ///   are the same variable (and non-zero).
    ///
    /// - Throws: `GMPError.divisionByZero` if `other` is zero.
    ///
    /// - Note: Wraps `mpq_div`.
    public func divided(by other: GMPRational) throws -> GMPRational {
        guard !other.numerator.isZero else {
            throw GMPError.divisionByZero
        }
        let result = GMPRational() // Mutated through pointer below
        __gmpq_div(
            &result._storage.value,
            &_storage.value,
            &other._storage.value
        )
        return result
    }

    /// Negate this rational, returning a new value.
    ///
    /// - Returns: A new `GMPRational` equal to `-self`.
    ///
    /// - Requires: This rational must be properly initialized.
    /// - Guarantees: Returns a new `GMPRational` with the negated value.
    ///   `self` is unchanged.
    ///
    /// - Note: Wraps `mpq_neg`.
    public func negated() -> GMPRational {
        let result = GMPRational() // Mutated through pointer below
        __gmpq_neg(
            &result._storage.value,
            &_storage.value
        )
        return result
    }

    /// Get the absolute value of this rational, returning a new value.
    ///
    /// - Returns: A new `GMPRational` equal to `|self|`.
    ///
    /// - Requires: This rational must be properly initialized.
    /// - Guarantees: Returns a new `GMPRational` with the absolute value.
    ///   `self` is unchanged.
    ///
    /// - Note: Wraps `mpq_abs`.
    public func absoluteValue() -> GMPRational {
        let result = GMPRational() // Mutated through pointer below
        __gmpq_abs(
            &result._storage.value,
            &_storage.value
        )
        return result
    }

    /// Invert this rational (compute reciprocal), returning a new value.
    ///
    /// - Returns: A new `GMPRational` equal to `1/self`.
    ///
    /// - Requires: This rational must be properly initialized and non-zero.
    /// - Guarantees: Returns a new `GMPRational` with the reciprocal
    /// (canonicalized).
    ///   `self` is unchanged.
    ///
    /// - Throws: `GMPError.divisionByZero` if `self` is zero.
    ///
    /// - Note: Wraps `mpq_inv`.
    public func inverted() throws -> GMPRational {
        guard !numerator.isZero else {
            throw GMPError.divisionByZero
        }
        let result = GMPRational() // Mutated through pointer below
        __gmpq_inv(
            &result._storage.value,
            &_storage.value
        )
        return result
    }

    // MARK: - Mutable Operations (Modify in Place)

    /// Add another `GMPRational` to this rational in place.
    ///
    /// - Parameter other: The rational to add.
    ///
    /// - Requires: Both rationals must be properly initialized.
    /// - Guarantees: After this call, `self` equals `self + other` (before the
    /// call).
    ///   The operation is safe even if `self` and `other` are the same
    /// variable.
    ///
    /// - Note: Wraps `mpq_add`.
    public mutating func add(_ other: GMPRational) {
        // Use immutable adding() to avoid exclusivity violations when self ===
        // other
        let result = adding(other)
        self = result
    }

    /// Subtract another `GMPRational` from this rational in place.
    ///
    /// - Parameter other: The rational to subtract.
    ///
    /// - Requires: Both rationals must be properly initialized.
    /// - Guarantees: After this call, `self` equals `self - other` (before the
    /// call).
    ///   The operation is safe even if `self` and `other` are the same
    /// variable.
    ///
    /// - Note: Wraps `mpq_sub`.
    public mutating func subtract(_ other: GMPRational) {
        // Use immutable subtracting() to avoid exclusivity violations when self
        // === other
        let result = subtracting(other)
        self = result
    }

    /// Multiply this rational by another in place.
    ///
    /// - Parameter other: The rational to multiply by.
    ///
    /// - Requires: Both rationals must be properly initialized.
    /// - Guarantees: After this call, `self` equals `self * other` (before the
    /// call).
    ///   The operation is safe even if `self` and `other` are the same
    /// variable.
    ///
    /// - Note: Wraps `mpq_mul`.
    public mutating func multiply(by other: GMPRational) {
        // Use immutable multiplied(by:) to avoid exclusivity violations when
        // self === other
        let result = multiplied(by: other)
        self = result
    }

    /// Divide this rational by another in place.
    ///
    /// - Parameter other: The rational to divide by. Must not be zero.
    ///
    /// - Requires: Both rationals must be properly initialized. `other` must
    /// not be zero.
    /// - Guarantees: After this call, `self` equals `self / other` (before the
    /// call).
    ///   The operation is safe even if `self` and `other` are the same variable
    /// (and non-zero).
    ///
    /// - Throws: `GMPError.divisionByZero` if `other` is zero.
    ///
    /// - Note: Wraps `mpq_div`.
    public mutating func divide(by other: GMPRational) throws {
        // Use immutable divided(by:) to avoid exclusivity violations when self
        // === other
        let result = try divided(by: other)
        self = result
    }

    /// Negate this rational in place.
    ///
    /// - Requires: This rational must be properly initialized.
    /// - Guarantees: After this call, `self` equals `-self` (before the call).
    ///
    /// - Note: Wraps `mpq_neg`.
    public mutating func negate() {
        // Use immutable negated() to avoid exclusivity violations
        let result = negated()
        self = result
    }

    /// Replace this rational with its absolute value in place.
    ///
    /// - Requires: This rational must be properly initialized.
    /// - Guarantees: After this call, `self` equals `|self|` (before the call).
    ///
    /// - Note: Wraps `mpq_abs`.
    public mutating func makeAbsolute() {
        // Use immutable absoluteValue() to avoid exclusivity violations
        let result = absoluteValue()
        self = result
    }

    /// Invert this rational (compute reciprocal) in place.
    ///
    /// - Requires: This rational must be properly initialized and non-zero.
    /// - Guarantees: After this call, `self` equals `1/self` (before the call).
    ///
    /// - Throws: `GMPError.divisionByZero` if `self` is zero.
    ///
    /// - Note: Wraps `mpq_inv`.
    public mutating func invert() throws {
        // Use immutable inverted() to avoid exclusivity violations
        let result = try inverted()
        self = result
    }

    // MARK: - Power of 2 Operations

    /// Multiply this rational by 2 raised to the power of `exponent`, returning
    /// a new value.
    ///
    /// For positive exponents, multiplies by 2^exponent. For negative
    /// exponents,
    /// effectively divides by 2^|exponent|.
    ///
    /// - Parameter exponent: The exponent for the power of 2. Can be negative.
    /// - Returns: A new `GMPRational` equal to `self * 2^exponent`.
    ///
    /// - Requires: This rational must be properly initialized.
    /// - Guarantees: Returns a new `GMPRational` with the result
    /// (canonicalized).
    ///   `self` is unchanged.
    ///
    /// - Note: Wraps `mpq_mul_2exp` for positive exponents, `mpq_div_2exp` for
    /// negative.
    public func multipliedByPowerOf2(_ exponent: Int) -> GMPRational {
        let result = GMPRational() // Mutated through pointer below
        if exponent >= 0 {
            __gmpq_mul_2exp(
                &result._storage.value,
                &_storage.value,
                mp_bitcnt_t(exponent)
            )
        } else {
            // For negative exponents, divide by 2^|exponent|
            __gmpq_div_2exp(
                &result._storage.value,
                &_storage.value,
                mp_bitcnt_t(-exponent)
            )
        }
        return result
    }

    /// Divide this rational by 2 raised to the power of `exponent`, returning a
    /// new value.
    ///
    /// - Parameter exponent: The exponent for the power of 2. Must be
    /// non-negative.
    /// - Returns: A new `GMPRational` equal to `self / 2^exponent`.
    ///
    /// - Requires: This rational must be properly initialized. `exponent` must
    /// be non-negative.
    /// - Guarantees: Returns a new `GMPRational` with the result
    /// (canonicalized).
    ///   `self` is unchanged.
    ///
    /// - Throws: `GMPError.invalidExponent` if `exponent` is negative.
    ///
    /// - Note: Wraps `mpq_div_2exp`.
    public func dividedByPowerOf2(_ exponent: Int) throws -> GMPRational {
        guard exponent >= 0 else {
            throw GMPError.invalidExponent(exponent)
        }
        let result = GMPRational() // Mutated through pointer below
        __gmpq_div_2exp(
            &result._storage.value,
            &_storage.value,
            mp_bitcnt_t(exponent)
        )
        return result
    }

    /// Multiply this rational by 2 raised to the power of `exponent` in place.
    ///
    /// - Parameter exponent: The exponent for the power of 2. Can be negative.
    ///
    /// - Requires: This rational must be properly initialized.
    /// - Guarantees: After this call, `self` equals `self * 2^exponent` (before
    /// the call).
    ///
    /// - Note: Wraps `mpq_mul_2exp`.
    public mutating func multiplyByPowerOf2(_ exponent: Int) {
        // Use immutable multipliedByPowerOf2() to avoid exclusivity violations
        let result = multipliedByPowerOf2(exponent)
        self = result
    }

    /// Divide this rational by 2 raised to the power of `exponent` in place.
    ///
    /// - Parameter exponent: The exponent for the power of 2. Must be
    /// non-negative.
    ///
    /// - Requires: This rational must be properly initialized. `exponent` must
    /// be non-negative.
    /// - Guarantees: After this call, `self` equals `self / 2^exponent` (before
    /// the call).
    ///
    /// - Throws: `GMPError.invalidExponent` if `exponent` is negative.
    ///
    /// - Note: Wraps `mpq_div_2exp`.
    public mutating func divideByPowerOf2(_ exponent: Int) throws {
        // Use immutable dividedByPowerOf2() to avoid exclusivity violations
        let result = try dividedByPowerOf2(exponent)
        self = result
    }

    // MARK: - Operator Overloads

    /// Add two `GMPRational` values.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side rational.
    ///   - rhs: The right-hand side rational.
    /// - Returns: The sum of `lhs` and `rhs`.
    ///
    /// - Requires: Both rationals must be properly initialized.
    /// - Guarantees: Returns a new `GMPRational` with the sum (canonicalized).
    public static func + (lhs: GMPRational, rhs: GMPRational) -> GMPRational {
        lhs.adding(rhs)
    }

    /// Subtract two `GMPRational` values.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side rational.
    ///   - rhs: The right-hand side rational.
    /// - Returns: The difference of `lhs` and `rhs`.
    ///
    /// - Requires: Both rationals must be properly initialized.
    /// - Guarantees: Returns a new `GMPRational` with the difference
    /// (canonicalized).
    public static func - (lhs: GMPRational, rhs: GMPRational) -> GMPRational {
        lhs.subtracting(rhs)
    }

    /// Multiply two `GMPRational` values.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side rational.
    ///   - rhs: The right-hand side rational.
    /// - Returns: The product of `lhs` and `rhs`.
    ///
    /// - Requires: Both rationals must be properly initialized.
    /// - Guarantees: Returns a new `GMPRational` with the product
    /// (canonicalized).
    public static func * (lhs: GMPRational, rhs: GMPRational) -> GMPRational {
        lhs.multiplied(by: rhs)
    }

    /// Divide two `GMPRational` values.
    ///
    /// - Parameters:
    ///   - lhs: The dividend.
    ///   - rhs: The divisor. Must not be zero.
    /// - Returns: The quotient of `lhs` and `rhs`.
    ///
    /// - Requires: Both rationals must be properly initialized. `rhs` must not
    /// be zero.
    /// - Guarantees: Returns a new `GMPRational` with the quotient
    /// (canonicalized).
    /// - Throws: `GMPError.divisionByZero` if `rhs` is zero.
    public static func / (
        lhs: GMPRational,
        rhs: GMPRational
    ) throws -> GMPRational {
        try lhs.divided(by: rhs)
    }

    /// Negate a `GMPRational` value.
    ///
    /// - Parameter value: The rational to negate.
    /// - Returns: The negation of `value`.
    ///
    /// - Requires: `value` must be properly initialized.
    /// - Guarantees: Returns a new `GMPRational` with the negated value.
    public static prefix func - (value: GMPRational) -> GMPRational {
        value.negated()
    }

    /// Add a `GMPRational` to another in place.
    ///
    /// - Parameters:
    ///   - lhs: The rational to modify.
    ///   - rhs: The rational to add.
    ///
    /// - Requires: Both rationals must be properly initialized.
    /// - Guarantees: After this call, `lhs` equals `lhs + rhs` (before the
    /// call).
    public static func += (lhs: inout GMPRational, rhs: GMPRational) {
        lhs.add(rhs)
    }

    /// Subtract a `GMPRational` from another in place.
    ///
    /// - Parameters:
    ///   - lhs: The rational to modify.
    ///   - rhs: The rational to subtract.
    ///
    /// - Requires: Both rationals must be properly initialized.
    /// - Guarantees: After this call, `lhs` equals `lhs - rhs` (before the
    /// call).
    public static func -= (lhs: inout GMPRational, rhs: GMPRational) {
        lhs.subtract(rhs)
    }

    /// Multiply a `GMPRational` by another in place.
    ///
    /// - Parameters:
    ///   - lhs: The rational to modify.
    ///   - rhs: The rational to multiply by.
    ///
    /// - Requires: Both rationals must be properly initialized.
    /// - Guarantees: After this call, `lhs` equals `lhs * rhs` (before the
    /// call).
    public static func *= (lhs: inout GMPRational, rhs: GMPRational) {
        lhs.multiply(by: rhs)
    }

    /// Divide a `GMPRational` by another in place.
    ///
    /// - Parameters:
    ///   - lhs: The rational to modify.
    ///   - rhs: The divisor. Must not be zero.
    ///
    /// - Requires: Both rationals must be properly initialized. `rhs` must not
    /// be zero.
    /// - Guarantees: After this call, `lhs` equals `lhs / rhs` (before the
    /// call).
    /// - Throws: `GMPError.divisionByZero` if `rhs` is zero.
    public static func /= (lhs: inout GMPRational, rhs: GMPRational) throws {
        try lhs.divide(by: rhs)
    }
}
