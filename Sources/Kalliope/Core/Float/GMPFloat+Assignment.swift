import CKalliope

/// Assignment operations for `GMPFloat`.
extension GMPFloat {
    /// Set this float's value from another `GMPFloat`.
    ///
    /// The precision of this float is preserved. The value is converted to this
    /// float's
    /// precision, which may involve rounding if the source has higher
    /// precision.
    ///
    /// - Parameter other: The float whose value will be copied.
    ///
    /// - Wraps: `mpf_set`
    ///
    /// - Requires: Both floats must be properly initialized. `other` must be a
    /// valid `GMPFloat`.
    /// - Guarantees: After this call, `self` has the value of `other` (rounded
    /// to `self`'s
    ///   precision if necessary). The operation is safe even if `self` and
    /// `other` are the
    ///   same variable.
    public mutating func set(_ other: GMPFloat) {
        _ensureUnique()
        __gmpf_set(&_storage.value, &other._storage.value)
    }

    /// Set this float's value from a signed integer.
    ///
    /// - Parameter value: The integer value. Can be positive or negative.
    ///
    /// - Wraps: `mpf_set_si`
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: After this call, `self` has the exact value of `value` (if
    /// representable
    ///   at this precision).
    public mutating func set(_ value: Int) {
        _ensureUnique()
        __gmpf_set_si(&_storage.value, CLong(value))
    }

    /// Set this float's value from an unsigned integer.
    ///
    /// This method is provided for explicit unsigned semantics. For most use
    /// cases,
    /// `set(_: Int)` is preferred as it follows Swift conventions.
    ///
    /// - Parameter value: The unsigned integer value. Must be non-negative.
    ///
    /// - Wraps: `mpf_set_ui`
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: After this call, `self` has the exact value of `value`.
    public mutating func set(_ value: UInt) {
        _ensureUnique()
        __gmpf_set_ui(&_storage.value, CUnsignedLong(value))
    }

    /// Set this float's value from a `Double`.
    ///
    /// The value is converted to this float's precision, which may involve
    /// rounding if
    /// this float has lower precision than a `Double`.
    ///
    /// - Parameter value: The floating-point value.
    ///
    /// - Wraps: `mpf_set_d`
    ///
    /// - Requires: This float must be properly initialized. If `value` is
    /// infinite or NaN,
    ///   the behavior is undefined.
    /// - Guarantees: After this call, `self` approximates `value` at this
    /// float's precision.
    public mutating func set(_ value: Double) {
        _ensureUnique()
        __gmpf_set_d(&_storage.value, value)
    }

    /// Set this float's value from a `GMPInteger`.
    ///
    /// - Parameter value: The integer value.
    ///
    /// - Wraps: `mpf_set_z`
    ///
    /// - Requires: This float and `value` must be properly initialized.
    /// - Guarantees: After this call, `self` has the exact value of `value` (if
    /// representable
    ///   at this precision).
    public mutating func set(_ value: GMPInteger) {
        _ensureUnique()
        __gmpf_set_z(&_storage.value, &value._storage.value)
    }

    // Note: The following method requires GMPRational to be implemented.
    // It is included here for API completeness but will need to be uncommented
    // once GMPRational is available.

    /*
     /// Set this float's value from a `GMPRational`.
     ///
     /// The rational is converted to a floating-point value at this float's precision.
     ///
     /// - Parameter value: The rational number.
     ///
     /// - Wraps: `mpf_set_q`
     ///
     /// - Requires: This float and `value` must be properly initialized.
     /// - Guarantees: After this call, `self` approximates `value` at this float's precision.
     public mutating func set(_ value: GMPRational) {
         _ensureUnique()
         __gmpf_set_q(&_storage.value, &value._storage.value)
     }
     */

    /// Set this float's value from a string representation.
    ///
    /// Parses a string in the specified base and sets the float's value. The
    /// string may
    /// include a decimal point and exponent (e.g., "1.23e-4").
    ///
    /// - Parameters:
    ///   - string: The string to parse. Must be a valid floating-point number
    /// in the
    ///     specified base. May include decimal point and exponent.
    ///   - base: The numeric base (radix) for parsing. Must be 0 or in the
    /// range 2-62.
    ///     Defaults to 10.
    /// - Returns: `true` if parsing succeeds, `false` otherwise.
    ///
    /// - Wraps: `mpf_set_str`
    ///
    /// - Requires: This float must be properly initialized. `base` must be 0 or
    /// in the
    ///   range 2-62. `string` must not be empty.
    /// - Guarantees: If parsing succeeds, `self` contains the parsed value. If
    /// parsing
    ///   fails, `self` is unchanged.
    public mutating func set(_ string: String, base: Int = 10) -> Bool {
        precondition(
            base == 0 || (base >= 2 && base <= 62),
            "base must be 0 or in the range 2-62"
        )
        _ensureUnique()
        let result = string.withCString { cString in
            __gmpf_set_str(&_storage.value, cString, Int32(base))
        }
        return result == 0
    }

    /// Create a new float from a signed integer value.
    ///
    /// - Parameter value: The integer value. Can be positive or negative.
    ///
    /// - Wraps: `mpf_init_set_si`
    ///
    /// - Requires: None
    /// - Guarantees: Returns a valid `GMPFloat` with the exact value of `value`
    /// (at default precision).
    public init(_ value: Int) {
        let defaultPrec = __gmpf_get_default_prec()
        _storage = _GMPFloatStorage(precision: defaultPrec)
        __gmpf_set_si(&_storage.value, CLong(value))
    }

    /// Create a new float from an unsigned integer value.
    ///
    /// This initializer is provided for explicit unsigned semantics. For most
    /// use cases,
    /// `init(_: Int)` is preferred.
    ///
    /// - Parameter value: The unsigned integer value. Must be non-negative.
    ///
    /// - Wraps: `mpf_init_set_ui`
    ///
    /// - Requires: None
    /// - Guarantees: Returns a valid `GMPFloat` with the exact value of
    /// `value`.
    public init(_ value: UInt) {
        let defaultPrec = __gmpf_get_default_prec()
        _storage = _GMPFloatStorage(precision: defaultPrec)
        __gmpf_set_ui(&_storage.value, CUnsignedLong(value))
    }

    /// Create a new float from a `Double` value.
    ///
    /// - Parameter value: The floating-point value.
    ///
    /// - Wraps: `mpf_init_set_d`
    ///
    /// - Requires: `value` must not be infinite or NaN.
    /// - Guarantees: Returns a valid `GMPFloat` approximating `value` at
    /// default precision.
    public init(_ value: Double) {
        let defaultPrec = __gmpf_get_default_prec()
        _storage = _GMPFloatStorage(precision: defaultPrec)
        __gmpf_set_d(&_storage.value, value)
    }

    /// Create a new float from a `GMPInteger` value.
    ///
    /// - Parameter value: The integer value.
    ///
    /// - Wraps: `mpf_init` + `mpf_set_z`
    ///
    /// - Requires: `value` must be properly initialized.
    /// - Guarantees: Returns a valid `GMPFloat` with the exact value of
    /// `value`.
    public init(_ value: GMPInteger) {
        let defaultPrec = __gmpf_get_default_prec()
        _storage = _GMPFloatStorage(precision: defaultPrec)
        __gmpf_set_z(&_storage.value, &value._storage.value)
    }

    // Note: The following initializer requires GMPRational to be implemented.
    // It is included here for API completeness but will need to be uncommented
    // once GMPRational is available.

    /*
     /// Create a new float from a `GMPRational` value.
     ///
     /// - Parameter value: The rational number.
     ///
     /// - Wraps: `mpf_init` + `mpf_set_q`
     ///
     /// - Requires: `value` must be properly initialized.
     /// - Guarantees: Returns a valid `GMPFloat` approximating `value` at default precision.
     public init(_ value: GMPRational) {
         let defaultPrec = __gmpf_get_default_prec()
         _storage = _GMPFloatStorage(precision: defaultPrec)
         __gmpf_set_q(&_storage.value, &value._storage.value)
     }
     */

    /// Create a new float from a string representation.
    ///
    /// - Parameters:
    ///   - string: The string to parse. Must be a valid floating-point number.
    ///   - base: The numeric base (radix) for parsing. Must be 0 or in the
    /// range 2-62.
    ///
    /// - Returns: A new `GMPFloat` if parsing succeeds, `nil` otherwise.
    ///
    /// - Wraps: `mpf_init_set_str`
    ///
    /// - Requires: `base` must be 0 or in the range 2-62. `string` must not be
    /// empty.
    /// - Guarantees: If parsing succeeds, returns a valid `GMPFloat` with the
    /// parsed value.
    ///   If parsing fails, returns `nil`.
    public init?(_ string: String, base: Int = 10) {
        precondition(
            base == 0 || (base >= 2 && base <= 62),
            "base must be 0 or in the range 2-62"
        )
        let defaultPrec = __gmpf_get_default_prec()
        _storage = _GMPFloatStorage(precision: defaultPrec)
        let result = string.withCString { cString in
            __gmpf_set_str(&_storage.value, cString, Int32(base))
        }
        if result != 0 {
            return nil
        }
    }

    /// Swap the values of this float and another float efficiently.
    ///
    /// - Parameter other: The float to swap with. Modified in place.
    ///
    /// - Wraps: `mpf_swap`
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: After this call, `self` has the value that `other` had,
    /// and
    ///   `other` has the value that `self` had. The operation is O(1) and very
    /// efficient.
    public mutating func swap(_ other: inout GMPFloat) {
        _ensureUnique()
        other._ensureUnique()
        __gmpf_swap(&_storage.value, &other._storage.value)
    }
}
