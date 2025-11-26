import CKalliope

/// Root extraction operations for `GMPInteger`.
extension GMPInteger {
    /// Compute the integer nth root of this integer.
    ///
    /// Returns the truncated integer part of the nth root. For example, the
    /// cube root
    /// of 10 is 2 (since 2^3 = 8 <= 10 < 3^3 = 27).
    ///
    /// - Parameter n: The root index. Must be positive.
    /// - Returns: A tuple `(root, isExact)` where `root` is the truncated
    /// integer nth root
    ///   and `isExact` is `true` if `self == root^n`, `false` otherwise.
    ///
    /// - Requires: This integer must be properly initialized. `n` must be
    /// positive (`> 0`).
    ///   If `n` is even and `self` is negative, the behavior is undefined.
    /// - Guarantees: Returns a tuple with the root and exactness flag. `self`
    /// is unchanged.
    ///   The root satisfies: `root^n <= self < (root + 1)^n` (for positive
    /// `self`).
    ///
    /// - Note: Wraps `mpz_root`.
    public func nthRoot(_ n: Int) -> (root: GMPInteger, isExact: Bool) {
        precondition(n > 0, "n must be positive")
        let root = GMPInteger() // Mutated through pointer below
        let isExact = __gmpz_root(
            &root._storage.value,
            &_storage.value,
            CUnsignedLong(n)
        ) != 0
        return (root, isExact)
    }

    /// Compute the integer nth root of this integer with remainder.
    ///
    /// - Parameter n: The root index. Must be positive.
    /// - Returns: A tuple `(root, remainder)` where `root` is the truncated
    /// integer nth root
    ///   and `remainder = self - root^n`.
    ///
    /// - Requires: This integer must be properly initialized. `n` must be
    /// positive (`> 0`).
    ///   If `n` is even and `self` is negative, the behavior is undefined.
    /// - Guarantees: Returns a tuple with the root and remainder. `self` is
    /// unchanged.
    ///   The values satisfy: `self = root^n + remainder` and `0 <= remainder <
    /// (root + 1)^n - root^n`.
    ///
    /// - Note: Wraps `mpz_rootrem`.
    public func nthRootWithRemainder(_ n: Int)
        -> (root: GMPInteger, remainder: GMPInteger)
    {
        precondition(n > 0, "n must be positive")
        let root = GMPInteger() // Mutated through pointer below
        let remainder = GMPInteger() // Mutated through pointer below
        __gmpz_rootrem(
            &root._storage.value,
            &remainder._storage.value,
            &_storage.value,
            CUnsignedLong(n)
        )
        return (root, remainder)
    }

    /// Get the integer square root of this integer.
    ///
    /// Returns the truncated integer part of the square root. For example, the
    /// square root
    /// of 10 is 3 (since 3^2 = 9 <= 10 < 4^2 = 16).
    ///
    /// - Returns: A new `GMPInteger` with the truncated integer square root.
    ///
    /// - Requires: This integer must be properly initialized. If `self` is
    /// negative, the
    ///   behavior is undefined.
    /// - Guarantees: Returns a new `GMPInteger` with the square root. `self` is
    /// unchanged.
    ///   The result satisfies: `result^2 <= self < (result + 1)^2`.
    ///
    /// - Note: Wraps `mpz_sqrt`.
    public var squareRoot: GMPInteger {
        let result = GMPInteger() // Mutated through pointer below
        __gmpz_sqrt(&result._storage.value, &_storage.value)
        return result
    }

    /// Get the integer square root of this integer with remainder.
    ///
    /// - Returns: A tuple `(root, remainder)` where `root` is the truncated
    /// integer square root
    ///   and `remainder = self - root^2`.
    ///
    /// - Requires: This integer must be properly initialized. If `self` is
    /// negative, the
    ///   behavior is undefined.
    /// - Guarantees: Returns a tuple with the root and remainder. `self` is
    /// unchanged.
    ///   The values satisfy: `self = root^2 + remainder` and `0 <= remainder <
    /// 2*root + 1`.
    ///   If `remainder` is zero, `self` is a perfect square.
    ///
    /// - Note: Wraps `mpz_sqrtrem`.
    public var squareRootWithRemainder: (
        root: GMPInteger,
        remainder: GMPInteger
    ) {
        let root = GMPInteger() // Mutated through pointer below
        let remainder = GMPInteger() // Mutated through pointer below
        __gmpz_sqrtrem(
            &root._storage.value,
            &remainder._storage.value,
            &_storage.value
        )
        return (root, remainder)
    }

    /// Check if this integer is a perfect square.
    ///
    /// A perfect square is an integer that equals `n^2` for some integer `n`.
    ///
    /// - Returns: `true` if `self` is a perfect square, `false` otherwise.
    ///
    /// - Requires: This integer must be properly initialized.
    /// - Guarantees: Returns `true` if and only if there exists an integer `n`
    /// such that
    ///   `self == n^2`. Zero and one are considered perfect squares.
    ///
    /// - Note: Wraps `mpz_perfect_square_p`.
    public var isPerfectSquare: Bool {
        __gmpz_perfect_square_p(&_storage.value) != 0
    }

    /// Check if this integer is a perfect power.
    ///
    /// A perfect power is an integer that equals `a^b` for some integers `a`
    /// and `b` with `b > 1`.
    /// Under this definition, both 0 and 1 are considered perfect powers.
    /// Negative values
    /// are accepted but can only be odd perfect powers.
    ///
    /// - Returns: `true` if `self` is a perfect power, `false` otherwise.
    ///
    /// - Requires: This integer must be properly initialized.
    /// - Guarantees: Returns `true` if and only if there exist integers `a` and
    /// `b` with `b > 1`
    ///   such that `self == a^b`. Zero and one always return `true`.
    ///
    /// - Note: Wraps `mpz_perfect_power_p`.
    public var isPerfectPower: Bool {
        __gmpz_perfect_power_p(&_storage.value) != 0
    }
}
