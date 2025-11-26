import CKalliope

/// Number-theoretic operations for `GMPInteger`.
///
/// This extension provides functions for GCD, LCM, modular arithmetic,
/// primality testing,
/// and special sequences like factorials, binomials, Fibonacci, and Lucas
/// numbers.
extension GMPInteger {
    // MARK: - Greatest Common Divisor

    /// Compute the greatest common divisor (GCD) of two integers.
    ///
    /// The GCD is the largest positive integer that divides both `a` and `b`.
    /// If both
    /// arguments are zero, the result is zero. Otherwise, the result is always
    /// positive.
    ///
    /// - Parameters:
    ///   - a: The first integer.
    ///   - b: The second integer.
    /// - Returns: A new `GMPInteger` with the GCD of `a` and `b`.
    ///
    /// - Requires: Both integers must be properly initialized.
    /// - Guarantees: Returns a new `GMPInteger` with the GCD. The result is
    /// always
    ///   non-negative. If both arguments are zero, returns zero. Otherwise,
    /// returns
    ///   a positive value.
    ///
    /// - Wraps: `mpz_gcd`
    public static func gcd(_ a: GMPInteger, _ b: GMPInteger) -> GMPInteger {
        let result = GMPInteger() // Mutated through pointer below
        __gmpz_gcd(&result._storage.value, &a._storage.value, &b._storage.value)
        return result
    }

    /// Compute the greatest common divisor (GCD) of a `GMPInteger` and an
    /// `Int`.
    ///
    /// - Parameters:
    ///   - a: The `GMPInteger` value.
    ///   - b: The `Int` value.
    /// - Returns: The GCD as an `Int`.
    ///
    /// - Requires: `a` must be properly initialized.
    /// - Guarantees: Returns a non-negative `Int` with the GCD.
    ///
    /// - Wraps: `mpz_gcd_ui`
    public static func gcd(_ a: GMPInteger, _ b: Int) -> Int {
        if b == 0 {
            // If b is zero, return absolute value of a (if it fits in Int)
            let absA = a.isNegative ? a.absoluteValue() : a
            return absA.fitsInInt() ? absA.toInt() : Int
                .max // Fallback for very large values
        }
        // Handle Int.min specially to avoid arithmetic overflow
        // Int.min = -2,147,483,648, so abs(Int.min) = 2,147,483,648 which fits
        // in UInt
        let absB = if b == Int.min {
            CUnsignedLong(Int.max) + 1
        } else {
            CUnsignedLong(b < 0 ? -b : b)
        }
        let result = __gmpz_gcd_ui(nil, &a._storage.value, absB)
        return Int(result)
    }

    // MARK: - Extended GCD (Bézout Coefficients)

    /// Compute the extended GCD with Bézout coefficients.
    ///
    /// Returns the GCD `g` and coefficients `s` and `t` such that `a*s + b*t =
    /// g`.
    /// This is useful for computing modular inverses and solving linear
    /// Diophantine equations.
    ///
    /// - Parameters:
    ///   - a: The first integer.
    ///   - b: The second integer.
    /// - Returns: A tuple `(gcd, s, t)` where `gcd` is the GCD of `a` and `b`,
    /// and
    ///   `a*s + b*t = gcd`.
    ///
    /// - Requires: Both integers must be properly initialized.
    /// - Guarantees: Returns a tuple with the GCD and Bézout coefficients. The
    /// GCD is
    ///   always non-negative. The coefficients satisfy: `a*s + b*t = gcd`.
    ///
    /// - Wraps: `mpz_gcdext`
    public static func extendedGCD(
        _ a: GMPInteger,
        _ b: GMPInteger
    ) -> (gcd: GMPInteger, s: GMPInteger, t: GMPInteger) {
        let gcd = GMPInteger() // Mutated through pointer below
        let s = GMPInteger() // Mutated through pointer below
        let t = GMPInteger() // Mutated through pointer below
        __gmpz_gcdext(
            &gcd._storage.value,
            &s._storage.value,
            &t._storage.value,
            &a._storage.value,
            &b._storage.value
        )
        return (gcd, s, t)
    }

    // MARK: - Least Common Multiple

    /// Compute the least common multiple (LCM) of two integers.
    ///
    /// The LCM is the smallest positive integer that is divisible by both `a`
    /// and `b`.
    /// If either argument is zero, the result is zero.
    ///
    /// - Parameters:
    ///   - a: The first integer.
    ///   - b: The second integer.
    /// - Returns: A new `GMPInteger` with the LCM of `a` and `b`.
    ///
    /// - Requires: Both integers must be properly initialized.
    /// - Guarantees: Returns a new `GMPInteger` with the LCM. The result is
    /// always
    ///   non-negative. If either argument is zero, returns zero.
    ///
    /// - Wraps: `mpz_lcm`
    public static func lcm(_ a: GMPInteger, _ b: GMPInteger) -> GMPInteger {
        let result = GMPInteger() // Mutated through pointer below
        __gmpz_lcm(&result._storage.value, &a._storage.value, &b._storage.value)
        return result
    }

    /// Compute the least common multiple (LCM) of a `GMPInteger` and an `Int`.
    ///
    /// - Parameters:
    ///   - a: The `GMPInteger` value.
    ///   - b: The `Int` value.
    /// - Returns: The LCM as a `GMPInteger`.
    ///
    /// - Requires: `a` must be properly initialized.
    /// - Guarantees: Returns a new `GMPInteger` with the LCM.
    ///
    /// - Wraps: `mpz_lcm_ui`
    public static func lcm(_ a: GMPInteger, _ b: Int) -> GMPInteger {
        let result = GMPInteger() // Mutated through pointer below
        // Handle Int.min specially to avoid arithmetic overflow
        // Int.min = -2,147,483,648, so abs(Int.min) = 2,147,483,648 which fits
        // in UInt
        let absB = if b == Int.min {
            CUnsignedLong(Int.max) + 1
        } else {
            CUnsignedLong(b < 0 ? -b : b)
        }
        __gmpz_lcm_ui(
            &result._storage.value,
            &a._storage.value,
            CUnsignedLong(absB)
        )
        return result
    }

    // MARK: - Modular Inverse

    /// Compute the modular inverse of this integer modulo `modulus`.
    ///
    /// Returns an integer `x` such that `(self * x) mod modulus == 1`. The
    /// inverse exists
    /// if and only if `gcd(self, modulus) == 1`.
    ///
    /// - Parameter modulus: The modulus. Must not be zero.
    /// - Returns: The modular inverse if it exists, `nil` otherwise.
    ///
    /// - Requires: This integer and `modulus` must be properly initialized.
    /// `modulus` must not be zero.
    /// - Guarantees: If the inverse exists, returns a new `GMPInteger` such
    /// that
    ///   `(self * result) mod modulus == 1` and `0 <= result < |modulus|`. If
    /// the inverse
    ///   doesn't exist (i.e., `gcd(self, modulus) != 1`), returns `nil`. `self`
    /// is unchanged.
    ///
    /// - Wraps: `mpz_invert`
    public func modularInverse(modulo modulus: GMPInteger) -> GMPInteger? {
        guard !modulus.isZero else {
            return nil
        }
        let result = GMPInteger() // Mutated through pointer below
        let success = __gmpz_invert(
            &result._storage.value,
            &_storage.value,
            &modulus._storage.value
        )
        if success != 0 {
            return result
        } else {
            return nil
        }
    }

    // MARK: - Jacobi Symbol

    /// Compute the Jacobi symbol (a/n).
    ///
    /// The Jacobi symbol is a generalization of the Legendre symbol. It's
    /// defined for
    /// odd positive `n` and any integer `a`. Returns -1, 0, or 1.
    ///
    /// - Parameters:
    ///   - a: The numerator.
    ///   - n: The denominator. Must be odd and positive.
    /// - Returns: The Jacobi symbol as an `Int`: -1, 0, or 1.
    ///
    /// - Requires: Both integers must be properly initialized. `n` must be odd
    /// and positive.
    /// - Guarantees: Returns -1, 0, or 1. Returns 0 if and only if `gcd(a, n)
    /// != 1`.
    ///
    /// - Wraps: `mpz_jacobi`
    public static func jacobiSymbol(_ a: GMPInteger, _ n: GMPInteger) -> Int {
        Int(__gmpz_jacobi(&a._storage.value, &n._storage.value))
    }

    /// Compute the Jacobi symbol (a/n) where `a` is an `Int`.
    ///
    /// - Parameters:
    ///   - a: The numerator as an `Int`.
    ///   - n: The denominator. Must be odd and positive.
    /// - Returns: The Jacobi symbol as an `Int`: -1, 0, or 1.
    ///
    /// - Requires: `n` must be properly initialized and odd and positive.
    /// - Guarantees: Returns -1, 0, or 1.
    public static func jacobiSymbol(_ a: Int, _ n: GMPInteger) -> Int {
        let aGMP = GMPInteger(a)
        return jacobiSymbol(aGMP, n)
    }

    // MARK: - Kronecker Symbol

    /// Compute the Kronecker symbol (a/n).
    ///
    /// The Kronecker symbol is a further generalization of the Jacobi symbol,
    /// defined
    /// for all integers `a` and `n` (including even `n`). Returns -1, 0, or 1.
    ///
    /// - Parameters:
    ///   - a: The numerator.
    ///   - n: The denominator.
    /// - Returns: The Kronecker symbol as an `Int`: -1, 0, or 1.
    ///
    /// - Requires: Both integers must be properly initialized.
    /// - Guarantees: Returns -1, 0, or 1. Returns 0 if and only if `gcd(a, n)
    /// != 1`.
    ///
    /// - Wraps: `mpz_kronecker` (which is an alias for `mpz_jacobi`)
    public static func kroneckerSymbol(
        _ a: GMPInteger,
        _ n: GMPInteger
    ) -> Int {
        Int(__gmpz_jacobi(&a._storage.value, &n._storage.value))
    }

    /// Compute the Kronecker symbol (a/n) where `a` is an `Int`.
    ///
    /// - Parameters:
    ///   - a: The numerator as an `Int`.
    ///   - n: The denominator.
    /// - Returns: The Kronecker symbol as an `Int`: -1, 0, or 1.
    ///
    /// - Requires: `n` must be properly initialized.
    /// - Guarantees: Returns -1, 0, or 1.
    ///
    /// - Wraps: `mpz_si_kronecker` or `mpz_ui_kronecker`
    public static func kroneckerSymbol(_ a: Int, _ n: GMPInteger) -> Int {
        if a >= 0 {
            Int(__gmpz_ui_kronecker(CUnsignedLong(a), &n._storage.value))
        } else {
            Int(__gmpz_si_kronecker(CLong(a), &n._storage.value))
        }
    }

    /// Compute the Kronecker symbol (a/n) where `n` is an `Int`.
    ///
    /// - Parameters:
    ///   - a: The numerator.
    ///   - n: The denominator as an `Int`.
    /// - Returns: The Kronecker symbol as an `Int`: -1, 0, or 1.
    ///
    /// - Requires: `a` must be properly initialized.
    /// - Guarantees: Returns -1, 0, or 1.
    ///
    /// - Wraps: `mpz_kronecker_si` or `mpz_kronecker_ui`
    public static func kroneckerSymbol(_ a: GMPInteger, _ n: Int) -> Int {
        if n >= 0 {
            Int(__gmpz_kronecker_ui(&a._storage.value, CUnsignedLong(n)))
        } else {
            Int(__gmpz_kronecker_si(&a._storage.value, CLong(n)))
        }
    }

    /// Compute the Kronecker symbol (a/n) where both are `Int`.
    ///
    /// - Parameters:
    ///   - a: The numerator as an `Int`.
    ///   - n: The denominator as an `Int`.
    /// - Returns: The Kronecker symbol as an `Int`: -1, 0, or 1.
    ///
    /// - Requires: None.
    /// - Guarantees: Returns -1, 0, or 1.
    public static func kroneckerSymbol(_ a: Int, _ n: Int) -> Int {
        // Convert to GMPInteger for computation
        let aGMP = GMPInteger(a)
        if n >= 0 {
            return Int(__gmpz_kronecker_ui(
                &aGMP._storage.value,
                CUnsignedLong(n)
            ))
        } else {
            return Int(__gmpz_kronecker_si(&aGMP._storage.value, CLong(n)))
        }
    }

    // MARK: - Primality Testing

    /// Test if this integer is probably prime using a probabilistic test.
    ///
    /// Uses the Miller-Rabin probabilistic primality test. The test is repeated
    /// `reps` times.
    ///
    /// - Parameter reps: The number of repetitions. Defaults to 25. More
    /// repetitions increase
    ///   confidence but take longer. Must be positive.
    /// - Returns: An `Int` indicating the result:
    ///   - `2`: Definitely prime (for small values where a deterministic test
    /// is used)
    ///   - `1`: Probably prime (passed all `reps` tests)
    ///   - `0`: Composite (failed at least one test)
    ///
    /// - Requires: This integer must be properly initialized. `reps` must be
    /// positive.
    /// - Guarantees: Returns 0, 1, or 2. Returns 2 only for small values.
    /// Returns 0 if
    ///   the integer is definitely composite. Returns 1 if it's probably prime
    /// (with
    ///   probability of error at most 4^-reps).
    ///
    /// - Wraps: `mpz_probab_prime_p`
    public func isProbablePrime(reps: Int = 25) -> Int {
        precondition(reps > 0, "reps must be positive")
        return Int(__gmpz_probab_prime_p(&_storage.value, CInt(reps)))
    }

    /// Get the next prime number greater than this integer.
    ///
    /// Uses a probabilistic test to find the next prime. The result is not
    /// guaranteed to be
    /// prime, but the probability of error is extremely small.
    ///
    /// - Returns: A new `GMPInteger` with the next probable prime.
    ///
    /// - Requires: This integer must be properly initialized.
    /// - Guarantees: Returns a new `GMPInteger` that is probably prime and
    /// greater than `self`.
    ///   `self` is unchanged. The result is not guaranteed to be prime, but the
    /// probability
    ///   of error is negligible.
    ///
    /// - Wraps: `mpz_nextprime`
    public var nextPrime: GMPInteger {
        let result = GMPInteger() // Mutated through pointer below
        __gmpz_nextprime(&result._storage.value, &_storage.value)
        return result
    }

    /// Get the previous prime number less than this integer.
    ///
    /// - Returns: A tuple `(prime, certainty)` where `prime` is the previous
    /// probable prime
    ///   and `certainty` indicates confidence (0-2, same as `isProbablePrime`).
    /// Returns `nil`
    ///   if no prime exists (e.g., if `self <= 2`).
    ///
    /// - Requires: This integer must be properly initialized.
    /// - Guarantees: If a prime exists, returns a tuple with the previous
    /// probable prime
    ///   and certainty level. Returns `nil` if no prime exists. `self` is
    /// unchanged.
    ///
    /// - Wraps: `mpz_prevprime`
    public var previousPrime: (prime: GMPInteger, certainty: Int)? {
        let result = GMPInteger() // Mutated through pointer below
        let found = __gmpz_prevprime(&result._storage.value, &_storage.value)
        if found != 0 {
            let certainty = result.isProbablePrime(reps: 25)
            return (result, certainty)
        } else {
            return nil
        }
    }

    /// Run the Miller-Rabin probabilistic primality test.
    ///
    /// This is a lower-level interface to the Miller-Rabin test used by
    /// `isProbablePrime`.
    ///
    /// - Parameter reps: The number of repetitions. Must be positive.
    /// - Returns: `1` if probably prime, `0` if composite.
    ///
    /// - Requires: This integer must be properly initialized. `reps` must be
    /// positive.
    /// - Guarantees: Returns 0 or 1. Returns 0 if composite, 1 if probably
    /// prime.
    ///
    /// - Wraps: `mpz_probab_prime_p`
    public func millerRabinTest(reps: Int) -> Int {
        precondition(reps > 0, "reps must be positive")
        let result = __gmpz_probab_prime_p(&_storage.value, CInt(reps))
        return result > 0 ? 1 : 0
    }

    // MARK: - Factorials and Binomials

    /// Compute the factorial: n! = n * (n-1) * ... * 2 * 1.
    ///
    /// - Parameter n: The value to compute the factorial of. Must be
    /// non-negative.
    /// - Returns: A new `GMPInteger` with n!.
    ///
    /// - Requires: `n` must be non-negative.
    /// - Guarantees: Returns a new `GMPInteger` with the factorial. Returns 1
    /// if `n == 0`.
    ///
    /// - Wraps: `mpz_fac_ui`
    public static func factorial(_ n: Int) -> GMPInteger {
        precondition(n >= 0, "n must be non-negative")
        let result = GMPInteger() // Mutated through pointer below
        __gmpz_fac_ui(&result._storage.value, CUnsignedLong(n))
        return result
    }

    /// Compute the binomial coefficient: C(n, k) = n! / (k! * (n-k)!).
    ///
    /// Also known as "n choose k", this is the number of ways to choose `k`
    /// items from `n` items.
    ///
    /// - Parameters:
    ///   - n: The total number of items. Must be non-negative.
    ///   - k: The number of items to choose. Must satisfy `0 <= k <= n`.
    /// - Returns: A new `GMPInteger` with C(n, k).
    ///
    /// - Requires: `n` must be non-negative, and `0 <= k <= n`.
    /// - Guarantees: Returns a new `GMPInteger` with the binomial coefficient.
    ///
    /// - Wraps: `mpz_bin_ui` or `mpz_bin_uiui`
    public static func binomial(_ n: Int, _ k: Int) -> GMPInteger {
        precondition(n >= 0, "n must be non-negative")
        precondition(k >= 0 && k <= n, "k must satisfy 0 <= k <= n")
        let result = GMPInteger() // Mutated through pointer below
        // Since n and k are Int, they can never exceed Int.max
        __gmpz_bin_uiui(
            &result._storage.value,
            CUnsignedLong(n),
            CUnsignedLong(k)
        )
        return result
    }

    /// Compute the double factorial: n!!.
    ///
    /// For even n: n!! = n * (n-2) * ... * 4 * 2
    /// For odd n: n!! = n * (n-2) * ... * 3 * 1
    ///
    /// - Parameter n: The value. Must be non-negative.
    /// - Returns: A new `GMPInteger` with n!!.
    ///
    /// - Requires: `n` must be non-negative.
    /// - Guarantees: Returns a new `GMPInteger` with the double factorial.
    ///
    /// - Wraps: `mpz_2fac_ui`
    public static func doubleFactorial(_ n: Int) -> GMPInteger {
        precondition(n >= 0, "n must be non-negative")
        let result = GMPInteger() // Mutated through pointer below
        __gmpz_2fac_ui(&result._storage.value, CUnsignedLong(n))
        return result
    }

    /// Compute the multi-factorial: n!...! (k times).
    ///
    /// This is the factorial applied `k` times. For example, 5!!! = (5!!)!.
    ///
    /// - Parameters:
    ///   - n: The value. Must be non-negative.
    ///   - k: The number of factorial applications. Must be positive.
    /// - Returns: A new `GMPInteger` with the multi-factorial.
    ///
    /// - Requires: `n` must be non-negative. `k` must be positive.
    /// - Guarantees: Returns a new `GMPInteger` with the multi-factorial.
    ///
    /// - Wraps: `mpz_mfac_uiui`
    public static func multiFactorial(_ n: Int, _ k: Int) -> GMPInteger {
        precondition(n >= 0, "n must be non-negative")
        precondition(k > 0, "k must be positive")
        let result = GMPInteger() // Mutated through pointer below
        __gmpz_mfac_uiui(
            &result._storage.value,
            CUnsignedLong(n),
            CUnsignedLong(k)
        )
        return result
    }

    /// Compute the primorial: product of all primes <= n.
    ///
    /// The primorial of n is the product of all prime numbers less than or
    /// equal to n.
    ///
    /// - Parameter n: The upper bound. Must be non-negative.
    /// - Returns: A new `GMPInteger` with the primorial.
    ///
    /// - Requires: `n` must be non-negative.
    /// - Guarantees: Returns a new `GMPInteger` with the primorial. Returns 1
    /// if `n < 2`.
    ///
    /// - Wraps: `mpz_primorial_ui`
    public static func primorial(_ n: Int) -> GMPInteger {
        precondition(n >= 0, "n must be non-negative")
        let result = GMPInteger() // Mutated through pointer below
        __gmpz_primorial_ui(&result._storage.value, CUnsignedLong(n))
        return result
    }

    // MARK: - Fibonacci and Lucas Numbers

    /// Compute the nth Fibonacci number: F(n).
    ///
    /// Fibonacci numbers are defined by: F(0) = 0, F(1) = 1, F(n) = F(n-1) +
    /// F(n-2).
    ///
    /// - Parameter n: The index. Must be non-negative.
    /// - Returns: A new `GMPInteger` with F(n).
    ///
    /// - Requires: `n` must be non-negative.
    /// - Guarantees: Returns a new `GMPInteger` with the nth Fibonacci number.
    ///
    /// - Wraps: `mpz_fib_ui`
    public static func fibonacci(_ n: Int) -> GMPInteger {
        precondition(n >= 0, "n must be non-negative")
        let result = GMPInteger() // Mutated through pointer below
        __gmpz_fib_ui(&result._storage.value, CUnsignedLong(n))
        return result
    }

    /// Compute the nth and (n-1)th Fibonacci numbers.
    ///
    /// More efficient than calling `fibonacci` twice, as both values are
    /// computed together.
    ///
    /// - Parameter n: The index. Must be non-negative.
    /// - Returns: A tuple `(fn, fn1)` where `fn = F(n)` and `fn1 = F(n-1)`.
    ///
    /// - Requires: `n` must be non-negative.
    /// - Guarantees: Returns a tuple with F(n) and F(n-1). If `n == 0`, `fn1`
    /// is undefined
    ///   (but the function still returns a value).
    ///
    /// - Wraps: `mpz_fib2_ui`
    public static func fibonacci2(_ n: Int)
        -> (fn: GMPInteger, fn1: GMPInteger)
    {
        precondition(n >= 0, "n must be non-negative")
        let fn = GMPInteger() // Mutated through pointer below
        let fn1 = GMPInteger() // Mutated through pointer below
        __gmpz_fib2_ui(
            &fn._storage.value,
            &fn1._storage.value,
            CUnsignedLong(n)
        )
        return (fn, fn1)
    }

    /// Compute the nth Lucas number: L(n).
    ///
    /// Lucas numbers are defined by: L(0) = 2, L(1) = 1, L(n) = L(n-1) +
    /// L(n-2).
    ///
    /// - Parameter n: The index. Must be non-negative.
    /// - Returns: A new `GMPInteger` with L(n).
    ///
    /// - Requires: `n` must be non-negative.
    /// - Guarantees: Returns a new `GMPInteger` with the nth Lucas number.
    ///
    /// - Wraps: `mpz_lucnum_ui`
    public static func lucas(_ n: Int) -> GMPInteger {
        precondition(n >= 0, "n must be non-negative")
        let result = GMPInteger() // Mutated through pointer below
        __gmpz_lucnum_ui(&result._storage.value, CUnsignedLong(n))
        return result
    }

    /// Compute the nth and (n-1)th Lucas numbers.
    ///
    /// More efficient than calling `lucas` twice.
    ///
    /// - Parameter n: The index. Must be non-negative.
    /// - Returns: A tuple `(ln, ln1)` where `ln = L(n)` and `ln1 = L(n-1)`.
    ///
    /// - Requires: `n` must be non-negative.
    /// - Guarantees: Returns a tuple with L(n) and L(n-1).
    ///
    /// - Wraps: `mpz_lucnum2_ui`
    public static func lucas2(_ n: Int) -> (ln: GMPInteger, ln1: GMPInteger) {
        precondition(n >= 0, "n must be non-negative")
        let ln = GMPInteger() // Mutated through pointer below
        let ln1 = GMPInteger() // Mutated through pointer below
        __gmpz_lucnum2_ui(
            &ln._storage.value,
            &ln1._storage.value,
            CUnsignedLong(n)
        )
        return (ln, ln1)
    }

    // MARK: - Factor Removal

    /// Remove all occurrences of `factor` from this integer.
    ///
    /// Repeatedly divides this integer by `factor` until it's no longer
    /// divisible.
    /// Useful for factorization algorithms.
    ///
    /// - Parameter factor: The factor to remove. Must not be zero.
    /// - Returns: The number of times `factor` was removed.
    ///
    /// - Requires: This integer and `factor` must be properly initialized.
    /// `factor` must
    ///   not be zero. `factor` must not be ±1 (otherwise the result is
    /// undefined).
    /// - Guarantees: After this call, `self` is no longer divisible by
    /// `factor`. Returns
    ///   the number of factors removed. If `factor` doesn't divide `self`,
    /// returns 0
    ///   and `self` is unchanged.
    ///
    /// - Wraps: `mpz_remove`
    public mutating func remove(factor: GMPInteger) -> Int {
        precondition(!factor.isZero, "factor must not be zero")
        _ensureUnique()
        // Use withUnsafeMutablePointer to avoid Swift exclusivity violation
        // when
        // passing the same storage for both input and output parameters
        return withUnsafeMutablePointer(to: &_storage.value) { rop in
            let op = UnsafePointer(rop)
            let count = __gmpz_remove(rop, op, &factor._storage.value)
            return Int(count)
        }
    }
}
