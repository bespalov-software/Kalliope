import CKalliope

/// Comparison operations for `GMPRational`.
extension GMPRational {
    /// Compare this rational with another, returning a comparison result.
    ///
    /// - Parameter other: The rational to compare with.
    /// - Returns: -1 if `self < other`, 0 if `self == other`, 1 if `self >
    /// other`.
    ///
    /// - Requires: Both rationals must be properly initialized.
    /// - Guarantees: Returns -1, 0, or 1. Returns 0 if and only if `self ==
    /// other`.
    ///
    /// - Note: Wraps `mpq_cmp`.
    public func compare(to other: GMPRational) -> Int {
        Int(__gmpq_cmp(&_storage.value, &other._storage.value))
    }

    /// Compare this rational with a `GMPInteger`.
    ///
    /// Compares `self` with `integer/1`.
    ///
    /// - Parameter integer: The integer to compare with.
    /// - Returns: -1 if `self < integer`, 0 if `self == integer`, 1 if `self >
    /// integer`.
    ///
    /// - Requires: This rational and `integer` must be properly initialized.
    /// - Guarantees: Returns -1, 0, or 1.
    ///
    /// - Note: Wraps `mpq_cmp_z`.
    public func compare(to integer: GMPInteger) -> Int {
        Int(__gmpq_cmp_z(&_storage.value, &integer._storage.value))
    }

    /// Compare this rational with an `Int` numerator and denominator.
    ///
    /// - Parameters:
    ///   - num: The numerator as an `Int`.
    ///   - den: The denominator as an `Int`. Must not be zero.
    /// - Returns: -1 if `self < num/den`, 0 if `self == num/den`, 1 if `self >
    /// num/den`.
    ///
    /// - Requires: This rational must be properly initialized. `den` must not
    /// be zero.
    /// - Guarantees: Returns -1, 0, or 1.
    ///
    /// - Note: Wraps `mpq_cmp_si` or `mpq_cmp_ui` (depending on sign).
    public func compare(to num: Int, den: Int) -> Int {
        precondition(den != 0, "denominator must not be zero")

        if num < 0 {
            // Use signed comparison for negative numerator
            return Int(__gmpq_cmp_si(
                &_storage.value,
                CLong(num),
                CUnsignedLong(den)
            ))
        } else {
            // Use unsigned comparison for non-negative numerator
            return Int(__gmpq_cmp_ui(
                &_storage.value,
                CUnsignedLong(num),
                CUnsignedLong(den)
            ))
        }
    }

    /// Get the sign of this rational number.
    ///
    /// - Returns: -1 if negative, 0 if zero, 1 if positive.
    ///
    /// - Requires: This rational must be properly initialized.
    /// - Guarantees: Returns -1, 0, or 1. Returns 0 if and only if `self == 0`.
    ///
    /// - Note: Uses `mpq_cmp_ui` to compare with 0/1.
    public var sign: Int {
        // Compare with 0/1 to get sign
        let cmp = __gmpq_cmp_ui(&_storage.value, 0, 1)
        if cmp < 0 {
            return -1
        } else if cmp > 0 {
            return 1
        } else {
            return 0
        }
    }

    /// Check if this rational number is zero.
    ///
    /// - Returns: `true` if `self == 0`, `false` otherwise.
    ///
    /// - Requires: This rational must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `self == 0`.
    ///
    /// - Note: Uses `mpq_cmp_ui` to compare with 0/1.
    public var isZero: Bool {
        __gmpq_cmp_ui(&_storage.value, 0, 1) == 0
    }

    /// Check if this rational number is negative.
    ///
    /// - Returns: `true` if `self < 0`, `false` otherwise.
    ///
    /// - Requires: This rational must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `self < 0`.
    public var isNegative: Bool {
        sign < 0
    }

    /// Check if this rational number is positive.
    ///
    /// - Returns: `true` if `self > 0`, `false` otherwise.
    ///
    /// - Requires: This rational must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `self > 0`.
    public var isPositive: Bool {
        sign > 0
    }
}

// MARK: - Equatable Conformance

extension GMPRational: Equatable {
    /// Check if two rational numbers are equal.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side rational.
    ///   - rhs: The right-hand side rational.
    /// - Returns: `true` if `lhs == rhs`, `false` otherwise.
    ///
    /// - Requires: Both rationals must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `lhs.compare(to: rhs) == 0`.
    ///
    /// - Note: Uses `mpq_equal`.
    public static func == (lhs: GMPRational, rhs: GMPRational) -> Bool {
        __gmpq_equal(&lhs._storage.value, &rhs._storage.value) != 0
    }
}

// MARK: - Comparable Conformance

/// Comparison operations for `GMPRational`.
///
/// `GMPRational` conforms to `Comparable`, enabling use in sorting, sets, and
/// other
/// operations that require ordering.
extension GMPRational: Comparable {
    /// Less-than comparison operator.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side rational.
    ///   - rhs: The right-hand side rational.
    /// - Returns: `true` if `lhs < rhs`, `false` otherwise.
    ///
    /// - Requires: Both rationals must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `lhs.compare(to: rhs) < 0`.
    public static func < (lhs: GMPRational, rhs: GMPRational) -> Bool {
        __gmpq_cmp(&lhs._storage.value, &rhs._storage.value) < 0
    }

    /// Less-than-or-equal comparison operator.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side rational.
    ///   - rhs: The right-hand side rational.
    /// - Returns: `true` if `lhs <= rhs`, `false` otherwise.
    ///
    /// - Requires: Both rationals must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `lhs.compare(to: rhs) <= 0`.
    public static func <= (lhs: GMPRational, rhs: GMPRational) -> Bool {
        __gmpq_cmp(&lhs._storage.value, &rhs._storage.value) <= 0
    }

    /// Greater-than comparison operator.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side rational.
    ///   - rhs: The right-hand side rational.
    /// - Returns: `true` if `lhs > rhs`, `false` otherwise.
    ///
    /// - Requires: Both rationals must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `lhs.compare(to: rhs) > 0`.
    public static func > (lhs: GMPRational, rhs: GMPRational) -> Bool {
        __gmpq_cmp(&lhs._storage.value, &rhs._storage.value) > 0
    }

    /// Greater-than-or-equal comparison operator.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side rational.
    ///   - rhs: The right-hand side rational.
    /// - Returns: `true` if `lhs >= rhs`, `false` otherwise.
    ///
    /// - Requires: Both rationals must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `lhs.compare(to: rhs) >= 0`.
    public static func >= (lhs: GMPRational, rhs: GMPRational) -> Bool {
        __gmpq_cmp(&lhs._storage.value, &rhs._storage.value) >= 0
    }
}

// MARK: - Hashable Conformance

/// Hashable conformance for `GMPRational`.
///
/// The hash value is based on the rational's value (canonicalized fraction),
/// not its internal representation.
extension GMPRational: Hashable {
    /// Hash the rational into the provided hasher.
    ///
    /// - Parameter hasher: The hasher to use for combining hash values.
    ///
    /// - Requires: This rational must be properly initialized.
    /// - Guarantees: The hash value is based on the rational's canonicalized
    /// value.
    ///   Two rationals with the same value will produce the same hash value.
    public func hash(into hasher: inout Hasher) {
        // Hash numerator and denominator directly for efficiency
        // Rationals are canonicalized, so same values will have same num/den
        numerator.hash(into: &hasher)
        denominator.hash(into: &hasher)
    }
}

// MARK: - CustomStringConvertible Conformance

extension GMPRational: CustomStringConvertible {
    /// A textual representation of this rational number.
    ///
    /// Returns the decimal string representation of the rational number.
    public var description: String {
        toString()
    }
}
