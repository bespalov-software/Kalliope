import CKalliope

/// Access to numerator and denominator components of `GMPRational`.
extension GMPRational {
    /// Get the numerator of this rational number.
    ///
    /// Returns the numerator as a `GMPInteger`. The returned value is a copy,
    /// so
    /// modifying it does not affect this rational.
    ///
    /// - Returns: A new `GMPInteger` with the numerator value.
    ///
    /// - Requires: This rational must be properly initialized.
    /// - Guarantees: Returns a new `GMPInteger` with the numerator. The
    /// denominator
    ///   is always positive in canonical form.
    ///
    /// - Note: Uses `mpq_get_num` (via `mpq_numref`).
    public var numerator: GMPInteger {
        let result = GMPInteger()
        __gmpq_get_num(&result._storage.value, &_storage.value)
        return result
    }

    /// Get the denominator of this rational number.
    ///
    /// Returns the denominator as a `GMPInteger`. The returned value is a copy,
    /// so
    /// modifying it does not affect this rational. The denominator is always
    /// positive
    /// in canonical form.
    ///
    /// - Returns: A new `GMPInteger` with the denominator value.
    ///
    /// - Requires: This rational must be properly initialized.
    /// - Guarantees: Returns a new `GMPInteger` with the denominator. The
    /// denominator
    ///   is always positive and non-zero.
    ///
    /// - Note: Uses `mpq_get_den` (via `mpq_denref`).
    public var denominator: GMPInteger {
        let result = GMPInteger()
        __gmpq_get_den(&result._storage.value, &_storage.value)
        return result
    }

    /// Set the numerator of this rational number.
    ///
    /// Sets the numerator to the specified value. The rational may need to be
    /// canonicalized after this operation.
    ///
    /// - Parameter value: The new numerator value.
    ///
    /// - Requires: This rational and `value` must be properly initialized.
    /// - Guarantees: After this call, the numerator is set to `value`. The
    /// rational
    ///   may not be in canonical form and may need `canonicalize()` to be
    /// called.
    ///
    /// - Note: Wraps `mpq_set_num`.
    public mutating func setNumerator(_ value: GMPInteger) {
        _ensureUnique()
        __gmpq_set_num(&_storage.value, &value._storage.value)
    }

    /// Set the denominator of this rational number.
    ///
    /// Sets the denominator to the specified value. The denominator must not be
    /// zero.
    /// The rational may need to be canonicalized after this operation.
    ///
    /// - Parameter value: The new denominator value. Must not be zero.
    ///
    /// - Requires: This rational and `value` must be properly initialized.
    /// `value` must not be zero.
    /// - Guarantees: After this call, the denominator is set to `value`. The
    /// rational
    ///   may not be in canonical form and may need `canonicalize()` to be
    /// called.
    ///
    /// - Throws: `GMPError.divisionByZero` if `value` is zero.
    ///
    /// - Note: Wraps `mpq_set_den`.
    public mutating func setDenominator(_ value: GMPInteger) throws {
        guard !value.isZero else {
            throw GMPError.divisionByZero
        }
        _ensureUnique()
        __gmpq_set_den(&_storage.value, &value._storage.value)
    }
}
