import CKalliope

/// Internal storage class for `GMPRandomState` implementing Copy-on-Write (COW)
/// semantics.
///
/// This class holds the actual GMP `gmp_randstate_t` structure and manages its
/// lifecycle.
/// It's marked as `final` and `internal` to ensure it's only used internally by
/// the `GMPRandomState` struct, which provides value semantics through COW.
///
/// - Note: Unlike the other GMP types, `GMPRandomState` typically doesn't need
///   `_ensureUnique()` because random state mutations are usually intentional
///   (advancing the state), and copying a random state creates an independent
///   state that will produce the same sequence from that point forward.
final class _GMPRandomStateStorage {
    /// The underlying GMP random state structure.
    ///
    /// This is the actual `gmp_randstate_t` value that GMP operates on. It's
    /// stored as
    /// a property to allow Swift's ARC to manage the class's lifetime, which
    /// in turn manages the GMP structure's lifecycle.
    var value: gmp_randstate_t

    /// The last seed that was set.
    ///
    /// GMP doesn't provide a way to retrieve the seed from a random state, so
    /// we
    /// store it separately. This allows the `seed` getter to return the seed
    /// value.
    /// For default initialization, this will be `nil` since the seed is
    /// system-generated.
    var lastSeed: GMPInteger?

    /// Initialize a new storage instance with the default random number
    /// generator algorithm.
    ///
    /// Allocates and initializes a new GMP random state structure with the
    /// default
    /// algorithm. The initial seed is based on system entropy.
    ///
    /// - Requires: None
    /// - Guarantees: After initialization, `value` is a valid, initialized
    ///   `gmp_randstate_t` structure with the default algorithm and a
    /// system-generated
    ///   seed. Memory will be automatically freed when the storage instance is
    /// deallocated.
    init() {
        value = gmp_randstate_t()
        __gmp_randinit_default(&value)
        // Default initialization uses system entropy, so we don't know the seed
        lastSeed = nil
    }

    /// Initialize a new storage instance by copying another.
    ///
    /// Creates an independent copy of the GMP random state. Both the original
    /// and
    /// the copy will produce the same sequence of random numbers from this
    /// point
    /// forward. This is used for Copy-on-Write semantics when a
    /// `GMPRandomState`
    /// needs to be mutated but is shared with other instances.
    ///
    /// - Parameter other: The storage instance to copy from.
    ///
    /// - Requires: `other` must be properly initialized and contain a valid
    ///   `gmp_randstate_t` structure.
    /// - Guarantees: After initialization, `value` is a valid, initialized
    ///   `gmp_randstate_t` structure that is an independent copy of
    /// `other.value`.
    ///   Both states will produce identical sequences of random numbers from
    /// this
    ///   point forward. The new instance is independent - mutations to one
    /// won't
    ///   affect the other.
    init(copying other: _GMPRandomStateStorage) {
        value = gmp_randstate_t()
        __gmp_randinit_set(&value, &other.value)
        // Copy the seed reference (GMPInteger has value semantics, so this is
        // safe)
        lastSeed = other.lastSeed
    }

    /// Deinitialize and free the GMP random state structure.
    ///
    /// Clears the GMP random state structure and frees all associated memory.
    /// This is called automatically by Swift's ARC when the storage instance
    /// is deallocated.
    ///
    /// - Requires: `value` must be a valid, initialized `gmp_randstate_t`
    /// structure.
    /// - Guarantees: After deinitialization, all memory associated with `value`
    ///   is freed. The `value` structure is no longer valid and must not be
    /// used.
    deinit {
        __gmp_randclear(&value)
    }
}

/// A random number generator state wrapping GMP's `gmp_randstate_t`.
///
/// `GMPRandomState` provides thread-safe, reproducible random number generation
/// for use with `GMPInteger`, `GMPRational`, and `GMPFloat` random number
/// functions.
/// Each instance maintains its own independent random state.
///
/// - Warning: **Not Cryptographically Secure**: This random number generator
///   uses GMP's pseudorandom number generators (PRNGs), which are **not**
///   cryptographically secure. These generators are suitable for simulations,
///   testing, Monte Carlo methods, and general-purpose randomness, but
///   **must not be used** for cryptographic purposes such as:
///   - Generating cryptographic keys
///   - Creating nonces or salts
///   - Generating session tokens
///   - Any security-sensitive applications
///
///   For cryptographic use cases, use Swift's `SecRandomCopyBytes()` or a
///   cryptographically secure random number generator (CSPRNG).
///
/// - Note: Memory is automatically managed through Swift's ARC. The underlying
/// GMP
///   structure is initialized on creation and cleared on deallocation.
///
/// `GMPRandomState` provides value semantics with automatic memory management
/// through
/// Copy-on-Write (COW). Multiple `GMPRandomState` instances can share the same
/// underlying
/// storage until one needs to be mutated, at which point a copy is made
/// automatically.
///
/// - Note: This struct uses a private storage class to implement COW semantics,
///   ensuring that value semantics are maintained while minimizing unnecessary
/// copies.
///   When a random state is copied, both instances will produce the same
/// sequence
///   of random numbers from that point forward.
public struct GMPRandomState {
    /// The internal storage holding the GMP random state structure.
    ///
    /// This is a reference to a `_GMPRandomStateStorage` instance. Multiple
    /// `GMPRandomState`
    /// instances may share the same storage reference until mutation occurs.
    var _storage: _GMPRandomStateStorage

    // MARK: - Initialization

    /// Initialize a new random state with the default algorithm.
    ///
    /// The default algorithm is platform-dependent but typically provides good
    /// quality random numbers. The initial seed is based on system entropy.
    ///
    /// - Warning: **Not Cryptographically Secure**: This random number
    /// generator
    ///   is not suitable for cryptographic purposes. Use `SecRandomCopyBytes()`
    ///   or a CSPRNG for security-sensitive applications.
    ///
    /// - Requires: None
    /// - Guarantees: Returns a valid `GMPRandomState` with the default
    /// algorithm
    ///   and a system-generated seed. The state is properly initialized and
    /// ready
    ///   for use. Memory will be automatically freed when the value is
    /// deallocated.
    ///
    /// - Note: Wraps GMP function `gmp_randinit_default`.
    public init() {
        _storage = _GMPRandomStateStorage()
    }

    /// Initialize a new random state with the Mersenne Twister algorithm.
    ///
    /// The Mersenne Twister is a high-quality pseudorandom number generator
    /// with
    /// a very long period (2^19937 - 1). It's suitable for most applications.
    ///
    /// - Warning: **Not Cryptographically Secure**: The Mersenne Twister is a
    ///   PRNG and is not suitable for cryptographic purposes. Use
    ///   `SecRandomCopyBytes()` or a CSPRNG for security-sensitive
    /// applications.
    ///
    /// - Parameter seed: The seed value. Can be any `GMPInteger`.
    ///
    /// - Requires: `seed` must be properly initialized.
    /// - Guarantees: Returns a valid `GMPRandomState` with the Mersenne Twister
    ///   algorithm initialized with the given seed. The same seed will produce
    ///   the same sequence of random numbers.
    ///
    /// - Note: Wraps GMP functions `gmp_randinit_mt` and `gmp_randseed`.
    public init(mersenneTwister seed: GMPInteger) {
        _storage = _GMPRandomStateStorage()
        __gmp_randinit_mt(&_storage.value)
        let seedPtr = withUnsafePointer(to: seed._storage.value) { $0 }
        __gmp_randseed(&_storage.value, seedPtr)
        _storage.lastSeed = seed
    }

    /// Initialize a new random state with a linear congruential algorithm
    /// (2^exponent modulus).
    ///
    /// Linear congruential generators are faster but have shorter periods and
    /// lower quality than the Mersenne Twister. Use only when speed is critical
    /// and quality requirements are lower.
    ///
    /// - Warning: **Not Cryptographically Secure**: Linear congruential
    ///   generators are weak PRNGs and are definitely not suitable for
    ///   cryptographic purposes. Use `SecRandomCopyBytes()` or a CSPRNG for
    ///   security-sensitive applications.
    ///
    /// - Parameters:
    ///   - seed: The initial seed value.
    ///   - multiplier: The multiplier for the linear congruential generator.
    /// Must fit in `UInt`.
    ///   - addend: The addend (increment) for the linear congruential
    /// generator. Must fit in `UInt`.
    ///   - exponent: The exponent for the modulus (modulus = 2^exponent). Must
    /// be positive.
    ///
    /// - Requires: All integers must be properly initialized. `exponent` must
    /// be positive.
    ///   `multiplier` and `addend` must be non-negative and fit in `UInt`.
    /// - Guarantees: Returns a valid `GMPRandomState` with the linear
    /// congruential
    ///   algorithm. The period is at most 2^exponent.
    ///
    /// - Note: Wraps GMP function `gmp_randinit_lc_2exp` and `gmp_randseed`.
    ///   Note: GMP's `gmp_randinit_lc_2exp` only accepts multiplier as
    /// `unsigned long`,
    ///   and doesn't have an addend parameter. The addend is set internally by
    /// GMP.
    ///   This interface accepts both for API consistency, but only multiplier
    /// is used.
    public init(
        linearCongruential2Exp seed: GMPInteger,
        multiplier: GMPInteger,
        addend _: GMPInteger,
        exponent: Int
    ) {
        precondition(exponent > 0, "exponent must be positive")
        // GMP's linear congruential generator with exponent = 1 causes an
        // infinite loop
        // in randget_lc() because chunk_nbits = m2exp / 2 = 0, making the while
        // loop
        // condition always true. Minimum practical exponent is 2.
        precondition(
            exponent >= 2,
            "exponent must be at least 2 (exponent = 1 causes infinite loop in GMP)"
        )
        precondition(
            !multiplier.isNegative && multiplier.fitsInUInt(),
            "multiplier must be non-negative and fit in UInt"
        )
        // Note: addend parameter is accepted for API consistency but GMP
        // doesn't use it
        _storage = _GMPRandomStateStorage()
        let seedPtr = withUnsafePointer(to: seed._storage.value) { $0 }
        __gmp_randinit_lc_2exp(
            &_storage.value,
            seedPtr,
            CUnsignedLong(multiplier.toUInt()),
            mp_bitcnt_t(exponent)
        )
        // Set the seed after initialization
        __gmp_randseed(&_storage.value, seedPtr)
        _storage.lastSeed = seed
    }

    /// Initialize a new random state with a linear congruential algorithm
    /// (auto-sized modulus).
    ///
    /// Similar to `init(linearCongruential2Exp:multiplier:addend:exponent:)`,
    /// but the
    /// modulus size is automatically determined from the seed size.
    ///
    /// - Warning: **Not Cryptographically Secure**: Linear congruential
    ///   generators are weak PRNGs and are definitely not suitable for
    ///   cryptographic purposes. Use `SecRandomCopyBytes()` or a CSPRNG for
    ///   security-sensitive applications.
    ///
    /// - Parameters:
    ///   - seed: The initial seed value.
    ///   - size: The size of the modulus in bits. Must be positive.
    ///
    /// - Returns: A new `GMPRandomState` if initialization succeeds.
    ///
    /// - Requires: `seed` must be properly initialized. `size` must be
    /// positive.
    /// - Guarantees: Returns a valid `GMPRandomState` with the linear
    /// congruential
    ///   algorithm if initialization succeeds.
    ///
    /// - Throws: May throw `GMPError.invalidRandomState` if initialization
    /// fails.
    ///
    /// - Note: Wraps GMP function `gmp_randinit_lc_2exp_size` and
    /// `gmp_randseed`.
    public init(linearCongruentialSize seed: GMPInteger, size: Int) throws {
        precondition(size > 0, "size must be positive")
        _storage = _GMPRandomStateStorage()
        let result = __gmp_randinit_lc_2exp_size(
            &_storage.value,
            mp_bitcnt_t(size)
        )
        if result == 0 {
            throw GMPError.invalidRandomState
        }
        let seedPtr = withUnsafePointer(to: seed._storage.value) { $0 }
        __gmp_randseed(&_storage.value, seedPtr)
        _storage.lastSeed = seed
    }

    /// Initialize a new random state by copying another.
    ///
    /// Creates an independent copy of the random state. Both states will
    /// produce
    /// the same sequence of random numbers from this point forward.
    ///
    /// - Parameter other: The random state to copy.
    ///
    /// - Requires: `other` must be properly initialized.
    /// - Guarantees: Returns a valid `GMPRandomState` that is an independent
    /// copy
    ///   of `other`. Both states will produce identical sequences.
    ///
    /// - Note: Wraps GMP function `gmp_randinit_set`.
    public init(copying other: GMPRandomState) {
        _storage = _GMPRandomStateStorage(copying: other._storage)
    }

    // MARK: - Seeding

    /// Seed (reinitialize) this random state.
    ///
    /// Resets the random state with a new seed. The sequence of random numbers
    /// will restart from the beginning for this seed.
    ///
    /// - Parameter value: The new seed value. Can be any `GMPInteger`.
    ///
    /// - Requires: This random state and `value` must be properly initialized.
    /// - Guarantees: After this call, the random state is reinitialized with
    /// the
    ///   new seed. The sequence of random numbers will restart.
    ///
    /// - Note: Wraps GMP function `gmp_randseed`.
    public mutating func seed(_ value: GMPInteger) {
        // Ensure unique storage for COW semantics
        if !isKnownUniquelyReferenced(&_storage) {
            _storage = _GMPRandomStateStorage(copying: _storage)
        }
        let seedPtr = withUnsafePointer(to: value._storage.value) { $0 }
        __gmp_randseed(&_storage.value, seedPtr)
        _storage.lastSeed = value
    }

    /// Seed (reinitialize) this random state with an `Int`.
    ///
    /// - Parameter value: The new seed value as an `Int`.
    ///
    /// - Requires: This random state must be properly initialized.
    /// - Guarantees: After this call, the random state is reinitialized with
    /// the
    ///   new seed.
    ///
    /// - Note: Wraps GMP function `gmp_randseed_ui`.
    public mutating func seed(_ value: Int) {
        // Ensure unique storage for COW semantics
        if !isKnownUniquelyReferenced(&_storage) {
            _storage = _GMPRandomStateStorage(copying: _storage)
        }
        // Handle Int.min specially to avoid overflow when converting to
        // unsigned
        let seedValue = if value == Int.min {
            // Int.min = -2,147,483,648, so abs(Int.min) = 2,147,483,648
            // This fits in CUnsignedLong (UInt) but not in Int
            CUnsignedLong(Int.max) + 1
        } else if value < 0 {
            // For negative values, convert to unsigned (GMP will handle it)
            CUnsignedLong(-value)
        } else {
            CUnsignedLong(value)
        }
        __gmp_randseed_ui(&_storage.value, seedValue)
        // Store the seed as GMPInteger for the getter
        _storage.lastSeed = GMPInteger(value)
    }

    /// Get the current seed of this random state.
    ///
    /// Returns the seed that was used to initialize this random state. Note
    /// that
    /// for some algorithms, this may not be the exact seed that was provided,
    /// but rather a processed version.
    ///
    /// - Returns: A new `GMPInteger` with the current seed.
    ///
    /// - Requires: This random state must be properly initialized.
    /// - Guarantees: Returns a new `GMPInteger` with the seed value. The seed
    ///   can be used to recreate the same random sequence.
    ///
    /// - Note: GMP doesn't provide a direct way to retrieve the seed from a
    /// random state.
    ///   This implementation stores the last seed that was set. For default
    /// initialization,
    ///   the seed is unknown and this will return 0.
    public var seed: GMPInteger {
        // Return the stored seed, or 0 if no seed was explicitly set (default
        // initialization)
        _storage.lastSeed ?? GMPInteger(0)
    }

    // MARK: - Random Number Generation

    /// Generate a random integer in the range [0, upperBound).
    ///
    /// Generates a uniformly distributed random integer strictly less than
    /// `upperBound`.
    /// This is a convenience method for generating random `Int` values.
    ///
    /// - Warning: **Not Cryptographically Secure**: This method uses a PRNG and
    ///   is not suitable for cryptographic purposes. Use `SecRandomCopyBytes()`
    ///   or a CSPRNG for security-sensitive applications.
    ///
    /// - Parameter upperBound: The upper bound (exclusive). Must be positive.
    /// - Returns: A random `Int` in the range [0, upperBound).
    ///
    /// - Requires: This random state must be properly initialized. `upperBound`
    /// must be positive.
    /// - Guarantees: Returns a random `Int` in the range [0, upperBound). The
    /// distribution
    ///   is uniform. The random state advances.
    ///
    /// - Note: Wraps GMP function `gmp_urandomm_ui`.
    public mutating func random(upperBound: Int) -> Int {
        precondition(upperBound > 0, "upperBound must be positive")
        // Ensure unique storage for COW semantics
        if !isKnownUniquelyReferenced(&_storage) {
            _storage = _GMPRandomStateStorage(copying: _storage)
        }
        return withExtendedLifetime(_storage) {
            withUnsafeMutablePointer(to: &_storage.value) { ptr in
                let result = __gmp_urandomm_ui(ptr, CUnsignedLong(upperBound))
                // The result is guaranteed to be < upperBound, so it fits in
                // Int
                // since upperBound is an Int. However, we need to handle the
                // conversion safely.
                // On 64-bit platforms, CUnsignedLong == UInt64, which can be
                // larger than Int.max
                // But since result < upperBound <= Int.max, we can safely
                // convert
                // Use UInt64.max + 1 for the modulus to avoid Int.max + 1
                // overflow
                let intMaxPlusOne = CUnsignedLong(Int.max) + 1
                if result > CUnsignedLong(Int.max) {
                    // This shouldn't happen if upperBound <= Int.max, but
                    // handle it safely
                    return Int(result % intMaxPlusOne)
                }
                return Int(result)
            }
        }
    }

    /// Generate a random integer with the given number of bits.
    ///
    /// Generates a uniformly distributed random integer with exactly `bits`
    /// bits.
    /// This is a convenience method for generating random `Int` values.
    ///
    /// - Warning: **Not Cryptographically Secure**: This method uses a PRNG and
    ///   is not suitable for cryptographic purposes. Use `SecRandomCopyBytes()`
    ///   or a CSPRNG for security-sensitive applications.
    ///
    /// - Parameter bits: The number of bits. Must be positive and not exceed
    /// the number
    ///   of bits in `Int`.
    /// - Returns: A random `Int` with the specified number of bits.
    ///
    /// - Requires: This random state must be properly initialized. `bits` must
    /// be positive
    ///   and not exceed the number of bits in `Int`.
    /// - Guarantees: Returns a random `Int` with exactly `bits` bits (for
    /// positive values).
    ///   The random state advances.
    ///
    /// - Note: Wraps GMP function `gmp_urandomb_ui`.
    public mutating func random(bits: Int) -> Int {
        precondition(bits > 0, "bits must be positive")
        precondition(bits <= Int.bitWidth, "bits must not exceed Int.bitWidth")
        // Ensure unique storage for COW semantics
        if !isKnownUniquelyReferenced(&_storage) {
            _storage = _GMPRandomStateStorage(copying: _storage)
        }
        return withExtendedLifetime(_storage) {
            withUnsafeMutablePointer(to: &_storage.value) { ptr in
                let result = __gmp_urandomb_ui(ptr, CUnsignedLong(bits))
                // The result has at most `bits` bits, and since bits <=
                // Int.bitWidth,
                // the result should fit in Int. However, we need to handle the
                // conversion safely.
                // On 64-bit platforms, CUnsignedLong == UInt64, which can be
                // larger than Int.max
                // But since result has at most Int.bitWidth bits, we can safely
                // convert
                // Use UInt64.max + 1 for the modulus to avoid Int.max + 1
                // overflow
                let intMaxPlusOne = CUnsignedLong(Int.max) + 1
                if result > CUnsignedLong(Int.max) {
                    // This can happen if bits == Int.bitWidth on 64-bit
                    // platforms
                    // The result has Int.bitWidth bits, which might exceed
                    // Int.max
                    // Return the value modulo (Int.max + 1) to fit in Int
                    return Int(result % intMaxPlusOne)
                }
                return Int(result)
            }
        }
    }
}
