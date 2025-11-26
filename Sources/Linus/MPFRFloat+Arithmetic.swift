// Import CKalliope first so gmp.h is available when CLinus imports mpfr.h
import CKalliope
import CLinus
import CLinusBridge
import Kalliope

// MARK: - Arithmetic Operations

/// Arithmetic operations for `MPFRFloat`.
///
/// All arithmetic operations use the precision of the destination float.
/// Results are
/// rounded according to the specified rounding mode. All operations return a
/// ternary
/// value indicating the rounding direction: 0 if exact, positive if rounded up,
/// negative if rounded down.
extension MPFRFloat {
    // MARK: - Immutable Operations

    /// Add another float to this float, returning a new value.
    ///
    /// The result uses the precision of `self`.
    ///
    /// - Parameters:
    ///   - other: The float to add.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` equal to `self + other`, and a ternary
    /// value
    ///   indicating the rounding direction.
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: Returns a new `MPFRFloat` with the sum, rounded to
    /// `self`'s precision
    ///   using the specified rounding mode. `self` is unchanged.
    ///
    /// - Note: Wraps `mpfr_add`.
    public func adding(
        _ other: MPFRFloat,
        rounding: MPFRRoundingMode = .nearest
    ) -> (result: MPFRFloat, ternary: Int) {
        let result =
            MPFRFloat(precision: precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        let ternary = mpfr_add(
            &result._storage.value,
            &_storage.value,
            &other._storage.value,
            rnd
        )
        return (result: result, ternary: Int(ternary))
    }

    /// Subtract another float from this float, returning a new value.
    ///
    /// - Parameters:
    ///   - other: The float to subtract.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` equal to `self - other`, and a ternary
    /// value.
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: Returns a new `MPFRFloat` with the difference, rounded to
    /// `self`'s precision.
    ///   `self` is unchanged.
    ///
    /// - Note: Wraps `mpfr_sub`.
    public func subtracting(
        _ other: MPFRFloat,
        rounding: MPFRRoundingMode = .nearest
    ) -> (result: MPFRFloat, ternary: Int) {
        let result =
            MPFRFloat(precision: precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        let ternary = mpfr_sub(
            &result._storage.value,
            &_storage.value,
            &other._storage.value,
            rnd
        )
        return (result: result, ternary: Int(ternary))
    }

    /// Multiply this float by another, returning a new value.
    ///
    /// - Parameters:
    ///   - other: The float to multiply by.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` equal to `self * other`, and a ternary
    /// value.
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: Returns a new `MPFRFloat` with the product, rounded to
    /// `self`'s precision.
    ///   `self` is unchanged.
    ///
    /// - Note: Wraps `mpfr_mul`.
    public func multiplied(
        by other: MPFRFloat,
        rounding: MPFRRoundingMode = .nearest
    ) -> (result: MPFRFloat, ternary: Int) {
        let result =
            MPFRFloat(precision: precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        let ternary = mpfr_mul(
            &result._storage.value,
            &_storage.value,
            &other._storage.value,
            rnd
        )
        return (result: result, ternary: Int(ternary))
    }

    /// Divide this float by another, returning a new value.
    ///
    /// - Parameters:
    ///   - other: The float to divide by.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` equal to `self / other`, and a ternary
    /// value.
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: Returns a new `MPFRFloat` with the quotient, rounded to
    /// `self`'s precision.
    ///   `self` is unchanged. If `other` is zero, the result is NaN.
    ///
    /// - Note: Wraps `mpfr_div`.
    public func divided(
        by other: MPFRFloat,
        rounding: MPFRRoundingMode = .nearest
    ) -> (result: MPFRFloat, ternary: Int) {
        let result =
            MPFRFloat(precision: precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        let ternary = mpfr_div(
            &result._storage.value,
            &_storage.value,
            &other._storage.value,
            rnd
        )
        return (result: result, ternary: Int(ternary))
    }

    /// Negate this float, returning a new value.
    ///
    /// - Parameters:
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` equal to `-self`, and a ternary value
    /// (always 0, as negation is exact).
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns a new `MPFRFloat` with the negated value. `self`
    /// is unchanged.
    ///
    /// - Note: Wraps `mpfr_neg`.
    public func negated(
        rounding: MPFRRoundingMode = .nearest
    ) -> (result: MPFRFloat, ternary: Int) {
        let result =
            MPFRFloat(precision: precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        let ternary = mpfr_neg(
            &result._storage.value,
            &_storage.value,
            rnd
        )
        return (result: result, ternary: Int(ternary))
    }

    /// Get the absolute value of this float, returning a new value.
    ///
    /// - Parameters:
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` equal to `|self|`, and a ternary value
    /// (always 0, as absolute value is exact).
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns a new `MPFRFloat` with the absolute value. `self`
    /// is unchanged.
    ///
    /// - Note: Wraps `mpfr_abs`.
    public func absoluteValue(
        rounding: MPFRRoundingMode = .nearest
    ) -> (result: MPFRFloat, ternary: Int) {
        let result =
            MPFRFloat(precision: precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        let ternary = mpfr_abs(
            &result._storage.value,
            &_storage.value,
            rnd
        )
        return (result: result, ternary: Int(ternary))
    }

    // MARK: - Mutable Operations

    /// Add another float to this float in place.
    ///
    /// - Parameters:
    ///   - other: The float to add.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A ternary value indicating the rounding direction.
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: After this call, `self` equals `self + other` (before the
    /// call).
    ///
    /// - Note: Uses immutable `adding()` + assign pattern to avoid exclusivity
    /// violations.
    @discardableResult
    public mutating func add(
        _ other: MPFRFloat,
        rounding: MPFRRoundingMode = .nearest
    ) -> Int {
        let (result, ternary) = adding(other, rounding: rounding)
        self = result
        return ternary
    }

    /// Add an integer to this float in place.
    ///
    /// - Parameters:
    ///   - value: The integer to add.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A ternary value indicating the rounding direction.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: After this call, `self` equals `self + value` (before the
    /// call).
    ///
    /// - Note: Wraps `mpfr_add_si` (negative) or `mpfr_add_ui` (non-negative).
    @discardableResult
    public mutating func add(
        _ value: Int,
        rounding: MPFRRoundingMode = .nearest
    ) -> Int {
        _ensureUnique()
        let rnd = rounding.toMPFRRoundingMode()
        // Use withUnsafeMutablePointer to avoid Swift exclusivity violation
        // when passing the same storage for both input and output parameters
        let ternary: Int32 = withUnsafeMutablePointer(to: &_storage
            .value)
        { rop in
            let op = UnsafePointer(rop)
            if value >= 0 {
                return mpfr_add_ui(rop, op, CUnsignedLong(value), rnd)
            } else {
                // Handle Int.min specially to avoid arithmetic overflow
                let absValue: CUnsignedLong = value == Int.min
                    ? CUnsignedLong(Int.max) + 1 : CUnsignedLong(-value)
                return mpfr_sub_ui(rop, op, absValue, rnd)
            }
        }
        return Int(ternary)
    }

    /// Subtract another float from this float in place.
    ///
    /// - Parameters:
    ///   - other: The float to subtract.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A ternary value indicating the rounding direction.
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: After this call, `self` equals `self - other` (before the
    /// call).
    ///
    /// - Note: Uses immutable `subtracting()` + assign pattern to avoid
    /// exclusivity violations.
    @discardableResult
    public mutating func subtract(
        _ other: MPFRFloat,
        rounding: MPFRRoundingMode = .nearest
    ) -> Int {
        let (result, ternary) = subtracting(other, rounding: rounding)
        self = result
        return ternary
    }

    /// Subtract an integer from this float in place.
    ///
    /// - Parameters:
    ///   - value: The integer to subtract.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A ternary value indicating the rounding direction.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: After this call, `self` equals `self - value` (before the
    /// call).
    ///
    /// - Note: Wraps `mpfr_sub_si` (negative) or `mpfr_sub_ui` (non-negative).
    @discardableResult
    public mutating func subtract(
        _ value: Int,
        rounding: MPFRRoundingMode = .nearest
    ) -> Int {
        _ensureUnique()
        let rnd = rounding.toMPFRRoundingMode()
        // Use withUnsafeMutablePointer to avoid Swift exclusivity violation
        // when passing the same storage for both input and output parameters
        let ternary: Int32 = withUnsafeMutablePointer(to: &_storage
            .value)
        { rop in
            let op = UnsafePointer(rop)
            if value >= 0 {
                return mpfr_sub_ui(rop, op, CUnsignedLong(value), rnd)
            } else {
                // Handle Int.min specially to avoid arithmetic overflow
                let absValue: CUnsignedLong = value == Int.min
                    ? CUnsignedLong(Int.max) + 1 : CUnsignedLong(-value)
                return mpfr_add_ui(rop, op, absValue, rnd)
            }
        }
        return Int(ternary)
    }

    /// Multiply this float by another in place.
    ///
    /// - Parameters:
    ///   - other: The float to multiply by.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A ternary value indicating the rounding direction.
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: After this call, `self` equals `self * other` (before the
    /// call).
    ///
    /// - Note: Uses immutable `multiplied(by:)` + assign pattern to avoid
    /// exclusivity violations.
    @discardableResult
    public mutating func multiply(
        by other: MPFRFloat,
        rounding: MPFRRoundingMode = .nearest
    ) -> Int {
        let (result, ternary) = multiplied(by: other, rounding: rounding)
        self = result
        return ternary
    }

    /// Multiply this float by an integer in place.
    ///
    /// - Parameters:
    ///   - value: The integer to multiply by.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A ternary value indicating the rounding direction.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: After this call, `self` equals `self * value` (before the
    /// call).
    ///
    /// - Note: Wraps `mpfr_mul_si` (negative) or `mpfr_mul_ui` (non-negative).
    @discardableResult
    public mutating func multiply(
        by value: Int,
        rounding: MPFRRoundingMode = .nearest
    ) -> Int {
        _ensureUnique()
        let rnd = rounding.toMPFRRoundingMode()
        // Use withUnsafeMutablePointer to avoid Swift exclusivity violation
        // when passing the same storage for both input and output parameters
        let ternary: Int32 = withUnsafeMutablePointer(to: &_storage
            .value)
        { rop in
            let op = UnsafePointer(rop)
            if value >= 0 {
                return mpfr_mul_ui(rop, op, CUnsignedLong(value), rnd)
            } else {
                // For negative multiplier, use absolute value and adjust
                // sign
                // Handle Int.min specially to avoid arithmetic overflow
                let absValue: CUnsignedLong = value == Int.min
                    ? CUnsignedLong(Int.max) + 1 : CUnsignedLong(-value)
                let tempTernary = mpfr_mul_ui(rop, op, absValue, rnd)
                _ = mpfr_neg(rop, rop, rnd)
                // Return the ternary from multiplication (negation is
                // exact)
                return tempTernary
            }
        }
        return Int(ternary)
    }

    /// Divide this float by another in place.
    ///
    /// - Parameters:
    ///   - other: The float to divide by.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A ternary value indicating the rounding direction.
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: After this call, `self` equals `self / other` (before the
    /// call).
    ///   If `other` is zero, `self` becomes NaN.
    ///
    /// - Note: Uses immutable `divided(by:)` + assign pattern to avoid
    /// exclusivity violations.
    @discardableResult
    public mutating func divide(
        by other: MPFRFloat,
        rounding: MPFRRoundingMode = .nearest
    ) -> Int {
        let (result, ternary) = divided(by: other, rounding: rounding)
        self = result
        return ternary
    }

    /// Divide this float by an integer in place.
    ///
    /// - Parameters:
    ///   - value: The integer to divide by.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A ternary value indicating the rounding direction.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: After this call, `self` equals `self / value` (before the
    /// call).
    ///   If `value` is zero, `self` becomes NaN.
    ///
    /// - Note: Wraps `mpfr_div_si` (negative) or `mpfr_div_ui` (non-negative).
    @discardableResult
    public mutating func divide(
        by value: Int,
        rounding: MPFRRoundingMode = .nearest
    ) -> Int {
        _ensureUnique()
        let rnd = rounding.toMPFRRoundingMode()
        // Use withUnsafeMutablePointer to avoid Swift exclusivity violation
        // when passing the same storage for both input and output parameters
        let ternary: Int32 = withUnsafeMutablePointer(to: &_storage
            .value)
        { rop in
            let op = UnsafePointer(rop)
            if value > 0 {
                return mpfr_div_ui(rop, op, CUnsignedLong(value), rnd)
            } else if value < 0 {
                // For negative divisor, use absolute value and adjust sign
                // Handle Int.min specially to avoid arithmetic overflow
                let absValue: CUnsignedLong = value == Int.min
                    ? CUnsignedLong(Int.max) + 1 : CUnsignedLong(-value)
                let tempTernary = mpfr_div_ui(rop, op, absValue, rnd)
                _ = mpfr_neg(rop, rop, rnd)
                // Return the ternary from division (negation is exact)
                return tempTernary
            } else {
                // Division by zero - set to NaN
                mpfr_set_nan(rop)
                return 0 // NaN operations return 0
            }
        }
        return Int(ternary)
    }

    /// Negate this float in place.
    ///
    /// - Parameters:
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A ternary value (always 0, as negation is exact).
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: After this call, `self` equals `-self` (before the call).
    ///
    /// - Note: Uses immutable `negated()` + assign pattern to avoid exclusivity
    /// violations.
    @discardableResult
    public mutating func negate(
        rounding: MPFRRoundingMode = .nearest
    ) -> Int {
        let (result, ternary) = negated(rounding: rounding)
        self = result
        return ternary
    }

    /// Replace this float with its absolute value in place.
    ///
    /// - Parameters:
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A ternary value (always 0, as absolute value is exact).
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: After this call, `self` equals `|self|` (before the call).
    ///
    /// - Note: Uses immutable `absoluteValue()` + assign pattern to avoid
    /// exclusivity violations.
    @discardableResult
    public mutating func makeAbsolute(
        rounding: MPFRRoundingMode = .nearest
    ) -> Int {
        let (result, ternary) = absoluteValue(rounding: rounding)
        self = result
        return ternary
    }

    // MARK: - Reverse Operations

    /// Subtract a float from an integer, returning a new value.
    ///
    /// Computes `value - other`.
    ///
    /// - Parameters:
    ///   - value: The integer to subtract from.
    ///   - other: The float to subtract.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` equal to `value - other`, and a ternary
    /// value.
    ///
    /// - Requires: `other` must be properly initialized.
    /// - Guarantees: Returns a new `MPFRFloat` with the difference, rounded to
    /// `other`'s precision.
    ///
    /// - Note: Wraps `mpfr_si_sub` (negative) or `mpfr_ui_sub` (non-negative).
    public static func subtracting(
        _ value: Int,
        _ other: MPFRFloat,
        rounding: MPFRRoundingMode = .nearest
    ) -> (result: MPFRFloat, ternary: Int) {
        let result = MPFRFloat(precision: other
            .precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        let ternary: Int32
        if value >= 0 {
            ternary = mpfr_ui_sub(
                &result._storage.value,
                CUnsignedLong(value),
                &other._storage.value,
                rnd
            )
        } else {
            // For negative value, compute as: value - other = -(|value| +
            // other)
            // First compute |value| + other, then negate
            // Handle Int.min specially to avoid arithmetic overflow
            let temp = MPFRFloat(precision: other
                .precision) // Mutated through pointer below
            let absValue: CUnsignedLong = value == Int.min
                ? CUnsignedLong(Int.max) + 1 : CUnsignedLong(-value)
            let addTernary = mpfr_add_ui(
                &temp._storage.value,
                &other._storage.value,
                absValue,
                rnd
            )
            _ = mpfr_neg(
                &result._storage.value,
                &temp._storage.value,
                rnd
            )
            // Return the ternary from addition (negation is exact)
            ternary = addTernary
        }
        return (result: result, ternary: Int(ternary))
    }

    /// Divide an integer by a float, returning a new value.
    ///
    /// Computes `value / other`.
    ///
    /// - Parameters:
    ///   - value: The integer to divide.
    ///   - other: The float to divide by.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` equal to `value / other`, and a ternary
    /// value.
    ///
    /// - Requires: `other` must be properly initialized.
    /// - Guarantees: Returns a new `MPFRFloat` with the quotient, rounded to
    /// `other`'s precision.
    ///   If `other` is zero, the result is NaN.
    ///
    /// - Note: Wraps `mpfr_si_div` (negative) or `mpfr_ui_div` (non-negative).
    public static func dividing(
        _ value: Int,
        _ other: MPFRFloat,
        rounding: MPFRRoundingMode = .nearest
    ) -> (result: MPFRFloat, ternary: Int) {
        let result = MPFRFloat(precision: other
            .precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        let ternary: Int32
        if value >= 0 {
            ternary = mpfr_ui_div(
                &result._storage.value,
                CUnsignedLong(value),
                &other._storage.value,
                rnd
            )
        } else {
            // For negative value, compute as: value / other = -(|value| /
            // other)
            // First compute |value| / other, then negate
            // Handle Int.min specially to avoid arithmetic overflow
            let temp = MPFRFloat(precision: other
                .precision) // Mutated through pointer below
            let absValue: CUnsignedLong = value == Int.min
                ? CUnsignedLong(Int.max) + 1 : CUnsignedLong(-value)
            let divTernary = mpfr_ui_div(
                &temp._storage.value,
                absValue,
                &other._storage.value,
                rnd
            )
            _ = mpfr_neg(
                &result._storage.value,
                &temp._storage.value,
                rnd
            )
            // Return the ternary from division (negation is exact)
            ternary = divTernary
        }
        return (result: result, ternary: Int(ternary))
    }

    /// Set this float to `value - other` in place.
    ///
    /// - Parameters:
    ///   - value: The integer to subtract from.
    ///   - other: The float to subtract.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A ternary value indicating the rounding direction.
    ///
    /// - Requires: Both this float and `other` must be properly initialized.
    /// - Guarantees: After this call, `self` equals `value - other`.
    ///
    /// - Note: Wraps `mpfr_si_sub` (negative) or `mpfr_ui_sub` (non-negative).
    @discardableResult
    public mutating func formSubtracting(
        _ value: Int,
        _ other: MPFRFloat,
        rounding: MPFRRoundingMode = .nearest
    ) -> Int {
        _ensureUnique()
        let rnd = rounding.toMPFRRoundingMode()
        let ternary: Int32
        if value >= 0 {
            // mpfr_ui_sub sets rop = ui - op, which is what we want
            ternary = mpfr_ui_sub(
                &_storage.value,
                CUnsignedLong(value),
                &other._storage.value,
                rnd
            )
        } else {
            // For negative value, compute as: value - other = -(|value| +
            // other)
            // First compute |value| + other in a temporary, then negate into
            // self
            // Handle Int.min specially to avoid arithmetic overflow
            let temp =
                MPFRFloat(precision: precision) // Mutated through pointer below
            let absValue: CUnsignedLong = value == Int.min
                ? CUnsignedLong(Int.max) + 1 : CUnsignedLong(-value)
            let addTernary = mpfr_add_ui(
                &temp._storage.value,
                &other._storage.value,
                absValue,
                rnd
            )
            _ = mpfr_neg(&_storage.value, &temp._storage.value, rnd)
            // Return the ternary from addition (negation is exact)
            ternary = addTernary
        }
        return Int(ternary)
    }

    /// Set this float to `value / other` in place.
    ///
    /// - Parameters:
    ///   - value: The integer to divide.
    ///   - other: The float to divide by.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A ternary value indicating the rounding direction.
    ///
    /// - Requires: Both this float and `other` must be properly initialized.
    /// - Guarantees: After this call, `self` equals `value / other`.
    ///   If `other` is zero, `self` becomes NaN.
    ///
    /// - Note: Wraps `mpfr_si_div` (negative) or `mpfr_ui_div` (non-negative).
    @discardableResult
    public mutating func formDividing(
        _ value: Int,
        _ other: MPFRFloat,
        rounding: MPFRRoundingMode = .nearest
    ) -> Int {
        _ensureUnique()
        let rnd = rounding.toMPFRRoundingMode()
        let ternary: Int32
        if value >= 0 {
            // mpfr_ui_div sets rop = ui / op, which is what we want
            ternary = mpfr_ui_div(
                &_storage.value,
                CUnsignedLong(value),
                &other._storage.value,
                rnd
            )
        } else {
            // For negative value, compute as: value / other = -(|value| /
            // other)
            // First compute |value| / other in a temporary, then negate into
            // self
            // Handle Int.min specially to avoid arithmetic overflow
            let temp =
                MPFRFloat(precision: precision) // Mutated through pointer below
            let absValue: CUnsignedLong = value == Int.min
                ? CUnsignedLong(Int.max) + 1 : CUnsignedLong(-value)
            let divTernary = mpfr_ui_div(
                &temp._storage.value,
                absValue,
                &other._storage.value,
                rnd
            )
            _ = mpfr_neg(&_storage.value, &temp._storage.value, rnd)
            // Return the ternary from division (negation is exact)
            ternary = divTernary
        }
        return Int(ternary)
    }

    // MARK: - Power of 2 Operations

    /// Multiply this float by a power of 2, returning a new value.
    ///
    /// Computes `self * 2^exponent`. If `exponent` is negative, this
    /// effectively divides by `2^|exponent|`.
    ///
    /// - Parameters:
    ///   - exponent: The exponent of 2. Can be positive or negative.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` equal to `self * 2^exponent`, and a ternary
    /// value.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns a new `MPFRFloat` with the result, rounded to
    /// `self`'s precision.
    ///   `self` is unchanged.
    ///
    /// - Note: Wraps `mpfr_mul_2si` (negative exponent) or `mpfr_mul_2ui`
    /// (non-negative exponent).
    public func multipliedByPowerOf2(
        _ exponent: Int,
        rounding: MPFRRoundingMode = .nearest
    ) -> (result: MPFRFloat, ternary: Int) {
        let result =
            MPFRFloat(precision: precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        let ternary: Int32 = if exponent >= 0 {
            mpfr_mul_2ui(
                &result._storage.value,
                &_storage.value,
                CUnsignedLong(exponent),
                rnd
            )
        } else {
            mpfr_mul_2si(
                &result._storage.value,
                &_storage.value,
                CLong(exponent),
                rnd
            )
        }
        return (result: result, ternary: Int(ternary))
    }

    /// Divide this float by a power of 2, returning a new value.
    ///
    /// Computes `self / 2^exponent`.
    ///
    /// - Parameters:
    ///   - exponent: The exponent of 2. Must be non-negative.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A new `MPFRFloat` equal to `self / 2^exponent`, and a ternary
    /// value.
    ///
    /// - Requires: This float must be properly initialized. `exponent` must be
    /// non-negative.
    /// - Guarantees: Returns a new `MPFRFloat` with the result, rounded to
    /// `self`'s precision.
    ///   `self` is unchanged.
    ///
    /// - Note: Wraps `mpfr_div_2ui`.
    public func dividedByPowerOf2(
        _ exponent: Int,
        rounding: MPFRRoundingMode = .nearest
    ) -> (result: MPFRFloat, ternary: Int) {
        precondition(
            exponent >= 0,
            "exponent must be non-negative for dividedByPowerOf2"
        )
        let result =
            MPFRFloat(precision: precision) // Mutated through pointer below
        let rnd = rounding.toMPFRRoundingMode()
        let ternary = mpfr_div_2ui(
            &result._storage.value,
            &_storage.value,
            CUnsignedLong(exponent),
            rnd
        )
        return (result: result, ternary: Int(ternary))
    }

    /// Multiply this float by a power of 2 in place.
    ///
    /// Computes `self * 2^exponent`. If `exponent` is negative, this
    /// effectively divides by `2^|exponent|`.
    ///
    /// - Parameters:
    ///   - exponent: The exponent of 2. Can be positive or negative.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A ternary value indicating the rounding direction.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: After this call, `self` equals `self * 2^exponent` (before
    /// the call).
    ///
    /// - Note: Wraps `mpfr_mul_2si` (negative exponent) or `mpfr_mul_2ui`
    /// (non-negative exponent).
    @discardableResult
    public mutating func multiplyByPowerOf2(
        _ exponent: Int,
        rounding: MPFRRoundingMode = .nearest
    ) -> Int {
        _ensureUnique()
        let rnd = rounding.toMPFRRoundingMode()
        // Use withUnsafeMutablePointer to avoid Swift exclusivity violation
        // when passing the same storage for both input and output parameters
        let ternary: Int32 = withUnsafeMutablePointer(to: &_storage
            .value)
        { rop in
            let op = UnsafePointer(rop)
            if exponent >= 0 {
                return mpfr_mul_2ui(rop, op, CUnsignedLong(exponent), rnd)
            } else {
                return mpfr_mul_2si(rop, op, CLong(exponent), rnd)
            }
        }
        return Int(ternary)
    }

    /// Divide this float by a power of 2 in place.
    ///
    /// Computes `self / 2^exponent`.
    ///
    /// - Parameters:
    ///   - exponent: The exponent of 2. Must be non-negative.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A ternary value indicating the rounding direction.
    ///
    /// - Requires: This float must be properly initialized. `exponent` must be
    /// non-negative.
    /// - Guarantees: After this call, `self` equals `self / 2^exponent` (before
    /// the call).
    ///
    /// - Note: Wraps `mpfr_div_2ui`.
    @discardableResult
    public mutating func divideByPowerOf2(
        _ exponent: Int,
        rounding: MPFRRoundingMode = .nearest
    ) -> Int {
        precondition(
            exponent >= 0,
            "exponent must be non-negative for divideByPowerOf2"
        )
        _ensureUnique()
        let rnd = rounding.toMPFRRoundingMode()
        // Use withUnsafeMutablePointer to avoid Swift exclusivity violation
        // when passing the same storage for both input and output parameters
        let ternary: Int32 = withUnsafeMutablePointer(to: &_storage
            .value)
        { rop in
            let op = UnsafePointer(rop)
            return mpfr_div_2ui(rop, op, CUnsignedLong(exponent), rnd)
        }
        return Int(ternary)
    }

    // MARK: - Operator Overloads

    /// Add two `MPFRFloat` values.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side float.
    ///   - rhs: The right-hand side float.
    /// - Returns: The sum of `lhs` and `rhs`, rounded to `lhs`'s precision
    /// using default rounding mode.
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: Returns a new `MPFRFloat` with the sum. Operands are
    /// unchanged.
    ///
    /// - Note: Uses `adding(_:rounding:)` with default rounding mode.
    public static func + (lhs: MPFRFloat, rhs: MPFRFloat) -> MPFRFloat {
        lhs.adding(rhs, rounding: .nearest).result
    }

    /// Add a `MPFRFloat` and an `Int`.
    ///
    /// - Parameters:
    ///   - lhs: The `MPFRFloat` value.
    ///   - rhs: The `Int` value.
    /// - Returns: The sum of `lhs` and `rhs`, rounded using default rounding
    /// mode.
    ///
    /// - Requires: `lhs` must be properly initialized.
    /// - Guarantees: Returns a new `MPFRFloat` with the sum. `lhs` is
    /// unchanged.
    ///
    /// - Note: Uses `add(_:Int, rounding:)` with default rounding mode.
    public static func + (lhs: MPFRFloat, rhs: Int) -> MPFRFloat {
        var result = lhs
        result.add(rhs, rounding: .nearest)
        return result
    }

    /// Subtract two `MPFRFloat` values.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side float.
    ///   - rhs: The right-hand side float.
    /// - Returns: The difference of `lhs` and `rhs`, rounded to `lhs`'s
    /// precision using default rounding mode.
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: Returns a new `MPFRFloat` with the difference. Operands
    /// are unchanged.
    ///
    /// - Note: Uses `subtracting(_:rounding:)` with default rounding mode.
    public static func - (lhs: MPFRFloat, rhs: MPFRFloat) -> MPFRFloat {
        lhs.subtracting(rhs, rounding: .nearest).result
    }

    /// Subtract an `Int` from a `MPFRFloat`.
    ///
    /// - Parameters:
    ///   - lhs: The `MPFRFloat` value.
    ///   - rhs: The `Int` value.
    /// - Returns: The difference of `lhs` and `rhs`, rounded using default
    /// rounding mode.
    ///
    /// - Requires: `lhs` must be properly initialized.
    /// - Guarantees: Returns a new `MPFRFloat` with the difference. `lhs` is
    /// unchanged.
    ///
    /// - Note: Uses `subtract(_:Int, rounding:)` with default rounding mode.
    public static func - (lhs: MPFRFloat, rhs: Int) -> MPFRFloat {
        var result = lhs
        result.subtract(rhs, rounding: .nearest)
        return result
    }

    /// Multiply two `MPFRFloat` values.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side float.
    ///   - rhs: The right-hand side float.
    /// - Returns: The product of `lhs` and `rhs`, rounded to `lhs`'s precision
    /// using default rounding mode.
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: Returns a new `MPFRFloat` with the product. Operands are
    /// unchanged.
    ///
    /// - Note: Uses `multiplied(by:rounding:)` with default rounding mode.
    public static func * (lhs: MPFRFloat, rhs: MPFRFloat) -> MPFRFloat {
        lhs.multiplied(by: rhs, rounding: .nearest).result
    }

    /// Multiply a `MPFRFloat` and an `Int`.
    ///
    /// - Parameters:
    ///   - lhs: The `MPFRFloat` value.
    ///   - rhs: The `Int` value.
    /// - Returns: The product of `lhs` and `rhs`, rounded using default
    /// rounding mode.
    ///
    /// - Requires: `lhs` must be properly initialized.
    /// - Guarantees: Returns a new `MPFRFloat` with the product. `lhs` is
    /// unchanged.
    ///
    /// - Note: Uses `multiply(by:Int, rounding:)` with default rounding mode.
    public static func * (lhs: MPFRFloat, rhs: Int) -> MPFRFloat {
        var result = lhs
        result.multiply(by: rhs, rounding: .nearest)
        return result
    }

    /// Divide two `MPFRFloat` values.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side float.
    ///   - rhs: The right-hand side float.
    /// - Returns: The quotient of `lhs` and `rhs`, rounded to `lhs`'s precision
    /// using default rounding mode.
    ///   If `rhs` is zero, the result is NaN.
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: Returns a new `MPFRFloat` with the quotient. Operands are
    /// unchanged.
    ///
    /// - Note: Uses `divided(by:rounding:)` with default rounding mode.
    public static func / (lhs: MPFRFloat, rhs: MPFRFloat) -> MPFRFloat {
        lhs.divided(by: rhs, rounding: .nearest).result
    }

    /// Divide a `MPFRFloat` by an `Int`.
    ///
    /// - Parameters:
    ///   - lhs: The `MPFRFloat` value.
    ///   - rhs: The `Int` value.
    /// - Returns: The quotient of `lhs` and `rhs`, rounded using default
    /// rounding mode.
    ///   If `rhs` is zero, the result is NaN.
    ///
    /// - Requires: `lhs` must be properly initialized.
    /// - Guarantees: Returns a new `MPFRFloat` with the quotient. `lhs` is
    /// unchanged.
    ///
    /// - Note: Uses `divide(by:Int, rounding:)` with default rounding mode.
    public static func / (lhs: MPFRFloat, rhs: Int) -> MPFRFloat {
        var result = lhs
        result.divide(by: rhs, rounding: .nearest)
        return result
    }

    /// Negate a `MPFRFloat` value.
    ///
    /// - Parameter value: The float to negate.
    /// - Returns: The negation of `value`, rounded using default rounding mode.
    ///
    /// - Requires: `value` must be properly initialized.
    /// - Guarantees: Returns a new `MPFRFloat` with the negated value. `value`
    /// is unchanged.
    ///
    /// - Note: Uses `negated(rounding:)` with default rounding mode.
    public static prefix func - (value: MPFRFloat) -> MPFRFloat {
        value.negated(rounding: .nearest).result
    }

    // MARK: - Compound Assignment Operators

    /// Add a `MPFRFloat` to this float in place.
    ///
    /// - Parameters:
    ///   - lhs: The float to modify.
    ///   - rhs: The float to add.
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: After this call, `lhs` equals `lhs + rhs` (before the
    /// call). `rhs` is unchanged.
    ///
    /// - Note: Uses `add(_:MPFRFloat, rounding:)` with default rounding mode.
    public static func += (lhs: inout MPFRFloat, rhs: MPFRFloat) {
        lhs.add(rhs, rounding: .nearest)
    }

    /// Add an `Int` to this float in place.
    ///
    /// - Parameters:
    ///   - lhs: The float to modify.
    ///   - rhs: The integer to add.
    ///
    /// - Requires: `lhs` must be properly initialized.
    /// - Guarantees: After this call, `lhs` equals `lhs + rhs` (before the
    /// call).
    ///
    /// - Note: Uses `add(_:Int, rounding:)` with default rounding mode.
    public static func += (lhs: inout MPFRFloat, rhs: Int) {
        lhs.add(rhs, rounding: .nearest)
    }

    /// Subtract a `MPFRFloat` from this float in place.
    ///
    /// - Parameters:
    ///   - lhs: The float to modify.
    ///   - rhs: The float to subtract.
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: After this call, `lhs` equals `lhs - rhs` (before the
    /// call). `rhs` is unchanged.
    ///
    /// - Note: Uses `subtract(_:rounding:)` with default rounding mode.
    public static func -= (lhs: inout MPFRFloat, rhs: MPFRFloat) {
        lhs.subtract(rhs, rounding: .nearest)
    }

    /// Subtract an `Int` from this float in place.
    ///
    /// - Parameters:
    ///   - lhs: The float to modify.
    ///   - rhs: The integer to subtract.
    ///
    /// - Requires: `lhs` must be properly initialized.
    /// - Guarantees: After this call, `lhs` equals `lhs - rhs` (before the
    /// call).
    ///
    /// - Note: Uses `subtract(_:Int, rounding:)` with default rounding mode.
    public static func -= (lhs: inout MPFRFloat, rhs: Int) {
        lhs.subtract(rhs, rounding: .nearest)
    }

    /// Multiply this float by a `MPFRFloat` in place.
    ///
    /// - Parameters:
    ///   - lhs: The float to modify.
    ///   - rhs: The float to multiply by.
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: After this call, `lhs` equals `lhs * rhs` (before the
    /// call). `rhs` is unchanged.
    ///
    /// - Note: Uses `multiply(by:rounding:)` with default rounding mode.
    public static func *= (lhs: inout MPFRFloat, rhs: MPFRFloat) {
        lhs.multiply(by: rhs, rounding: .nearest)
    }

    /// Multiply this float by an `Int` in place.
    ///
    /// - Parameters:
    ///   - lhs: The float to modify.
    ///   - rhs: The integer to multiply by.
    ///
    /// - Requires: `lhs` must be properly initialized.
    /// - Guarantees: After this call, `lhs` equals `lhs * rhs` (before the
    /// call).
    ///
    /// - Note: Uses `multiply(by:Int, rounding:)` with default rounding mode.
    public static func *= (lhs: inout MPFRFloat, rhs: Int) {
        lhs.multiply(by: rhs, rounding: .nearest)
    }

    /// Divide this float by a `MPFRFloat` in place.
    ///
    /// - Parameters:
    ///   - lhs: The float to modify.
    ///   - rhs: The float to divide by.
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: After this call, `lhs` equals `lhs / rhs` (before the
    /// call). `rhs` is unchanged.
    ///   If `rhs` is zero, `lhs` is set to NaN.
    ///
    /// - Note: Uses `divide(by:rounding:)` with default rounding mode.
    public static func /= (lhs: inout MPFRFloat, rhs: MPFRFloat) {
        lhs.divide(by: rhs, rounding: .nearest)
    }

    /// Divide this float by an `Int` in place.
    ///
    /// - Parameters:
    ///   - lhs: The float to modify.
    ///   - rhs: The integer to divide by.
    ///
    /// - Requires: `lhs` must be properly initialized.
    /// - Guarantees: After this call, `lhs` equals `lhs / rhs` (before the
    /// call).
    ///   If `rhs` is zero, `lhs` is set to NaN.
    ///
    /// - Note: Uses `divide(by:Int, rounding:)` with default rounding mode.
    public static func /= (lhs: inout MPFRFloat, rhs: Int) {
        lhs.divide(by: rhs, rounding: .nearest)
    }
}
