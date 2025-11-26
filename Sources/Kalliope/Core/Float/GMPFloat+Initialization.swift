import CKalliope

/// Initialization operations for `GMPFloat`.
extension GMPFloat {
    /// Initialize a new floating-point number with default precision and value
    /// 0.0.
    ///
    /// The default precision is platform-dependent but typically 53 bits
    /// (equivalent
    /// to `Double` precision). Use `setDefaultPrecision(_:)` to change the
    /// default.
    ///
    /// - Wraps: `mpf_init`
    ///
    /// - Requires: None
    /// - Guarantees: Returns a valid `GMPFloat` with value 0.0 and default
    /// precision.
    ///   The float is properly initialized and ready for use. Memory will be
    /// automatically
    ///   freed when the value is deallocated.
    public init() {
        let defaultPrec = __gmpf_get_default_prec()
        _storage = _GMPFloatStorage(precision: defaultPrec)
    }

    /// Initialize a new floating-point number with specified precision and
    /// value 0.0.
    ///
    /// - Parameter precision: The precision in bits. Must be positive. This
    /// determines
    ///   the number of significant bits in the mantissa.
    /// - Returns: A new `GMPFloat` with value 0.0 and the specified precision.
    ///
    /// - Wraps: `mpf_init2`
    ///
    /// - Requires: `precision` must be positive.
    /// - Guarantees: Returns a valid `GMPFloat` with value 0.0 and the
    /// specified precision.
    ///   Memory will be automatically freed when the value is deallocated.
    /// - Throws: `GMPError.invalidPrecision` if precision is not positive.
    public init(precision: Int) throws {
        guard precision > 0 else {
            throw GMPError.invalidPrecision
        }
        _storage = _GMPFloatStorage(precision: mp_bitcnt_t(precision))
    }

    /// Get or set the precision of this floating-point number.
    ///
    /// Getting the precision returns the current precision in bits. Setting the
    /// precision
    /// may reallocate memory and may lose precision if the new precision is
    /// less than
    /// the current precision.
    ///
    /// - Returns: The precision in bits (getter).
    ///
    /// - Wraps: `mpf_get_prec` (getter), `mpf_set_prec` (setter)
    ///
    /// - Requires: This float must be properly initialized. When setting, the
    /// new precision
    ///   must be positive.
    /// - Guarantees: The getter returns the current precision in bits. The
    /// setter updates
    ///   the precision; if the new precision is less than the current, some
    /// precision may
    ///   be lost. If the new precision is greater, the value is preserved
    /// exactly.
    public var precision: Int {
        get {
            Int(__gmpf_get_prec(&_storage.value))
        }
        set {
            guard newValue > 0 else {
                fatalError("precision must be positive")
            }
            _ensureUnique()
            __gmpf_set_prec(&_storage.value, mp_bitcnt_t(newValue))
        }
    }

    /// Set the default precision for future `GMPFloat` initializations.
    ///
    /// This affects all future calls to `init()` (without a precision
    /// parameter).
    /// Existing `GMPFloat` instances are not affected.
    ///
    /// - Parameter precision: The default precision in bits. Must be positive.
    ///
    /// - Wraps: `mpf_set_default_prec`
    ///
    /// - Requires: `precision` must be positive.
    /// - Guarantees: After this call, all future `init()` calls will use this
    /// precision
    ///   (unless overridden by `init(precision:)`). Existing instances are
    /// unchanged.
    /// - Throws: `GMPError.invalidPrecision` if precision is not positive.
    public static func setDefaultPrecision(_ precision: Int) throws {
        guard precision > 0 else {
            throw GMPError.invalidPrecision
        }
        __gmpf_set_default_prec(mp_bitcnt_t(precision))
    }

    /// Get the default precision for `GMPFloat` initializations.
    ///
    /// - Returns: The default precision in bits.
    ///
    /// - Wraps: `mpf_get_default_prec`
    ///
    /// - Requires: None
    /// - Guarantees: Returns the precision that will be used by `init()`
    /// (without parameters).
    public static var defaultPrecision: Int {
        Int(__gmpf_get_default_prec())
    }
}
