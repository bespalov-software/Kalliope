import CKalliope

/// Internal storage class for `GMPFloat` implementing Copy-on-Write (COW)
/// semantics.
///
/// This class holds the actual GMP `mpf_t` structure and manages its lifecycle.
/// It's marked as `final` and `internal` to allow access from extensions in the
/// same module.
final class _GMPFloatStorage {
    /// The underlying GMP floating-point structure.
    ///
    /// This is the actual `mpf_t` value that GMP operates on. It's stored as
    /// a property to allow Swift's ARC to manage the class's lifetime, which
    /// in turn manages the GMP structure's lifecycle.
    var value: mpf_t

    /// Initialize a new storage instance with a zero float at the specified
    /// precision.
    ///
    /// Allocates and initializes a new GMP floating-point structure with value
    /// 0.0
    /// and the specified precision.
    ///
    /// - Parameter precision: The precision in bits. Must be positive. This
    /// determines
    ///   the number of significant bits in the mantissa.
    ///
    /// - Requires: `precision` must be positive.
    /// - Guarantees: After initialization, `value` is a valid, initialized
    ///   `mpf_t` structure with value 0.0 and the specified precision. Memory
    /// will
    ///   be automatically freed when the storage instance is deallocated.
    init(precision: mp_bitcnt_t) {
        value = mpf_t()
        __gmpf_init2(&value, precision)
    }

    /// Initialize a new storage instance by copying another.
    ///
    /// Creates an independent copy of the GMP floating-point value. The new
    /// instance
    /// uses the same precision as the source. This is used for Copy-on-Write
    /// semantics
    /// when a `GMPFloat` needs to be mutated but is shared with other
    /// instances.
    ///
    /// - Parameter other: The storage instance to copy from.
    ///
    /// - Requires: `other` must be properly initialized and contain a valid
    ///   `mpf_t` structure.
    /// - Guarantees: After initialization, `value` is a valid, initialized
    ///   `mpf_t` structure with the same value and precision as `other.value`.
    ///   The new instance is independent - mutations to one won't affect the
    /// other.
    init(copying other: _GMPFloatStorage) {
        let prec = __gmpf_get_prec(&other.value)
        value = mpf_t()
        __gmpf_init2(&value, prec)
        __gmpf_set(&value, &other.value)
    }

    /// Deinitialize and free the GMP floating-point structure.
    ///
    /// Clears the GMP floating-point structure and frees all associated memory.
    /// This is called automatically by Swift's ARC when the storage instance
    /// is deallocated.
    ///
    /// - Requires: `value` must be a valid, initialized `mpf_t` structure.
    /// - Guarantees: After deinitialization, all memory associated with `value`
    ///   is freed. The `value` structure is no longer valid and must not be
    /// used.
    deinit {
        __gmpf_clear(&value)
    }
}

/// An arbitrary-precision floating-point number type wrapping GMP's `mpf_t`.
///
/// `GMPFloat` provides floating-point arithmetic with user-specifiable
/// precision.
/// Precision is specified in bits and can be adjusted at any time.
///
/// - Note: Memory is automatically managed through Swift's ARC. The underlying
/// GMP
///   structure is initialized on creation and cleared on deallocation.
///
/// `GMPFloat` provides value semantics with automatic memory management through
/// Copy-on-Write (COW). Multiple `GMPFloat` instances can share the same
/// underlying
/// storage until one needs to be mutated, at which point a copy is made
/// automatically.
///
/// - Note: This struct uses a private storage class to implement COW semantics,
///   ensuring that value semantics are maintained while minimizing unnecessary
/// copies.
public struct GMPFloat {
    /// The internal storage holding the GMP floating-point structure.
    ///
    /// This is a reference to a `_GMPFloatStorage` instance. Multiple
    /// `GMPFloat`
    /// instances may share the same storage reference until mutation occurs.
    var _storage: _GMPFloatStorage

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
    ///   instance (no other `GMPFloat` instances share it). If a copy was made,
    ///   the value and precision are preserved. If no copy was needed, the
    /// operation
    ///   is O(1).
    mutating func _ensureUnique() {
        if !isKnownUniquelyReferenced(&_storage) {
            _storage = _GMPFloatStorage(copying: _storage)
        }
    }
}
