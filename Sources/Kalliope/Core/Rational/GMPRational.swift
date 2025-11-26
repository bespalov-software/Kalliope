import CKalliope

/// Internal storage class for `GMPRational` implementing Copy-on-Write (COW)
/// semantics.
///
/// This class holds the actual GMP `mpq_t` structure and manages its lifecycle.
/// It's marked as `final` and `internal` to allow access from extensions in the
/// same module.
final class _GMPRationalStorage {
    /// The underlying GMP rational structure.
    ///
    /// This is the actual `mpq_t` value that GMP operates on. It's stored as
    /// a property to allow Swift's ARC to manage the class's lifetime, which
    /// in turn manages the GMP structure's lifecycle.
    var value: mpq_t

    /// Initialize a new storage instance with a zero rational (0/1).
    ///
    /// Allocates and initializes a new GMP rational structure with value 0/1.
    ///
    /// - Requires: None
    /// - Guarantees: After initialization, `value` is a valid, initialized
    ///   `mpq_t` structure with value 0/1. Memory will be automatically freed
    ///   when the storage instance is deallocated.
    init() {
        value = mpq_t()
        __gmpq_init(&value)
    }

    /// Initialize a new storage instance by copying another.
    ///
    /// Creates an independent copy of the GMP rational. This is used for
    /// Copy-on-Write semantics when a `GMPRational` needs to be mutated but
    /// is shared with other instances.
    ///
    /// - Parameter other: The storage instance to copy from.
    ///
    /// - Requires: `other` must be properly initialized and contain a valid
    ///   `mpq_t` structure.
    /// - Guarantees: After initialization, `value` is a valid, initialized
    ///   `mpq_t` structure with the same value as `other.value`. The new
    ///   instance is independent - mutations to one won't affect the other.
    init(copying other: _GMPRationalStorage) {
        value = mpq_t()
        __gmpq_init(&value)
        __gmpq_set(&value, &other.value)
    }

    /// Deinitialize and free the GMP rational structure.
    ///
    /// Clears the GMP rational structure and frees all associated memory.
    /// This is called automatically by Swift's ARC when the storage instance
    /// is deallocated.
    ///
    /// - Requires: `value` must be a valid, initialized `mpq_t` structure.
    /// - Guarantees: After deinitialization, all memory associated with `value`
    ///   is freed. The `value` structure is no longer valid and must not be
    /// used.
    deinit {
        __gmpq_clear(&value)
    }
}

/// An arbitrary-precision rational number type wrapping GMP's `mpq_t`.
///
/// `GMPRational` represents rational numbers as fractions of two `GMPInteger`
/// values
/// (numerator and denominator). The denominator is always positive, and the
/// fraction
/// is kept in canonical form (reduced to lowest terms).
///
/// - Note: Memory is automatically managed through Swift's ARC. The underlying
/// GMP
///   structure is initialized on creation and cleared on deallocation.
///
/// `GMPRational` provides value semantics with automatic memory management
/// through
/// Copy-on-Write (COW). Multiple `GMPRational` instances can share the same
/// underlying
/// storage until one needs to be mutated, at which point a copy is made
/// automatically.
///
/// - Note: This struct uses a private storage class to implement COW semantics,
///   ensuring that value semantics are maintained while minimizing unnecessary
/// copies.
public struct GMPRational {
    /// The internal storage holding the GMP rational structure.
    ///
    /// This is a reference to a `_GMPRationalStorage` instance. Multiple
    /// `GMPRational`
    /// instances may share the same storage reference until mutation occurs.
    var _storage: _GMPRationalStorage

    /// Ensure this rational has unique storage before mutation.
    ///
    /// This method implements Copy-on-Write semantics. Before mutating the
    /// rational,
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
    ///   instance (no other `GMPRational` instances share it). If a copy was
    /// made,
    ///   the value is preserved. If no copy was needed, the operation is O(1).
    mutating func _ensureUnique() {
        if !isKnownUniquelyReferenced(&_storage) {
            _storage = _GMPRationalStorage(copying: _storage)
        }
    }

    // MARK: - Initialization

    /// Initialize a new rational number with value 0/1.
    ///
    /// - Requires: None
    /// - Guarantees: Returns a valid `GMPRational` with value 0/1. The rational
    /// is
    ///   properly initialized and ready for use. Memory will be automatically
    /// freed
    ///   when the value is deallocated.
    ///
    /// - Note: Wraps `mpq_init`.
    public init() {
        _storage = _GMPRationalStorage()
    }
}
