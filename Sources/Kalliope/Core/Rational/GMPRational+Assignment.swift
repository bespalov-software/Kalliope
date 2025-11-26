import CKalliope

/// Assignment operations for `GMPRational`.
extension GMPRational {
    /// Set this rational's value from another `GMPRational`.
    ///
    /// - Parameter other: The rational whose value will be copied.
    ///
    /// - Requires: Both rationals must be properly initialized. `other` must be
    /// a valid `GMPRational`.
    /// - Guarantees: After this call, `self` has the same value as `other`. The
    /// operation
    ///   is safe even if `self` and `other` are the same variable.
    ///
    /// - Note: Wraps `mpq_set`.
    public mutating func set(_ other: GMPRational) {
        _ensureUnique()
        __gmpq_set(&_storage.value, &other._storage.value)
    }

    /// Set this rational's value from a `GMPInteger`.
    ///
    /// Sets the rational to `integer/1`.
    ///
    /// - Parameter integer: The integer value.
    ///
    /// - Requires: This rational and `integer` must be properly initialized.
    /// - Guarantees: After this call, `self` equals `integer/1`.
    ///
    /// - Note: Wraps `mpq_set_z`.
    public mutating func set(_ integer: GMPInteger) {
        _ensureUnique()
        __gmpq_set_z(&_storage.value, &integer._storage.value)
    }

    /// Set this rational's value from `GMPInteger` numerator and denominator.
    ///
    /// The fraction is automatically canonicalized.
    ///
    /// - Parameters:
    ///   - numerator: The numerator as a `GMPInteger`.
    ///   - denominator: The denominator as a `GMPInteger`. Must not be zero.
    ///
    /// - Requires: This rational must be properly initialized. `denominator`
    /// must not be zero.
    /// - Guarantees: After this call, `self` has the canonicalized fraction.
    ///
    /// - Throws: `GMPError.divisionByZero` if `denominator` is zero.
    ///
    /// - Note: Wraps `mpq_set_num`, `mpq_set_den`, and `mpq_canonicalize`.
    public mutating func set(
        numerator: GMPInteger,
        denominator: GMPInteger
    ) throws {
        guard !denominator.isZero else {
            throw GMPError.divisionByZero
        }
        _ensureUnique()
        __gmpq_set_num(&_storage.value, &numerator._storage.value)
        __gmpq_set_den(&_storage.value, &denominator._storage.value)
        __gmpq_canonicalize(&_storage.value)
    }

    /// Set this rational's value from `Int` numerator and denominator.
    ///
    /// The fraction is automatically canonicalized.
    ///
    /// - Parameters:
    ///   - numerator: The numerator as an `Int`.
    ///   - denominator: The denominator as an `Int`. Must not be zero.
    ///
    /// - Requires: This rational must be properly initialized. `denominator`
    /// must not be zero.
    /// - Guarantees: After this call, `self` has the canonicalized fraction.
    ///
    /// - Throws: `GMPError.divisionByZero` if `denominator` is zero.
    ///
    /// - Note: Wraps `mpq_set_si` or `mpq_set_ui` (depending on sign).
    public mutating func set(numerator: Int, denominator: Int) throws {
        guard denominator != 0 else {
            throw GMPError.divisionByZero
        }
        // Convert to GMPInteger and use the GMPInteger version
        try set(
            numerator: GMPInteger(numerator),
            denominator: GMPInteger(denominator)
        )
    }

    /// Set this rational's value from `UInt` numerator and denominator.
    ///
    /// This method is provided for explicit unsigned semantics. For most use
    /// cases,
    /// `set(numerator:denominator:)` with `Int` is preferred.
    ///
    /// - Parameters:
    ///   - numerator: The numerator as a `UInt`.
    ///   - denominator: The denominator as a `UInt`. Must not be zero.
    ///
    /// - Requires: This rational must be properly initialized. `denominator`
    /// must not be zero.
    /// - Guarantees: After this call, `self` has the canonicalized fraction.
    ///
    /// - Throws: `GMPError.divisionByZero` if `denominator` is zero.
    ///
    /// - Note: Wraps `mpq_set_ui`.
    public mutating func set(numerator: UInt, denominator: UInt) throws {
        guard denominator != 0 else {
            throw GMPError.divisionByZero
        }
        // Convert to GMPInteger and use the GMPInteger version
        try set(
            numerator: GMPInteger(numerator),
            denominator: GMPInteger(denominator)
        )
    }

    /// Set this rational's value from a `Double`.
    ///
    /// Converts the double to a rational number. The conversion may be
    /// approximate
    /// depending on the precision of the double.
    ///
    /// - Parameter value: The floating-point value to assign.
    ///
    /// - Requires: This rational must be properly initialized. If `value` is
    /// infinite or NaN,
    ///   the behavior is undefined.
    /// - Guarantees: After this call, `self` approximates `value`. The
    /// approximation
    ///   may not be exact due to floating-point precision.
    ///
    /// - Note: Wraps `mpq_set_d`.
    public mutating func set(_ value: Double) {
        _ensureUnique()
        __gmpq_set_d(&_storage.value, value)
    }

    /// Set this rational's value from a `GMPFloat`.
    ///
    /// Converts the float to a rational number. The conversion may be
    /// approximate
    /// depending on the float's precision.
    ///
    /// - Parameter value: The floating-point number to assign.
    ///
    /// - Requires: This rational and `value` must be properly initialized.
    /// - Guarantees: After this call, `self` approximates `value`.
    ///
    /// - Note: Wraps `mpq_set_f`.
    public mutating func set(_ value: GMPFloat) {
        _ensureUnique()
        __gmpq_set_f(&_storage.value, &value._storage.value)
    }

    /// Set this rational's value from a string representation.
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
    /// - Returns: `true` if parsing succeeds, `false` otherwise.
    ///
    /// - Requires: This rational must be properly initialized. `base` must be 0
    /// or in the
    ///   range 2-62. `string` must not be empty.
    /// - Guarantees: If parsing succeeds, `self` contains the canonicalized
    /// parsed value.
    ///   If parsing fails, `self` is unchanged.
    ///
    /// - Note: Wraps `mpq_set_str`.
    public mutating func set(_ string: String, base: Int = 10) -> Bool {
        precondition(
            base == 0 || (base >= 2 && base <= 62),
            "base must be 0 or in the range 2-62"
        )
        guard !string.isEmpty else {
            return false
        }
        // Use a temporary rational for parsing to avoid modifying self on
        // failure
        let temp = GMPRational() // Mutated through pointer below
        let result = string.withCString { cString in
            withUnsafeMutablePointer(to: &temp._storage.value) { tempPtr in
                __gmpq_set_str(tempPtr, cString, Int32(base))
            }
        }
        if result == 0 {
            withUnsafeMutablePointer(to: &temp._storage.value) { tempPtr in
                __gmpq_canonicalize(tempPtr)
            }
            // Only update self if parsing succeeded
            _ensureUnique()
            __gmpq_set(&_storage.value, &temp._storage.value)
            return true
        }
        return false
    }

    /// Create a new rational from a `GMPInteger`.
    ///
    /// - Parameter integer: The integer value.
    ///
    /// - Requires: `integer` must be properly initialized.
    /// - Guarantees: Returns a valid `GMPRational` with value `integer/1`.
    public init(_ integer: GMPInteger) {
        _storage = _GMPRationalStorage()
        __gmpq_set_z(&_storage.value, &integer._storage.value)
    }

    /// Create a new rational from a `Double`.
    ///
    /// - Parameter value: The floating-point value.
    ///
    /// - Requires: `value` must not be infinite or NaN.
    /// - Guarantees: Returns a valid `GMPRational` approximating `value`.
    public init(_ value: Double) {
        _storage = _GMPRationalStorage()
        __gmpq_set_d(&_storage.value, value)
    }

    /// Create a new rational from a `GMPFloat`.
    ///
    /// - Parameter value: The floating-point number.
    ///
    /// - Requires: `value` must be properly initialized.
    /// - Guarantees: Returns a valid `GMPRational` approximating `value`.
    public init(_ value: GMPFloat) {
        _storage = _GMPRationalStorage()
        __gmpq_set_f(&_storage.value, &value._storage.value)
    }

    /// Swap the values of this rational and another rational efficiently.
    ///
    /// - Parameter other: The rational to swap with. Modified in place.
    ///
    /// - Requires: Both rationals must be properly initialized.
    /// - Guarantees: After this call, `self` has the value that `other` had,
    /// and
    ///   `other` has the value that `self` had. The operation is O(1) and very
    /// efficient.
    ///
    /// - Note: Wraps `mpq_swap`.
    public mutating func swap(_ other: inout GMPRational) {
        _ensureUnique()
        other._ensureUnique()
        __gmpq_swap(&_storage.value, &other._storage.value)
    }
}
