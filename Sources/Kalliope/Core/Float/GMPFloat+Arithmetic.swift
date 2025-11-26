import CKalliope

/// Arithmetic operations for `GMPFloat`.
///
/// All arithmetic operations use the precision of the destination float.
/// Results are
/// rounded to the destination's precision.
extension GMPFloat {
    // MARK: - Immutable Operations

    /// Add another float to this float, returning a new value.
    ///
    /// The result uses the precision of `self`.
    ///
    /// - Parameter other: The float to add.
    /// - Returns: A new `GMPFloat` equal to `self + other`.
    ///
    /// - Note: Wraps `mpf_add`.
    public func adding(_ other: GMPFloat) -> GMPFloat {
        let result =
            try! GMPFloat(precision: precision) // Mutated through pointer below
        __gmpf_add(
            &result._storage.value,
            &_storage.value,
            &other._storage.value
        )
        return result
    }

    /// Subtract another float from this float, returning a new value.
    ///
    /// - Parameter other: The float to subtract.
    /// - Returns: A new `GMPFloat` equal to `self - other`.
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: Returns a new `GMPFloat` with the difference, rounded to
    /// `self`'s precision.
    ///   `self` is unchanged.
    ///
    /// - Note: Wraps `mpf_sub`.
    public func subtracting(_ other: GMPFloat) -> GMPFloat {
        let result =
            try! GMPFloat(precision: precision) // Mutated through pointer below
        __gmpf_sub(
            &result._storage.value,
            &_storage.value,
            &other._storage.value
        )
        return result
    }

    /// Multiply this float by another, returning a new value.
    ///
    /// - Parameter other: The float to multiply by.
    /// - Returns: A new `GMPFloat` equal to `self * other`.
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: Returns a new `GMPFloat` with the product, rounded to
    /// `self`'s precision.
    ///   `self` is unchanged.
    ///
    /// - Note: Wraps `mpf_mul`.
    public func multiplied(by other: GMPFloat) -> GMPFloat {
        let result =
            try! GMPFloat(precision: precision) // Mutated through pointer below
        __gmpf_mul(
            &result._storage.value,
            &_storage.value,
            &other._storage.value
        )
        return result
    }

    /// Divide this float by another, returning a new value.
    ///
    /// - Parameter other: The float to divide by. Must not be zero.
    /// - Returns: A new `GMPFloat` equal to `self / other`.
    ///
    /// - Requires: Both floats must be properly initialized. `other` must not
    /// be zero.
    /// - Guarantees: Returns a new `GMPFloat` with the quotient, rounded to
    /// `self`'s precision.
    ///   `self` is unchanged.
    ///
    /// - Throws: May throw `GMPError.divisionByZero` if `other` is zero.
    ///
    /// - Note: Wraps `mpf_div`.
    public func divided(by other: GMPFloat) throws -> GMPFloat {
        guard !other.isZero else {
            throw GMPError.divisionByZero
        }
        let result =
            try! GMPFloat(precision: precision) // Mutated through pointer below
        __gmpf_div(
            &result._storage.value,
            &_storage.value,
            &other._storage.value
        )
        return result
    }

    /// Return the negation of this float.
    ///
    /// - Returns: A new `GMPFloat` equal to `-self`.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns a new `GMPFloat` with the negated value. `self` is
    /// unchanged.
    ///
    /// - Note: Wraps `mpf_neg`.
    public func negated() -> GMPFloat {
        let result =
            try! GMPFloat(precision: precision) // Mutated through pointer below
        __gmpf_neg(&result._storage.value, &_storage.value)
        return result
    }

    /// Return the absolute value of this float.
    ///
    /// - Returns: A new `GMPFloat` equal to `|self|`.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns a new `GMPFloat` with the absolute value. `self`
    /// is unchanged.
    ///
    /// - Note: Wraps `mpf_abs`.
    public func absoluteValue() -> GMPFloat {
        let result =
            try! GMPFloat(precision: precision) // Mutated through pointer below
        __gmpf_abs(&result._storage.value, &_storage.value)
        return result
    }

    // MARK: - Mutable Operations

    /// Add another float to this float in place.
    ///
    /// - Parameter other: The float to add.
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: After this call, `self` equals `self + other` (before the
    /// call),
    ///   rounded to `self`'s precision.
    ///
    /// - Note: Wraps `mpf_add`.
    public mutating func add(_ other: GMPFloat) {
        // Use immutable adding() to avoid exclusivity violations when self ===
        // other
        let result = adding(other)
        self = result
    }

    /// Subtract another float from this float in place.
    ///
    /// - Parameter other: The float to subtract.
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: After this call, `self` equals `self - other` (before the
    /// call),
    ///   rounded to `self`'s precision.
    ///
    /// - Note: Wraps `mpf_sub`.
    public mutating func subtract(_ other: GMPFloat) {
        // Use immutable subtracting() to avoid exclusivity violations when self
        // === other
        let result = subtracting(other)
        self = result
    }

    /// Multiply this float by another in place.
    ///
    /// - Parameter other: The float to multiply by.
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: After this call, `self` equals `self * other` (before the
    /// call),
    ///   rounded to `self`'s precision.
    ///
    /// - Note: Wraps `mpf_mul`.
    public mutating func multiply(by other: GMPFloat) {
        // Use immutable multiplied(by:) to avoid exclusivity violations when
        // self === other
        let result = multiplied(by: other)
        self = result
    }

    /// Divide this float by another in place.
    ///
    /// - Parameter other: The float to divide by. Must not be zero.
    ///
    /// - Requires: Both floats must be properly initialized. `other` must not
    /// be zero.
    /// - Guarantees: After this call, `self` equals `self / other` (before the
    /// call),
    ///   rounded to `self`'s precision.
    ///
    /// - Throws: May throw `GMPError.divisionByZero` if `other` is zero.
    ///
    /// - Note: Wraps `mpf_div`.
    public mutating func divide(by other: GMPFloat) throws {
        // Use immutable divided(by:) to avoid exclusivity violations when self
        // === other
        let result = try divided(by: other)
        self = result
    }

    /// Add an `Int` to this float in place.
    ///
    /// - Parameter other: The integer to add.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: After this call, `self` equals `self + other` (before the
    /// call).
    ///
    /// - Note: Wraps `mpf_add_ui` or `mpf_add_si` depending on the sign of
    /// `other`.
    public mutating func add(_ other: Int) {
        _ensureUnique()
        // Use withUnsafeMutablePointer to avoid Swift exclusivity violation
        // when passing the same storage for both input and output parameters
        withUnsafeMutablePointer(to: &_storage.value) { rop in
            let op = UnsafePointer(rop)
            if other >= 0 {
                __gmpf_add_ui(rop, op, CUnsignedLong(other))
            } else {
                // Handle Int.min specially to avoid arithmetic overflow
                let absOther: CUnsignedLong = other == Int.min
                    ? CUnsignedLong(Int.max) + 1 : CUnsignedLong(-other)
                __gmpf_sub_ui(rop, op, absOther)
            }
        }
    }

    /// Subtract an `Int` from this float in place.
    ///
    /// - Parameter other: The integer to subtract.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: After this call, `self` equals `self - other` (before the
    /// call).
    ///
    /// - Note: Wraps `mpf_sub_ui` or `mpf_sub_si` depending on the sign of
    /// `other`.
    public mutating func subtract(_ other: Int) {
        _ensureUnique()
        // Use withUnsafeMutablePointer to avoid Swift exclusivity violation
        // when passing the same storage for both input and output parameters
        withUnsafeMutablePointer(to: &_storage.value) { rop in
            let op = UnsafePointer(rop)
            if other >= 0 {
                __gmpf_sub_ui(rop, op, CUnsignedLong(other))
            } else {
                // Handle Int.min specially to avoid arithmetic overflow
                let absOther: CUnsignedLong = other == Int.min
                    ? CUnsignedLong(Int.max) + 1 : CUnsignedLong(-other)
                __gmpf_add_ui(rop, op, absOther)
            }
        }
    }

    /// Multiply this float by an `Int` in place.
    ///
    /// - Parameter other: The integer to multiply by.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: After this call, `self` equals `self * other` (before the
    /// call).
    ///
    /// - Note: Wraps `mpf_mul_ui` for positive values. For negative values,
    /// multiplies by
    ///   absolute value and negates the result.
    public mutating func multiply(by other: Int) {
        _ensureUnique()
        // Use withUnsafeMutablePointer to avoid Swift exclusivity violation
        // when passing the same storage for both input and output parameters
        withUnsafeMutablePointer(to: &_storage.value) { rop in
            let op = UnsafePointer(rop)
            if other >= 0 {
                __gmpf_mul_ui(rop, op, CUnsignedLong(other))
            } else {
                // For negative multiplier, use absolute value and adjust sign
                // Handle Int.min specially to avoid arithmetic overflow
                let absOther: CUnsignedLong = other == Int.min
                    ? CUnsignedLong(Int.max) + 1 : CUnsignedLong(-other)
                __gmpf_mul_ui(rop, op, absOther)
                __gmpf_neg(rop, rop)
            }
        }
    }

    /// Divide this float by an `Int` in place.
    ///
    /// - Parameter other: The integer to divide by. Must not be zero.
    ///
    /// - Requires: This float must be properly initialized. `other` must not be
    /// zero.
    /// - Guarantees: After this call, `self` equals `self / other` (before the
    /// call).
    ///
    /// - Throws: May throw `GMPError.divisionByZero` if `other` is zero.
    ///
    /// - Note: Wraps `mpf_div_ui` for positive values. For negative values,
    /// divides by
    ///   absolute value and negates the result.
    public mutating func divide(by other: Int) throws {
        guard other != 0 else {
            throw GMPError.divisionByZero
        }
        _ensureUnique()
        // Use withUnsafeMutablePointer to avoid Swift exclusivity violation
        // when passing the same storage for both input and output parameters
        withUnsafeMutablePointer(to: &_storage.value) { rop in
            let op = UnsafePointer(rop)
            if other > 0 {
                __gmpf_div_ui(rop, op, CUnsignedLong(other))
            } else {
                // For negative divisor, use absolute value and adjust sign
                // Handle Int.min specially to avoid arithmetic overflow
                let absOther: CUnsignedLong = other == Int.min
                    ? CUnsignedLong(Int.max) + 1 : CUnsignedLong(-other)
                __gmpf_div_ui(rop, op, absOther)
                __gmpf_neg(rop, rop)
            }
        }
    }

    /// Negate this float in place.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: After this call, `self` equals `-self` (before the call).
    ///
    /// - Note: Wraps `mpf_neg`.
    public mutating func negate() {
        // Use immutable negated() to avoid exclusivity violations
        let result = negated()
        self = result
    }

    /// Replace this float with its absolute value in place.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: After this call, `self` equals `|self|` (before the call).
    ///
    /// - Note: Wraps `mpf_abs`.
    public mutating func makeAbsolute() {
        _ensureUnique()
        // Use withUnsafeMutablePointer to avoid Swift exclusivity violation
        // when passing the same storage for both input and output parameters
        withUnsafeMutablePointer(to: &_storage.value) { rop in
            let op = UnsafePointer(rop)
            __gmpf_abs(rop, op)
        }
    }

    // MARK: - Reverse Operations

    /// Subtract a float from an integer, returning a new value.
    ///
    /// Computes `value - other`.
    ///
    /// - Parameters:
    ///   - value: The integer to subtract from.
    ///   - other: The float to subtract.
    /// - Returns: A new `GMPFloat` equal to `value - other`.
    ///
    /// - Requires: `other` must be properly initialized.
    /// - Guarantees: Returns a new `GMPFloat` with the difference.
    ///
    /// - Note: Wraps `mpf_ui_sub` for non-negative values. For negative values,
    ///   computes as `-(|value| + other)`.
    public static func subtracting(
        _ value: Int,
        _ other: GMPFloat
    ) -> GMPFloat {
        let result = try! GMPFloat(precision: other
            .precision) // Mutated through pointer below
        if value >= 0 {
            __gmpf_ui_sub(
                &result._storage.value,
                CUnsignedLong(value),
                &other._storage.value
            )
        } else {
            // For negative value, compute as: value - other = -(|value| +
            // other)
            // First compute |value| + other, then negate
            // Handle Int.min specially to avoid arithmetic overflow
            let temp = try! GMPFloat(precision: other
                .precision) // Mutated through pointer below
            let absValue: CUnsignedLong = value == Int.min
                ? CUnsignedLong(Int.max) + 1 : CUnsignedLong(-value)
            __gmpf_add_ui(&temp._storage.value, &other._storage.value, absValue)
            __gmpf_neg(&result._storage.value, &temp._storage.value)
        }
        return result
    }

    /// Divide an integer by a float, returning a new value.
    ///
    /// Computes `value / other`.
    ///
    /// - Parameters:
    ///   - value: The integer to divide.
    ///   - other: The float to divide by. Must not be zero.
    /// - Returns: A new `GMPFloat` equal to `value / other`.
    ///
    /// - Requires: `other` must be properly initialized. `other` must not be
    /// zero.
    /// - Guarantees: Returns a new `GMPFloat` with the quotient.
    ///
    /// - Throws: May throw `GMPError.divisionByZero` if `other` is zero.
    ///
    /// - Note: Wraps `mpf_ui_div` for non-negative values. For negative values,
    ///   computes as `-|value| / other`.
    public static func dividing(
        _ value: Int,
        _ other: GMPFloat
    ) throws -> GMPFloat {
        guard !other.isZero else {
            throw GMPError.divisionByZero
        }
        let result = try! GMPFloat(precision: other
            .precision) // Mutated through pointer below
        if value >= 0 {
            __gmpf_ui_div(
                &result._storage.value,
                CUnsignedLong(value),
                &other._storage.value
            )
        } else {
            // For negative value, compute as: value / other = -(|value| /
            // other)
            // First compute |value| / other, then negate
            // Handle Int.min specially to avoid arithmetic overflow
            let temp = try! GMPFloat(precision: other
                .precision) // Mutated through pointer below
            let absValue: CUnsignedLong = value == Int.min
                ? CUnsignedLong(Int.max) + 1 : CUnsignedLong(-value)
            __gmpf_ui_div(&temp._storage.value, absValue, &other._storage.value)
            __gmpf_neg(&result._storage.value, &temp._storage.value)
        }
        return result
    }

    /// Set this float to `value - other` in place.
    ///
    /// - Parameters:
    ///   - value: The integer to subtract from.
    ///   - other: The float to subtract.
    ///
    /// - Requires: This float and `other` must be properly initialized.
    /// - Guarantees: After this call, `self` equals `value - other`.
    ///
    /// - Note: Wraps `mpf_ui_sub` for non-negative values. For negative values,
    ///   computes as `-(|value| + other)`.
    public mutating func formSubtracting(_ value: Int, _ other: GMPFloat) {
        _ensureUnique()
        // Use withUnsafeMutablePointer to avoid Swift exclusivity violation
        withUnsafeMutablePointer(to: &_storage.value) { rop in
            if value >= 0 {
                __gmpf_ui_sub(rop, CUnsignedLong(value), &other._storage.value)
            } else {
                // For negative value, compute as: value - other = -(|value| +
                // other)
                // First compute |value| + other, then negate
                // Handle Int.min specially to avoid arithmetic overflow
                let temp = try! GMPFloat(precision: other
                    .precision) // Mutated through pointer below
                let absValue: CUnsignedLong = value == Int.min
                    ? CUnsignedLong(Int.max) + 1 : CUnsignedLong(-value)
                __gmpf_add_ui(
                    &temp._storage.value,
                    &other._storage.value,
                    absValue
                )
                __gmpf_neg(rop, &temp._storage.value)
            }
        }
    }

    /// Set this float to `value / other` in place.
    ///
    /// - Parameters:
    ///   - value: The integer to divide.
    ///   - other: The float to divide by. Must not be zero.
    ///
    /// - Requires: This float and `other` must be properly initialized. `other`
    /// must not be zero.
    /// - Guarantees: After this call, `self` equals `value / other`.
    ///
    /// - Throws: May throw `GMPError.divisionByZero` if `other` is zero.
    ///
    /// - Note: Wraps `mpf_ui_div` for non-negative values. For negative values,
    ///   computes as `-|value| / other`.
    public mutating func formDividing(_ value: Int, _ other: GMPFloat) throws {
        guard !other.isZero else {
            throw GMPError.divisionByZero
        }
        _ensureUnique()
        // Use withUnsafeMutablePointer to avoid Swift exclusivity violation
        withUnsafeMutablePointer(to: &_storage.value) { rop in
            if value >= 0 {
                __gmpf_ui_div(rop, CUnsignedLong(value), &other._storage.value)
            } else {
                // For negative value, compute as: value / other = -(|value| /
                // other)
                // First compute |value| / other, then negate
                // Handle Int.min specially to avoid arithmetic overflow
                let temp = try! GMPFloat(precision: other
                    .precision) // Mutated through pointer below
                let absValue: CUnsignedLong = value == Int.min
                    ? CUnsignedLong(Int.max) + 1 : CUnsignedLong(-value)
                __gmpf_ui_div(
                    &temp._storage.value,
                    absValue,
                    &other._storage.value
                )
                __gmpf_neg(rop, &temp._storage.value)
            }
        }
    }

    // MARK: - Power of 2 Operations

    /// Multiply this float by 2 raised to the power of `exponent`, returning a
    /// new value.
    ///
    /// - Parameter exponent: The exponent for the power of 2. Can be negative
    /// for division.
    /// - Returns: A new `GMPFloat` equal to `self * 2^exponent`.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns a new `GMPFloat` with the result. `self` is
    /// unchanged.
    ///
    /// - Note: Wraps `mpf_mul_2exp` for non-negative exponents. For negative
    /// exponents,
    ///   uses `mpf_div_2exp` with the absolute value.
    public func multipliedByPowerOf2(_ exponent: Int) -> GMPFloat {
        let result =
            try! GMPFloat(precision: precision) // Mutated through pointer below
        if exponent >= 0 {
            __gmpf_mul_2exp(
                &result._storage.value,
                &_storage.value,
                mp_bitcnt_t(exponent)
            )
        } else {
            // For negative exponent, divide by 2^|exponent|
            __gmpf_div_2exp(
                &result._storage.value,
                &_storage.value,
                mp_bitcnt_t(-exponent)
            )
        }
        return result
    }

    /// Divide this float by 2 raised to the power of `exponent`, returning a
    /// new value.
    ///
    /// - Parameter exponent: The exponent for the power of 2. Must be
    /// non-negative.
    /// - Returns: A new `GMPFloat` equal to `self / 2^exponent`.
    ///
    /// - Requires: This float must be properly initialized. `exponent` must be
    /// non-negative.
    /// - Guarantees: Returns a new `GMPFloat` with the result. `self` is
    /// unchanged.
    ///
    /// - Throws: May throw `GMPError.invalidExponent` if `exponent` is
    /// negative.
    ///
    /// - Note: Wraps `mpf_div_2exp`.
    public func dividedByPowerOf2(_ exponent: Int) throws -> GMPFloat {
        guard exponent >= 0 else {
            throw GMPError.invalidExponent(exponent)
        }
        let result =
            try! GMPFloat(precision: precision) // Mutated through pointer below
        __gmpf_div_2exp(
            &result._storage.value,
            &_storage.value,
            mp_bitcnt_t(exponent)
        )
        return result
    }

    /// Multiply this float by 2 raised to the power of `exponent` in place.
    ///
    /// - Parameter exponent: The exponent for the power of 2. Can be negative
    /// for division.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: After this call, `self` equals `self * 2^exponent` (before
    /// the call).
    ///
    /// - Note: Wraps `mpf_mul_2exp` for non-negative exponents. For negative
    /// exponents,
    ///   uses `mpf_div_2exp` with the absolute value.
    public mutating func multiplyByPowerOf2(_ exponent: Int) {
        _ensureUnique()
        // Use withUnsafeMutablePointer to avoid Swift exclusivity violation
        // when passing the same storage for both input and output parameters
        withUnsafeMutablePointer(to: &_storage.value) { rop in
            let op = UnsafePointer(rop)
            if exponent >= 0 {
                __gmpf_mul_2exp(rop, op, mp_bitcnt_t(exponent))
            } else {
                // For negative exponent, divide by 2^|exponent|
                __gmpf_div_2exp(rop, op, mp_bitcnt_t(-exponent))
            }
        }
    }

    /// Divide this float by 2 raised to the power of `exponent` in place.
    ///
    /// - Parameter exponent: The exponent for the power of 2. Must be
    /// non-negative.
    ///
    /// - Requires: This float must be properly initialized. `exponent` must be
    /// non-negative.
    /// - Guarantees: After this call, `self` equals `self / 2^exponent` (before
    /// the call).
    ///
    /// - Throws: May throw `GMPError.invalidExponent` if `exponent` is
    /// negative.
    ///
    /// - Note: Wraps `mpf_div_2exp`.
    public mutating func divideByPowerOf2(_ exponent: Int) throws {
        guard exponent >= 0 else {
            throw GMPError.invalidExponent(exponent)
        }
        _ensureUnique()
        // Use withUnsafeMutablePointer to avoid Swift exclusivity violation
        // when passing the same storage for both input and output parameters
        withUnsafeMutablePointer(to: &_storage.value) { rop in
            let op = UnsafePointer(rop)
            __gmpf_div_2exp(rop, op, mp_bitcnt_t(exponent))
        }
    }

    // MARK: - Operator Overloads

    /// Add two `GMPFloat` values.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side float.
    ///   - rhs: The right-hand side float.
    /// - Returns: The sum of `lhs` and `rhs`, rounded to `lhs`'s precision.
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: Returns a new `GMPFloat` with the sum.
    ///
    /// - Note: Wraps `mpf_add`.
    public static func + (lhs: GMPFloat, rhs: GMPFloat) -> GMPFloat {
        lhs.adding(rhs)
    }

    /// Add a `GMPFloat` and an `Int`.
    ///
    /// - Parameters:
    ///   - lhs: The `GMPFloat` value.
    ///   - rhs: The `Int` value.
    /// - Returns: The sum of `lhs` and `rhs`.
    ///
    /// - Requires: `lhs` must be properly initialized.
    /// - Guarantees: Returns a new `GMPFloat` with the sum.
    ///
    /// - Note: Wraps `mpf_add_ui` or `mpf_add_si` depending on the sign of
    /// `rhs`.
    public static func + (lhs: GMPFloat, rhs: Int) -> GMPFloat {
        var result = lhs
        result.add(rhs)
        return result
    }

    /// Subtract two `GMPFloat` values.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side float.
    ///   - rhs: The right-hand side float.
    /// - Returns: The difference of `lhs` and `rhs`, rounded to `lhs`'s
    /// precision.
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: Returns a new `GMPFloat` with the difference.
    ///
    /// - Note: Wraps `mpf_sub`.
    public static func - (lhs: GMPFloat, rhs: GMPFloat) -> GMPFloat {
        lhs.subtracting(rhs)
    }

    /// Subtract an `Int` from a `GMPFloat`.
    ///
    /// - Parameters:
    ///   - lhs: The `GMPFloat` value.
    ///   - rhs: The `Int` value.
    /// - Returns: The difference of `lhs` and `rhs`.
    ///
    /// - Requires: `lhs` must be properly initialized.
    /// - Guarantees: Returns a new `GMPFloat` with the difference.
    ///
    /// - Note: Wraps `mpf_sub_ui` or `mpf_sub_si` depending on the sign of
    /// `rhs`.
    public static func - (lhs: GMPFloat, rhs: Int) -> GMPFloat {
        var result = lhs
        result.subtract(rhs)
        return result
    }

    /// Multiply two `GMPFloat` values.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side float.
    ///   - rhs: The right-hand side float.
    /// - Returns: The product of `lhs` and `rhs`, rounded to `lhs`'s precision.
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: Returns a new `GMPFloat` with the product.
    ///
    /// - Note: Wraps `mpf_mul`.
    public static func * (lhs: GMPFloat, rhs: GMPFloat) -> GMPFloat {
        lhs.multiplied(by: rhs)
    }

    /// Multiply a `GMPFloat` and an `Int`.
    ///
    /// - Parameters:
    ///   - lhs: The `GMPFloat` value.
    ///   - rhs: The `Int` value.
    /// - Returns: The product of `lhs` and `rhs`.
    ///
    /// - Requires: `lhs` must be properly initialized.
    /// - Guarantees: Returns a new `GMPFloat` with the product.
    ///
    /// - Note: Wraps `mpf_mul_ui` or `mpf_mul_si` depending on the sign of
    /// `rhs`.
    public static func * (lhs: GMPFloat, rhs: Int) -> GMPFloat {
        var result = lhs
        result.multiply(by: rhs)
        return result
    }

    /// Divide two `GMPFloat` values.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side float.
    ///   - rhs: The right-hand side float. Must not be zero.
    /// - Returns: The quotient of `lhs` and `rhs`, rounded to `lhs`'s
    /// precision.
    ///
    /// - Requires: Both floats must be properly initialized. `rhs` must not be
    /// zero.
    /// - Guarantees: Returns a new `GMPFloat` with the quotient.
    ///
    /// - Throws: May throw `GMPError.divisionByZero` if `rhs` is zero.
    ///
    /// - Note: Wraps `mpf_div`.
    public static func / (lhs: GMPFloat, rhs: GMPFloat) throws -> GMPFloat {
        try lhs.divided(by: rhs)
    }

    /// Divide a `GMPFloat` by an `Int`.
    ///
    /// - Parameters:
    ///   - lhs: The `GMPFloat` value.
    ///   - rhs: The `Int` value. Must not be zero.
    /// - Returns: The quotient of `lhs` and `rhs`.
    ///
    /// - Requires: `lhs` must be properly initialized. `rhs` must not be zero.
    /// - Guarantees: Returns a new `GMPFloat` with the quotient.
    ///
    /// - Throws: May throw `GMPError.divisionByZero` if `rhs` is zero.
    ///
    /// - Note: Wraps `mpf_div_ui` or `mpf_div_si` depending on the sign of
    /// `rhs`.
    public static func / (lhs: GMPFloat, rhs: Int) throws -> GMPFloat {
        var result = lhs
        try result.divide(by: rhs)
        return result
    }

    /// Negate a `GMPFloat` value.
    ///
    /// - Parameter value: The float to negate.
    /// - Returns: The negation of `value`.
    ///
    /// - Requires: `value` must be properly initialized.
    /// - Guarantees: Returns a new `GMPFloat` with the negated value.
    public static prefix func - (value: GMPFloat) -> GMPFloat {
        value.negated()
    }

    /// Add a `GMPFloat` to another in place.
    ///
    /// - Parameters:
    ///   - lhs: The float to modify.
    ///   - rhs: The float to add.
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: After this call, `lhs` equals `lhs + rhs` (before the
    /// call).
    public static func += (lhs: inout GMPFloat, rhs: GMPFloat) {
        lhs.add(rhs)
    }

    /// Add an `Int` to a `GMPFloat` in place.
    ///
    /// - Parameters:
    ///   - lhs: The float to modify.
    ///   - rhs: The `Int` to add.
    ///
    /// - Requires: `lhs` must be properly initialized.
    /// - Guarantees: After this call, `lhs` equals `lhs + rhs` (before the
    /// call).
    public static func += (lhs: inout GMPFloat, rhs: Int) {
        lhs.add(rhs)
    }

    /// Subtract a `GMPFloat` from another in place.
    ///
    /// - Parameters:
    ///   - lhs: The float to modify.
    ///   - rhs: The float to subtract.
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: After this call, `lhs` equals `lhs - rhs` (before the
    /// call).
    public static func -= (lhs: inout GMPFloat, rhs: GMPFloat) {
        lhs.subtract(rhs)
    }

    /// Subtract an `Int` from a `GMPFloat` in place.
    ///
    /// - Parameters:
    ///   - lhs: The float to modify.
    ///   - rhs: The `Int` to subtract.
    ///
    /// - Requires: `lhs` must be properly initialized.
    /// - Guarantees: After this call, `lhs` equals `lhs - rhs` (before the
    /// call).
    public static func -= (lhs: inout GMPFloat, rhs: Int) {
        lhs.subtract(rhs)
    }

    /// Multiply a `GMPFloat` by another in place.
    ///
    /// - Parameters:
    ///   - lhs: The float to modify.
    ///   - rhs: The float to multiply by.
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: After this call, `lhs` equals `lhs * rhs` (before the
    /// call).
    public static func *= (lhs: inout GMPFloat, rhs: GMPFloat) {
        lhs.multiply(by: rhs)
    }

    /// Multiply a `GMPFloat` by an `Int` in place.
    ///
    /// - Parameters:
    ///   - lhs: The float to modify.
    ///   - rhs: The `Int` to multiply by.
    ///
    /// - Requires: `lhs` must be properly initialized.
    /// - Guarantees: After this call, `lhs` equals `lhs * rhs` (before the
    /// call).
    public static func *= (lhs: inout GMPFloat, rhs: Int) {
        lhs.multiply(by: rhs)
    }

    /// Divide a `GMPFloat` by another in place.
    ///
    /// - Parameters:
    ///   - lhs: The float to modify.
    ///   - rhs: The float to divide by. Must not be zero.
    ///
    /// - Requires: Both floats must be properly initialized. `rhs` must not be
    /// zero.
    /// - Guarantees: After this call, `lhs` equals `lhs / rhs` (before the
    /// call).
    ///
    /// - Throws: May throw `GMPError.divisionByZero` if `rhs` is zero.
    public static func /= (lhs: inout GMPFloat, rhs: GMPFloat) throws {
        try lhs.divide(by: rhs)
    }

    /// Divide a `GMPFloat` by an `Int` in place.
    ///
    /// - Parameters:
    ///   - lhs: The float to modify.
    ///   - rhs: The `Int` to divide by. Must not be zero.
    ///
    /// - Requires: `lhs` must be properly initialized. `rhs` must not be zero.
    /// - Guarantees: After this call, `lhs` equals `lhs / rhs` (before the
    /// call).
    ///
    /// - Throws: May throw `GMPError.divisionByZero` if `rhs` is zero.
    public static func /= (lhs: inout GMPFloat, rhs: Int) throws {
        try lhs.divide(by: rhs)
    }
}
