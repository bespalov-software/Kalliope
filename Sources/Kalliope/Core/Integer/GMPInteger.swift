import CKalliope

/// Internal storage class for `GMPInteger` implementing Copy-on-Write (COW)
/// semantics.
///
/// This class holds the actual GMP `mpz_t` structure and manages its lifecycle.
/// It's marked as `final` and `internal` to allow access from extensions in the
/// same module.
final class _GMPIntegerStorage {
    /// The underlying GMP integer structure.
    ///
    /// This is the actual `mpz_t` value that GMP operates on. It's stored as
    /// a property to allow Swift's ARC to manage the class's lifetime, which
    /// in turn manages the GMP structure's lifecycle.
    var value: mpz_t

    /// Initialize a new storage instance with a zero integer.
    ///
    /// Allocates and initializes a new GMP integer structure with value 0.
    ///
    /// - Requires: None
    /// - Guarantees: After initialization, `value` is a valid, initialized
    ///   `mpz_t` structure with value 0. Memory will be automatically freed
    ///   when the storage instance is deallocated.
    init() {
        value = mpz_t()
        __gmpz_init(&value)
    }

    /// Initialize a new storage instance by copying another.
    ///
    /// Creates an independent copy of the GMP integer. This is used for
    /// Copy-on-Write semantics when a `GMPInteger` needs to be mutated but
    /// is shared with other instances.
    ///
    /// - Parameter other: The storage instance to copy from.
    ///
    /// - Requires: `other` must be properly initialized and contain a valid
    ///   `mpz_t` structure.
    /// - Guarantees: After initialization, `value` is a valid, initialized
    ///   `mpz_t` structure with the same value as `other.value`. The new
    ///   instance is independent - mutations to one won't affect the other.
    init(copying other: _GMPIntegerStorage) {
        value = mpz_t()
        __gmpz_init(&value)
        __gmpz_set(&value, &other.value)
    }

    /// Initialize a new storage instance with preallocated space.
    ///
    /// - Parameter bits: The minimum number of bits to preallocate.
    init(preallocatedBits bits: Int) {
        value = mpz_t()
        __gmpz_init2(&value, mp_bitcnt_t(bits))
    }

    /// Deinitialize and free the GMP integer structure.
    ///
    /// Clears the GMP integer structure and frees all associated memory.
    /// This is called automatically by Swift's ARC when the storage instance
    /// is deallocated.
    ///
    /// - Requires: `value` must be a valid, initialized `mpz_t` structure.
    /// - Guarantees: After deinitialization, all memory associated with `value`
    ///   is freed. The `value` structure is no longer valid and must not be
    /// used.
    deinit {
        __gmpz_clear(&value)
    }
}

/// An arbitrary-precision integer type wrapping GMP's `mpz_t`.
///
/// `GMPInteger` provides value semantics with automatic memory management
/// through
/// Copy-on-Write (COW). Multiple `GMPInteger` instances can share the same
/// underlying
/// storage until one needs to be mutated, at which point a copy is made
/// automatically.
///
/// - Note: This struct uses a private storage class to implement COW semantics,
///   ensuring that value semantics are maintained while minimizing unnecessary
/// copies.
public struct GMPInteger {
    /// The internal storage holding the GMP integer structure.
    ///
    /// This is a reference to a `_GMPIntegerStorage` instance. Multiple
    /// `GMPInteger`
    /// instances may share the same storage reference until mutation occurs.
    var _storage: _GMPIntegerStorage

    /// Ensure this integer has unique storage before mutation.
    ///
    /// This method implements Copy-on-Write semantics. Before mutating the
    /// integer,
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
    ///   instance (no other `GMPInteger` instances share it). If a copy was
    /// made,
    ///   the value is preserved. If no copy was needed, the operation is O(1).
    mutating func _ensureUnique() {
        if !isKnownUniquelyReferenced(&_storage) {
            _storage = _GMPIntegerStorage(copying: _storage)
        }
    }

    // MARK: - Initialization

    /// Initialize a new integer with value zero.
    ///
    /// This initializer allocates space for the integer and sets its value to
    /// 0.
    /// The amount of space allocated is determined automatically by GMP and
    /// will
    /// grow as needed when values are stored.
    ///
    /// - Requires: None
    /// - Guarantees: Returns a valid `GMPInteger` with value 0. The integer is
    ///   properly initialized and ready for use. Memory will be automatically
    ///   freed when the value is deallocated.
    ///
    /// - Note: Wraps GMP function `mpz_init`.
    public init() {
        _storage = _GMPIntegerStorage()
    }

    /// Initialize a new integer with value zero, preallocating space for at
    /// least `bits` bits.
    ///
    /// This initializer is useful when you know the approximate size of values
    /// you'll be storing, as it can avoid repeated reallocations. However, it's
    /// never necessary to call this - GMP will automatically reallocate as
    /// needed.
    ///
    /// - Parameter bits: The minimum number of bits to preallocate. Must be
    /// non-negative.
    ///   Internally converted to `mp_bitcnt_t` for GMP calls.
    ///
    /// - Requires: `bits >= 0`
    /// - Guarantees: Returns a valid `GMPInteger` with value 0 and space for at
    /// least
    ///   `bits` bits. The integer will grow automatically if larger values are
    /// stored.
    ///   Memory will be automatically freed when the value is deallocated.
    ///
    /// - Note: GMP may allocate slightly more space than requested (typically
    /// one
    ///   limb more) to optimize operations. If you need to ensure no
    /// reallocation
    ///   occurs, add the number of bits in `mp_limb_t` to your estimate.
    ///
    /// - Note: Wraps GMP function `mpz_init2`.
    public init(preallocatedBits bits: Int) {
        precondition(bits >= 0, "bits must be non-negative")
        _storage = _GMPIntegerStorage(preallocatedBits: bits)
    }

    /// Create a new integer from a signed integer value.
    ///
    /// - Parameter value: The integer value. Can be positive or negative.
    ///
    /// - Requires: None
    /// - Guarantees: Returns a valid `GMPInteger` with the exact value of
    /// `value`.
    ///
    /// - Note: Wraps GMP function `mpz_init_set_si`.
    public init(_ value: Int) {
        _storage = _GMPIntegerStorage()
        __gmpz_set_si(&_storage.value, value)
    }

    /// Create a new integer from an unsigned integer value.
    ///
    /// This initializer is provided for explicit unsigned semantics. For most
    /// use cases,
    /// `init(_: Int)` is preferred as it follows Swift conventions.
    ///
    /// - Parameter value: The unsigned integer value. Must be non-negative.
    ///
    /// - Requires: None
    /// - Guarantees: Returns a valid `GMPInteger` with the exact value of
    /// `value`.
    ///
    /// - Note: Wraps GMP function `mpz_init_set_ui`.
    public init(_ value: UInt) {
        _storage = _GMPIntegerStorage()
        __gmpz_set_ui(&_storage.value, value)
    }

    /// Create a new integer from a `Double` value, truncating toward zero.
    ///
    /// - Parameter value: The floating-point value. The fractional part is
    /// discarded.
    ///
    /// - Requires: `value` must not be infinite or NaN.
    /// - Guarantees: Returns a valid `GMPInteger` with the integer part of
    /// `value`,
    ///   truncated toward zero. The sign is preserved.
    ///
    /// - Note: Wraps GMP function `mpz_init_set_d`.
    public init(_ value: Double) {
        _storage = _GMPIntegerStorage()
        __gmpz_set_d(&_storage.value, value)
    }

    /// Create a new integer from a string representation.
    ///
    /// - Parameters:
    ///   - string: The string to parse. Must be a valid number in the specified
    /// base.
    ///   - base: The numeric base (radix) for parsing. Must be 0 or in the
    /// range 2-62.
    ///
    /// - Returns: A new `GMPInteger` if parsing succeeds, `nil` otherwise.
    ///
    /// - Requires: `base` must be 0 or in the range 2-62. `string` must not be
    /// empty.
    /// - Guarantees: If parsing succeeds, returns a valid `GMPInteger` with the
    /// parsed value.
    ///   If parsing fails, returns `nil`.
    ///
    /// - Note: Wraps GMP function `mpz_init_set_str`.
    public init?(_ string: String, base: Int = 10) {
        precondition(
            base == 0 || (base >= 2 && base <= 62),
            "base must be 0 or in the range 2-62"
        )
        _storage = _GMPIntegerStorage()
        let result = string.withCString { cString in
            __gmpz_set_str(&_storage.value, cString, Int32(base))
        }
        if result != 0 {
            return nil
        }
    }

    /// Reallocate this integer to hold at least `bits` bits.
    ///
    /// Changes the space allocated for this integer. The current value is
    /// preserved
    /// if it fits in the new size, or set to 0 if it doesn't.
    ///
    /// This function is never necessary - GMP handles reallocation
    /// automatically.
    /// However, it can be useful to:
    /// - Increase space to avoid repeated automatic reallocations
    /// - Decrease space to return memory to the heap
    ///
    /// - Parameter bits: The minimum number of bits to allocate. Must be
    /// non-negative.
    ///   Internally converted to `mp_bitcnt_t` for GMP calls.
    ///
    /// - Requires: `bits >= 0`. The integer must be properly initialized.
    /// - Guarantees: After this call, the integer has space for at least `bits`
    /// bits.
    ///   If the current value fits, it is preserved. Otherwise, the value is
    /// set to 0.
    ///
    /// - Note: Wraps GMP function `mpz_realloc2`.
    public mutating func reallocate(bits: Int) {
        precondition(bits >= 0, "bits must be non-negative")
        _ensureUnique()
        __gmpz_realloc2(&_storage.value, mp_bitcnt_t(bits))
    }

    // MARK: - Assignment

    /// Set this integer's value from another `GMPInteger`.
    ///
    /// - Parameter other: The integer whose value will be copied.
    ///
    /// - Requires: Both integers must be properly initialized. `other` must be
    /// a valid `GMPInteger`.
    /// - Guarantees: After this call, `self` has the same value as `other`. The
    /// operation
    ///   is safe even if `self` and `other` are the same variable.
    ///
    /// - Note: Wraps GMP function `mpz_set`.
    public mutating func set(_ other: GMPInteger) {
        _ensureUnique()
        __gmpz_set(&_storage.value, &other._storage.value)
    }

    /// Set this integer's value from a signed integer.
    ///
    /// - Parameter value: The integer value to assign. Can be positive or
    /// negative.
    ///
    /// - Requires: The integer must be properly initialized.
    /// - Guarantees: After this call, `self` has the exact value of `value`.
    /// The value
    ///   is preserved exactly, regardless of sign.
    ///
    /// - Note: Wraps GMP function `mpz_set_si`.
    public mutating func set(_ value: Int) {
        _ensureUnique()
        __gmpz_set_si(&_storage.value, value)
    }

    /// Set this integer's value from an unsigned integer.
    ///
    /// This method is provided for explicit unsigned semantics. For most use
    /// cases,
    /// `set(_: Int)` is preferred as it follows Swift conventions.
    ///
    /// - Parameter value: The unsigned integer value to assign. Must be
    /// non-negative.
    ///
    /// - Requires: The integer must be properly initialized.
    /// - Guarantees: After this call, `self` has the exact value of `value`.
    ///
    /// - Note: Wraps GMP function `mpz_set_ui`.
    public mutating func set(_ value: UInt) {
        _ensureUnique()
        __gmpz_set_ui(&_storage.value, value)
    }

    /// Set this integer's value from a `Double`, truncating toward zero.
    ///
    /// The fractional part of the double is discarded. The result is the same
    /// as
    /// converting to integer by truncation (rounding toward zero).
    ///
    /// - Parameter value: The floating-point value to assign. The fractional
    /// part is discarded.
    ///
    /// - Requires: The integer must be properly initialized. If `value` is
    /// infinite or NaN,
    ///   the behavior is undefined.
    /// - Guarantees: After this call, `self` has the integer part of `value`,
    /// truncated
    ///   toward zero. The sign is preserved.
    ///
    /// - Note: Wraps GMP function `mpz_set_d`.
    public mutating func set(_ value: Double) {
        _ensureUnique()
        __gmpz_set_d(&_storage.value, value)
    }

    // Note: The following methods require GMPRational and GMPFloat to be
    // implemented.
    // They are included here for API completeness but will need to be
    // uncommented
    // once those types are available.

    /*
     /// Set this integer's value from a `GMPRational`, truncating toward zero.
     ///
     /// The fractional part of the rational is discarded. The result is the integer
     /// part of the rational number.
     ///
     /// - Parameter value: The rational number to assign. The fractional part is discarded.
     ///
     /// - Requires: The integer must be properly initialized. `value` must be a valid `GMPRational`.
     /// - Guarantees: After this call, `self` has the integer part of `value`, truncated
     ///   toward zero. The sign is preserved.
     ///
     /// - Note: Wraps GMP function `mpz_set_q`.
     public mutating func set(_ value: GMPRational) {
         _ensureUnique()
         __gmpz_set_q(&_storage.value, &value._storage.value)
     }

     /// Set this integer's value from a `GMPFloat`, truncating toward zero.
     ///
     /// The fractional part of the float is discarded. The result is the integer
     /// part of the floating-point number.
     ///
     /// - Parameter value: The floating-point number to assign. The fractional part is discarded.
     ///
     /// - Requires: The integer must be properly initialized. `value` must be a valid `GMPFloat`.
     /// - Guarantees: After this call, `self` has the integer part of `value`, truncated
     ///   toward zero. The sign is preserved.
     ///
     /// - Note: Wraps GMP function `mpz_set_f`.
     public mutating func set(_ value: GMPFloat) {
         _ensureUnique()
         __gmpz_set_f(&_storage.value, &value._storage.value)
     }

     /// Create a new integer from a `GMPRational` value, truncating toward zero.
     ///
     /// - Parameter value: The rational number. The fractional part is discarded.
     ///
     /// - Requires: `value` must be a valid `GMPRational`.
     /// - Guarantees: Returns a valid `GMPInteger` with the integer part of `value`,
     ///   truncated toward zero. The sign is preserved.
     ///
     /// - Note: Wraps GMP functions `mpz_init` and `mpz_set_q`.
     public init(_ value: GMPRational) {
         _storage = _GMPIntegerStorage()
         __gmpz_set_q(&_storage.value, &value._storage.value)
     }

     /// Create a new integer from a `GMPFloat` value, truncating toward zero.
     ///
     /// - Parameter value: The floating-point number. The fractional part is discarded.
     ///
     /// - Requires: `value` must be a valid `GMPFloat`.
     /// - Guarantees: Returns a valid `GMPInteger` with the integer part of `value`,
     ///   truncated toward zero. The sign is preserved.
     ///
     /// - Note: Wraps GMP functions `mpz_init` and `mpz_set_f`.
     public init(_ value: GMPFloat) {
         _storage = _GMPIntegerStorage()
         __gmpz_set_f(&_storage.value, &value._storage.value)
     }
     */

    /// Set this integer's value from a string representation.
    ///
    /// Parses a string in the specified base and sets the integer's value.
    /// White space
    /// in the string is ignored. For base 0, the base is automatically detected
    /// from
    /// the string prefix: `0x` or `0X` for hexadecimal, `0b` or `0B` for
    /// binary,
    /// `0` for octal, otherwise decimal.
    ///
    /// - Parameters:
    ///   - string: The string to parse. Must be a valid number in the specified
    /// base.
    ///     White space is allowed and ignored.
    ///   - base: The numeric base (radix) for parsing. Must be in the range
    /// 2-62, or 0
    ///     for auto-detection. For bases 2-36, case is ignored. For bases
    /// 37-62,
    ///     upper-case letters represent 10-35, lower-case letters represent
    /// 36-61.
    ///
    /// - Returns: `true` if the entire string was successfully parsed as a
    /// valid number,
    ///   `false` otherwise.
    ///
    /// - Requires: The integer must be properly initialized. `base` must be 0
    /// or in the
    ///   range 2-62. `string` must not be empty (after removing white space).
    /// - Guarantees: If the function returns `true`, `self` contains the parsed
    /// integer value.
    ///   If it returns `false`, `self` is unchanged. The operation is safe even
    /// if parsing fails.
    ///
    /// - Note: Wraps GMP function `mpz_set_str`.
    public mutating func set(_ string: String, base: Int = 10) -> Bool {
        precondition(
            base == 0 || (base >= 2 && base <= 62),
            "base must be 0 or in the range 2-62"
        )
        _ensureUnique()
        let result = string.withCString { cString in
            __gmpz_set_str(&_storage.value, cString, Int32(base))
        }
        return result == 0
    }

    /// Swap the values of this integer and another integer efficiently.
    ///
    /// This operation is very fast as it only swaps pointers to the underlying
    /// data,
    /// not the data itself. It's safe to swap an integer with itself (no-op).
    ///
    /// - Parameter other: The integer to swap with. Modified in place.
    ///
    /// - Requires: Both integers must be properly initialized.
    /// - Guarantees: After this call, `self` has the value that `other` had,
    /// and
    ///   `other` has the value that `self` had. The operation is O(1) and very
    /// efficient.
    ///
    /// - Note: Wraps GMP function `mpz_swap`.
    public mutating func swap(_ other: inout GMPInteger) {
        _ensureUnique()
        other._ensureUnique()
        __gmpz_swap(&_storage.value, &other._storage.value)
    }

    // MARK: - Conversion

    /// Convert this integer to an unsigned integer.
    ///
    /// If the value is too large to fit in a `UInt`, only the least significant
    /// bits that fit are returned. The sign of the value is ignored - only the
    /// absolute value is used.
    ///
    /// - Returns: The value as a `UInt`. If the value is too large, returns
    /// only
    ///   the least significant bits. If the value is negative, returns the
    /// absolute
    ///   value truncated to fit.
    ///
    /// - Requires: The integer must be properly initialized.
    /// - Guarantees: Always returns a valid `UInt`. The result represents the
    ///   least significant bits of the absolute value if the integer is too
    /// large.
    ///   Use `fitsInUInt()` to check if the conversion is exact.
    ///
    /// - Note: Wraps GMP function `mpz_get_ui`.
    public func toUInt() -> UInt {
        __gmpz_get_ui(&_storage.value)
    }

    /// Convert this integer to a signed integer.
    ///
    /// If the value fits in an `Int`, it is returned exactly. Otherwise, the
    /// least significant part is returned with the same sign as the original
    /// value.
    ///
    /// - Returns: The value as an `Int` if it fits, otherwise the least
    /// significant
    ///   part with the same sign.
    ///
    /// - Requires: The integer must be properly initialized.
    /// - Guarantees: Always returns a valid `Int`. If the value fits, it is
    /// returned
    ///   exactly. Otherwise, returns the least significant bits with sign
    /// preserved.
    ///   Use `fitsInInt()` to check if the conversion is exact.
    ///
    /// - Note: Wraps GMP function `mpz_get_si`.
    public func toInt() -> Int {
        Int(__gmpz_get_si(&_storage.value))
    }

    /// Convert this integer to a `Double`, truncating if necessary.
    ///
    /// The conversion truncates toward zero (rounds toward zero). If the value
    /// is too large for a `Double`, the result is system-dependent (typically
    /// infinity, and a hardware overflow trap may occur).
    ///
    /// - Returns: The value as a `Double`, truncated toward zero.
    ///
    /// - Requires: The integer must be properly initialized.
    /// - Guarantees: Returns a `Double` representing the integer value,
    /// truncated
    ///   toward zero. If the value is too large, the result is
    /// system-dependent.
    ///
    /// - Note: Wraps GMP function `mpz_get_d`.
    public func toDouble() -> Double {
        __gmpz_get_d(&_storage.value)
    }

    /// Convert this integer to a `Double` with separate exponent.
    ///
    /// Similar to the standard C `frexp` function. Returns the value as a
    /// mantissa
    /// in the range [0.5, 1) and a separate exponent such that `mantissa *
    /// 2^exponent`
    /// equals the (truncated) integer value.
    ///
    /// - Returns: A tuple `(mantissa: Double, exponent: Int)` where the
    /// mantissa is
    ///   in the range [0.5, 1) and `mantissa * 2^exponent` equals the integer
    /// value.
    ///   If the value is zero, returns `(0.0, 0)`.
    ///
    /// - Requires: The integer must be properly initialized.
    /// - Guarantees: The mantissa is always in the range [0.5, 1) (or 0.0 for
    /// zero),
    ///   and `mantissa * 2^exponent` equals the truncated integer value.
    ///
    /// - Note: Wraps GMP function `mpz_get_d_2exp`.
    public func toDouble2Exp() -> (mantissa: Double, exponent: Int) {
        var exp: CLong = 0
        let mantissa = __gmpz_get_d_2exp(&exp, &_storage.value)
        return (mantissa: mantissa, exponent: Int(exp))
    }

    /// Convert this integer to a string representation in the given base.
    ///
    /// Converts the integer to a string of digits in the specified base. For
    /// bases
    /// 2-36, digits and lower-case letters are used. For bases 37-62, digits,
    /// upper-case letters, and lower-case letters are used (in that
    /// significance order).
    ///
    /// - Parameter base: The numeric base (radix) for conversion. Must be in
    /// the
    ///   range 2-62, or from -2 to -36. For negative bases, upper-case letters
    /// are used.
    ///   Defaults to 10 (decimal).
    ///
    /// - Returns: A string representation of the integer in the specified base.
    ///   Includes a minus sign if the value is negative.
    ///
    /// - Requires: The integer must be properly initialized. `base` must be in
    /// the
    ///   range 2-62 or -36 to -2.
    /// - Guarantees: Returns a valid string representation. The string can be
    /// parsed
    ///   back using `init(_:base:)` with the same base to recover the original
    /// value.
    ///
    /// - Note: Wraps GMP function `mpz_get_str`.
    public func toString(base: Int = 10) -> String {
        precondition(
            base >= 2 && base <= 62 || base >= -36 && base <= -2,
            "base must be in range 2-62 or -36 to -2"
        )
        let size = __gmpz_sizeinbase(
            &_storage.value,
            Int32(base >= 0 ? base : -base)
        )
        let buffer = UnsafeMutablePointer<CChar>
            .allocate(capacity: size + 2) // +2 for sign and null terminator
        defer { buffer.deallocate() }
        __gmpz_get_str(buffer, Int32(base), &_storage.value)
        return String(cString: buffer)
    }

    /// Check if this integer's value fits exactly in a `UInt`.
    ///
    /// - Returns: `true` if the value is non-negative and fits in a `UInt`,
    /// `false` otherwise.
    ///
    /// - Requires: The integer must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `toUInt()` would return the
    /// exact value.
    ///
    /// - Note: Wraps GMP function `mpz_fits_ulong_p` (or platform-specific fits
    /// function).
    public func fitsInUInt() -> Bool {
        __gmpz_fits_ulong_p(&_storage.value) != 0
    }

    /// Check if this integer's value fits exactly in an `Int`.
    ///
    /// - Returns: `true` if the value fits in an `Int`, `false` otherwise.
    ///
    /// - Requires: The integer must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `toInt()` would return the
    /// exact value.
    ///
    /// - Note: Wraps GMP function `mpz_fits_slong_p` (or platform-specific fits
    /// function).
    public func fitsInInt() -> Bool {
        __gmpz_fits_slong_p(&_storage.value) != 0
    }

    /// Check if this integer's value fits exactly in a `UInt64`.
    ///
    /// - Returns: `true` if the value is non-negative and fits in a `UInt64`,
    /// `false` otherwise.
    ///
    /// - Requires: The integer must be properly initialized.
    /// - Guarantees: Returns `true` if and only if the value can be represented
    /// exactly as a `UInt64`.
    ///
    /// - Note: Wraps GMP function `mpz_fits_ulong_p` (when `UInt64` matches
    /// `unsigned long`) or uses custom check.
    public func fitsInUInt64() -> Bool {
        // On 64-bit platforms, UInt64 == unsigned long, so we can use the same
        // function
        #if arch(x86_64) || arch(arm64) || arch(arm64_32)
            return __gmpz_fits_ulong_p(&_storage.value) != 0
        #else
            // On 32-bit platforms, need custom check
            return !isNegative && compare(to: GMPInteger(UInt64.max)) <= 0
        #endif
    }

    /// Check if this integer's value fits exactly in an `Int64`.
    ///
    /// - Returns: `true` if the value fits in an `Int64`, `false` otherwise.
    ///
    /// - Requires: The integer must be properly initialized.
    /// - Guarantees: Returns `true` if and only if the value can be represented
    /// exactly as an `Int64`.
    ///
    /// - Note: Wraps GMP function `mpz_fits_slong_p` (when `Int64` matches
    /// `signed long`) or uses custom check.
    public func fitsInInt64() -> Bool {
        // On 64-bit platforms, Int64 == signed long, so we can use the same
        // function
        #if arch(x86_64) || arch(arm64) || arch(arm64_32)
            return __gmpz_fits_slong_p(&_storage.value) != 0
        #else
            // On 32-bit platforms, need custom check
            let min = GMPInteger(Int64.min)
            let max = GMPInteger(Int64.max)
            return compare(to: min) >= 0 && compare(to: max) <= 0
        #endif
    }

    /// Check if this integer's value fits exactly in a `UInt32`.
    ///
    /// - Returns: `true` if the value is non-negative and fits in a `UInt32`,
    /// `false` otherwise.
    ///
    /// - Requires: The integer must be properly initialized.
    /// - Guarantees: Returns `true` if and only if the value can be represented
    /// exactly as a `UInt32`.
    ///
    /// - Note: Wraps GMP function `mpz_fits_uint_p`.
    public func fitsInUInt32() -> Bool {
        __gmpz_fits_uint_p(&_storage.value) != 0
    }

    /// Check if this integer's value fits exactly in an `Int32`.
    ///
    /// - Returns: `true` if the value fits in an `Int32`, `false` otherwise.
    ///
    /// - Requires: The integer must be properly initialized.
    /// - Guarantees: Returns `true` if and only if the value can be represented
    /// exactly as an `Int32`.
    ///
    /// - Note: Wraps GMP function `mpz_fits_sint_p`.
    public func fitsInInt32() -> Bool {
        __gmpz_fits_sint_p(&_storage.value) != 0
    }

    /// Check if this integer's value fits exactly in a `UInt16`.
    ///
    /// - Returns: `true` if the value is non-negative and fits in a `UInt16`,
    /// `false` otherwise.
    ///
    /// - Requires: The integer must be properly initialized.
    /// - Guarantees: Returns `true` if and only if the value can be represented
    /// exactly as a `UInt16`.
    ///
    /// - Note: Wraps GMP function `mpz_fits_ushort_p`.
    public func fitsInUInt16() -> Bool {
        __gmpz_fits_ushort_p(&_storage.value) != 0
    }

    /// Check if this integer's value fits exactly in an `Int16`.
    ///
    /// - Returns: `true` if the value fits in an `Int16`, `false` otherwise.
    ///
    /// - Requires: The integer must be properly initialized.
    /// - Guarantees: Returns `true` if and only if the value can be represented
    /// exactly as an `Int16`.
    ///
    /// - Note: Wraps GMP function `mpz_fits_sshort_p`.
    public func fitsInInt16() -> Bool {
        __gmpz_fits_sshort_p(&_storage.value) != 0
    }

    /// Get the number of bits required to represent the absolute value of this
    /// integer.
    ///
    /// Returns the minimum number of bits needed to represent the absolute
    /// value.
    /// Zero returns 0. Negative values return the bit count of their absolute
    /// value.
    ///
    /// - Returns: The number of bits required, or 0 if the value is zero.
    ///
    /// - Requires: The integer must be properly initialized.
    /// - Guarantees: Returns a non-negative integer. The result is 0 if and
    /// only if
    ///   the value is zero. Otherwise, it's the minimum number of bits needed.
    ///
    /// - Note: Wraps GMP function `mpz_sizeinbase` with base 2.
    public var bitCount: Int {
        if isZero {
            return 0
        }
        return Int(__gmpz_sizeinbase(&_storage.value, 2))
    }

    /// Get the number of limbs (digits) used to represent this integer.
    ///
    /// A limb is the fundamental unit used by GMP to store integers. The number
    /// of
    /// limbs indicates the size of the internal representation.
    ///
    /// - Returns: The number of limbs used. Zero returns 0.
    ///
    /// - Requires: The integer must be properly initialized.
    /// - Guarantees: Returns a non-negative integer. The result is 0 if and
    /// only if
    ///   the value is zero.
    ///
    /// - Note: Wraps GMP function `mpz_size`.
    public var limbCount: Int {
        Int(__gmpz_size(&_storage.value))
    }

    /// Get the number of characters needed to represent this integer in the
    /// given base.
    ///
    /// This includes space for a possible minus sign and the null terminator.
    /// The result is suitable for allocating buffer space for string
    /// conversion.
    ///
    /// - Parameter base: The numeric base (radix). Must be in the range 2-62 or
    /// -36 to -2.
    ///
    /// - Returns: The number of characters needed, including sign and null
    /// terminator.
    ///
    /// - Requires: The integer must be properly initialized. `base` must be in
    /// the
    ///   range 2-62 or -36 to -2.
    /// - Guarantees: Returns a positive integer. The result is at least 2 (for
    /// "0\0").
    ///   The actual string from `toString(base:)` will have length
    /// `sizeInBase(base) - 1`.
    ///
    /// - Note: Wraps GMP function `mpz_sizeinbase`.
    public func sizeInBase(_ base: Int) -> Int {
        precondition(
            base >= 2 && base <= 62 || base >= -36 && base <= -2,
            "base must be in range 2-62 or -36 to -2"
        )
        return Int(__gmpz_sizeinbase(
            &_storage.value,
            Int32(base >= 0 ? base : -base)
        ))
    }

    /// Check if this integer is zero.
    ///
    /// - Returns: `true` if `self == 0`, `false` otherwise.
    ///
    /// - Requires: This integer must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `self == 0`.
    public var isZero: Bool {
        __gmpz_cmp_ui(&_storage.value, 0) == 0
    }

    // MARK: - Comparison

    /// Compare this integer with another, returning a comparison result.
    ///
    /// - Parameter other: The integer to compare with.
    /// - Returns: -1 if `self < other`, 0 if `self == other`, 1 if `self >
    /// other`.
    ///
    /// - Requires: Both integers must be properly initialized.
    /// - Guarantees: Returns -1, 0, or 1. Returns 0 if and only if `self ==
    /// other`.
    ///
    /// - Note: Wraps GMP function `mpz_cmp`.
    public func compare(to other: GMPInteger) -> Int {
        Int(__gmpz_cmp(&_storage.value, &other._storage.value))
    }

    /// Compare this integer with a `Double` value.
    ///
    /// The integer is converted to a `Double` for comparison. If the integer is
    /// too
    /// large to represent exactly as a `Double`, the comparison may be
    /// approximate.
    ///
    /// - Parameter value: The `Double` value to compare with.
    /// - Returns: -1 if `self < value`, 0 if `self == value`, 1 if `self >
    /// value`.
    ///
    /// - Requires: This integer must be properly initialized. If `value` is
    /// infinite or NaN,
    ///   the behavior is undefined.
    /// - Guarantees: Returns -1, 0, or 1. The comparison uses the integer's
    /// `Double` representation.
    ///
    /// - Note: Wraps GMP function `mpz_cmp_d`.
    public func compare(to value: Double) -> Int {
        Int(__gmpz_cmp_d(&_storage.value, value))
    }

    /// Compare this integer with an `Int` value.
    ///
    /// - Parameter value: The `Int` value to compare with.
    /// - Returns: -1 if `self < value`, 0 if `self == value`, 1 if `self >
    /// value`.
    ///
    /// - Requires: This integer must be properly initialized.
    /// - Guarantees: Returns -1, 0, or 1. Returns 0 if and only if `self ==
    /// value`.
    ///
    /// - Note: Wraps GMP function `mpz_cmp_si`.
    public func compare(to value: Int) -> Int {
        Int(__gmpz_cmp_si(&_storage.value, CLong(value)))
    }

    /// Compare the absolute values of this integer and another.
    ///
    /// Compares `|self|` with `|other|`, ignoring the sign.
    ///
    /// - Parameter other: The integer to compare with.
    /// - Returns: -1 if `|self| < |other|`, 0 if `|self| == |other|`, 1 if
    /// `|self| > |other|`.
    ///
    /// - Requires: Both integers must be properly initialized.
    /// - Guarantees: Returns -1, 0, or 1. Returns 0 if and only if `|self| ==
    /// |other|`.
    ///
    /// - Note: Wraps GMP function `mpz_cmpabs`.
    public func compareAbsoluteValue(to other: GMPInteger) -> Int {
        Int(__gmpz_cmpabs(&_storage.value, &other._storage.value))
    }

    /// Compare the absolute value of this integer with a `Double` value.
    ///
    /// - Parameter value: The `Double` value (absolute value used).
    /// - Returns: -1 if `|self| < |value|`, 0 if `|self| == |value|`, 1 if
    /// `|self| > |value|`.
    ///
    /// - Requires: This integer must be properly initialized.
    /// - Guarantees: Returns -1, 0, or 1.
    ///
    /// - Note: Wraps GMP function `mpz_cmpabs_d`.
    public func compareAbsoluteValue(to value: Double) -> Int {
        Int(__gmpz_cmpabs_d(&_storage.value, value))
    }

    /// Compare the absolute value of this integer with an `Int` value.
    ///
    /// - Parameter value: The `Int` value (absolute value used).
    /// - Returns: -1 if `|self| < |value|`, 0 if `|self| == |value|`, 1 if
    /// `|self| > |value|`.
    ///
    /// - Requires: This integer must be properly initialized.
    /// - Guarantees: Returns -1, 0, or 1.
    ///
    /// - Note: Wraps GMP function `mpz_cmpabs_ui`.
    public func compareAbsoluteValue(to value: Int) -> Int {
        Int(__gmpz_cmpabs_ui(&_storage.value, CUnsignedLong(abs(value))))
    }

    /// Get the sign of this integer.
    ///
    /// - Returns: -1 if negative, 0 if zero, 1 if positive.
    ///
    /// - Requires: This integer must be properly initialized.
    /// - Guarantees: Returns -1, 0, or 1. Returns 0 if and only if `self == 0`.
    ///
    /// - Note: Wraps GMP macro `mpz_sgn`.
    public var sign: Int {
        let cmp = __gmpz_cmp_ui(&_storage.value, 0)
        if cmp < 0 {
            return -1
        } else if cmp > 0 {
            return 1
        } else {
            return 0
        }
    }

    /// Check if this integer is negative.
    ///
    /// - Returns: `true` if `self < 0`, `false` otherwise.
    ///
    /// - Requires: This integer must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `self < 0`.
    public var isNegative: Bool {
        __gmpz_cmp_ui(&_storage.value, 0) < 0
    }

    /// Check if this integer is positive.
    ///
    /// - Returns: `true` if `self > 0`, `false` otherwise.
    ///
    /// - Requires: This integer must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `self > 0`.
    public var isPositive: Bool {
        __gmpz_cmp_ui(&_storage.value, 0) > 0
    }
}

// MARK: - Equatable Conformance

extension GMPInteger: Equatable {
    public static func == (lhs: GMPInteger, rhs: GMPInteger) -> Bool {
        __gmpz_cmp(&lhs._storage.value, &rhs._storage.value) == 0
    }
}

// MARK: - Comparable Conformance

/// Comparison operations for `GMPInteger`.
///
/// `GMPInteger` conforms to `Comparable`, enabling use in sorting, sets, and
/// other
/// operations that require ordering.
extension GMPInteger: Comparable {
    /// Less-than comparison operator.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side integer.
    ///   - rhs: The right-hand side integer.
    /// - Returns: `true` if `lhs < rhs`, `false` otherwise.
    ///
    /// - Requires: Both integers must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `lhs.compare(to: rhs) < 0`.
    public static func < (lhs: GMPInteger, rhs: GMPInteger) -> Bool {
        __gmpz_cmp(&lhs._storage.value, &rhs._storage.value) < 0
    }

    /// Less-than-or-equal comparison operator.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side integer.
    ///   - rhs: The right-hand side integer.
    /// - Returns: `true` if `lhs <= rhs`, `false` otherwise.
    ///
    /// - Requires: Both integers must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `lhs.compare(to: rhs) <= 0`.
    public static func <= (lhs: GMPInteger, rhs: GMPInteger) -> Bool {
        __gmpz_cmp(&lhs._storage.value, &rhs._storage.value) <= 0
    }

    /// Greater-than comparison operator.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side integer.
    ///   - rhs: The right-hand side integer.
    /// - Returns: `true` if `lhs > rhs`, `false` otherwise.
    ///
    /// - Requires: Both integers must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `lhs.compare(to: rhs) > 0`.
    public static func > (lhs: GMPInteger, rhs: GMPInteger) -> Bool {
        __gmpz_cmp(&lhs._storage.value, &rhs._storage.value) > 0
    }

    /// Greater-than-or-equal comparison operator.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side integer.
    ///   - rhs: The right-hand side integer.
    /// - Returns: `true` if `lhs >= rhs`, `false` otherwise.
    ///
    /// - Requires: Both integers must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `lhs.compare(to: rhs) >= 0`.
    public static func >= (lhs: GMPInteger, rhs: GMPInteger) -> Bool {
        __gmpz_cmp(&lhs._storage.value, &rhs._storage.value) >= 0
    }
}
