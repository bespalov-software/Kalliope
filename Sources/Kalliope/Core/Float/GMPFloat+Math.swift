import CKalliope
import Foundation
import Security

/// Mathematical functions for `GMPFloat`.
extension GMPFloat {
    /// Get the square root of this float.
    ///
    /// Computes the square root using the precision of this float. If the value
    /// is negative,
    /// throws an error.
    ///
    /// - Returns: A new `GMPFloat` with the square root.
    ///
    /// - Requires: This float must be properly initialized. The value must be
    /// non-negative.
    /// - Guarantees: Returns a new `GMPFloat` with the square root, rounded to
    /// `self`'s precision.
    ///   `self` is unchanged.
    ///
    /// - Throws: May throw `GMPError.negativeSquareRoot` if the value is
    /// negative.
    ///
    /// - Note: Wraps `mpf_sqrt`.
    public func squareRoot() throws -> GMPFloat {
        guard !isNegative else {
            throw GMPError.negativeSquareRoot
        }
        let result =
            try! GMPFloat(precision: precision) // Mutated through pointer below
        __gmpf_sqrt(&result._storage.value, &_storage.value)
        return result
    }

    /// Replace this float with its square root in place.
    ///
    /// - Requires: This float must be properly initialized. The value must be
    /// non-negative.
    /// - Guarantees: After this call, `self` equals the square root of `self`
    /// (before the call),
    ///   rounded to `self`'s precision.
    ///
    /// - Throws: May throw `GMPError.negativeSquareRoot` if the value is
    /// negative.
    ///
    /// - Note: Wraps `mpf_sqrt`.
    public mutating func formSquareRoot() throws {
        // Use immutable squareRoot() + assignment pattern to avoid exclusivity
        // violations
        let result = try squareRoot()
        self = result
    }

    /// Compute the square root of an integer.
    ///
    /// - Parameter value: The integer value. Must be non-negative.
    /// - Returns: A new `GMPFloat` with the square root at default precision.
    ///
    /// - Requires: `value` must be non-negative.
    /// - Guarantees: Returns a new `GMPFloat` with the square root.
    ///
    /// - Throws: May throw `GMPError.negativeSquareRoot` if `value` is
    /// negative.
    ///
    /// - Note: Wraps `mpf_sqrt_ui`.
    public static func squareRoot(of value: Int) throws -> GMPFloat {
        guard value >= 0 else {
            throw GMPError.negativeSquareRoot
        }
        let result =
            GMPFloat() // Mutated through pointer below, default precision
        __gmpf_sqrt_ui(&result._storage.value, CUnsignedLong(value))
        return result
    }

    /// Raise this float to the power of `exponent`.
    ///
    /// Computes `self^exponent` using the precision of this float.
    ///
    /// - Parameter exponent: The exponent. Must be non-negative.
    /// - Returns: A new `GMPFloat` equal to `self^exponent`.
    ///
    /// - Requires: This float must be properly initialized. `exponent` must be
    /// non-negative.
    /// - Guarantees: Returns a new `GMPFloat` with the result, rounded to
    /// `self`'s precision.
    ///   `self` is unchanged.
    ///
    /// - Note: Wraps `mpf_pow_ui`.
    public func raisedToPower(_ exponent: Int) -> GMPFloat {
        precondition(exponent >= 0, "exponent must be non-negative")
        let result =
            try! GMPFloat(precision: precision) // Mutated through pointer below
        __gmpf_pow_ui(
            &result._storage.value,
            &_storage.value,
            CUnsignedLong(exponent)
        )
        return result
    }

    /// Replace this float with its value raised to the power of `exponent` in
    /// place.
    ///
    /// - Parameter exponent: The exponent. Must be non-negative.
    ///
    /// - Requires: This float must be properly initialized. `exponent` must be
    /// non-negative.
    /// - Guarantees: After this call, `self` equals `self^exponent` (before the
    /// call),
    ///   rounded to `self`'s precision.
    ///
    /// - Note: Wraps `mpf_pow_ui`.
    public mutating func formRaisedToPower(_ exponent: Int) {
        // Use immutable raisedToPower(_:) + assignment pattern to avoid
        // exclusivity violations
        let result = raisedToPower(exponent)
        self = result
    }

    /// Get the floor (greatest integer <= this float) of this float.
    ///
    /// - Returns: A new `GMPFloat` with the floor value.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns a new `GMPFloat` with the floor value. `self` is
    /// unchanged.
    ///
    /// - Note: Wraps `mpf_floor`.
    public var floor: GMPFloat {
        let result =
            try! GMPFloat(precision: precision) // Mutated through pointer below
        __gmpf_floor(&result._storage.value, &_storage.value)
        return result
    }

    /// Replace this float with its floor value in place.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: After this call, `self` equals the floor of `self` (before
    /// the call).
    ///
    /// - Note: Wraps `mpf_floor`.
    public mutating func formFloor() {
        // Use immutable floor property + assignment pattern to avoid
        // exclusivity violations
        let result = floor
        self = result
    }

    /// Get the ceiling (least integer >= this float) of this float.
    ///
    /// - Returns: A new `GMPFloat` with the ceiling value.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns a new `GMPFloat` with the ceiling value. `self` is
    /// unchanged.
    ///
    /// - Note: Wraps `mpf_ceil`.
    public var ceiling: GMPFloat {
        let result =
            try! GMPFloat(precision: precision) // Mutated through pointer below
        __gmpf_ceil(&result._storage.value, &_storage.value)
        return result
    }

    /// Replace this float with its ceiling value in place.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: After this call, `self` equals the ceiling of `self`
    /// (before the call).
    ///
    /// - Note: Wraps `mpf_ceil`.
    public mutating func formCeiling() {
        // Use immutable ceiling property + assignment pattern to avoid
        // exclusivity violations
        let result = ceiling
        self = result
    }

    /// Get the truncated (rounded toward zero) value of this float.
    ///
    /// - Returns: A new `GMPFloat` with the truncated value.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns a new `GMPFloat` with the truncated value. `self`
    /// is unchanged.
    ///
    /// - Note: Wraps `mpf_trunc`.
    public var truncated: GMPFloat {
        let result =
            try! GMPFloat(precision: precision) // Mutated through pointer below
        __gmpf_trunc(&result._storage.value, &_storage.value)
        return result
    }

    /// Replace this float with its truncated value in place.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: After this call, `self` equals the truncated value of
    /// `self` (before the call).
    ///
    /// - Note: Wraps `mpf_trunc`.
    public mutating func formTruncate() {
        // Use immutable truncated property + assignment pattern to avoid
        // exclusivity violations
        let result = truncated
        self = result
    }

    /// Check if this float represents an integer value.
    ///
    /// - Returns: `true` if this float has no fractional part, `false`
    /// otherwise.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns `true` if and only if this float represents an
    /// integer value.
    ///
    /// - Note: Wraps `mpf_integer_p`.
    public var isInteger: Bool {
        __gmpf_integer_p(&_storage.value) != 0
    }

    /// Compute the relative difference between two floats.
    ///
    /// Returns `|a - b| / max(|a|, |b|)`. This is useful for comparing
    /// floating-point
    /// values with a tolerance.
    ///
    /// - Parameters:
    ///   - a: The first float.
    ///   - b: The second float.
    /// - Returns: A new `GMPFloat` with the relative difference.
    ///
    /// - Requires: Both floats must be properly initialized. If both are zero,
    /// the result is 0.
    /// - Guarantees: Returns a new `GMPFloat` with the relative difference. The
    /// result is
    ///   always non-negative and in the range [0, 1] (or 0 if both values are
    /// zero).
    ///
    /// - Note: Wraps `mpf_reldiff`.
    public static func relativeDifference(
        _ a: GMPFloat,
        _ b: GMPFloat
    ) -> GMPFloat {
        let result = try! GMPFloat(precision: a
            .precision) // Mutated through pointer below
        __gmpf_reldiff(
            &result._storage.value,
            &a._storage.value,
            &b._storage.value
        )
        // GMP's mpf_reldiff can return negative values, so we take the absolute
        // value
        // to ensure the result is always non-negative as per requirements
        return result.absoluteValue()
    }

    /// Get the number of limbs used to represent this float.
    ///
    /// A limb is the fundamental unit used by GMP to store floats. The number
    /// of limbs
    /// indicates the size of the internal representation.
    ///
    /// - Returns: The number of limbs used.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Returns a non-negative integer representing the number of
    /// limbs.
    ///
    /// - Note: Wraps `mpf_size`.
    public var limbCount: Int {
        Int(__gmpf_size(&_storage.value))
    }

    /// Print a debug representation of this float to standard error.
    ///
    /// Outputs a human-readable representation of the float's internal
    /// structure,
    /// useful for debugging. The format is implementation-defined and may
    /// change.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: Outputs debug information to standard error. `self` is
    /// unchanged.
    ///
    /// - Note: For debugging only. The output format is not guaranteed to be
    /// stable.
    ///   Wraps `mpf_dump`.
    public func dump() {
        __gmpf_dump(&_storage.value)
    }

    /// Generate a random float with the given number of bits.
    ///
    /// - Warning: **Not Cryptographically Secure**: This method uses a PRNG and
    ///   is not suitable for cryptographic purposes. Use `SecRandomCopyBytes()`
    ///   or a CSPRNG for security-sensitive applications.
    ///
    /// - Parameters:
    ///   - bits: The number of bits for the mantissa. Must be positive.
    ///   - state: The random number generator state.
    /// - Returns: A new `GMPFloat` with a random value.
    ///
    /// - Requires: `bits` must be positive. `state` must be properly
    /// initialized.
    /// - Guarantees: Returns a new `GMPFloat` with a random value in the range
    /// [0, 1).
    ///
    /// - Note: Wraps `mpf_urandomb`.
    public static func random(
        bits: Int,
        using state: GMPRandomState
    ) -> GMPFloat {
        precondition(bits > 0, "bits must be positive")
        let result =
            GMPFloat() // Mutated through pointer below, default precision
        // GMP functions mutate the random state, so we need a mutable pointer
        // Since _storage is a class reference, we can get a mutable pointer to
        // its value property
        let storage = state._storage
        withUnsafeMutablePointer(to: &storage.value) { statePtr in
            __gmpf_urandomb(&result._storage.value, statePtr, mp_bitcnt_t(bits))
        }
        return result
    }

    // MARK: - Cryptographically Secure Random Numbers

    /// Generate a cryptographically secure random float with the given number
    /// of bits.
    ///
    /// Generates a uniformly distributed random float in the range [0, 1) using
    /// the system's cryptographically secure random number generator
    /// (`SecRandomCopyBytes`).
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
    /// - Parameters:
    ///   - bits: The number of bits for the mantissa. Must be positive.
    /// - Returns: A new `GMPFloat` with a cryptographically secure random value
    ///   in the range [0, 1).
    ///
    /// - Throws: `GMPError` if random number generation fails (e.g., system
    ///   entropy pool is unavailable).
    ///
    /// - Requires: `bits` must be positive.
    /// - Guarantees: Returns a new `GMPFloat` with a cryptographically secure
    ///   random value in the range [0, 1).
    public static func secureRandom(bits: Int) throws -> GMPFloat {
        precondition(bits > 0, "bits must be positive")

        // Calculate the number of bytes needed for the mantissa (round up)
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

        // Create a GMPInteger from the random bytes
        let randomInteger = GMPInteger()
        randomBytes.withUnsafeBytes { bytes in
            let wordSize = 1
            let wordCount = bytesNeeded
            __gmpz_import(
                &randomInteger._storage.value,
                size_t(wordCount),
                -1, // native byte order
                size_t(wordSize),
                0, // native endianness
                0, // no nails
                bytes.baseAddress
            )
        }

        // Mask to get exactly `bits` bits
        let maxValue = (GMPInteger(1) << bits) - 1
        let maskedInteger = randomInteger & maxValue

        // Convert to float in range [0, 1)
        // We divide by 2^bits to get a value in [0, 1)
        let divisor = GMPInteger(1) << bits

        // Create floats with higher precision for accurate division
        var numerator = try GMPFloat(precision: bits + 10)
        numerator.set(maskedInteger)
        var denominator = try GMPFloat(precision: bits + 10)
        denominator.set(divisor)

        let resultFloat = try numerator / denominator

        // Create final result with exact precision
        // According to GMP docs, set() preserves the target's precision, so we
        // create with the correct precision first, then set the value
        var finalResult = try GMPFloat(precision: bits)
        // Set the value from resultFloat - this should preserve finalResult's
        // precision
        // and round the value appropriately
        finalResult.set(resultFloat)
        return finalResult
    }
}
