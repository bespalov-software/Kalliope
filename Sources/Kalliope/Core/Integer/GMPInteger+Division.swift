import CKalliope

/// Division operations for `GMPInteger`.
///
/// GMP provides three styles of division, each with different rounding
/// behavior:
/// - **Floor division** (`fdiv`): Rounds quotient toward -∞, remainder has same
/// sign as divisor
/// - **Ceiling division** (`cdiv`): Rounds quotient toward +∞, remainder has
/// opposite sign to divisor
/// - **Truncating division** (`tdiv`): Rounds quotient toward zero, remainder
/// has same sign as dividend
///
/// In all cases, `dividend = quotient * divisor + remainder` and `0 <=
/// |remainder| < |divisor|`.
extension GMPInteger {
    // MARK: - Floor Division (Rounds Toward -∞)

    /// Divide this integer by another using floor division, returning the
    /// quotient.
    ///
    /// Floor division rounds the quotient toward -∞ (downward). The remainder
    /// will
    /// have the same sign as the divisor.
    ///
    /// - Parameter divisor: The divisor. Must not be zero.
    /// - Returns: The quotient using floor division.
    ///
    /// - Requires: This integer and `divisor` must be properly initialized.
    /// `divisor` must not be zero.
    /// - Guarantees: Returns a new `GMPInteger` with the quotient. `self` is
    /// unchanged.
    ///   The quotient and remainder satisfy: `self = quotient * divisor +
    /// remainder`,
    ///   where `remainder` has the same sign as `divisor`.
    ///
    /// - Note: Wraps `mpz_fdiv_q`.
    /// - Throws: `GMPError.divisionByZero` if `divisor` is zero.
    public func floorDivided(by divisor: GMPInteger) throws -> GMPInteger {
        guard !divisor.isZero else {
            throw GMPError.divisionByZero
        }
        let result = GMPInteger() // Mutated through pointer below
        __gmpz_fdiv_q(
            &result._storage.value,
            &_storage.value,
            &divisor._storage.value
        )
        return result
    }

    /// Divide this integer by an `Int` using floor division, returning the
    /// quotient.
    ///
    /// - Parameter divisor: The divisor. Must not be zero.
    /// - Returns: The quotient using floor division.
    ///
    /// - Requires: This integer must be properly initialized. `divisor` must
    /// not be zero.
    /// - Guarantees: Returns a new `GMPInteger` with the quotient. `self` is
    /// unchanged.
    ///
    /// - Note: Wraps `mpz_fdiv_q_ui`.
    /// - Throws: `GMPError.divisionByZero` if `divisor` is zero.
    public func floorDivided(by divisor: Int) throws -> GMPInteger {
        guard divisor != 0 else {
            throw GMPError.divisionByZero
        }
        let result = GMPInteger() // Mutated through pointer below
        // Use withUnsafePointer to avoid Swift exclusivity violation
        let opPtr = withUnsafePointer(to: _storage.value) { $0 }
        let resultPtr = withUnsafeMutablePointer(to: &result._storage.value) {
            $0
        }

        if divisor >= 0 {
            __gmpz_fdiv_q_ui(
                resultPtr,
                opPtr,
                CUnsignedLong(divisor)
            )
        } else {
            // For negative divisor, use absolute value and adjust sign
            // Handle Int.min specially to avoid arithmetic overflow
            let absDivisor: CUnsignedLong = divisor == Int
                .min ? CUnsignedLong(Int.max) + 1 : CUnsignedLong(-divisor)
            __gmpz_fdiv_q_ui(
                resultPtr,
                opPtr,
                absDivisor
            )
            __gmpz_neg(resultPtr, resultPtr)
        }
        return result
    }

    /// Get the remainder when dividing this integer by another using floor
    /// division.
    ///
    /// - Parameter divisor: The divisor. Must not be zero.
    /// - Returns: The remainder, which has the same sign as `divisor`.
    ///
    /// - Requires: This integer and `divisor` must be properly initialized.
    /// `divisor` must not be zero.
    /// - Guarantees: Returns a new `GMPInteger` with the remainder. `self` is
    /// unchanged.
    ///   The remainder satisfies: `0 <= |remainder| < |divisor|` and has the
    /// same sign as `divisor`.
    ///
    /// - Note: Wraps `mpz_fdiv_r`.
    /// - Throws: `GMPError.divisionByZero` if `divisor` is zero.
    public func floorRemainder(dividingBy divisor: GMPInteger) throws
        -> GMPInteger
    {
        guard !divisor.isZero else {
            throw GMPError.divisionByZero
        }
        let result = GMPInteger() // Mutated through pointer below
        __gmpz_fdiv_r(
            &result._storage.value,
            &_storage.value,
            &divisor._storage.value
        )
        return result
    }

    /// Get the remainder when dividing this integer by an `Int` using floor
    /// division.
    ///
    /// - Parameter divisor: The divisor. Must not be zero.
    /// - Returns: The remainder as an `Int`, which has the same sign as
    /// `divisor`.
    ///
    /// - Requires: This integer must be properly initialized. `divisor` must
    /// not be zero.
    /// - Guarantees: Returns the remainder. `self` is unchanged.
    ///
    /// - Note: Wraps `mpz_fdiv_r_ui`.
    /// - Throws: `GMPError.divisionByZero` if `divisor` is zero.
    public func floorRemainder(dividingBy divisor: Int) throws -> Int {
        guard divisor != 0 else {
            throw GMPError.divisionByZero
        }
        let absDivisor = abs(divisor)
        // Use temporary variable since this is a non-mutating function
        // __gmpz_fdiv_r_ui modifies the first parameter, so we can't use
        // _storage.value directly
        let temp = GMPInteger() // Mutated through pointer below
        // Use withUnsafePointer to avoid Swift exclusivity violation
        let opPtr = withUnsafePointer(to: _storage.value) { $0 }
        let remainder = __gmpz_fdiv_r_ui(
            &temp._storage.value,
            opPtr,
            CUnsignedLong(absDivisor)
        )
        // Adjust sign: remainder should have same sign as divisor
        if divisor < 0 {
            return -Int(remainder)
        } else {
            return Int(remainder)
        }
    }

    /// Divide this integer by another using floor division, returning both
    /// quotient and remainder.
    ///
    /// - Parameter divisor: The divisor. Must not be zero.
    /// - Returns: A tuple `(quotient, remainder)` where the quotient is rounded
    /// toward -∞
    ///   and the remainder has the same sign as `divisor`.
    ///
    /// - Requires: This integer and `divisor` must be properly initialized.
    /// `divisor` must not be zero.
    /// - Guarantees: Returns a tuple with quotient and remainder. `self` is
    /// unchanged.
    ///   The values satisfy: `self = quotient * divisor + remainder`.
    ///
    /// - Note: Wraps `mpz_fdiv_qr`.
    /// - Throws: `GMPError.divisionByZero` if `divisor` is zero.
    public func floorQuotientAndRemainder(dividingBy divisor: GMPInteger) throws
        -> (quotient: GMPInteger, remainder: GMPInteger)
    {
        guard !divisor.isZero else {
            throw GMPError.divisionByZero
        }
        let quotient = GMPInteger() // Mutated through pointer below
        let remainder = GMPInteger() // Mutated through pointer below
        __gmpz_fdiv_qr(
            &quotient._storage.value,
            &remainder._storage.value,
            &_storage.value,
            &divisor._storage.value
        )
        return (quotient, remainder)
    }

    /// Divide this integer by an `Int` using floor division, returning both
    /// quotient and remainder.
    ///
    /// - Parameter divisor: The divisor. Must not be zero.
    /// - Returns: A tuple `(quotient, remainder)` where the quotient is a
    /// `GMPInteger`
    ///   and the remainder is an `Int` with the same sign as `divisor`.
    ///
    /// - Requires: This integer must be properly initialized. `divisor` must
    /// not be zero.
    /// - Guarantees: Returns a tuple with quotient and remainder. `self` is
    /// unchanged.
    ///
    /// - Note: Wraps `mpz_fdiv_qr_ui`.
    /// - Throws: `GMPError.divisionByZero` if `divisor` is zero.
    public func floorQuotientAndRemainder(dividingBy divisor: Int) throws
        -> (quotient: GMPInteger, remainder: Int)
    {
        guard divisor != 0 else {
            throw GMPError.divisionByZero
        }
        let quotient = GMPInteger() // Mutated through pointer below
        let remainderTemp = GMPInteger() // Mutated through pointer below
        let absDivisor = abs(divisor)
        let remainderValue = __gmpz_fdiv_qr_ui(
            &quotient._storage.value,
            &remainderTemp._storage.value,
            &_storage.value,
            CUnsignedLong(absDivisor)
        )
        // Adjust sign: remainder should have same sign as divisor
        let signedRemainder = divisor < 0 ? -Int(remainderValue) :
            Int(remainderValue)
        return (quotient, signedRemainder)
    }

    // MARK: - Ceiling Division (Rounds Toward +∞)

    /// Divide this integer by another using ceiling division, returning the
    /// quotient.
    ///
    /// Ceiling division rounds the quotient toward +∞ (upward). The remainder
    /// will
    /// have the opposite sign to the divisor.
    ///
    /// - Parameter divisor: The divisor. Must not be zero.
    /// - Returns: The quotient using ceiling division.
    ///
    /// - Requires: This integer and `divisor` must be properly initialized.
    /// `divisor` must not be zero.
    /// - Guarantees: Returns a new `GMPInteger` with the quotient. `self` is
    /// unchanged.
    ///   The remainder has the opposite sign to `divisor`.
    ///
    /// - Note: Wraps `mpz_cdiv_q`.
    /// - Throws: `GMPError.divisionByZero` if `divisor` is zero.
    public func ceilingDivided(by divisor: GMPInteger) throws -> GMPInteger {
        guard !divisor.isZero else {
            throw GMPError.divisionByZero
        }
        let result = GMPInteger() // Mutated through pointer below
        __gmpz_cdiv_q(
            &result._storage.value,
            &_storage.value,
            &divisor._storage.value
        )
        return result
    }

    /// Divide this integer by an `Int` using ceiling division, returning the
    /// quotient.
    ///
    /// - Parameter divisor: The divisor. Must not be zero.
    /// - Returns: The quotient using ceiling division.
    ///
    /// - Requires: This integer must be properly initialized. `divisor` must
    /// not be zero.
    /// - Guarantees: Returns a new `GMPInteger` with the quotient. `self` is
    /// unchanged.
    ///
    /// - Note: Wraps `mpz_cdiv_q_ui`.
    /// - Throws: `GMPError.divisionByZero` if `divisor` is zero.
    public func ceilingDivided(by divisor: Int) throws -> GMPInteger {
        guard divisor != 0 else {
            throw GMPError.divisionByZero
        }
        let result = GMPInteger() // Mutated through pointer below
        // Use withUnsafePointer to avoid Swift exclusivity violation
        // Store values needed outside the closure
        let divisorValue = divisor
        let opPtr = withUnsafePointer(to: _storage.value) { $0 }
        let resultPtr = withUnsafeMutablePointer(to: &result._storage.value) {
            $0
        }

        if divisorValue >= 0 {
            __gmpz_cdiv_q_ui(
                resultPtr,
                opPtr,
                CUnsignedLong(divisorValue)
            )
        } else {
            // For negative divisor, use absolute value and adjust sign
            // Handle Int.min specially to avoid arithmetic overflow
            let absDivisor: CUnsignedLong = divisorValue == Int
                .min ? CUnsignedLong(Int.max) + 1 : CUnsignedLong(-divisorValue)
            __gmpz_cdiv_q_ui(
                resultPtr,
                opPtr,
                absDivisor
            )
            __gmpz_neg(resultPtr, resultPtr)
        }
        return result
    }

    /// Get the remainder when dividing this integer by another using ceiling
    /// division.
    ///
    /// - Parameter divisor: The divisor. Must not be zero.
    /// - Returns: The remainder, which has the opposite sign to `divisor`.
    ///
    /// - Requires: This integer and `divisor` must be properly initialized.
    /// `divisor` must not be zero.
    /// - Guarantees: Returns a new `GMPInteger` with the remainder. `self` is
    /// unchanged.
    ///   The remainder has the opposite sign to `divisor`.
    ///
    /// - Note: Wraps `mpz_cdiv_r`.
    /// - Throws: `GMPError.divisionByZero` if `divisor` is zero.
    public func ceilingRemainder(dividingBy divisor: GMPInteger) throws
        -> GMPInteger
    {
        guard !divisor.isZero else {
            throw GMPError.divisionByZero
        }
        let result = GMPInteger() // Mutated through pointer below
        __gmpz_cdiv_r(
            &result._storage.value,
            &_storage.value,
            &divisor._storage.value
        )
        return result
    }

    /// Get the remainder when dividing this integer by an `Int` using ceiling
    /// division.
    ///
    /// - Parameter divisor: The divisor. Must not be zero.
    /// - Returns: The remainder as an `Int`, which has the opposite sign to
    /// `divisor`.
    ///
    /// - Requires: This integer must be properly initialized. `divisor` must
    /// not be zero.
    /// - Guarantees: Returns the remainder. `self` is unchanged.
    ///
    /// - Note: Wraps `mpz_cdiv_r_ui`.
    /// - Throws: `GMPError.divisionByZero` if `divisor` is zero.
    public func ceilingRemainder(dividingBy divisor: Int) throws -> Int {
        guard divisor != 0 else {
            throw GMPError.divisionByZero
        }
        let absDivisor = abs(divisor)
        // Use temporary variable since this is a non-mutating function
        // __gmpz_cdiv_r_ui modifies the first parameter, so we can't use
        // _storage.value directly
        let temp = GMPInteger() // Mutated through pointer below
        // Use withUnsafePointer to avoid Swift exclusivity violation
        let remainder = withUnsafePointer(to: _storage.value) { op in
            __gmpz_cdiv_r_ui(
                &temp._storage.value,
                op,
                CUnsignedLong(absDivisor)
            )
        }
        // Adjust sign: remainder should have opposite sign to divisor
        if divisor < 0 {
            return Int(remainder)
        } else {
            return -Int(remainder)
        }
    }

    /// Divide this integer by another using ceiling division, returning both
    /// quotient and remainder.
    ///
    /// - Parameter divisor: The divisor. Must not be zero.
    /// - Returns: A tuple `(quotient, remainder)` where the quotient is rounded
    /// toward +∞
    ///   and the remainder has the opposite sign to `divisor`.
    ///
    /// - Requires: This integer and `divisor` must be properly initialized.
    /// `divisor` must not be zero.
    /// - Guarantees: Returns a tuple with quotient and remainder. `self` is
    /// unchanged.
    ///
    /// - Note: Wraps `mpz_cdiv_qr`.
    /// - Throws: `GMPError.divisionByZero` if `divisor` is zero.
    public func ceilingQuotientAndRemainder(
        dividingBy divisor: GMPInteger
    ) throws
        -> (quotient: GMPInteger, remainder: GMPInteger)
    {
        guard !divisor.isZero else {
            throw GMPError.divisionByZero
        }
        let quotient = GMPInteger() // Mutated through pointer below
        let remainder = GMPInteger() // Mutated through pointer below
        __gmpz_cdiv_qr(
            &quotient._storage.value,
            &remainder._storage.value,
            &_storage.value,
            &divisor._storage.value
        )
        return (quotient, remainder)
    }

    /// Divide this integer by an `Int` using ceiling division, returning both
    /// quotient and remainder.
    ///
    /// - Parameter divisor: The divisor. Must not be zero.
    /// - Returns: A tuple `(quotient, remainder)` where the quotient is a
    /// `GMPInteger`
    ///   and the remainder is an `Int` with the opposite sign to `divisor`.
    ///
    /// - Requires: This integer must be properly initialized. `divisor` must
    /// not be zero.
    /// - Guarantees: Returns a tuple with quotient and remainder. `self` is
    /// unchanged.
    ///
    /// - Note: Wraps `mpz_cdiv_qr_ui`.
    /// - Throws: `GMPError.divisionByZero` if `divisor` is zero.
    public func ceilingQuotientAndRemainder(dividingBy divisor: Int) throws
        -> (quotient: GMPInteger, remainder: Int)
    {
        guard divisor != 0 else {
            throw GMPError.divisionByZero
        }
        let quotient = GMPInteger() // Mutated through pointer below
        let remainderTemp = GMPInteger() // Mutated through pointer below
        let absDivisor = abs(divisor)
        // Use withUnsafePointer to avoid Swift exclusivity violation
        let opPtr = withUnsafePointer(to: _storage.value) { $0 }
        let quotientPtr = withUnsafeMutablePointer(to: &quotient._storage
            .value) { $0 }
        let remainderValue = __gmpz_cdiv_qr_ui(
            quotientPtr,
            &remainderTemp._storage.value,
            opPtr,
            CUnsignedLong(absDivisor)
        )
        // For negative divisor, negate the quotient (same as in ceilingDivided)
        if divisor < 0 {
            __gmpz_neg(quotientPtr, quotientPtr)
        }
        // Adjust sign: remainder should have opposite sign to divisor
        let signedRemainder = divisor < 0 ? Int(remainderValue) :
            -Int(remainderValue)
        return (quotient, signedRemainder)
    }

    // MARK: - Truncating Division (Rounds Toward Zero)

    /// Divide this integer by another using truncating division, returning the
    /// quotient.
    ///
    /// Truncating division rounds the quotient toward zero. The remainder will
    /// have
    /// the same sign as the dividend. This is the same as C's `/` operator.
    ///
    /// - Parameter divisor: The divisor. Must not be zero.
    /// - Returns: The quotient using truncating division.
    ///
    /// - Requires: This integer and `divisor` must be properly initialized.
    /// `divisor` must not be zero.
    /// - Guarantees: Returns a new `GMPInteger` with the quotient. `self` is
    /// unchanged.
    ///   The remainder has the same sign as `self`.
    ///
    /// - Note: Wraps `mpz_tdiv_q`.
    /// - Throws: `GMPError.divisionByZero` if `divisor` is zero.
    public func truncatedDivided(by divisor: GMPInteger) throws -> GMPInteger {
        guard !divisor.isZero else {
            throw GMPError.divisionByZero
        }
        let result = GMPInteger() // Mutated through pointer below
        __gmpz_tdiv_q(
            &result._storage.value,
            &_storage.value,
            &divisor._storage.value
        )
        return result
    }

    /// Divide this integer by an `Int` using truncating division, returning the
    /// quotient.
    ///
    /// - Parameter divisor: The divisor. Must not be zero.
    /// - Returns: The quotient using truncating division.
    ///
    /// - Requires: This integer must be properly initialized. `divisor` must
    /// not be zero.
    /// - Guarantees: Returns a new `GMPInteger` with the quotient. `self` is
    /// unchanged.
    ///
    /// - Note: Wraps `mpz_tdiv_q_ui`.
    /// - Throws: `GMPError.divisionByZero` if `divisor` is zero.
    public func truncatedDivided(by divisor: Int) throws -> GMPInteger {
        guard divisor != 0 else {
            throw GMPError.divisionByZero
        }
        let result = GMPInteger() // Mutated through pointer below
        // Use withUnsafePointer to avoid Swift exclusivity violation
        let opPtr = withUnsafePointer(to: _storage.value) { $0 }
        let resultPtr = withUnsafeMutablePointer(to: &result._storage.value) {
            $0
        }
        if divisor >= 0 {
            __gmpz_tdiv_q_ui(
                resultPtr,
                opPtr,
                CUnsignedLong(divisor)
            )
        } else {
            // For negative divisor, use absolute value and adjust sign
            // Handle Int.min specially to avoid arithmetic overflow
            let absDivisor: CUnsignedLong = divisor == Int
                .min ? CUnsignedLong(Int.max) + 1 : CUnsignedLong(-divisor)
            __gmpz_tdiv_q_ui(
                resultPtr,
                opPtr,
                absDivisor
            )
            __gmpz_neg(resultPtr, resultPtr)
        }
        return result
    }

    /// Get the remainder when dividing this integer by another using truncating
    /// division.
    ///
    /// - Parameter divisor: The divisor. Must not be zero.
    /// - Returns: The remainder, which has the same sign as `self`.
    ///
    /// - Requires: This integer and `divisor` must be properly initialized.
    /// `divisor` must not be zero.
    /// - Guarantees: Returns a new `GMPInteger` with the remainder. `self` is
    /// unchanged.
    ///   The remainder has the same sign as `self`.
    ///
    /// - Note: Wraps `mpz_tdiv_r`.
    /// - Throws: `GMPError.divisionByZero` if `divisor` is zero.
    public func truncatedRemainder(dividingBy divisor: GMPInteger) throws
        -> GMPInteger
    {
        guard !divisor.isZero else {
            throw GMPError.divisionByZero
        }
        let result = GMPInteger() // Mutated through pointer below
        __gmpz_tdiv_r(
            &result._storage.value,
            &_storage.value,
            &divisor._storage.value
        )
        return result
    }

    /// Get the remainder when dividing this integer by an `Int` using
    /// truncating division.
    ///
    /// - Parameter divisor: The divisor. Must not be zero.
    /// - Returns: The remainder as an `Int`, which has the same sign as `self`.
    ///
    /// - Requires: This integer must be properly initialized. `divisor` must
    /// not be zero.
    /// - Guarantees: Returns the remainder. `self` is unchanged.
    ///
    /// - Note: Wraps `mpz_tdiv_r_ui`.
    /// - Throws: `GMPError.divisionByZero` if `divisor` is zero.
    public func truncatedRemainder(dividingBy divisor: Int) throws -> Int {
        guard divisor != 0 else {
            throw GMPError.divisionByZero
        }
        let absDivisor = abs(divisor)
        // Use temporary variable since this is a non-mutating function
        // __gmpz_tdiv_r_ui modifies the first parameter, so we can't use
        // _storage.value directly
        let temp = GMPInteger() // Mutated through pointer below
        // Use withUnsafePointer to avoid Swift exclusivity violation
        let opPtr = withUnsafePointer(to: _storage.value) { $0 }
        let tempPtr = withUnsafeMutablePointer(to: &temp._storage.value) { $0 }
        let remainder = __gmpz_tdiv_r_ui(
            tempPtr,
            opPtr,
            CUnsignedLong(absDivisor)
        )
        // Adjust sign: remainder should have same sign as dividend (self)
        if sign < 0 {
            return -Int(remainder)
        } else {
            return Int(remainder)
        }
    }

    /// Divide this integer by another using truncating division, returning both
    /// quotient and remainder.
    ///
    /// - Parameter divisor: The divisor. Must not be zero.
    /// - Returns: A tuple `(quotient, remainder)` where the quotient is rounded
    /// toward zero
    ///   and the remainder has the same sign as `self`.
    ///
    /// - Requires: This integer and `divisor` must be properly initialized.
    /// `divisor` must not be zero.
    /// - Guarantees: Returns a tuple with quotient and remainder. `self` is
    /// unchanged.
    ///
    /// - Note: Wraps `mpz_tdiv_qr`.
    /// - Throws: `GMPError.divisionByZero` if `divisor` is zero.
    public func truncatedQuotientAndRemainder(
        dividingBy divisor: GMPInteger
    ) throws
        -> (quotient: GMPInteger, remainder: GMPInteger)
    {
        guard !divisor.isZero else {
            throw GMPError.divisionByZero
        }
        let quotient = GMPInteger() // Mutated through pointer below
        let remainder = GMPInteger() // Mutated through pointer below
        __gmpz_tdiv_qr(
            &quotient._storage.value,
            &remainder._storage.value,
            &_storage.value,
            &divisor._storage.value
        )
        return (quotient, remainder)
    }

    /// Divide this integer by an `Int` using truncating division, returning
    /// both quotient and remainder.
    ///
    /// - Parameter divisor: The divisor. Must not be zero.
    /// - Returns: A tuple `(quotient, remainder)` where the quotient is a
    /// `GMPInteger`
    ///   and the remainder is an `Int` with the same sign as `self`.
    ///
    /// - Requires: This integer must be properly initialized. `divisor` must
    /// not be zero.
    /// - Guarantees: Returns a tuple with quotient and remainder. `self` is
    /// unchanged.
    ///
    /// - Note: Wraps `mpz_tdiv_qr_ui`.
    /// - Throws: `GMPError.divisionByZero` if `divisor` is zero.
    public func truncatedQuotientAndRemainder(dividingBy divisor: Int) throws
        -> (quotient: GMPInteger, remainder: Int)
    {
        guard divisor != 0 else {
            throw GMPError.divisionByZero
        }
        let quotient = GMPInteger() // Mutated through pointer below
        let remainderTemp = GMPInteger() // Mutated through pointer below
        let absDivisor = abs(divisor)
        // Use withUnsafePointer to avoid Swift exclusivity violation
        let opPtr = withUnsafePointer(to: _storage.value) { $0 }
        let quotientPtr = withUnsafeMutablePointer(to: &quotient._storage
            .value) { $0 }
        let remainderTempPtr = withUnsafeMutablePointer(to: &remainderTemp
            ._storage.value) { $0 }
        let remainderValue = __gmpz_tdiv_qr_ui(
            quotientPtr,
            remainderTempPtr,
            opPtr,
            CUnsignedLong(absDivisor)
        )
        // For negative divisor, negate the quotient (same as in
        // truncatedDivided)
        if divisor < 0 {
            __gmpz_neg(quotientPtr, quotientPtr)
        }
        // Adjust sign: remainder should have same sign as dividend (self)
        let signedRemainder = sign < 0 ? -Int(remainderValue) :
            Int(remainderValue)
        return (quotient, signedRemainder)
    }

    // MARK: - Modulo (Always Non-Negative)

    /// Compute this integer modulo another, returning a non-negative result.
    ///
    /// The sign of the modulus is ignored. The result is always non-negative
    /// and
    /// equivalent to `floorRemainder(dividingBy:)` when the modulus is
    /// positive.
    ///
    /// - Parameter modulus: The modulus. Must not be zero.
    /// - Returns: A new `GMPInteger` with the result, always non-negative.
    ///
    /// - Requires: This integer and `modulus` must be properly initialized.
    /// `modulus` must not be zero.
    /// - Guarantees: Returns a new `GMPInteger` with a non-negative result.
    /// `self` is unchanged.
    ///   The result satisfies: `0 <= result < |modulus|`.
    ///
    /// - Note: Wraps `mpz_mod`.
    /// - Throws: `GMPError.divisionByZero` if `modulus` is zero.
    public func modulo(_ modulus: GMPInteger) throws -> GMPInteger {
        guard !modulus.isZero else {
            throw GMPError.divisionByZero
        }
        let result = GMPInteger() // Mutated through pointer below
        __gmpz_mod(
            &result._storage.value,
            &_storage.value,
            &modulus._storage.value
        )
        return result
    }

    /// Compute this integer modulo an `Int`, returning a non-negative result.
    ///
    /// - Parameter modulus: The modulus. Must not be zero.
    /// - Returns: The result as an `Int`, always non-negative.
    ///
    /// - Requires: This integer must be properly initialized. `modulus` must
    /// not be zero.
    /// - Guarantees: Returns a non-negative `Int`. `self` is unchanged.
    ///
    /// - Note: Wraps `mpz_mod_ui`.
    /// - Throws: `GMPError.divisionByZero` if `modulus` is zero.
    public func modulo(_ modulus: Int) throws -> Int {
        guard modulus != 0 else {
            throw GMPError.divisionByZero
        }
        let absModulus = abs(modulus)
        // Use withUnsafePointer to avoid Swift exclusivity violation
        let opPtr = withUnsafePointer(to: _storage.value) { $0 }
        let result = __gmpz_fdiv_ui(opPtr, CUnsignedLong(absModulus))
        return Int(result)
    }

    // MARK: - Exact Division (Faster When Divisor Divides Dividend)

    /// Divide this integer by another, assuming the division is exact.
    ///
    /// This function is much faster than regular division, but **only**
    /// produces correct
    /// results when the divisor exactly divides the dividend. If the division
    /// is not exact,
    /// the result is undefined (may be incorrect or cause a crash).
    ///
    /// Use this when you know the division is exact, for example when reducing
    /// a rational
    /// to lowest terms.
    ///
    /// - Parameter divisor: The divisor. Must not be zero, and must exactly
    /// divide `self`.
    /// - Returns: A new `GMPInteger` with the quotient.
    ///
    /// - Requires: This integer and `divisor` must be properly initialized.
    /// `divisor` must
    ///   not be zero, and must exactly divide `self`. Use `isDivisible(by:)` to
    /// verify.
    /// - Guarantees: Returns a new `GMPInteger` with the quotient if the
    /// division is exact.
    ///   If not exact, the result is undefined. `self` is unchanged.
    ///
    /// - Warning: **Only use this when you are certain the division is exact.**
    /// Otherwise,
    ///   use `truncatedDivided(by:)` or another division function.
    ///
    /// - Note: Wraps `mpz_divexact`.
    /// - Throws: `GMPError.divisionByZero` if `divisor` is zero.
    public func exactlyDivided(by divisor: GMPInteger) throws -> GMPInteger {
        guard !divisor.isZero else {
            throw GMPError.divisionByZero
        }
        let result = GMPInteger() // Mutated through pointer below
        __gmpz_divexact(
            &result._storage.value,
            &_storage.value,
            &divisor._storage.value
        )
        return result
    }

    /// Divide this integer by an `Int`, assuming the division is exact.
    ///
    /// - Parameter divisor: The divisor. Must not be zero, and must exactly
    /// divide `self`.
    /// - Returns: A new `GMPInteger` with the quotient.
    ///
    /// - Requires: This integer must be properly initialized. `divisor` must
    /// not be zero,
    ///   and must exactly divide `self`.
    /// - Guarantees: Returns a new `GMPInteger` with the quotient if the
    /// division is exact.
    ///   If not exact, the result is undefined. `self` is unchanged.
    ///
    /// - Warning: **Only use this when you are certain the division is exact.**
    ///
    /// - Note: Wraps `mpz_divexact_ui`.
    /// - Throws: `GMPError.divisionByZero` if `divisor` is zero.
    public func exactlyDivided(by divisor: Int) throws -> GMPInteger {
        guard divisor != 0 else {
            throw GMPError.divisionByZero
        }
        let result = GMPInteger() // Mutated through pointer below
        let absDivisor = abs(divisor)
        // Use withUnsafePointer to avoid Swift exclusivity violation
        let opPtr = withUnsafePointer(to: _storage.value) { $0 }
        let resultPtr = withUnsafeMutablePointer(to: &result._storage.value) {
            $0
        }
        __gmpz_divexact_ui(
            resultPtr,
            opPtr,
            CUnsignedLong(absDivisor)
        )
        // Adjust sign if divisor was negative
        if divisor < 0 {
            __gmpz_neg(resultPtr, resultPtr)
        }
        return result
    }

    // MARK: - Divisibility Tests

    /// Check if this integer is exactly divisible by another.
    ///
    /// Returns `true` if there exists an integer `q` such that `self = q *
    /// divisor`.
    /// Unlike other division functions, `divisor` may be zero (only 0 is
    /// divisible by 0).
    ///
    /// - Parameter divisor: The divisor to test.
    /// - Returns: `true` if `self` is divisible by `divisor`, `false`
    /// otherwise.
    ///
    /// - Requires: This integer and `divisor` must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `exactlyDivided(by:)` would
    /// produce
    ///   a correct result (or if both are zero).
    ///
    /// - Note: Wraps `mpz_divisible_p`.
    public func isDivisible(by divisor: GMPInteger) -> Bool {
        // Special case: 0 is divisible by 0, but nothing else is divisible by 0
        if divisor.isZero {
            return isZero
        }
        return __gmpz_divisible_p(&_storage.value, &divisor._storage.value) != 0
    }

    /// Check if this integer is exactly divisible by an `Int`.
    ///
    /// - Parameter divisor: The divisor to test. May be zero (only 0 is
    /// divisible by 0).
    /// - Returns: `true` if `self` is divisible by `divisor`, `false`
    /// otherwise.
    ///
    /// - Requires: This integer must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `exactlyDivided(by:)` would
    /// produce
    ///   a correct result.
    ///
    /// - Note: Wraps `mpz_divisible_ui_p`.
    public func isDivisible(by divisor: Int) -> Bool {
        // Special case: 0 is divisible by 0, but nothing else is divisible by 0
        if divisor == 0 {
            return isZero
        }
        let absDivisor = abs(divisor)
        return __gmpz_divisible_ui_p(
            &_storage.value,
            CUnsignedLong(absDivisor)
        ) != 0
    }

    /// Check if this integer is exactly divisible by a power of 2.
    ///
    /// - Parameter exponent: The exponent for the power of 2 (i.e., test
    /// divisibility by 2^exponent).
    ///   Must be non-negative.
    /// - Returns: `true` if `self` is divisible by 2^exponent, `false`
    /// otherwise.
    ///
    /// - Requires: This integer must be properly initialized. `exponent` must
    /// be non-negative.
    /// - Guarantees: Returns `true` if and only if the integer is divisible by
    /// 2^exponent.
    ///
    /// - Note: Wraps `mpz_divisible_2exp_p`.
    /// - Throws: `GMPError.invalidExponent` if `exponent` is negative.
    public func isDivisible(byPowerOf2 exponent: Int) throws -> Bool {
        guard exponent >= 0 else {
            throw GMPError.invalidExponent(exponent)
        }
        return __gmpz_divisible_2exp_p(
            &_storage.value,
            mp_bitcnt_t(exponent)
        ) !=
            0
    }

    // MARK: - Congruence Tests

    /// Check if this integer is congruent to another modulo a given modulus.
    ///
    /// Two integers are congruent modulo `modulus` if their difference is
    /// divisible by `modulus`.
    /// Returns `true` if there exists an integer `q` such that `self = value +
    /// q * modulus`.
    ///
    /// Unlike other division functions, `modulus` may be zero (only equal
    /// values are congruent mod 0).
    ///
    /// - Parameters:
    ///   - value: The value to compare against.
    ///   - modulus: The modulus. May be zero (only equal values are congruent
    /// mod 0).
    /// - Returns: `true` if `self ≡ value (mod modulus)`, `false` otherwise.
    ///
    /// - Requires: All integers must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `(self - value) % modulus ==
    /// 0`
    ///   (when modulus != 0).
    ///
    /// - Note: Wraps `mpz_congruent_p`.
    public func isCongruent(
        to value: GMPInteger,
        modulo modulus: GMPInteger
    ) -> Bool {
        // Special case: mod 0 means equality
        if modulus.isZero {
            return self == value
        }
        return __gmpz_congruent_p(
            &_storage.value,
            &value._storage.value,
            &modulus._storage.value
        ) != 0
    }

    /// Check if this integer is congruent to an `Int` modulo another `Int`.
    ///
    /// - Parameters:
    ///   - value: The `Int` value to compare against.
    ///   - modulus: The modulus as an `Int`. May be zero.
    /// - Returns: `true` if `self ≡ value (mod modulus)`, `false` otherwise.
    ///
    /// - Requires: This integer must be properly initialized.
    /// - Guarantees: Returns `true` if and only if the congruence relation
    /// holds.
    ///
    /// - Note: Wraps `mpz_congruent_ui_p`.
    public func isCongruent(to value: Int, modulo modulus: Int) -> Bool {
        // Special case: mod 0 means equality
        if modulus == 0 {
            return self == GMPInteger(value)
        }
        let absModulus = abs(modulus)
        // Reduce value modulo absModulus to handle negative values correctly
        // For negative values, we want value mod absModulus in range [0,
        // absModulus-1]
        let reducedValue: CUnsignedLong
        if value < 0 {
            // For negative value, compute (value mod absModulus)
            // This is equivalent to absModulus - ((-value) % absModulus) if
            // value % absModulus != 0
            let absValue = CUnsignedLong(-value)
            let remainder = absValue % CUnsignedLong(absModulus)
            reducedValue = remainder == 0 ? 0 : CUnsignedLong(absModulus) -
                remainder
        } else {
            reducedValue = CUnsignedLong(value) % CUnsignedLong(absModulus)
        }
        return __gmpz_congruent_ui_p(
            &_storage.value,
            reducedValue,
            CUnsignedLong(absModulus)
        ) != 0
    }

    /// Check if this integer is congruent to another modulo a power of 2.
    ///
    /// - Parameters:
    ///   - value: The value to compare against.
    ///   - exponent: The exponent for the power of 2 (i.e., test congruence mod
    /// 2^exponent).
    ///     Must be non-negative.
    /// - Returns: `true` if `self ≡ value (mod 2^exponent)`, `false` otherwise.
    ///
    /// - Requires: Both integers must be properly initialized. `exponent` must
    /// be non-negative.
    /// - Guarantees: Returns `true` if and only if the congruence relation
    /// holds.
    ///
    /// - Note: Wraps `mpz_congruent_2exp_p`.
    /// - Throws: `GMPError.invalidExponent` if `exponent` is negative.
    public func isCongruent(
        to value: GMPInteger,
        moduloPowerOf2 exponent: Int
    ) throws -> Bool {
        guard exponent >= 0 else {
            throw GMPError.invalidExponent(exponent)
        }
        return __gmpz_congruent_2exp_p(
            &_storage.value,
            &value._storage.value,
            mp_bitcnt_t(exponent)
        ) != 0
    }

    // MARK: - Power of 2 Division

    /// Divide this integer by 2^exponent using floor division.
    ///
    /// Equivalent to a right shift for positive values, but handles negative
    /// values
    /// as arithmetic right shift (two's complement).
    ///
    /// - Parameter exponent: The exponent for the power of 2. Must be
    /// non-negative.
    /// - Returns: A new `GMPInteger` with the quotient.
    ///
    /// - Requires: This integer must be properly initialized. `exponent` must
    /// be non-negative.
    /// - Guarantees: Returns a new `GMPInteger` with the quotient. `self` is
    /// unchanged.
    ///
    /// - Note: Wraps `mpz_fdiv_q_2exp`.
    /// - Throws: `GMPError.invalidExponent` if `exponent` is negative.
    public func floorDividedByPowerOf2(_ exponent: Int) throws -> GMPInteger {
        guard exponent >= 0 else {
            throw GMPError.invalidExponent(exponent)
        }
        let result = GMPInteger() // Mutated through pointer below
        __gmpz_fdiv_q_2exp(
            &result._storage.value,
            &_storage.value,
            mp_bitcnt_t(exponent)
        )
        return result
    }

    /// Get the remainder when dividing this integer by 2^exponent using floor
    /// division.
    ///
    /// - Parameter exponent: The exponent for the power of 2. Must be
    /// non-negative.
    /// - Returns: A new `GMPInteger` with the remainder.
    ///
    /// - Requires: This integer must be properly initialized. `exponent` must
    /// be non-negative.
    /// - Guarantees: Returns a new `GMPInteger` with the remainder. `self` is
    /// unchanged.
    ///
    /// - Note: Wraps `mpz_fdiv_r_2exp`.
    /// - Throws: `GMPError.invalidExponent` if `exponent` is negative.
    public func floorRemainderDividingByPowerOf2(_ exponent: Int) throws
        -> GMPInteger
    {
        guard exponent >= 0 else {
            throw GMPError.invalidExponent(exponent)
        }
        let result = GMPInteger() // Mutated through pointer below
        __gmpz_fdiv_r_2exp(
            &result._storage.value,
            &_storage.value,
            mp_bitcnt_t(exponent)
        )
        return result
    }

    /// Divide this integer by 2^exponent using ceiling division.
    ///
    /// - Parameter exponent: The exponent for the power of 2. Must be
    /// non-negative.
    /// - Returns: A new `GMPInteger` with the quotient.
    ///
    /// - Requires: This integer must be properly initialized. `exponent` must
    /// be non-negative.
    /// - Guarantees: Returns a new `GMPInteger` with the quotient. `self` is
    /// unchanged.
    ///
    /// - Note: Wraps `mpz_cdiv_q_2exp`.
    /// - Throws: `GMPError.invalidExponent` if `exponent` is negative.
    public func ceilingDividedByPowerOf2(_ exponent: Int) throws -> GMPInteger {
        guard exponent >= 0 else {
            throw GMPError.invalidExponent(exponent)
        }
        let result = GMPInteger() // Mutated through pointer below
        __gmpz_cdiv_q_2exp(
            &result._storage.value,
            &_storage.value,
            mp_bitcnt_t(exponent)
        )
        return result
    }

    /// Get the remainder when dividing this integer by 2^exponent using ceiling
    /// division.
    ///
    /// - Parameter exponent: The exponent for the power of 2. Must be
    /// non-negative.
    /// - Returns: A new `GMPInteger` with the remainder.
    ///
    /// - Requires: This integer must be properly initialized. `exponent` must
    /// be non-negative.
    /// - Guarantees: Returns a new `GMPInteger` with the remainder. `self` is
    /// unchanged.
    ///
    /// - Note: Wraps `mpz_cdiv_r_2exp`.
    /// - Throws: `GMPError.invalidExponent` if `exponent` is negative.
    public func ceilingRemainderDividingByPowerOf2(_ exponent: Int) throws
        -> GMPInteger
    {
        guard exponent >= 0 else {
            throw GMPError.invalidExponent(exponent)
        }
        let result = GMPInteger() // Mutated through pointer below
        __gmpz_cdiv_r_2exp(
            &result._storage.value,
            &_storage.value,
            mp_bitcnt_t(exponent)
        )
        return result
    }

    /// Divide this integer by 2^exponent using truncating division.
    ///
    /// For positive values, equivalent to a right shift. For negative values,
    /// treats
    /// the value as sign and magnitude (not two's complement).
    ///
    /// - Parameter exponent: The exponent for the power of 2. Must be
    /// non-negative.
    /// - Returns: A new `GMPInteger` with the quotient.
    ///
    /// - Requires: This integer must be properly initialized. `exponent` must
    /// be non-negative.
    /// - Guarantees: Returns a new `GMPInteger` with the quotient. `self` is
    /// unchanged.
    ///
    /// - Note: Wraps `mpz_tdiv_q_2exp`.
    /// - Throws: `GMPError.invalidExponent` if `exponent` is negative.
    public func truncatedDividedByPowerOf2(_ exponent: Int) throws
        -> GMPInteger
    {
        guard exponent >= 0 else {
            throw GMPError.invalidExponent(exponent)
        }
        let result = GMPInteger() // Mutated through pointer below
        __gmpz_tdiv_q_2exp(
            &result._storage.value,
            &_storage.value,
            mp_bitcnt_t(exponent)
        )
        return result
    }

    /// Get the remainder when dividing this integer by 2^exponent using
    /// truncating division.
    ///
    /// - Parameter exponent: The exponent for the power of 2. Must be
    /// non-negative.
    /// - Returns: A new `GMPInteger` with the remainder.
    ///
    /// - Requires: This integer must be properly initialized. `exponent` must
    /// be non-negative.
    /// - Guarantees: Returns a new `GMPInteger` with the remainder. `self` is
    /// unchanged.
    ///
    /// - Note: Wraps `mpz_tdiv_r_2exp`.
    /// - Throws: `GMPError.invalidExponent` if `exponent` is negative.
    public func truncatedRemainderDividingByPowerOf2(_ exponent: Int) throws
        -> GMPInteger
    {
        guard exponent >= 0 else {
            throw GMPError.invalidExponent(exponent)
        }
        let result = GMPInteger() // Mutated through pointer below
        __gmpz_tdiv_r_2exp(
            &result._storage.value,
            &_storage.value,
            mp_bitcnt_t(exponent)
        )
        return result
    }

    // MARK: - Operator Overloads

    /// Divide two `GMPInteger` values using truncating division.
    ///
    /// This is the standard division operator, equivalent to C's `/` operator.
    /// The quotient is rounded toward zero.
    ///
    /// - Parameters:
    ///   - lhs: The dividend.
    ///   - rhs: The divisor. Must not be zero.
    /// - Returns: The quotient using truncating division.
    ///
    /// - Requires: Both integers must be properly initialized. `rhs` must not
    /// be zero.
    /// - Guarantees: Returns a new `GMPInteger` with the quotient.
    /// - Throws: `GMPError.divisionByZero` if `rhs` is zero.
    public static func / (lhs: GMPInteger, rhs: GMPInteger) -> GMPInteger {
        guard !rhs.isZero else {
            fatalError("Division by zero")
        }
        // Safe to force try since we've already checked rhs.isZero above
        return try! lhs.truncatedDivided(by: rhs)
    }

    /// Get the remainder when dividing two `GMPInteger` values using truncating
    /// division.
    ///
    /// This is the standard remainder operator, equivalent to C's `%` operator.
    /// The remainder has the same sign as the dividend.
    ///
    /// - Parameters:
    ///   - lhs: The dividend.
    ///   - rhs: The divisor. Must not be zero.
    /// - Returns: The remainder using truncating division.
    ///
    /// - Requires: Both integers must be properly initialized. `rhs` must not
    /// be zero.
    /// - Guarantees: Returns a new `GMPInteger` with the remainder.
    /// - Throws: `GMPError.divisionByZero` if `rhs` is zero.
    public static func % (lhs: GMPInteger, rhs: GMPInteger) -> GMPInteger {
        guard !rhs.isZero else {
            fatalError("Division by zero")
        }
        // Safe to force try since we've already checked rhs.isZero above
        return try! lhs.truncatedRemainder(dividingBy: rhs)
    }

    /// Divide a `GMPInteger` by another in place using truncating division.
    ///
    /// - Parameters:
    ///   - lhs: The integer to modify (becomes the quotient).
    ///   - rhs: The divisor. Must not be zero.
    ///
    /// - Requires: Both integers must be properly initialized. `rhs` must not
    /// be zero.
    /// - Guarantees: After this call, `lhs` equals `lhs / rhs` (before the
    /// call).
    /// - Throws: `GMPError.divisionByZero` if `rhs` is zero.
    public static func /= (lhs: inout GMPInteger, rhs: GMPInteger) {
        guard !rhs.isZero else {
            fatalError("Division by zero")
        }
        // Safe to force try since we've already checked rhs.isZero above
        lhs = try! lhs.truncatedDivided(by: rhs)
    }

    /// Get the remainder when dividing a `GMPInteger` by another in place using
    /// truncating division.
    ///
    /// - Parameters:
    ///   - lhs: The integer to modify (becomes the remainder).
    ///   - rhs: The divisor. Must not be zero.
    ///
    /// - Requires: Both integers must be properly initialized. `rhs` must not
    /// be zero.
    /// - Guarantees: After this call, `lhs` equals `lhs % rhs` (before the
    /// call).
    /// - Throws: `GMPError.divisionByZero` if `rhs` is zero.
    public static func %= (lhs: inout GMPInteger, rhs: GMPInteger) {
        guard !rhs.isZero else {
            fatalError("Division by zero")
        }
        // Safe to force try since we've already checked rhs.isZero above
        lhs = try! lhs.truncatedRemainder(dividingBy: rhs)
    }
}
