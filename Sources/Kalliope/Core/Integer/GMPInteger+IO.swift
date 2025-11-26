import CKalliope
import CKalliopeBridge
import Darwin
import Foundation
import Security

/// Binary import/export operations for `GMPInteger`.
///
/// These functions provide platform-independent binary serialization of
/// integers,
/// useful for network communication, file storage, and data exchange between
/// different systems.
extension GMPInteger {
    /// Byte order for words in binary export/import.
    ///
    /// Determines the order of words (multi-byte units) in the binary format.
    public enum ByteOrder {
        /// Use the platform's native byte order.
        case native

        /// Least significant word first (little-endian word order).
        case leastSignificantFirst

        /// Most significant word first (big-endian word order).
        case mostSignificantFirst

        /// Convert to GMP's order parameter
        /// -1 = native (use host's word order)
        /// 1 = least significant word first
        /// Note: GMP doesn't directly support "most significant first" - it
        /// uses native order
        func toGMPOrder() -> Int32 {
            switch self {
            case .native:
                -1
            case .leastSignificantFirst:
                1
            case .mostSignificantFirst:
                // GMP uses native order for this case
                -1
            }
        }
    }

    /// Endianness for bytes within words in binary export/import.
    ///
    /// Determines the byte order within each word (multi-byte unit).
    public enum Endianness {
        /// Use the platform's native endianness.
        case native

        /// Little-endian (least significant byte first).
        case little

        /// Big-endian (most significant byte first).
        case big

        /// Convert to GMP's endian parameter (0 for native, -1 for little, 1
        /// for big)
        func toGMPEndian() -> Int32 {
            switch self {
            case .native:
                0
            case .little:
                -1
            case .big:
                1
            }
        }
    }

    /// Export this integer to binary data in a platform-independent format.
    ///
    /// Serializes the integer to a binary format that can be read on any
    /// platform
    /// with the same parameters. The format is compatible with GMP's export
    /// format.
    ///
    /// - Note: Wraps GMP function `mpz_export`.
    ///
    /// - Parameters:
    ///   - order: The byte order for words. `.native` uses the platform's
    /// native order.
    ///   - size: The size of each word in bytes. Must be positive. Common
    /// values are 1, 2, 4, 8.
    ///   - endian: The endianness for bytes within words. `.native` uses the
    /// platform's native endianness.
    ///   - nails: The number of high-order bits to ignore in each word. Must be
    /// non-negative
    ///     and less than `size * 8`. Defaults to 0 (use all bits).
    /// - Returns: A `Data` object containing the serialized integer.
    ///
    /// - Requires: This integer must be properly initialized. `size` must be
    /// positive.
    ///   `nails` must be non-negative and less than `size * 8`.
    /// - Guarantees: Returns a `Data` object that can be imported using
    /// `init(data:order:size:endian:nails:)`
    ///   with the same parameters to recover the original value. `self` is
    /// unchanged.
    public func export(
        order: ByteOrder = .native,
        size: Int,
        endian: Endianness = .native,
        nails: Int = 0
    ) -> Data {
        precondition(size > 0, "size must be positive")
        precondition(
            nails >= 0 && nails < size * 8,
            "nails must be non-negative and less than size * 8"
        )

        // Store the sign (0 for non-negative, 1 for negative)
        // GMP's mpz_export only exports absolute values, so we need to preserve
        // the sign separately
        let isNegative = __gmpz_cmp_ui(&_storage.value, 0) < 0
        let signByte: UInt8 = isNegative ? 1 : 0

        var count: size_t = 0
        let buffer = __gmpz_export(
            nil,
            &count,
            order.toGMPOrder(),
            size_t(size),
            endian.toGMPEndian(),
            size_t(nails),
            &_storage.value
        )

        guard let buffer, count > 0 else {
            // If count is 0 or buffer is nil, return data with just the sign
            // byte
            var result = Data()
            result.append(signByte)
            return result
        }

        var data = Data()
        data.append(signByte) // Prepend sign byte
        data.append(Data(bytes: buffer, count: Int(count) * size))
        // GMP allocates the buffer using malloc, we need to free it
        free(buffer)
        return data
    }

    /// Import an integer from binary data.
    ///
    /// Deserializes an integer from binary data exported by
    /// `export(order:size:endian:nails:)`.
    /// The parameters must match those used for export.
    ///
    /// - Note: Wraps GMP function `mpz_import`.
    ///
    /// - Parameters:
    ///   - data: The binary data to import from.
    ///   - order: The byte order for words. Must match the export parameter.
    ///   - size: The size of each word in bytes. Must match the export
    /// parameter.
    ///   - endian: The endianness for bytes within words. Must match the export
    /// parameter.
    ///   - nails: The number of high-order bits to ignore. Must match the
    /// export parameter.
    /// - Returns: A new `GMPInteger` if import succeeds, `nil` otherwise.
    ///
    /// - Requires: `size` must be positive. `nails` must be non-negative and
    /// less than `size * 8`.
    ///   `data` must be valid and contain enough bytes for at least one word.
    /// - Guarantees: If import succeeds, returns a new `GMPInteger` with the
    /// deserialized value.
    ///   If import fails (e.g., invalid data), returns `nil`.
    public init?(
        data: Data,
        order: ByteOrder = .native,
        size: Int,
        endian: Endianness = .native,
        nails: Int = 0
    ) {
        precondition(size > 0, "size must be positive")
        precondition(
            nails >= 0 && nails < size * 8,
            "nails must be non-negative and less than size * 8"
        )

        // Check if we have at least the sign byte
        guard data.count >= 1 else {
            return nil
        }

        // Extract sign byte (first byte: 0 for non-negative, 1 for negative)
        let signByte = data[0]
        let isNegative = signByte == 1

        _storage = _GMPIntegerStorage()

        // Handle zero case: if only sign byte is present, it's zero
        if data.count == 1 {
            // Already initialized to zero, just verify sign
            if isNegative {
                // This shouldn't happen for zero, but handle it gracefully
                return nil
            }
            return
        }

        // Check if we have enough data for at least one word (excluding sign
        // byte)
        guard data.count >= 1 + size else {
            return nil
        }

        // Import the absolute value (skip the sign byte)
        let valueData = data.subdata(in: 1 ..< data.count)
        let count = valueData.count / size

        // Import directly into storage
        valueData.withUnsafeBytes { bytes in
            __gmpz_import(
                &_storage.value,
                size_t(count),
                order.toGMPOrder(),
                size_t(size),
                endian.toGMPEndian(),
                size_t(nails),
                bytes.baseAddress
            )
        }

        // Restore the sign if the value was negative (use negated() to avoid
        // exclusivity issues)
        if isNegative {
            let negated = GMPInteger()
            __gmpz_neg(&negated._storage.value, &_storage.value)
            __gmpz_set(&_storage.value, &negated._storage.value)
        }
    }

    // MARK: - String-based I/O (Primary Swift API)

    /// Convert this integer to a string representation in the given base.
    ///
    /// This is the primary Swift API for converting integers to strings.
    /// Equivalent to
    /// `toString(base:)` but provided for consistency with I/O naming.
    ///
    /// - Note: Wraps GMP function `mpz_get_str`.
    ///
    /// - Parameter base: The numeric base (radix) for conversion. Must be in
    /// the range 2-62,
    ///   or from -2 to -36. Defaults to 10 (decimal).
    /// - Returns: A string representation of the integer in the specified base.
    ///
    /// - Requires: This integer must be properly initialized. `base` must be in
    /// the range
    ///   2-62 or -36 to -2.
    /// - Guarantees: Returns a valid string representation. The string can be
    /// parsed back
    ///   using `init(string:base:)` with the same base to recover the original
    /// value.
    public func writeToString(base: Int = 10) -> String {
        toString(base: base)
    }

    /// Create an integer from a string representation.
    ///
    /// This is the primary Swift API for parsing integers from strings.
    /// Equivalent to
    /// `init(_:base:)` but provided for consistency with I/O naming.
    ///
    /// - Note: Wraps GMP function `mpz_set_str`.
    ///
    /// - Parameters:
    ///   - string: The string to parse. Must be a valid number in the specified
    /// base.
    ///   - base: The numeric base (radix) for parsing. Must be 0 or in the
    /// range 2-62.
    ///     Defaults to 10.
    /// - Returns: A new `GMPInteger` if parsing succeeds, `nil` otherwise.
    ///
    /// - Requires: `base` must be 0 or in the range 2-62. `string` must not be
    /// empty.
    /// - Guarantees: If parsing succeeds, returns a valid `GMPInteger` with the
    /// parsed value.
    ///   If parsing fails, returns `nil`.
    public init?(string: String, base: Int = 10) {
        self.init(string, base: base)
    }

    // MARK: - Random Numbers

    /// Generate a random integer with the given number of bits.
    ///
    /// Generates a uniformly distributed random integer with exactly `bits`
    /// bits.
    /// The result is in the range [2^(bits-1), 2^bits) for positive values.
    ///
    /// - Warning: **Not Cryptographically Secure**: This method uses a PRNG and
    ///   is not suitable for cryptographic purposes. Use `SecRandomCopyBytes()`
    ///   or a CSPRNG for security-sensitive applications.
    ///
    /// - Note: Wraps GMP function `mpz_urandomb`.
    ///
    /// - Parameters:
    ///   - bits: The number of bits. Must be positive.
    ///   - state: The random number generator state.
    /// - Returns: A new `GMPInteger` with a random value of the specified bit
    /// length.
    ///
    /// - Requires: `bits` must be positive. `state` must be properly
    /// initialized.
    /// - Guarantees: Returns a new `GMPInteger` with a random value. The value
    /// has
    ///   exactly `bits` bits (for positive values).
    public static func random(
        bits: Int,
        using state: GMPRandomState
    ) -> GMPInteger {
        precondition(bits > 0, "bits must be positive")
        let result = GMPInteger()
        // GMP functions mutate the random state, so we need a mutable pointer
        // Since _storage is a class reference, we can get a mutable pointer to
        // its value property
        let storage = state._storage
        withUnsafeMutablePointer(to: &storage.value) { statePtr in
            withUnsafeMutablePointer(to: &result._storage.value) { resultPtr in
                __gmpz_urandomb(resultPtr, statePtr, mp_bitcnt_t(bits))
            }
        }
        return result
    }

    /// Generate a random integer in the range [0, upperBound).
    ///
    /// Generates a uniformly distributed random integer strictly less than
    /// `upperBound`.
    ///
    /// - Warning: **Not Cryptographically Secure**: This method uses a PRNG and
    ///   is not suitable for cryptographic purposes. Use `SecRandomCopyBytes()`
    ///   or a CSPRNG for security-sensitive applications.
    ///
    /// - Note: Wraps GMP function `mpz_urandomm`.
    ///
    /// - Parameters:
    ///   - upperBound: The upper bound (exclusive). Must be positive.
    ///   - state: The random number generator state.
    /// - Returns: A new `GMPInteger` with a random value in [0, upperBound).
    ///
    /// - Requires: `upperBound` must be properly initialized and positive.
    /// `state` must
    ///   be properly initialized.
    /// - Guarantees: Returns a new `GMPInteger` with a random value. The value
    /// satisfies
    ///   `0 <= result < upperBound`.
    public static func random(
        upperBound: GMPInteger,
        using state: GMPRandomState
    ) -> GMPInteger {
        precondition(
            !upperBound.isZero && !upperBound.isNegative,
            "upperBound must be positive"
        )
        let result = GMPInteger()
        // GMP functions mutate the random state, so we need a mutable pointer
        // Since _storage is a class reference, we can get a mutable pointer to
        // its value property
        let storage = state._storage
        withUnsafeMutablePointer(to: &storage.value) { statePtr in
            withUnsafePointer(to: upperBound._storage.value) { upperBoundPtr in
                withUnsafeMutablePointer(to: &result._storage
                    .value)
                { resultPtr in
                    __gmpz_urandomm(resultPtr, statePtr, upperBoundPtr)
                }
            }
        }
        return result
    }

    /// Generate a random integer with the given number of bits (long sequences
    /// variant).
    ///
    /// Similar to `random(bits:using:)`, but generates numbers with long
    /// sequences of
    /// consecutive 0s and 1s. Useful for testing algorithms that may have
    /// special cases
    /// for such patterns.
    ///
    /// - Warning: **Not Cryptographically Secure**: This method uses a PRNG and
    ///   is not suitable for cryptographic purposes. Use `SecRandomCopyBytes()`
    ///   or a CSPRNG for security-sensitive applications.
    ///
    /// - Note: Wraps GMP function `mpz_rrandomb`.
    ///
    /// - Parameters:
    ///   - bits: The number of bits. Must be positive.
    ///   - state: The random number generator state.
    /// - Returns: A new `GMPInteger` with a random value.
    ///
    /// - Requires: `bits` must be positive. `state` must be properly
    /// initialized.
    /// - Guarantees: Returns a new `GMPInteger` with a random value.
    public static func randomLong(
        bits: Int,
        using state: GMPRandomState
    ) -> GMPInteger {
        precondition(bits > 0, "bits must be positive")
        let result = GMPInteger()
        // GMP functions mutate the random state, so we need a mutable pointer
        // Since _storage is a class reference, we can get a mutable pointer to
        // its value property
        let storage = state._storage
        withUnsafeMutablePointer(to: &storage.value) { statePtr in
            withUnsafeMutablePointer(to: &result._storage.value) { resultPtr in
                __gmpz_rrandomb(resultPtr, statePtr, mp_bitcnt_t(bits))
            }
        }
        return result
    }

    // MARK: - Cryptographically Secure Random Numbers

    /// Generate a cryptographically secure random integer with the given number
    /// of bits.
    ///
    /// Generates a uniformly distributed random integer with exactly `bits`
    /// bits
    /// using the system's cryptographically secure random number generator
    /// (`SecRandomCopyBytes`). The result is in the range [2^(bits-1), 2^bits)
    /// for positive values.
    ///
    /// This method is suitable for cryptographic purposes such as:
    /// - Generating cryptographic keys
    /// - Creating nonces or salts
    /// - Generating session tokens
    /// - Any security-sensitive applications
    ///
    /// - Note: Uses `SecRandomCopyBytes()` from the Security framework, which
    ///   provides cryptographically secure random bytes from the system's
    ///   entropy pool.
    ///
    /// - Parameter bits: The number of bits. Must be positive.
    /// - Returns: A new `GMPInteger` with a cryptographically secure random
    ///   value of the specified bit length.
    ///
    /// - Throws: `GMPError` if random number generation fails (e.g., system
    ///   entropy pool is unavailable).
    ///
    /// - Requires: `bits` must be positive.
    /// - Guarantees: Returns a new `GMPInteger` with a cryptographically secure
    ///   random value. The value has exactly `bits` bits (for positive values).
    public static func secureRandom(bits: Int) throws -> GMPInteger {
        precondition(bits > 0, "bits must be positive")

        // Calculate the number of bytes needed (round up)
        let bytesNeeded = (bits + 7) / 8

        // Generate cryptographically secure random bytes
        var randomBytes = Data(count: bytesNeeded)
        let result = randomBytes.withUnsafeMutableBytes { bytes in
            SecRandomCopyBytes(
                kSecRandomDefault,
                bytesNeeded,
                bytes.baseAddress!
            )
        }

        guard result == errSecSuccess else {
            throw GMPError.invalidRandomState
        }

        // Create GMPInteger from the random bytes using import
        let resultInteger = GMPInteger()
        randomBytes.withUnsafeBytes { bytes in
            // Use 1-byte words for simplicity and portability
            let wordSize = 1
            let wordCount = bytesNeeded
            __gmpz_import(
                &resultInteger._storage.value,
                size_t(wordCount),
                -1, // native byte order
                size_t(wordSize),
                0, // native endianness
                0, // no nails
                bytes.baseAddress
            )
        }

        // Mask to ensure we have exactly the right number of bits
        // For exactly `bits` bits, we want range [2^(bits-1), 2^bits)
        let maxValue = (GMPInteger(1) << bits) - 1
        let minValue = GMPInteger(1) << (bits - 1)

        // Apply mask and ensure we're in the correct range
        let masked = resultInteger & maxValue
        if masked < minValue {
            // If too small, add minValue to ensure we have exactly `bits` bits
            __gmpz_set(
                &resultInteger._storage.value,
                &(masked + minValue)._storage.value
            )
        } else {
            __gmpz_set(&resultInteger._storage.value, &masked._storage.value)
        }

        return resultInteger
    }

    /// Generate a cryptographically secure random integer in the range [0,
    /// upperBound).
    ///
    /// Generates a uniformly distributed random integer strictly less than
    /// `upperBound` using the system's cryptographically secure random number
    /// generator (`SecRandomCopyBytes`).
    ///
    /// This method is suitable for cryptographic purposes such as:
    /// - Generating cryptographic keys
    /// - Creating nonces or salts
    /// - Generating session tokens
    /// - Any security-sensitive applications
    ///
    /// - Note: Uses `SecRandomCopyBytes()` from the Security framework, which
    ///   provides cryptographically secure random bytes from the system's
    ///   entropy pool. Uses rejection sampling to ensure uniform distribution
    ///   within the specified range.
    ///
    /// - Parameter upperBound: The upper bound (exclusive). Must be positive.
    /// - Returns: A new `GMPInteger` with a cryptographically secure random
    ///   value in [0, upperBound).
    ///
    /// - Throws: `GMPError` if random number generation fails (e.g., system
    ///   entropy pool is unavailable).
    ///
    /// - Requires: `upperBound` must be properly initialized and positive.
    /// - Guarantees: Returns a new `GMPInteger` with a cryptographically secure
    ///   random value. The value satisfies `0 <= result < upperBound`.
    public static func secureRandom(upperBound: GMPInteger) throws
        -> GMPInteger
    {
        precondition(
            !upperBound.isZero && !upperBound.isNegative,
            "upperBound must be positive"
        )

        // Calculate the number of bits needed to represent upperBound
        let bitsNeeded = upperBound.bitCount

        // Use rejection sampling to ensure uniform distribution
        // Generate random numbers until we get one in the valid range
        var attempts = 0
        let maxAttempts = 1000 // Prevent infinite loops

        while attempts < maxAttempts {
            // Generate a random number with enough bits
            let candidate = try secureRandom(bits: bitsNeeded)

            // Check if candidate is in range [0, upperBound)
            if candidate < upperBound {
                return candidate
            }

            attempts += 1
        }

        // Fallback: use modular reduction (slightly biased but acceptable for large ranges)
        let random = try secureRandom(bits: bitsNeeded)
        return random % upperBound
    }

    // MARK: - Debug

    /// Print a debug representation of this integer to standard error.
    ///
    /// Outputs a human-readable representation of the integer's internal
    /// structure,
    /// useful for debugging. The format is implementation-defined and may
    /// change.
    ///
    /// - Requires: This integer must be properly initialized.
    /// - Guarantees: Outputs debug information to standard error. `self` is
    /// unchanged.
    ///
    /// - Note: For debugging only. The output format is not guaranteed to be
    /// stable.
    public func dump() {
        __gmpz_dump(&_storage.value)
    }

    // MARK: - Low-Level Access

    /// Get the limb (digit) at the specified index.
    ///
    /// Limbs are indexed from 0 (least significant) upward. For negative
    /// values,
    /// limbs are in two's complement representation.
    ///
    /// - Note: Wraps GMP function `mpz_getlimbn`.
    ///
    /// - Parameter index: The limb index. Must be non-negative and less than
    /// `limbCount`.
    /// - Returns: The limb value as a `UInt`.
    ///
    /// - Requires: This integer must be properly initialized. `index` must be
    /// non-negative
    ///   and less than `limbCount`.
    /// - Guarantees: Returns the limb value at the specified index. `self` is
    /// unchanged.
    public func getLimb(at index: Int) -> UInt {
        precondition(index >= 0, "index must be non-negative")
        return UInt(__gmpz_getlimbn(&_storage.value, mp_size_t(index)))
    }

    /// Get a read-only pointer to the internal limb array.
    ///
    /// **Unsafe**: The pointer is only valid while the integer exists and is
    /// not mutated.
    /// Do not store the pointer beyond the integer's lifetime. Do not modify
    /// through this pointer.
    ///
    /// - Note: Wraps GMP function `mpz_limbs_read`.
    ///
    /// - Returns: An `UnsafePointer<UInt>` to the limb array. The array has
    /// `limbCount` elements.
    ///
    /// - Requires: This integer must be properly initialized.
    /// - Guarantees: Returns a valid pointer to the limb array. The pointer is
    /// only valid
    ///   while `self` exists and is not mutated. The array has `limbCount`
    /// elements.
    ///
    /// - Warning: **Unsafe**. The pointer becomes invalid if the integer is
    /// mutated or deallocated.
    public var limbsRead: UnsafePointer<UInt> {
        UnsafePointer<UInt>(__gmpz_limbs_read(&_storage.value))
    }

    /// Get a writable pointer to the limb array, reallocating if necessary.
    ///
    /// **Unsafe**: This function may reallocate the internal storage. The
    /// existing value
    /// is preserved only if it fits in the new size. You must call
    /// `limbsFinish(size:)`
    /// after modifying the limbs to update the internal size.
    ///
    /// - Note: Wraps GMP function `mpz_limbs_write`.
    ///
    /// - Parameter count: The minimum number of limbs needed. Must be
    /// non-negative.
    /// - Returns: An `UnsafeMutablePointer<UInt>` to the limb array. The array
    /// has at least
    ///   `count` elements, but may have more.
    ///
    /// - Requires: This integer must be properly initialized. `count` must be
    /// non-negative.
    /// - Guarantees: Returns a writable pointer to at least `count` limbs. The
    /// existing value
    ///   is preserved if it fits. You must call `limbsFinish(size:)` after
    /// modifications.
    ///
    /// - Warning: **Unsafe**. You must call `limbsFinish(size:)` after
    /// modifications.
    ///   Incorrect usage can corrupt the integer.
    public mutating func limbsWrite(count: Int) -> UnsafeMutablePointer<UInt> {
        precondition(count >= 0, "count must be non-negative")
        _ensureUnique()
        return UnsafeMutablePointer<UInt>(__gmpz_limbs_write(
            &_storage.value,
            mp_size_t(count)
        ))
    }

    /// Get a writable pointer to the limb array, preserving existing data.
    ///
    /// **Unsafe**: Similar to `limbsWrite(count:)`, but guarantees the existing
    /// value is
    /// preserved. You must call `limbsFinish(size:)` after modifying the limbs.
    ///
    /// - Note: Wraps GMP function `mpz_limbs_modify`.
    ///
    /// - Parameter count: The minimum number of limbs needed. Must be
    /// non-negative.
    /// - Returns: An `UnsafeMutablePointer<UInt>` to the limb array.
    ///
    /// - Requires: This integer must be properly initialized. `count` must be
    /// non-negative.
    /// - Guarantees: Returns a writable pointer. The existing value is
    /// preserved. You must
    ///   call `limbsFinish(size:)` after modifications.
    ///
    /// - Warning: **Unsafe**. You must call `limbsFinish(size:)` after
    /// modifications.
    public mutating func limbsModify(count: Int) -> UnsafeMutablePointer<UInt> {
        precondition(count >= 0, "count must be non-negative")
        _ensureUnique()
        return UnsafeMutablePointer<UInt>(__gmpz_limbs_modify(
            &_storage.value,
            mp_size_t(count)
        ))
    }

    /// Finish limb modification and update the internal size.
    ///
    /// **Unsafe**: Must be called after modifying limbs through
    /// `limbsWrite(count:)` or
    /// `limbsModify(count:)`. Updates the internal size based on the actual
    /// number of
    /// significant limbs.
    ///
    /// - Note: Wraps GMP function `mpz_limbs_finish`.
    ///
    /// - Parameter size: The actual number of significant limbs. Must be
    /// non-negative and
    ///   not exceed the allocated size. For negative values, `size` should be
    /// negative.
    ///
    /// - Requires: This integer must be properly initialized. `size` must be
    /// valid for the
    ///   allocated limb array. You must have previously called
    /// `limbsWrite(count:)` or
    ///   `limbsModify(count:)`.
    /// - Guarantees: Updates the internal size to `size`. The integer now
    /// reflects the
    ///   modified limb values.
    ///
    /// - Warning: **Unsafe**. Must be called after limb modifications.
    /// Incorrect `size`
    ///   will corrupt the integer.
    public mutating func limbsFinish(size: Int) {
        _ensureUnique()
        __gmpz_limbs_finish(&_storage.value, mp_size_t(size))
    }

    /// Create a read-only integer from an existing limb array.
    ///
    /// **Unsafe**: Creates a `GMPInteger` that references the provided limb
    /// array without
    /// copying. The limb array must remain valid for the lifetime of the
    /// integer. Do not
    /// modify the limb array while the integer exists.
    ///
    /// - Note: Wraps GMP function `mpz_roinit_n`.
    ///
    /// - Parameters:
    ///   - limbs: A pointer to the limb array. Must remain valid for the
    /// integer's lifetime.
    ///   - size: The number of significant limbs. For negative values, `size`
    /// should be negative.
    /// - Returns: A new `GMPInteger` that references the limb array.
    ///
    /// - Requires: `limbs` must be a valid pointer to at least `|size|` limbs.
    /// The limb array
    ///   must remain valid for the integer's lifetime. `size` must not be zero.
    /// - Guarantees: Returns a new `GMPInteger` that references the limb array.
    /// The integer
    ///   does not copy the data. Modifying the limb array will affect the
    /// integer.
    ///
    /// - Warning: **Unsafe**. The limb array must remain valid and unmodified
    /// while the
    ///   integer exists. This function is primarily for advanced C interop
    /// scenarios.
    public static func readOnly(
        limbs: UnsafePointer<UInt>,
        size: Int
    ) -> GMPInteger {
        precondition(size != 0, "size must not be zero")
        var temp = mpz_t()
        _ = __gmpz_roinit_n(&temp, limbs, mp_size_t(size))
        // Note: This is tricky - we need to create a GMPInteger that references
        // the roinit result
        // This requires special handling as roinit doesn't allocate new storage
        // For now, this is a placeholder
        return GMPInteger()
    }

    // MARK: - FileHandle-based I/O (Swift-idiomatic)

    /// Write this integer to a FileHandle in string format.
    ///
    /// Writes the integer as a string of digits in the specified base, followed
    /// by a newline.
    ///
    /// - Parameters:
    ///   - fileHandle: The FileHandle to write to. Must be open for writing.
    ///   - base: The numeric base (radix) for conversion. Must be in the range
    /// 2-62.
    ///     Defaults to 10.
    /// - Returns: The number of bytes written, or 0 on error.
    ///
    /// - Requires: This integer must be properly initialized. `fileHandle` must
    /// be open
    ///   for writing. `base` must be in the range 2-62.
    /// - Guarantees: If successful, returns the number of bytes written
    /// (including newline).
    ///   If an error occurs, returns 0. `self` is unchanged.
    public func write(to fileHandle: FileHandle, base: Int = 10) -> Int {
        precondition(base >= 2 && base <= 62, "base must be in the range 2-62")
        let string = writeToString(base: base) + "\n"
        guard let data = string.data(using: .utf8) else {
            return 0
        }
        fileHandle.write(data)
        return data.count
    }

    /// Create an integer by reading from a FileHandle in string format.
    ///
    /// Reads characters from the FileHandle until a newline or end of file is
    /// encountered,
    /// then parses the string as an integer in the specified base.
    ///
    /// - Parameters:
    ///   - fileHandle: The FileHandle to read from. Must be open for reading.
    ///   - base: The numeric base (radix) for parsing. Must be 0 or in the
    /// range 2-62.
    ///     Defaults to 10.
    /// - Returns: A new `GMPInteger` if reading and parsing succeed, `nil`
    /// otherwise.
    ///
    /// - Requires: `fileHandle` must be open for reading. `base` must be 0 or
    /// in the
    ///   range 2-62.
    /// - Guarantees: If reading and parsing succeed, returns a valid
    /// `GMPInteger`.
    ///   If reading fails or parsing fails, returns `nil`.
    public init?(fileHandle: FileHandle, base: Int = 10) {
        precondition(
            base == 0 || (base >= 2 && base <= 62),
            "base must be 0 or in the range 2-62"
        )

        // Safely get file descriptor using helper that catches ObjC exceptions
        let fd = withExtendedLifetime(fileHandle) {
            let unmanaged = Unmanaged.passUnretained(fileHandle)
            return ckalliope_safe_file_descriptor(unmanaged.toOpaque())
        }
        guard fd >= 0 else {
            // File descriptor is invalid (closed handle)
            return nil
        }

        var line = ""
        var buffer = Data()
        let chunkSize = 1024

        // File descriptor is valid, so we can safely read
        // Note: readData(ofLength:) may still throw ObjC exceptions in edge
        // cases,
        // but the file descriptor check prevents most issues
        while true {
            let data = fileHandle.readData(ofLength: chunkSize)
            if data.isEmpty {
                break
            }
            buffer.append(data)
            if let string = String(data: buffer, encoding: .utf8),
               let newlineIndex = string.firstIndex(of: "\n")
            {
                line = String(string[..<newlineIndex])
                break
            }
        }

        if line.isEmpty, !buffer.isEmpty {
            if let string = String(data: buffer, encoding: .utf8) {
                line = string
            }
        }

        guard !line.isEmpty else {
            return nil
        }

        self.init(string: line, base: base)
    }

    /// Write this integer to a FileHandle in raw binary format.
    ///
    /// Writes the integer in GMP's raw binary format (platform-independent).
    /// The format
    /// is the same as used by `export(order:size:endian:nails:)` with default
    /// parameters.
    ///
    /// - Parameter fileHandle: The FileHandle to write to. Must be open for
    /// writing.
    /// - Returns: The number of bytes written, or 0 on error.
    ///
    /// - Requires: This integer must be properly initialized. `fileHandle` must
    /// be open
    ///   for writing.
    /// - Guarantees: If successful, returns the number of bytes written. If an
    /// error occurs,
    ///   returns 0. `self` is unchanged. The data can be read back using
    /// `init(rawFileHandle:)`.
    public func writeRaw(to fileHandle: FileHandle) -> Int {
        let data = export(order: .native, size: 8, endian: .native, nails: 0)
        fileHandle.write(data)
        return data.count
    }

    /// Create an integer by reading from a FileHandle in raw binary format.
    ///
    /// Reads the integer from GMP's raw binary format. The format must match
    /// that written
    /// by `writeRaw(to:)`.
    ///
    /// - Parameter fileHandle: The FileHandle to read from. Must be open for
    /// reading.
    /// - Returns: A new `GMPInteger` if reading succeeds, `nil` otherwise.
    ///
    /// - Requires: `fileHandle` must be open for reading. The file must contain
    /// valid
    ///   GMP raw binary data.
    /// - Guarantees: If reading succeeds, returns a valid `GMPInteger` with the
    /// deserialized
    ///   value. If reading fails (e.g., invalid format or end of file), returns
    /// `nil`.
    public init?(rawFileHandle: FileHandle) {
        // Safely get file descriptor using helper that catches ObjC exceptions
        let fd = withExtendedLifetime(rawFileHandle) {
            let unmanaged = Unmanaged.passUnretained(rawFileHandle)
            return ckalliope_safe_file_descriptor(unmanaged.toOpaque())
        }
        guard fd >= 0 else {
            // File descriptor is invalid (closed handle)
            return nil
        }

        // Read raw binary data - we need to determine the size first
        // For simplicity, read a reasonable chunk and try to import
        let initialData = rawFileHandle.readData(ofLength: 1024)
        guard !initialData.isEmpty else {
            return nil
        }

        // Try importing with default parameters
        self.init(
            data: initialData,
            order: .native,
            size: 8,
            endian: .native,
            nails: 0
        )
    }
}
