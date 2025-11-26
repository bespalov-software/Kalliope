// Import CKalliope first so gmp.h is available when CLinus imports mpfr.h
import CKalliope
import CLinus
import CLinusBridge
import Darwin
import Kalliope

/// Internal storage class for `MPFRFloat` implementing Copy-on-Write (COW)
/// semantics.
///
/// This class holds the actual MPFR `mpfr_t` structure and manages its
/// lifecycle.
/// It's marked as `final` and `internal` to allow access from extensions in the
/// same module.
final class _MPFRFloatStorage {
    /// The underlying MPFR floating-point structure.
    ///
    /// This is the actual `mpfr_t` value that MPFR operates on. It's stored as
    /// a property to allow Swift's ARC to manage the class's lifetime, which
    /// in turn manages the MPFR structure's lifecycle.
    var value: mpfr_t

    /// Initialize a new storage instance with a NaN float at the specified
    /// precision.
    ///
    /// Allocates and initializes a new MPFR floating-point structure with value
    /// NaN
    /// and the specified precision.
    ///
    /// - Parameter precision: The precision in bits. Must be between
    /// MPFR_PREC_MIN
    ///   and MPFR_PREC_MAX. This determines the number of significant bits in
    /// the mantissa.
    ///
    /// - Requires: `precision` must be between MPFR_PREC_MIN and MPFR_PREC_MAX.
    /// - Guarantees: After initialization, `value` is a valid, initialized
    ///   `mpfr_t` structure with value NaN and the specified precision. Memory
    /// will
    ///   be automatically freed when the storage instance is deallocated.
    init(precision: mpfr_prec_t) {
        value = mpfr_t()
        mpfr_init2(&value, precision)
    }

    /// Initialize a new storage instance by copying another.
    ///
    /// Creates an independent copy of the MPFR floating-point value. The new
    /// instance
    /// uses the same precision as the source. This is used for Copy-on-Write
    /// semantics
    /// when a `MPFRFloat` needs to be mutated but is shared with other
    /// instances.
    ///
    /// - Parameter other: The storage instance to copy from.
    ///
    /// - Requires: `other` must be properly initialized and contain a valid
    ///   `mpfr_t` structure.
    /// - Guarantees: After initialization, `value` is a valid, initialized
    ///   `mpfr_t` structure with the same value and precision as `other.value`.
    ///   The new instance is independent - mutations to one won't affect the
    /// other.
    init(copying other: _MPFRFloatStorage) {
        let prec = mpfr_get_prec(&other.value)
        value = mpfr_t()
        mpfr_init2(&value, prec)
        mpfr_set(&value, &other.value, MPFR_RNDN)
    }

    /// Deinitialize and free the MPFR floating-point structure.
    ///
    /// Clears the MPFR floating-point structure and frees all associated
    /// memory.
    /// This is called automatically by Swift's ARC when the storage instance
    /// is deallocated.
    ///
    /// - Requires: `value` must be a valid, initialized `mpfr_t` structure.
    /// - Guarantees: After deinitialization, all memory associated with `value`
    ///   is freed. The `value` structure is no longer valid and must not be
    /// used.
    deinit {
        mpfr_clear(&value)
    }
}

/// An arbitrary-precision floating-point number type wrapping MPFR's `mpfr_t`.
///
/// `MPFRFloat` provides floating-point arithmetic with user-specifiable
/// precision and
/// IEEE 754-compliant rounding modes. Precision is specified in bits and can be
/// adjusted at any time. Unlike GMP's `mpf_t`, MPFR provides correct rounding
/// and follows IEEE 754 semantics.
///
/// - Note: Memory is automatically managed through Swift's ARC. The underlying
/// MPFR
///   structure is initialized on creation and cleared on deallocation.
///
/// `MPFRFloat` provides value semantics with automatic memory management
/// through
/// Copy-on-Write (COW). Multiple `MPFRFloat` instances can share the same
/// underlying
/// storage until one needs to be mutated, at which point a copy is made
/// automatically.
///
/// - Note: This struct uses a private storage class to implement COW semantics,
///   ensuring that value semantics are maintained while minimizing unnecessary
/// copies.
public struct MPFRFloat {
    /// The internal storage holding the MPFR floating-point structure.
    ///
    /// This is a reference to a `_MPFRFloatStorage` instance. Multiple
    /// `MPFRFloat`
    /// instances may share the same storage reference until mutation occurs.
    var _storage: _MPFRFloatStorage

    /// Ensure this float has unique storage before mutation.
    ///
    /// This method implements Copy-on-Write semantics. Before mutating the
    /// float,
    /// it checks if the storage is shared with other instances. If it is, a new
    /// independent copy is created. This ensures that mutations don't affect
    /// other
    /// instances that share the same storage.
    ///
    /// This method should be called at the beginning of any mutating operation
    /// to ensure value semantics are maintained.
    ///
    /// - Requires: `_storage` must be properly initialized.
    /// - Guarantees: After this call, `_storage` is uniquely referenced by this
    ///   instance (no other `MPFRFloat` instances share it). If a copy was
    /// made,
    ///   the value and precision are preserved. If no copy was needed, the
    /// operation
    ///   is O(1).
    mutating func _ensureUnique() {
        if !isKnownUniquelyReferenced(&_storage) {
            _storage = _MPFRFloatStorage(copying: _storage)
        }
    }

    // MARK: - Initialization

    /// Initialize a new floating-point number with default precision and value
    /// NaN.
    ///
    /// The default precision is platform-dependent but typically 53 bits
    /// (equivalent
    /// to `Double` precision). Use `setDefaultPrecision(_:)` to change the
    /// default.
    /// Unlike GMP's `mpf_init`, MPFR initializes to NaN rather than zero.
    ///
    /// - Wraps: `mpfr_init`
    ///
    /// - Requires: None
    /// - Guarantees: Returns a valid `MPFRFloat` with value NaN and default
    /// precision.
    ///   The float is properly initialized and ready for use. Memory will be
    /// automatically
    ///   freed when the value is deallocated.
    public init() {
        let defaultPrec = mpfr_get_default_prec()
        _storage = _MPFRFloatStorage(precision: defaultPrec)
    }

    /// Initialize a new floating-point number with specified precision and
    /// value NaN.
    ///
    /// - Parameter precision: The precision in bits. Must be between
    /// MPFR_PREC_MIN
    ///   and MPFR_PREC_MAX. This determines the number of significant bits in
    /// the mantissa.
    /// - Returns: A new `MPFRFloat` with value NaN and the specified precision.
    ///
    /// - Wraps: `mpfr_init2`
    ///
    /// - Requires: `precision` must be between MPFR_PREC_MIN and MPFR_PREC_MAX.
    /// - Guarantees: Returns a valid `MPFRFloat` with value NaN and the
    /// specified precision.
    ///   Memory will be automatically freed when the value is deallocated.
    public init(precision: Int) {
        let precMin = Int(clinus_get_prec_min())
        let precMax = Int(clinus_get_prec_max())
        precondition(
            precision >= precMin && precision <= precMax,
            "precision must be between MPFR_PREC_MIN and MPFR_PREC_MAX"
        )
        _storage = _MPFRFloatStorage(precision: mpfr_prec_t(precision))
    }

    /// Get or set the precision of this floating-point number.
    ///
    /// Getting the precision returns the current precision in bits. Setting the
    /// precision
    /// may reallocate memory. If the new precision is less than the current
    /// precision,
    /// the value is set to NaN (unlike GMP, which preserves the value).
    ///
    /// - Returns: The precision in bits (getter).
    ///
    /// - Wraps: `mpfr_get_prec` (getter), `mpfr_set_prec` (setter)
    ///
    /// - Requires: This float must be properly initialized. When setting, the
    /// new precision
    ///   must be between MPFR_PREC_MIN and MPFR_PREC_MAX.
    /// - Guarantees: The getter returns the current precision in bits. The
    /// setter updates
    ///   the precision; if the new precision is less than the current, the
    /// value is set to NaN.
    ///   If the new precision is greater, the value is preserved exactly.
    public var precision: Int {
        get {
            Int(mpfr_get_prec(&_storage.value))
        }
        set {
            let precMin = Int(clinus_get_prec_min())
            let precMax = Int(clinus_get_prec_max())
            precondition(
                newValue >= precMin && newValue <= precMax,
                "precision must be between MPFR_PREC_MIN and MPFR_PREC_MAX"
            )
            _ensureUnique()
            mpfr_set_prec(&_storage.value, mpfr_prec_t(newValue))
        }
    }

    /// Check if this float is NaN (Not-a-Number).
    ///
    /// - Returns: `true` if `self` is NaN, `false` otherwise.
    ///
    /// - Wraps: `mpfr_nan_p`
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `self` is NaN.
    public var isNaN: Bool {
        mpfr_nan_p(&_storage.value) != 0
    }

    // MARK: - Assignment

    /// Set this float's value from another `MPFRFloat`.
    ///
    /// The precision of this float is preserved. The value is converted to this
    /// float's precision, which may involve rounding if the source has higher
    /// precision.
    ///
    /// - Parameters:
    ///   - other: The float whose value will be copied.
    ///   - rounding: The rounding mode to use when converting precision.
    /// Defaults to `.nearest`.
    ///
    /// - Returns: A ternary value: 0 if exact, positive if rounded up, negative
    /// if rounded down.
    ///
    /// - Wraps: `mpfr_set`
    ///
    /// - Requires: Both floats must be properly initialized. `other` must be a
    /// valid `MPFRFloat`.
    /// - Guarantees: After this call, `self` has the value of `other` (rounded
    /// to `self`'s
    ///   precision if necessary). The operation is safe even if `self` and
    /// `other` are the
    ///   same variable (MPFR handles overlapping operands correctly).
    @discardableResult
    public mutating func set(
        _ other: MPFRFloat,
        rounding: MPFRRoundingMode = .nearest
    ) -> Int {
        _ensureUnique()
        let rnd = rounding.toMPFRRoundingMode()
        // MPFR's mpfr_set handles overlapping operands correctly, so direct
        // assignment is safe
        return Int(mpfr_set(&_storage.value, &other._storage.value, rnd))
    }

    /// Set this float's value from a signed integer.
    ///
    /// Integers are exact, so rounding modes don't affect the result, but they
    /// must be accepted.
    ///
    /// - Parameters:
    ///   - value: The integer value. Can be positive or negative.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`. Has no
    /// effect
    ///     since integers are exact.
    ///
    /// - Returns: A ternary value: always 0 (exact) since integers are exact.
    ///
    /// - Wraps: `mpfr_set_si`
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: After this call, `self` has the exact value of `value`.
    ///   The value is preserved exactly, regardless of sign. `Int.min` is
    /// handled correctly.
    @discardableResult
    public mutating func set(
        _ value: Int,
        rounding: MPFRRoundingMode = .nearest
    ) -> Int {
        _ensureUnique()
        let rnd = rounding.toMPFRRoundingMode()
        // mpfr_set_si handles Int.min correctly (it takes CLong which can
        // represent Int.min)
        return Int(mpfr_set_si(&_storage.value, CLong(value), rnd))
    }

    /// Set this float's value from an unsigned integer.
    ///
    /// This method is provided for explicit unsigned semantics. For most use
    /// cases,
    /// `set(_: Int)` is preferred as it follows Swift conventions.
    ///
    /// Integers are exact, so rounding modes don't affect the result, but they
    /// must be accepted.
    ///
    /// - Parameters:
    ///   - value: The unsigned integer value. Must be non-negative.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`. Has no
    /// effect
    ///     since integers are exact.
    ///
    /// - Returns: A ternary value: always 0 (exact) since integers are exact.
    ///
    /// - Wraps: `mpfr_set_ui`
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: After this call, `self` has the exact value of `value`.
    @discardableResult
    public mutating func set(
        _ value: UInt,
        rounding: MPFRRoundingMode = .nearest
    ) -> Int {
        _ensureUnique()
        let rnd = rounding.toMPFRRoundingMode()
        return Int(mpfr_set_ui(&_storage.value, CUnsignedLong(value), rnd))
    }

    /// Set this float's value from a `Double`.
    ///
    /// - Parameters:
    ///   - value: The floating-point value.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    ///
    /// - Returns: A ternary value indicating the rounding direction: 0 if
    /// exact,
    ///   positive if rounded up, negative if rounded down.
    ///
    /// - Wraps: `mpfr_set_d`
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: After this call, `self` has the value of `value` (rounded
    /// to `self`'s
    ///   precision if necessary). Special values (Infinity, NaN) are preserved.
    @discardableResult
    public mutating func set(
        _ value: Double,
        rounding: MPFRRoundingMode = .nearest
    ) -> Int {
        _ensureUnique()
        let rnd = rounding.toMPFRRoundingMode()
        return Int(mpfr_set_d(&_storage.value, value, rnd))
    }

    /// Set this float's value from a `GMPInteger`.
    ///
    /// Integers are exact, so rounding modes don't affect the result, but they
    /// must be accepted.
    ///
    /// - Parameters:
    ///   - value: The integer value. Can be positive or negative, and can be
    /// arbitrarily large.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`. Has no
    /// effect
    ///     since integers are exact.
    ///
    /// - Returns: A ternary value: always 0 (exact) since integers are exact.
    ///
    /// - Wraps: `mpfr_set_z`
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: After this call, `self` has the exact value of `value` (if
    /// representable
    ///   at this precision). The value is preserved exactly, regardless of
    /// sign.
    @discardableResult
    public mutating func set(
        _ value: GMPInteger,
        rounding: MPFRRoundingMode = .nearest
    ) -> Int {
        _ensureUnique()
        let rnd = rounding.toMPFRRoundingMode()
        return value.withCPointer { zPtr in
            Int(mpfr_set_z(&_storage.value, zPtr, rnd))
        }
    }

    /// Set this float's value from a `GMPRational`.
    ///
    /// Rational numbers may require rounding if they cannot be represented
    /// exactly at this
    /// float's precision.
    ///
    /// - Parameters:
    ///   - value: The rational value. Can be positive or negative.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    ///
    /// - Returns: A ternary value: 0 if exact, positive if rounded up, negative
    /// if rounded down.
    ///
    /// - Wraps: `mpfr_set_q`
    ///
    /// - Requires: This float must be properly initialized. `value` must not
    /// have a zero denominator.
    /// - Guarantees: After this call, `self` has the value of `value` (rounded
    /// to `self`'s
    ///   precision if necessary).
    @discardableResult
    public mutating func set(
        _ value: GMPRational,
        rounding: MPFRRoundingMode = .nearest
    ) -> Int {
        _ensureUnique()
        let rnd = rounding.toMPFRRoundingMode()
        return value.withCPointer { qPtr in
            Int(mpfr_set_q(&_storage.value, qPtr, rnd))
        }
    }

    /// Set this float's value from a string representation.
    ///
    /// Parses a string representation of a number in the specified base. The
    /// string
    /// can include an exponent (e.g., "1.23e-4" for decimal, "1.8p0" for
    /// hexadecimal).
    /// Base 0 auto-detects the base from prefixes: "0x" for hex, "0b" for
    /// binary, etc.
    ///
    /// - Parameters:
    ///   - string: The string to parse. Can include whitespace (ignored).
    ///   - base: The numeric base (radix) for parsing. Must be 0 (auto-detect)
    /// or in
    ///     the range 2-62. For bases 2-36, case is ignored. For bases 37-62,
    ///     upper-case letters represent 10-35, lower-case letters represent
    /// 36-61.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    ///
    /// - Returns: `true` if the entire string was successfully parsed as a
    /// valid number,
    ///   `false` otherwise. If `false`, `self` is unchanged.
    ///
    /// - Wraps: `mpfr_set_str`
    ///
    /// - Requires: This float must be properly initialized. `base` must be 0 or
    /// in the
    ///   range 2-62. `string` must not be empty (after removing whitespace).
    /// - Guarantees: If the function returns `true`, `self` contains the parsed
    /// value
    ///   (rounded to `self`'s precision if necessary). If it returns `false`,
    /// `self` is
    ///   unchanged.
    @discardableResult
    public mutating func set(
        _ string: String,
        base: Int = 10,
        rounding: MPFRRoundingMode = .nearest
    ) -> Bool {
        precondition(
            base == 0 || (base >= 2 && base <= 62),
            "base must be 0 or in the range 2-62"
        )
        _ensureUnique()
        let rnd = rounding.toMPFRRoundingMode()
        let result = string.withCString { cString in
            mpfr_set_str(&_storage.value, cString, Int32(base), rnd)
        }
        return result == 0
    }

    /// Convert this float to a `Double`.
    ///
    /// The conversion may lose precision if this float has more precision than
    /// a `Double`.
    /// If the value is too large for a `Double`, the result is system-dependent
    /// (typically infinity).
    ///
    /// - Parameter rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: The value as a `Double`. Special values (Infinity, NaN) are
    /// preserved.
    ///
    /// - Wraps: `mpfr_get_d`
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns a `Double` representing the float value. The
    /// conversion may
    ///   lose precision. If the value is too large, the result is
    /// system-dependent.
    public func toDouble(rounding: MPFRRoundingMode = .nearest) -> Double {
        let rnd = rounding.toMPFRRoundingMode()
        return mpfr_get_d(&_storage.value, rnd)
    }

    /// Convert this float to a `Double` with separate exponent.
    ///
    /// Similar to the standard C `frexp` function. Returns the value as a
    /// mantissa
    /// in the range [0.5, 1) or [-1, -0.5) and a separate exponent such that
    /// `mantissa * 2^exponent`
    /// equals the float value.
    ///
    /// - Parameter rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A tuple `(mantissa: Double, exponent: Int)` where the
    /// mantissa is
    ///   in the range [0.5, 1) (or [-1, -0.5) for negative) and `mantissa *
    /// 2^exponent` equals
    ///   the float value. If the value is zero, returns `(0.0, 0)`.
    ///
    /// - Wraps: `mpfr_get_d_2exp`
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: The mantissa is always in the range [0.5, 1) (or [-1,
    /// -0.5) for negative),
    ///   and `mantissa * 2^exponent` equals the float value.
    public func toDouble2Exp(rounding: MPFRRoundingMode = .nearest)
        -> (mantissa: Double, exponent: Int)
    {
        let rnd = rounding.toMPFRRoundingMode()
        var exp: CLong = 0
        let mantissa = mpfr_get_d_2exp(&exp, &_storage.value, rnd)
        return (mantissa: mantissa, exponent: Int(exp))
    }

    /// Convert this float to an unsigned integer.
    ///
    /// Truncates toward zero. If the value is too large or negative, only the
    /// least
    /// significant bits are returned.
    ///
    /// - Parameter rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: The value as a `UInt`, truncated toward zero.
    ///
    /// - Wraps: `mpfr_get_ui`
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns a `UInt` representing the truncated value. Use
    /// `fitsInUInt()`
    ///   to check if the conversion is exact.
    public func toUInt(rounding: MPFRRoundingMode = .nearest) -> UInt {
        let rnd = rounding.toMPFRRoundingMode()
        return UInt(mpfr_get_ui(&_storage.value, rnd))
    }

    /// Convert this float to a signed integer.
    ///
    /// Truncates toward zero. If the value is too large, only the least
    /// significant
    /// bits are returned.
    ///
    /// - Parameter rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: The value as an `Int`, truncated toward zero.
    ///
    /// - Wraps: `mpfr_get_si`
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns an `Int` representing the truncated value. Use
    /// `fitsInInt()`
    ///   to check if the conversion is exact.
    public func toInt(rounding: MPFRRoundingMode = .nearest) -> Int {
        let rnd = rounding.toMPFRRoundingMode()
        return Int(mpfr_get_si(&_storage.value, rnd))
    }

    /// Convert this float to a string representation in the given base.
    ///
    /// - Parameters:
    ///   - base: The numeric base (radix) for conversion. Must be in the range
    /// 2-62,
    ///     or from -2 to -36. Defaults to 10 (decimal).
    ///   - digits: The number of significant digits to output. If 0, outputs
    /// all significant
    ///     digits. Must be non-negative.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    /// - Returns: A string representation of the float in the specified base.
    ///
    /// - Wraps: `mpfr_get_str`
    ///
    /// - Requires: This float must be properly initialized. `base` must be in
    /// the range
    ///   2-62 or -36 to -2. `digits` must be non-negative.
    /// - Guarantees: Returns a valid string representation. The string can be
    /// parsed back
    ///   using `set(_:String, base:rounding:)` with the same base to recover
    /// the value
    ///   (within precision limits).
    public func toString(
        base: Int = 10,
        digits: Int = 0,
        rounding: MPFRRoundingMode = .nearest
    ) -> String {
        precondition(
            (base >= 2 && base <= 62) || (base >= -36 && base <= -2),
            "base must be in range 2-62 or -36 to -2"
        )
        precondition(digits >= 0, "digits must be non-negative")

        let rnd = rounding.toMPFRRoundingMode()
        var exp: mpfr_exp_t = 0
        let absBase = base >= 0 ? base : -base

        // Call mpfr_get_str with NULL to allocate buffer
        // Returns pointer to allocated string that we must free
        let cString = mpfr_get_str(
            nil,
            &exp,
            Int32(absBase),
            size_t(digits),
            &_storage.value,
            rnd
        )
        defer {
            // Free the allocated string
            free(cString)
        }

        guard let cString else {
            // Should not happen, but handle gracefully
            return "0"
        }

        let mantissaString = String(cString: cString)

        // Handle zero case
        if mantissaString == "0" || mantissaString.isEmpty {
            return "0"
        }

        // Format the string with decimal point and exponent
        // The mantissa from MPFR has the decimal point before the first digit
        // exp is the exponent in the given base
        if exp == 0 {
            // Value is between 1/base and 1, so format as "0.mantissa"
            return "0.\(mantissaString)"
        } else if exp > 0 {
            // Value >= 1, insert decimal point after exp digits
            if exp >= mantissaString.count {
                // All digits are before decimal point, append zeros if needed
                return mantissaString + String(
                    repeating: "0",
                    count: Int(exp) - mantissaString.count
                )
            } else {
                // Insert decimal point
                let index = mantissaString.index(
                    mantissaString.startIndex,
                    offsetBy: Int(exp)
                )
                return String(mantissaString[..<index]) + "." +
                    String(mantissaString[index...])
            }
        } else {
            // Value < 1/base, format as "0.00...0mantissa" with |exp| zeros
            let zeros = String(repeating: "0", count: Int(-exp))
            return "0.\(zeros)\(mantissaString)"
        }
    }

    /// Create a new float from a signed integer value.
    ///
    /// - Parameters:
    ///   - value: The integer value. Can be positive or negative.
    ///   - precision: The precision in bits. If nil, uses default precision.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`. Has no
    /// effect
    ///     since integers are exact.
    ///
    /// - Wraps: `mpfr_init2`, `mpfr_set_si`
    ///
    /// - Requires: If `precision` is provided, it must be between MPFR_PREC_MIN
    /// and MPFR_PREC_MAX.
    /// - Guarantees: Returns a valid `MPFRFloat` with the exact value of
    /// `value`.
    ///   `Int.min` is handled correctly.
    public init(
        _ value: Int,
        precision: Int? = nil,
        rounding: MPFRRoundingMode = .nearest
    ) {
        if let prec = precision {
            let precMin = Int(clinus_get_prec_min())
            let precMax = Int(clinus_get_prec_max())
            precondition(
                prec >= precMin && prec <= precMax,
                "precision must be between MPFR_PREC_MIN and MPFR_PREC_MAX"
            )
            _storage = _MPFRFloatStorage(precision: mpfr_prec_t(prec))
        } else {
            let defaultPrec = mpfr_get_default_prec()
            _storage = _MPFRFloatStorage(precision: defaultPrec)
        }
        let rnd = rounding.toMPFRRoundingMode()
        _ = mpfr_set_si(&_storage.value, CLong(value), rnd)
    }

    /// Create a new float from an unsigned integer value.
    ///
    /// - Parameters:
    ///   - value: The unsigned integer value. Must be non-negative.
    ///   - precision: The precision in bits. If nil, uses default precision.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`. Has no
    /// effect
    ///     since integers are exact.
    ///
    /// - Wraps: `mpfr_init2`, `mpfr_set_ui`
    ///
    /// - Requires: If `precision` is provided, it must be between MPFR_PREC_MIN
    /// and MPFR_PREC_MAX.
    /// - Guarantees: Returns a valid `MPFRFloat` with the exact value of
    /// `value`.
    public init(
        _ value: UInt,
        precision: Int? = nil,
        rounding: MPFRRoundingMode = .nearest
    ) {
        if let prec = precision {
            let precMin = Int(clinus_get_prec_min())
            let precMax = Int(clinus_get_prec_max())
            precondition(
                prec >= precMin && prec <= precMax,
                "precision must be between MPFR_PREC_MIN and MPFR_PREC_MAX"
            )
            _storage = _MPFRFloatStorage(precision: mpfr_prec_t(prec))
        } else {
            let defaultPrec = mpfr_get_default_prec()
            _storage = _MPFRFloatStorage(precision: defaultPrec)
        }
        let rnd = rounding.toMPFRRoundingMode()
        _ = mpfr_set_ui(&_storage.value, CUnsignedLong(value), rnd)
    }

    /// Create a new float from a `Double` value.
    ///
    /// - Parameters:
    ///   - value: The floating-point value.
    ///   - precision: The precision in bits. If nil, uses default precision.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    ///
    /// - Wraps: `mpfr_init2`, `mpfr_set_d`
    ///
    /// - Requires: If `precision` is provided, it must be between MPFR_PREC_MIN
    /// and MPFR_PREC_MAX.
    /// - Guarantees: Returns a valid `MPFRFloat` with the value of `value`
    /// (rounded to the
    ///   specified precision if necessary). Special values (Infinity, NaN) are
    /// preserved.
    public init(
        _ value: Double,
        precision: Int? = nil,
        rounding: MPFRRoundingMode = .nearest
    ) {
        if let prec = precision {
            let precMin = Int(clinus_get_prec_min())
            let precMax = Int(clinus_get_prec_max())
            precondition(
                prec >= precMin && prec <= precMax,
                "precision must be between MPFR_PREC_MIN and MPFR_PREC_MAX"
            )
            _storage = _MPFRFloatStorage(precision: mpfr_prec_t(prec))
        } else {
            let defaultPrec = mpfr_get_default_prec()
            _storage = _MPFRFloatStorage(precision: defaultPrec)
        }
        let rnd = rounding.toMPFRRoundingMode()
        _ = mpfr_set_d(&_storage.value, value, rnd)
    }

    /// Create a new float from a `GMPInteger` value.
    ///
    /// - Parameters:
    ///   - value: The integer value. Can be positive or negative, and can be
    /// arbitrarily large.
    ///   - precision: The precision in bits. If nil, uses default precision.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`. Has no
    /// effect
    ///     since integers are exact.
    ///
    /// - Wraps: `mpfr_init2`, `mpfr_set_z`
    ///
    /// - Requires: If `precision` is provided, it must be between MPFR_PREC_MIN
    /// and MPFR_PREC_MAX.
    /// - Guarantees: Returns a valid `MPFRFloat` with the exact value of
    /// `value` (if representable
    ///   at the specified precision).
    public init(
        _ value: GMPInteger,
        precision: Int? = nil,
        rounding: MPFRRoundingMode = .nearest
    ) {
        if let prec = precision {
            let precMin = Int(clinus_get_prec_min())
            let precMax = Int(clinus_get_prec_max())
            precondition(
                prec >= precMin && prec <= precMax,
                "precision must be between MPFR_PREC_MIN and MPFR_PREC_MAX"
            )
            _storage = _MPFRFloatStorage(precision: mpfr_prec_t(prec))
        } else {
            let defaultPrec = mpfr_get_default_prec()
            _storage = _MPFRFloatStorage(precision: defaultPrec)
        }
        let rnd = rounding.toMPFRRoundingMode()
        _ = value.withCPointer { zPtr in
            mpfr_set_z(&_storage.value, zPtr, rnd)
        }
    }

    /// Create a new float from a `GMPRational` value.
    ///
    /// - Parameters:
    ///   - value: The rational value. Can be positive or negative.
    ///   - precision: The precision in bits. If nil, uses default precision.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    ///
    /// - Wraps: `mpfr_init2`, `mpfr_set_q`
    ///
    /// - Requires: If `precision` is provided, it must be between MPFR_PREC_MIN
    /// and MPFR_PREC_MAX.
    ///   `value` must not have a zero denominator.
    /// - Guarantees: Returns a valid `MPFRFloat` with the value of `value`
    /// (rounded to the
    ///   specified precision if necessary).
    public init(
        _ value: GMPRational,
        precision: Int? = nil,
        rounding: MPFRRoundingMode = .nearest
    ) {
        if let prec = precision {
            let precMin = Int(clinus_get_prec_min())
            let precMax = Int(clinus_get_prec_max())
            precondition(
                prec >= precMin && prec <= precMax,
                "precision must be between MPFR_PREC_MIN and MPFR_PREC_MAX"
            )
            _storage = _MPFRFloatStorage(precision: mpfr_prec_t(prec))
        } else {
            let defaultPrec = mpfr_get_default_prec()
            _storage = _MPFRFloatStorage(precision: defaultPrec)
        }
        let rnd = rounding.toMPFRRoundingMode()
        _ = value.withCPointer { qPtr in
            mpfr_set_q(&_storage.value, qPtr, rnd)
        }
    }

    /// Create a new float from a string representation.
    ///
    /// Parses a string representation of a number in the specified base. The
    /// string
    /// can include an exponent (e.g., "1.23e-4" for decimal, "1.8p0" for
    /// hexadecimal).
    /// Base 0 auto-detects the base from prefixes: "0x" for hex, "0b" for
    /// binary, etc.
    ///
    /// - Parameters:
    ///   - string: The string to parse. Can include whitespace (ignored).
    ///   - base: The numeric base (radix) for parsing. Must be 0 (auto-detect)
    /// or in
    ///     the range 2-62. For bases 2-36, case is ignored. For bases 37-62,
    ///     upper-case letters represent 10-35, lower-case letters represent
    /// 36-61.
    ///   - precision: The precision in bits. If nil, uses default precision.
    ///   - rounding: The rounding mode to use. Defaults to `.nearest`.
    ///
    /// - Returns: A new `MPFRFloat` if parsing succeeds, `nil` otherwise.
    ///
    /// - Wraps: `mpfr_init2`, `mpfr_set_str`
    ///
    /// - Requires: If `precision` is provided, it must be between MPFR_PREC_MIN
    /// and MPFR_PREC_MAX.
    ///   `base` must be 0 or in the range 2-62. `string` must not be empty
    /// (after removing whitespace).
    /// - Guarantees: If parsing succeeds, returns a valid `MPFRFloat` with the
    /// parsed value
    ///   (rounded to the specified precision if necessary). If parsing fails,
    /// returns `nil`.
    public init?(
        _ string: String,
        base: Int = 10,
        precision: Int? = nil,
        rounding: MPFRRoundingMode = .nearest
    ) {
        precondition(
            base == 0 || (base >= 2 && base <= 62),
            "base must be 0 or in the range 2-62"
        )
        if let prec = precision {
            let precMin = Int(clinus_get_prec_min())
            let precMax = Int(clinus_get_prec_max())
            precondition(
                prec >= precMin && prec <= precMax,
                "precision must be between MPFR_PREC_MIN and MPFR_PREC_MAX"
            )
            _storage = _MPFRFloatStorage(precision: mpfr_prec_t(prec))
        } else {
            let defaultPrec = mpfr_get_default_prec()
            _storage = _MPFRFloatStorage(precision: defaultPrec)
        }
        let rnd = rounding.toMPFRRoundingMode()
        let result = string.withCString { cString in
            mpfr_set_str(&_storage.value, cString, Int32(base), rnd)
        }
        if result != 0 {
            return nil
        }
    }

    /// Swap the values of this float and another float efficiently.
    ///
    /// This operation is very fast as it only swaps pointers to the underlying
    /// data,
    /// not the data itself. It's safe to swap a float with itself (no-op).
    ///
    /// - Parameter other: The float to swap with. Modified in place.
    ///
    /// - Wraps: `mpfr_swap`
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: After this call, `self` has the value that `other` had,
    ///   and `other` has the value that `self` had. The operation is O(1) and
    /// very efficient.
    ///   Precisions are swapped along with values.
    public mutating func swap(_ other: inout MPFRFloat) {
        _ensureUnique()
        other._ensureUnique()
        mpfr_swap(&_storage.value, &other._storage.value)
    }

    // MARK: - Comparison

    /// Compare this float with another, returning a comparison result.
    ///
    /// - Parameter other: The float to compare with.
    /// - Returns: -1 if `self < other`, 0 if `self == other`, 1 if `self >
    /// other`.
    ///   If either value is NaN, returns 0 (per MPFR specification).
    ///
    /// - Wraps: `mpfr_cmp`
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: Returns -1, 0, or 1. Returns 0 if and only if `self ==
    /// other` exactly.
    ///   For floating-point values, consider using `isEqual(to:bits:)` instead
    /// of exact equality.
    public func compare(to other: MPFRFloat) -> Int {
        // MPFR's mpfr_cmp handles overlapping operands correctly
        Int(mpfr_cmp(&_storage.value, &other._storage.value))
    }

    /// Compare this float with a `GMPInteger`.
    ///
    /// Compares `self` with `integer` converted to a float.
    ///
    /// - Parameter integer: The integer to compare with.
    /// - Returns: -1 if `self < integer`, 0 if `self == integer`, 1 if `self >
    /// integer`.
    ///
    /// - Wraps: `mpfr_cmp_z`
    ///
    /// - Requires: This float and `integer` must be properly initialized.
    /// - Guarantees: Returns -1, 0, or 1.
    public func compare(to integer: GMPInteger) -> Int {
        integer.withCPointer { zPtr in
            Int(mpfr_cmp_z(&_storage.value, zPtr))
        }
    }

    /// Compare this float with a `Double` value.
    ///
    /// The float is compared with the `Double` value. If the float is too large
    /// to represent exactly as a `Double`, the comparison may be approximate.
    ///
    /// - Parameter value: The `Double` value to compare with.
    /// - Returns: -1 if `self < value`, 0 if `self == value`, 1 if `self >
    /// value`.
    ///   If either value is NaN, returns 0 (per MPFR specification).
    ///
    /// - Wraps: `mpfr_cmp_d`
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns -1, 0, or 1. The comparison uses the float's
    /// `Double` representation.
    public func compare(to value: Double) -> Int {
        Int(mpfr_cmp_d(&_storage.value, value))
    }

    /// Compare this float with an `Int` value.
    ///
    /// - Parameter value: The `Int` value to compare with.
    /// - Returns: -1 if `self < value`, 0 if `self == value`, 1 if `self >
    /// value`.
    ///
    /// - Wraps: `mpfr_cmp_si`
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns -1, 0, or 1.
    public func compare(to value: Int) -> Int {
        Int(mpfr_cmp_si(&_storage.value, CLong(value)))
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
    ///   Returns `false` if either value is NaN.
    ///
    /// - Wraps: `mpfr_eq`
    ///
    /// - Requires: Both floats must be properly initialized. `bits` must be
    /// positive.
    /// - Guarantees: Returns `true` if the relative difference is less than
    /// 2^-bits.
    public func isEqual(to other: MPFRFloat, bits: Int) -> Bool {
        precondition(bits > 0, "bits must be positive")
        return mpfr_eq(
            &_storage.value,
            &other._storage.value,
            mp_bitcnt_t(bits)
        ) != 0
    }

    /// Get the sign of this float.
    ///
    /// - Returns: -1 if negative, 0 if zero or NaN, 1 if positive.
    ///
    /// - Wraps: `mpfr_sgn`
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns -1, 0, or 1. Returns 0 if and only if `self == 0`
    /// or `self` is NaN.
    public var sign: Int {
        Int(mpfr_sgn(&_storage.value))
    }

    /// Check if this float is zero.
    ///
    /// - Returns: `true` if `self == 0`, `false` otherwise.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `self == 0` exactly.
    public var isZero: Bool {
        mpfr_zero_p(&_storage.value) != 0
    }

    /// Check if this float is negative.
    ///
    /// - Returns: `true` if `self < 0`, `false` otherwise.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `self < 0`.
    public var isNegative: Bool {
        sign < 0
    }

    /// Check if this float is positive.
    ///
    /// - Returns: `true` if `self > 0`, `false` otherwise.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `self > 0`.
    public var isPositive: Bool {
        sign > 0
    }

    /// Check if this float is infinity (positive or negative).
    ///
    /// - Returns: `true` if `self` is positive or negative infinity, `false`
    /// otherwise.
    ///
    /// - Wraps: `mpfr_inf_p`
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `self` is infinity.
    public var isInfinity: Bool {
        mpfr_inf_p(&_storage.value) != 0
    }

    /// Check if this float is a regular number (not NaN, not infinity).
    ///
    /// - Returns: `true` if `self` is a regular number (including zero),
    /// `false` otherwise.
    ///
    /// - Wraps: `mpfr_number_p`
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `self` is a regular number
    /// (not NaN, not infinity).
    public var isRegular: Bool {
        mpfr_number_p(&_storage.value) != 0
    }

    // MARK: - Fits In Checks

    /// Check if this float's value fits exactly in a `UInt`.
    ///
    /// - Returns: `true` if the value is non-negative, has no fractional part,
    /// and fits
    ///   in a `UInt`, `false` otherwise.
    ///
    /// - Wraps: `mpfr_fits_ulong_p` or `mpfr_fits_uint_p` (platform-dependent),
    /// `mpfr_integer_p`
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `toUInt()` would return the
    /// exact value.
    public func fitsInUInt() -> Bool {
        // Must be non-negative, integer, and fit in UInt
        guard !isNegative else { return false }
        guard mpfr_integer_p(&_storage.value) != 0 else { return false }
        #if arch(x86_64) || arch(arm64)
            // On 64-bit platforms, UInt is 64 bits, use mpfr_fits_ulong_p
            return mpfr_fits_ulong_p(&_storage.value, MPFR_RNDN) != 0
        #else
            // On 32-bit platforms, UInt is 32 bits, use mpfr_fits_uint_p
            return mpfr_fits_uint_p(&_storage.value, MPFR_RNDN) != 0
        #endif
    }

    /// Check if this float's value fits exactly in an `Int`.
    ///
    /// - Returns: `true` if the value has no fractional part and fits in an
    /// `Int`,
    ///   `false` otherwise.
    ///
    /// - Wraps: `mpfr_fits_slong_p` or `mpfr_fits_sint_p` (platform-dependent),
    /// `mpfr_integer_p`
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `toInt()` would return the
    /// exact value.
    public func fitsInInt() -> Bool {
        // Must be integer and fit in Int
        guard mpfr_integer_p(&_storage.value) != 0 else { return false }
        #if arch(x86_64) || arch(arm64)
            // On 64-bit platforms, Int is 64 bits, use mpfr_fits_slong_p
            return mpfr_fits_slong_p(&_storage.value, MPFR_RNDN) != 0
        #else
            // On 32-bit platforms, Int is 32 bits, use mpfr_fits_sint_p
            return mpfr_fits_sint_p(&_storage.value, MPFR_RNDN) != 0
        #endif
    }

    /// Check if this float's value fits exactly in a `UInt64`.
    ///
    /// - Returns: `true` if the value is non-negative, has no fractional part,
    /// and fits
    ///   in a `UInt64`, `false` otherwise.
    ///
    /// - Wraps: `mpfr_fits_ulong_p`, `mpfr_integer_p`
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns `true` if and only if the value can be represented
    /// exactly as a `UInt64`.
    public func fitsInUInt64() -> Bool {
        // Must be non-negative, integer, and fit in UInt64
        guard !isNegative else { return false }
        guard mpfr_integer_p(&_storage.value) != 0 else { return false }
        return mpfr_fits_ulong_p(&_storage.value, MPFR_RNDN) != 0
    }

    /// Check if this float's value fits exactly in an `Int64`.
    ///
    /// - Returns: `true` if the value has no fractional part and fits in an
    /// `Int64`,
    ///   `false` otherwise.
    ///
    /// - Wraps: `mpfr_fits_slong_p`, `mpfr_integer_p`
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns `true` if and only if the value can be represented
    /// exactly as an `Int64`.
    public func fitsInInt64() -> Bool {
        // Must be integer and fit in Int64
        guard mpfr_integer_p(&_storage.value) != 0 else { return false }
        return mpfr_fits_slong_p(&_storage.value, MPFR_RNDN) != 0
    }
}

// MARK: - Equatable Conformance

extension MPFRFloat: Equatable {
    public static func == (lhs: MPFRFloat, rhs: MPFRFloat) -> Bool {
        // MPFR's mpfr_cmp returns 0 for equal values, and also for NaN
        // comparisons
        // We need to check for NaN separately
        if lhs.isNaN || rhs.isNaN {
            return false // NaN is never equal to anything, including itself
        }
        return mpfr_cmp(&lhs._storage.value, &rhs._storage.value) == 0
    }
}

// MARK: - Comparable Conformance

extension MPFRFloat: Comparable {
    /// Less-than comparison operator.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side float.
    ///   - rhs: The right-hand side float.
    /// - Returns: `true` if `lhs < rhs`, `false` otherwise. Returns `false` if
    /// either value is NaN.
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `lhs.compare(to: rhs) < 0`.
    public static func < (lhs: MPFRFloat, rhs: MPFRFloat) -> Bool {
        if lhs.isNaN || rhs.isNaN {
            return false // NaN comparisons always return false
        }
        return mpfr_cmp(&lhs._storage.value, &rhs._storage.value) < 0
    }

    /// Less-than-or-equal comparison operator.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side float.
    ///   - rhs: The right-hand side float.
    /// - Returns: `true` if `lhs <= rhs`, `false` otherwise. Returns `false` if
    /// either value is NaN.
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `lhs.compare(to: rhs) <= 0`.
    public static func <= (lhs: MPFRFloat, rhs: MPFRFloat) -> Bool {
        if lhs.isNaN || rhs.isNaN {
            return false // NaN comparisons always return false
        }
        return mpfr_cmp(&lhs._storage.value, &rhs._storage.value) <= 0
    }

    /// Greater-than comparison operator.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side float.
    ///   - rhs: The right-hand side float.
    /// - Returns: `true` if `lhs > rhs`, `false` otherwise. Returns `false` if
    /// either value is NaN.
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `lhs.compare(to: rhs) > 0`.
    public static func > (lhs: MPFRFloat, rhs: MPFRFloat) -> Bool {
        if lhs.isNaN || rhs.isNaN {
            return false // NaN comparisons always return false
        }
        return mpfr_cmp(&lhs._storage.value, &rhs._storage.value) > 0
    }

    /// Greater-than-or-equal comparison operator.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side float.
    ///   - rhs: The right-hand side float.
    /// - Returns: `true` if `lhs >= rhs`, `false` otherwise. Returns `false` if
    /// either value is NaN.
    ///
    /// - Requires: Both floats must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `lhs.compare(to: rhs) >= 0`.
    public static func >= (lhs: MPFRFloat, rhs: MPFRFloat) -> Bool {
        if lhs.isNaN || rhs.isNaN {
            return false // NaN comparisons always return false
        }
        return mpfr_cmp(&lhs._storage.value, &rhs._storage.value) >= 0
    }
}

// MARK: - Rounding Mode (temporary implementation for tests)

/// Rounding modes for MPFR operations, following IEEE 754 semantics.
public enum MPFRRoundingMode {
    /// Round to nearest, with ties to even (roundTiesToEven in IEEE 754).
    /// This is the default and recommended rounding mode.
    case nearest

    /// Round toward zero (roundTowardZero in IEEE 754).
    case towardZero

    /// Round toward positive infinity (roundTowardPositive in IEEE 754).
    case towardPositiveInfinity

    /// Round toward negative infinity (roundTowardNegative in IEEE 754).
    case towardNegativeInfinity

    /// Round away from zero.
    case awayFromZero

    /// Faithful rounding (experimental). Results may not be reproducible.
    /// The result is either the value corresponding to `towardNegativeInfinity`
    /// or `towardPositiveInfinity`.
    case faithful

    /// Convert to MPFR rounding mode constant.
    func toMPFRRoundingMode() -> mpfr_rnd_t {
        switch self {
        case .nearest:
            MPFR_RNDN
        case .towardZero:
            MPFR_RNDZ
        case .towardPositiveInfinity:
            MPFR_RNDU
        case .towardNegativeInfinity:
            MPFR_RNDD
        case .awayFromZero:
            MPFR_RNDA
        case .faithful:
            MPFR_RNDF
        }
    }

    /// Create from MPFR rounding mode constant.
    static func fromMPFRRoundingMode(_ rnd: mpfr_rnd_t) -> MPFRRoundingMode {
        switch rnd {
        case MPFR_RNDN:
            .nearest
        case MPFR_RNDZ:
            .towardZero
        case MPFR_RNDU:
            .towardPositiveInfinity
        case MPFR_RNDD:
            .towardNegativeInfinity
        case MPFR_RNDA:
            .awayFromZero
        case MPFR_RNDF:
            .faithful
        default:
            .nearest // Fallback to nearest
        }
    }
}

// MARK: - Default Precision and Rounding Mode

extension MPFRFloat {
    /// Set the default precision for new `MPFRFloat` instances.
    ///
    /// This affects all new instances created with `init()` that don't specify
    /// a precision. Existing instances are not affected.
    ///
    /// - Parameter precision: The precision in bits. Must be between
    /// MPFR_PREC_MIN
    ///   and MPFR_PREC_MAX.
    ///
    /// - Wraps: `mpfr_set_default_prec`
    ///
    /// - Requires: `precision` must be between MPFR_PREC_MIN and MPFR_PREC_MAX.
    /// - Guarantees: All subsequent calls to `init()` will use this precision.
    public static func setDefaultPrecision(_ precision: Int) {
        let precMin = Int(clinus_get_prec_min())
        let precMax = Int(clinus_get_prec_max())
        precondition(
            precision >= precMin && precision <= precMax,
            "precision must be between MPFR_PREC_MIN and MPFR_PREC_MAX"
        )
        mpfr_set_default_prec(mpfr_prec_t(precision))
    }

    /// Get the default precision for new `MPFRFloat` instances.
    ///
    /// This is the precision that will be used when creating new instances
    /// with `init()` without specifying a precision.
    ///
    /// - Returns: The default precision in bits.
    ///
    /// - Wraps: `mpfr_get_default_prec`
    ///
    /// - Requires: None
    /// - Guarantees: Returns the current default precision value.
    public static var defaultPrecision: Int {
        Int(mpfr_get_default_prec())
    }

    /// Set the default rounding mode for MPFR operations.
    ///
    /// This affects operations that don't explicitly specify a rounding mode.
    /// Existing instances are not affected.
    ///
    /// - Parameter mode: The rounding mode to use as default.
    ///
    /// - Wraps: `mpfr_set_default_rounding_mode`
    ///
    /// - Requires: None
    /// - Guarantees: All subsequent operations without explicit rounding mode
    ///   will use this rounding mode.
    public static func setDefaultRoundingMode(_ mode: MPFRRoundingMode) {
        mpfr_set_default_rounding_mode(mode.toMPFRRoundingMode())
    }

    /// Get the default rounding mode for MPFR operations.
    ///
    /// This is the rounding mode that will be used for operations that don't
    /// explicitly specify a rounding mode.
    ///
    /// - Returns: The default rounding mode.
    ///
    /// - Wraps: `mpfr_get_default_rounding_mode`
    ///
    /// - Requires: None
    /// - Guarantees: Returns the current default rounding mode.
    public static var defaultRoundingMode: MPFRRoundingMode {
        MPFRRoundingMode.fromMPFRRoundingMode(mpfr_get_default_rounding_mode())
    }
}
