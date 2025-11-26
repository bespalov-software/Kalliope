import CKalliope

/// Initialization methods for `GMPRational`.
extension GMPRational {
    /// Initialize a new rational number from numerator and denominator.
    ///
    /// The fraction is automatically canonicalized (reduced to lowest terms
    /// with
    /// positive denominator).
    ///
    /// - Parameters:
    ///   - numerator: The numerator. Can be any `GMPInteger`.
    ///   - denominator: The denominator. Must not be zero.
    /// - Returns: A new `GMPRational` with the canonicalized fraction.
    ///
    /// - Requires: Both integers must be properly initialized. `denominator`
    /// must not be zero.
    /// - Guarantees: Returns a valid `GMPRational` with the canonicalized
    /// fraction.
    ///   The denominator is always positive, and the fraction is in lowest
    /// terms.
    ///
    /// - Throws: `GMPError.divisionByZero` if `denominator` is zero.
    ///
    /// - Note: Wraps `mpq_set_num`, `mpq_set_den`, and `mpq_canonicalize`.
    public init(numerator: GMPInteger, denominator: GMPInteger) throws {
        guard !denominator.isZero else {
            throw GMPError.divisionByZero
        }
        _storage = _GMPRationalStorage()
        __gmpq_set_num(&_storage.value, &numerator._storage.value)
        __gmpq_set_den(&_storage.value, &denominator._storage.value)
        __gmpq_canonicalize(&_storage.value)
    }

    /// Initialize a new rational number from `Int` numerator and denominator.
    ///
    /// - Parameters:
    ///   - numerator: The numerator as an `Int`.
    ///   - denominator: The denominator as an `Int`. Must not be zero.
    /// - Returns: A new `GMPRational` with the canonicalized fraction.
    ///
    /// - Requires: `denominator` must not be zero.
    /// - Guarantees: Returns a valid `GMPRational` with the canonicalized
    /// fraction.
    ///
    /// - Throws: `GMPError.divisionByZero` if `denominator` is zero.
    ///
    /// - Note: Wraps `mpq_set_si` or `mpq_set_ui` (depending on sign).
    public init(numerator: Int, denominator: Int) throws {
        guard denominator != 0 else {
            throw GMPError.divisionByZero
        }
        try self.init(
            numerator: GMPInteger(numerator),
            denominator: GMPInteger(denominator)
        )
    }

    /// Initialize a new rational number from `UInt` numerator and denominator.
    ///
    /// This initializer is provided for explicit unsigned semantics. For most
    /// use cases,
    /// `init(numerator:denominator:)` with `Int` is preferred.
    ///
    /// - Parameters:
    ///   - numerator: The numerator as a `UInt`.
    ///   - denominator: The denominator as a `UInt`. Must not be zero.
    /// - Returns: A new `GMPRational` with the canonicalized fraction.
    ///
    /// - Requires: `denominator` must not be zero.
    /// - Guarantees: Returns a valid `GMPRational` with the canonicalized
    /// fraction.
    ///
    /// - Throws: `GMPError.divisionByZero` if `denominator` is zero.
    ///
    /// - Note: Wraps `mpq_set_ui`.
    public init(numerator: UInt, denominator: UInt) throws {
        guard denominator != 0 else {
            throw GMPError.divisionByZero
        }
        try self.init(
            numerator: GMPInteger(numerator),
            denominator: GMPInteger(denominator)
        )
    }

    /// Canonicalize this rational number (reduce to lowest terms, ensure
    /// positive denominator).
    ///
    /// Reduces the fraction to lowest terms by dividing both numerator and
    /// denominator
    /// by their GCD, and ensures the denominator is positive (adjusting the
    /// numerator's
    /// sign if necessary).
    ///
    /// - Requires: This rational must be properly initialized. The denominator
    /// must not be zero.
    /// - Guarantees: After this call, the fraction is in canonical form: the
    /// denominator
    ///   is positive, and `gcd(|numerator|, denominator) == 1`. The value is
    /// unchanged.
    ///
    /// - Throws: `GMPError.divisionByZero` if the denominator is zero.
    ///
    /// - Note: Wraps `mpq_canonicalize`.
    public mutating func canonicalize() throws {
        _ensureUnique()
        // Check if denominator is zero before canonicalizing
        // Use direct GMP access to check denominator without creating a copy
        // via property
        // Access the denominator field directly using withUnsafeMutablePointer
        let isZero = withUnsafeMutablePointer(to: &_storage.value) { qPtr in
            // mpq_denref(Q) expands to &((Q)->_mp_den)
            // Access the _mp_den field of the mpq_t structure
            let denPtr = withUnsafeMutablePointer(to: &qPtr.pointee._mp_den) {
                $0
            }
            return __gmpz_cmp_ui(denPtr, 0) == 0
        }
        if isZero {
            throw GMPError.divisionByZero
        }
        __gmpq_canonicalize(&_storage.value)
    }
}
