import CKalliope

/// Comparison operations for `GMPFloat`.
extension GMPFloat {
    /// Check if this float is zero.
    ///
    /// - Returns: `true` if `self == 0`, `false` otherwise.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `self == 0` exactly.
    public var isZero: Bool {
        __gmpf_cmp_ui(&_storage.value, 0) == 0
    }

    /// Check if this float is negative.
    ///
    /// - Returns: `true` if `self < 0`, `false` otherwise.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `self < 0`.
    public var isNegative: Bool {
        __gmpf_cmp_ui(&_storage.value, 0) < 0
    }

    /// Check if this float is positive.
    ///
    /// - Returns: `true` if `self > 0`, `false` otherwise.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `self > 0`.
    public var isPositive: Bool {
        __gmpf_cmp_ui(&_storage.value, 0) > 0
    }

    /// Get the sign of this float.
    ///
    /// - Returns: -1 if negative, 0 if zero, 1 if positive.
    ///
    /// - Wraps: `mpf_cmp_ui` (comparing with 0)
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns -1, 0, or 1. Returns 0 if and only if `self == 0`.
    public var sign: Int {
        let cmp = __gmpf_cmp_ui(&_storage.value, 0)
        if cmp < 0 {
            return -1
        } else if cmp > 0 {
            return 1
        } else {
            return 0
        }
    }

    /// Compare this float with another, returning a comparison result.
    ///
    /// - Parameter other: The float to compare with.
    /// - Returns: -1 if `self < other`, 0 if `self == other`, 1 if `self >
    /// other`.
    ///
    /// - Wraps: `mpf_cmp`
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: Returns -1, 0, or 1. Returns 0 if and only if `self ==
    /// other` exactly.
    ///   For floating-point values, consider using `isEqual(to:bits:)` instead
    /// of exact equality.
    public func compare(to other: GMPFloat) -> Int {
        Int(__gmpf_cmp(&_storage.value, &other._storage.value))
    }

    /// Compare this float with a `GMPInteger`.
    ///
    /// Compares `self` with `integer` converted to a float.
    ///
    /// - Parameter integer: The integer to compare with.
    /// - Returns: -1 if `self < integer`, 0 if `self == integer`, 1 if `self >
    /// integer`.
    ///
    /// - Wraps: `mpf_cmp_z`
    ///
    /// - Requires: This float and `integer` must be properly initialized.
    /// - Guarantees: Returns -1, 0, or 1.
    public func compare(to integer: GMPInteger) -> Int {
        Int(__gmpf_cmp_z(&_storage.value, &integer._storage.value))
    }

    /// Compare this float with a `Double` value.
    ///
    /// The float is compared with the `Double` value. If the float is too large
    /// to
    /// represent exactly as a `Double`, the comparison may be approximate.
    ///
    /// - Parameter value: The `Double` value to compare with.
    /// - Returns: -1 if `self < value`, 0 if `self == value`, 1 if `self >
    /// value`.
    ///
    /// - Wraps: `mpf_cmp_d`
    ///
    /// - Requires: This float must be properly initialized. If `value` is
    /// infinite or NaN,
    ///   the behavior is undefined.
    /// - Guarantees: Returns -1, 0, or 1. The comparison uses the float's
    /// `Double` representation.
    public func compare(to value: Double) -> Int {
        Int(__gmpf_cmp_d(&_storage.value, value))
    }

    /// Compare this float with an `Int` value.
    ///
    /// - Parameter value: The `Int` value to compare with.
    /// - Returns: -1 if `self < value`, 0 if `self == value`, 1 if `self >
    /// value`.
    ///
    /// - Wraps: `mpf_cmp_si`
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns -1, 0, or 1.
    public func compare(to value: Int) -> Int {
        Int(__gmpf_cmp_si(&_storage.value, CLong(value)))
    }

    /// Check if this float's value is equal to another within a bit tolerance.
    ///
    /// Two floats are considered equal if their relative difference is less
    /// than 2^-bits.
    /// This is the recommended way to compare floating-point values for
    /// equality.
    ///
    /// - Parameters:
    ///   - other: The float to compare with.
    ///   - bits: The number of bits of tolerance. Must be positive. A typical
    /// value
    ///     is the precision of the floats being compared.
    /// - Returns: `true` if the floats are equal within the tolerance, `false`
    /// otherwise.
    ///
    /// - Wraps: `mpf_eq`
    ///
    /// - Requires: Both floats must be properly initialized. `bits` must be
    /// positive.
    /// - Guarantees: Returns `true` if the relative difference is less than
    /// 2^-bits.
    ///   This is equivalent to `GMPFloat.relativeDifference(self, other) <
    /// 2^-bits`.
    public func isEqual(to other: GMPFloat, bits: Int) -> Bool {
        precondition(bits > 0, "bits must be positive")
        return __gmpf_eq(
            &_storage.value,
            &other._storage.value,
            mp_bitcnt_t(bits)
        ) != 0
    }
}

// MARK: - Equatable Conformance

extension GMPFloat: Equatable {
    public static func == (lhs: GMPFloat, rhs: GMPFloat) -> Bool {
        __gmpf_cmp(&lhs._storage.value, &rhs._storage.value) == 0
    }
}

// MARK: - Comparable Conformance

/// Comparison operations for `GMPFloat`.
///
/// `GMPFloat` conforms to `Comparable`, enabling use in sorting, sets, and
/// other
/// operations that require ordering. Note that floating-point comparisons
/// should
/// typically use `isEqual(to:bits:)` with a tolerance rather than exact
/// equality.
extension GMPFloat: Comparable {
    /// Less-than comparison operator.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side float.
    ///   - rhs: The right-hand side float.
    /// - Returns: `true` if `lhs < rhs`, `false` otherwise.
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `lhs.compare(to: rhs) < 0`.
    public static func < (lhs: GMPFloat, rhs: GMPFloat) -> Bool {
        __gmpf_cmp(&lhs._storage.value, &rhs._storage.value) < 0
    }

    /// Less-than-or-equal comparison operator.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side float.
    ///   - rhs: The right-hand side float.
    /// - Returns: `true` if `lhs <= rhs`, `false` otherwise.
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `lhs.compare(to: rhs) <= 0`.
    public static func <= (lhs: GMPFloat, rhs: GMPFloat) -> Bool {
        __gmpf_cmp(&lhs._storage.value, &rhs._storage.value) <= 0
    }

    /// Greater-than comparison operator.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side float.
    ///   - rhs: The right-hand side float.
    /// - Returns: `true` if `lhs > rhs`, `false` otherwise.
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `lhs.compare(to: rhs) > 0`.
    public static func > (lhs: GMPFloat, rhs: GMPFloat) -> Bool {
        __gmpf_cmp(&lhs._storage.value, &rhs._storage.value) > 0
    }

    /// Greater-than-or-equal comparison operator.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side float.
    ///   - rhs: The right-hand side float.
    /// - Returns: `true` if `lhs >= rhs`, `false` otherwise.
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `lhs.compare(to: rhs) >= 0`.
    public static func >= (lhs: GMPFloat, rhs: GMPFloat) -> Bool {
        __gmpf_cmp(&lhs._storage.value, &rhs._storage.value) >= 0
    }
}

// MARK: - Hashable Conformance

/// Hashable conformance for `GMPFloat`.
///
/// **Note**: The hash is based on the float's mathematical value, not its
/// precision.
/// Two floats with the same value but different precisions will have the same
/// hash value.
/// This ensures Hashable compliance: if `a == b`, then `hash(a) == hash(b)`.
extension GMPFloat: Hashable {
    /// Hash the float into the provided hasher.
    ///
    /// - Parameter hasher: The hasher to use for combining hash values.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: The hash value is based on the float's mathematical value.
    ///   Two floats with the same value will produce the same hash value,
    /// regardless
    ///   of precision. This satisfies the Hashable requirement: if `a == b`,
    /// then
    ///   `hash(a) == hash(b)`.
    ///
    /// - Note: The hash uses a normalized representation by converting to a
    ///   `GMPRational` via `mpq_set_f()`, which gives an exact rational
    ///   representation. Rationals are canonicalized (reduced to lowest terms),
    ///   ensuring that same values hash the same regardless of precision.
    ///   This preserves full precision and ensures Hashable compliance: equal
    ///   values always hash the same, regardless of their internal precision.
    ///   This approach is similar to CPython's rational-based hashing strategy.
    public func hash(into hasher: inout Hasher) {
        // Convert GMPFloat to GMPRational using mpq_set_f
        // This gives an exact rational representation that is canonicalized
        // (reduced to lowest terms), ensuring same values hash the same
        // regardless of precision. This is similar to CPython's approach of
        // using rational number reduction for hashing.
        var rationalQ = mpq_t()
        __gmpq_init(&rationalQ)
        defer {
            __gmpq_clear(&rationalQ)
        }

        __gmpq_set_f(&rationalQ, &_storage.value)

        // Create a GMPRational from the mpq_t and use its hash method
        // GMPRational's hash uses numerator and denominator, which are
        // canonicalized, ensuring same values hash the same
        var rational = GMPRational()
        rational.withMutableCPointer { dstPtr in
            __gmpq_set(dstPtr, &rationalQ)
        }

        // Use GMPRational's hash method - it handles canonicalized num/den
        rational.hash(into: &hasher)

        // Note: This approach converts to rational and uses its canonicalized
        // form, so floats with the same mathematical value but different
        // precisions
        // will hash to the same value, which satisfies the Hashable
        // requirement:
        // if `a == b`, then `hash(a) == hash(b)`. This preserves full precision
        // (no loss to Double) and is similar to CPython's rational-based
        // hashing.
    }
}

// MARK: - CustomStringConvertible Conformance

extension GMPFloat: CustomStringConvertible {
    /// A textual representation of this float.
    ///
    /// Returns the decimal string representation of the float.
    public var description: String {
        toString()
    }
}
