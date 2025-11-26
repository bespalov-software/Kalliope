import CKalliope

/// Arithmetic operations for `GMPInteger`.
///
/// This extension provides both immutable (functional) and mutable (in-place)
/// arithmetic operations. All operations support arbitrary precision and handle
/// overflow automatically.
extension GMPInteger {
    // MARK: - Immutable Operations (Return New Values)

    /// Add another `GMPInteger` to this integer, returning a new value.
    ///
    /// - Parameter other: The integer to add.
    /// - Returns: A new `GMPInteger` equal to `self + other`.
    ///
    /// - Requires: Both integers must be properly initialized.
    /// - Guarantees: Returns a new `GMPInteger` with the sum. `self` is
    /// unchanged.
    ///   The operation is safe even if `self` and `other` are the same
    /// variable.
    ///
    /// - Note: Wraps `mpz_add`.
    public func adding(_ other: GMPInteger) -> GMPInteger {
        let result = GMPInteger() // Mutated through pointer below
        __gmpz_add(
            &result._storage.value,
            &_storage.value,
            &other._storage.value
        )
        return result
    }

    /// Add an `Int` to this integer, returning a new value.
    ///
    /// - Parameter other: The integer to add.
    /// - Returns: A new `GMPInteger` equal to `self + other`.
    ///
    /// - Requires: This integer must be properly initialized.
    /// - Guarantees: Returns a new `GMPInteger` with the sum. `self` is
    /// unchanged.
    ///
    /// - Note: Wraps `mpz_add_ui` or `mpz_add_si` depending on the sign of
    /// `other`.
    public func adding(_ other: Int) -> GMPInteger {
        let result = GMPInteger() // Mutated through pointer below
        if other >= 0 {
            __gmpz_add_ui(
                &result._storage.value,
                &_storage.value,
                CUnsignedLong(other)
            )
        } else {
            // Handle Int.min specially to avoid arithmetic overflow
            let absOther: CUnsignedLong = other == Int
                .min ? CUnsignedLong(Int.max) + 1 : CUnsignedLong(-other)
            __gmpz_sub_ui(&result._storage.value, &_storage.value, absOther)
        }
        return result
    }

    /// Subtract another `GMPInteger` from this integer, returning a new value.
    ///
    /// - Parameter other: The integer to subtract.
    /// - Returns: A new `GMPInteger` equal to `self - other`.
    ///
    /// - Requires: Both integers must be properly initialized.
    /// - Guarantees: Returns a new `GMPInteger` with the difference. `self` is
    /// unchanged.
    ///
    /// - Note: Wraps `mpz_sub`.
    public func subtracting(_ other: GMPInteger) -> GMPInteger {
        let result = GMPInteger() // Mutated through pointer below
        __gmpz_sub(
            &result._storage.value,
            &_storage.value,
            &other._storage.value
        )
        return result
    }

    /// Subtract an `Int` from this integer, returning a new value.
    ///
    /// - Parameter other: The integer to subtract.
    /// - Returns: A new `GMPInteger` equal to `self - other`.
    ///
    /// - Requires: This integer must be properly initialized.
    /// - Guarantees: Returns a new `GMPInteger` with the difference. `self` is
    /// unchanged.
    ///
    /// - Note: Wraps `mpz_sub_ui` or `mpz_sub_si` depending on the sign of
    /// `other`.
    public func subtracting(_ other: Int) -> GMPInteger {
        let result = GMPInteger() // Mutated through pointer below
        if other >= 0 {
            __gmpz_sub_ui(
                &result._storage.value,
                &_storage.value,
                CUnsignedLong(other)
            )
        } else {
            // Handle Int.min specially to avoid arithmetic overflow
            let absOther: CUnsignedLong = other == Int
                .min ? CUnsignedLong(Int.max) + 1 : CUnsignedLong(-other)
            __gmpz_add_ui(&result._storage.value, &_storage.value, absOther)
        }
        return result
    }

    /// Subtract a `GMPInteger` from an `Int`, returning a new value.
    ///
    /// - Parameters:
    ///   - lhs: The integer to subtract from.
    ///   - rhs: The `GMPInteger` to subtract.
    /// - Returns: A new `GMPInteger` equal to `lhs - rhs`.
    ///
    /// - Requires: `rhs` must be properly initialized.
    /// - Guarantees: Returns a new `GMPInteger` with the difference.
    ///
    /// - Note: Wraps `mpz_ui_sub`.
    public static func subtracting(
        _ lhs: Int,
        _ rhs: GMPInteger
    ) -> GMPInteger {
        let result = GMPInteger() // Mutated through pointer below
        if lhs >= 0 {
            __gmpz_ui_sub(
                &result._storage.value,
                CUnsignedLong(lhs),
                &rhs._storage.value
            )
        } else {
            // For negative lhs, compute as: lhs - rhs = -(|lhs| + rhs)
            // First compute |lhs| + rhs, then negate
            // Handle Int.min specially to avoid arithmetic overflow
            // Int.min = -2,147,483,648, so abs(Int.min) = 2,147,483,648 which
            // fits in UInt
            let temp = GMPInteger() // Mutated through pointer below
            let absLhs = if lhs == Int.min {
                CUnsignedLong(Int.max) + 1
            } else {
                CUnsignedLong(-lhs)
            }
            __gmpz_add_ui(&temp._storage.value, &rhs._storage.value, absLhs)
            __gmpz_neg(&result._storage.value, &temp._storage.value)
        }
        return result
    }

    /// Multiply this integer by another `GMPInteger`, returning a new value.
    ///
    /// - Parameter other: The integer to multiply by.
    /// - Returns: A new `GMPInteger` equal to `self * other`.
    ///
    /// - Requires: Both integers must be properly initialized.
    /// - Guarantees: Returns a new `GMPInteger` with the product. `self` is
    /// unchanged.
    ///
    /// - Note: Wraps `mpz_mul`.
    public func multiplied(by other: GMPInteger) -> GMPInteger {
        let result = GMPInteger() // Mutated through pointer below
        __gmpz_mul(
            &result._storage.value,
            &_storage.value,
            &other._storage.value
        )
        return result
    }

    /// Multiply this integer by an `Int`, returning a new value.
    ///
    /// - Parameter other: The integer to multiply by.
    /// - Returns: A new `GMPInteger` equal to `self * other`.
    ///
    /// - Requires: This integer must be properly initialized.
    /// - Guarantees: Returns a new `GMPInteger` with the product. `self` is
    /// unchanged.
    ///
    /// - Note: Wraps `mpz_mul_ui` or `mpz_mul_si` depending on the sign of
    /// `other`.
    public func multiplied(by other: Int) -> GMPInteger {
        let result = GMPInteger() // Mutated through pointer below
        if other >= 0 {
            __gmpz_mul_ui(
                &result._storage.value,
                &_storage.value,
                CUnsignedLong(other)
            )
        } else {
            __gmpz_mul_si(&result._storage.value, &_storage.value, CLong(other))
        }
        return result
    }

    /// Return the negation of this integer.
    ///
    /// - Returns: A new `GMPInteger` equal to `-self`.
    ///
    /// - Requires: This integer must be properly initialized.
    /// - Guarantees: Returns a new `GMPInteger` with the negated value. `self`
    /// is unchanged.
    ///
    /// - Note: Wraps `mpz_neg`.
    public func negated() -> GMPInteger {
        let result = GMPInteger() // Mutated through pointer below
        __gmpz_neg(&result._storage.value, &_storage.value)
        return result
    }

    /// Return the absolute value of this integer.
    ///
    /// - Returns: A new `GMPInteger` equal to `|self|`.
    ///
    /// - Requires: This integer must be properly initialized.
    /// - Guarantees: Returns a new `GMPInteger` with the absolute value. `self`
    /// is unchanged.
    ///
    /// - Note: Wraps `mpz_abs`.
    public func absoluteValue() -> GMPInteger {
        let result = GMPInteger() // Mutated through pointer below
        __gmpz_abs(&result._storage.value, &_storage.value)
        return result
    }

    // MARK: - Mutable Operations (Modify In Place)

    /// Add another `GMPInteger` to this integer in place.
    ///
    /// - Parameter other: The integer to add.
    ///
    /// - Requires: Both integers must be properly initialized.
    /// - Guarantees: After this call, `self` equals `self + other` (before the
    /// call).
    ///   The operation is safe even if `self` and `other` are the same
    /// variable.
    ///
    /// - Note: Wraps `mpz_add`.
    public mutating func add(_ other: GMPInteger) {
        // Root cause: When self and other are the same variable (e.g.,
        // a.add(a)),
        // Swift's exclusivity checker sees accessing other._storage as
        // accessing
        // the same variable we're modifying, even after _ensureUnique() makes
        // the
        // storage objects different.
        //
        // Solution: Use the immutable adding() method which creates a new result,
        // then assign it back. This avoids accessing other._storage from within
        // the mutating context. GMP handles overlapping operands correctly.
        let result = adding(other)
        self = result
    }

    /// Add an `Int` to this integer in place.
    ///
    /// - Parameter other: The integer to add.
    ///
    /// - Requires: This integer must be properly initialized.
    /// - Guarantees: After this call, `self` equals `self + other` (before the
    /// call).
    ///
    /// - Note: Wraps `mpz_add_ui` or `mpz_add_si` depending on the sign of
    /// `other`.
    public mutating func add(_ other: Int) {
        _ensureUnique()
        // Use withUnsafeMutablePointer to avoid Swift exclusivity violation
        // when
        // passing the same storage for both input and output parameters
        withUnsafeMutablePointer(to: &_storage.value) { rop in
            let op = UnsafePointer(rop)
            if other >= 0 {
                __gmpz_add_ui(rop, op, CUnsignedLong(other))
            } else {
                // Handle Int.min specially to avoid arithmetic overflow
                let absOther: CUnsignedLong = other == Int
                    .min ? CUnsignedLong(Int.max) + 1 : CUnsignedLong(-other)
                __gmpz_sub_ui(rop, op, absOther)
            }
        }
    }

    /// Subtract another `GMPInteger` from this integer in place.
    ///
    /// - Parameter other: The integer to subtract.
    ///
    /// - Requires: Both integers must be properly initialized.
    /// - Guarantees: After this call, `self` equals `self - other` (before the
    /// call).
    ///
    /// - Note: Wraps `mpz_sub`.
    public mutating func subtract(_ other: GMPInteger) {
        // Use immutable subtracting() to avoid exclusivity violations when self
        // === other
        let result = subtracting(other)
        self = result
    }

    /// Subtract an `Int` from this integer in place.
    ///
    /// - Parameter other: The integer to subtract.
    ///
    /// - Requires: This integer must be properly initialized.
    /// - Guarantees: After this call, `self` equals `self - other` (before the
    /// call).
    ///
    /// - Note: Wraps `mpz_sub_ui` or `mpz_sub_si` depending on the sign of
    /// `other`.
    public mutating func subtract(_ other: Int) {
        _ensureUnique()
        // Use withUnsafeMutablePointer to avoid Swift exclusivity violation
        // when
        // passing the same storage for both input and output parameters
        withUnsafeMutablePointer(to: &_storage.value) { rop in
            let op = UnsafePointer(rop)
            if other >= 0 {
                __gmpz_sub_ui(rop, op, CUnsignedLong(other))
            } else {
                // Handle Int.min specially to avoid arithmetic overflow
                let absOther: CUnsignedLong = other == Int
                    .min ? CUnsignedLong(Int.max) + 1 : CUnsignedLong(-other)
                __gmpz_add_ui(rop, op, absOther)
            }
        }
    }

    /// Multiply this integer by another `GMPInteger` in place.
    ///
    /// - Parameter other: The integer to multiply by.
    ///
    /// - Requires: Both integers must be properly initialized.
    /// - Guarantees: After this call, `self` equals `self * other` (before the
    /// call).
    ///
    /// - Note: Wraps `mpz_mul`.
    public mutating func multiply(by other: GMPInteger) {
        // Use immutable multiplied(by:) to avoid exclusivity violations when
        // self === other
        let result = multiplied(by: other)
        self = result
    }

    /// Multiply this integer by an `Int` in place.
    ///
    /// - Parameter other: The integer to multiply by.
    ///
    /// - Requires: This integer must be properly initialized.
    /// - Guarantees: After this call, `self` equals `self * other` (before the
    /// call).
    ///
    /// - Note: Wraps `mpz_mul_ui` or `mpz_mul_si` depending on the sign of
    /// `other`.
    public mutating func multiply(by other: Int) {
        _ensureUnique()
        // Use withUnsafeMutablePointer to avoid Swift exclusivity violation
        // when
        // passing the same storage for both input and output parameters
        withUnsafeMutablePointer(to: &_storage.value) { rop in
            let op = UnsafePointer(rop)
            if other >= 0 {
                __gmpz_mul_ui(rop, op, CUnsignedLong(other))
            } else {
                __gmpz_mul_si(rop, op, CLong(other))
            }
        }
    }

    /// Negate this integer in place.
    ///
    /// - Requires: This integer must be properly initialized.
    /// - Guarantees: After this call, `self` equals `-self` (before the call).
    ///
    /// - Note: Wraps `mpz_neg`.
    public mutating func negate() {
        // Use immutable negated() to avoid exclusivity violations
        let result = negated()
        self = result
    }

    /// Replace this integer with its absolute value in place.
    ///
    /// - Requires: This integer must be properly initialized.
    /// - Guarantees: After this call, `self` equals `|self|` (before the call).
    ///
    /// - Note: Wraps `mpz_abs`.
    public mutating func makeAbsolute() {
        _ensureUnique()
        // Use withUnsafeMutablePointer to avoid Swift exclusivity violation
        // when
        // passing the same storage for both input and output parameters
        withUnsafeMutablePointer(to: &_storage.value) { rop in
            let op = UnsafePointer(rop)
            __gmpz_abs(rop, op)
        }
    }

    // MARK: - Combined Multiply-Add/Subtract

    /// Add the product of two integers to this integer in place.
    ///
    /// Equivalent to `self = self + multiplicand * multiplier`, but potentially
    /// more efficient as it avoids creating an intermediate product.
    ///
    /// - Parameters:
    ///   - multiplicand: The first factor of the product to add.
    ///   - multiplier: The second factor of the product to add.
    ///
    /// - Requires: All integers must be properly initialized.
    /// - Guarantees: After this call, `self` equals `self + multiplicand *
    /// multiplier`
    ///   (before the call). The operation is safe even if `self` is the same as
    ///   `multiplicand` or `multiplier`.
    ///
    /// - Note: Wraps `mpz_addmul`.
    public mutating func addProduct(
        _ multiplicand: GMPInteger,
        _ multiplier: GMPInteger
    ) {
        // Use immutable operations to avoid exclusivity violations when self,
        // multiplicand,
        // or multiplier are the same variable. Equivalent to: self = self +
        // multiplicand * multiplier
        let product = multiplicand.multiplied(by: multiplier)
        let result = adding(product)
        self = result
    }

    /// Add the product of a `GMPInteger` and an `Int` to this integer in place.
    ///
    /// - Parameters:
    ///   - multiplicand: The `GMPInteger` factor of the product to add.
    ///   - multiplier: The `Int` factor of the product to add.
    ///
    /// - Requires: This integer and `multiplicand` must be properly
    /// initialized.
    /// - Guarantees: After this call, `self` equals `self + multiplicand *
    /// multiplier`
    ///   (before the call).
    ///
    /// - Note: Wraps `mpz_addmul_ui`.
    public mutating func addProduct(
        _ multiplicand: GMPInteger,
        _ multiplier: Int
    ) {
        // Use immutable operations to avoid exclusivity violations when self
        // === multiplicand
        let product = multiplicand.multiplied(by: multiplier)
        let result = adding(product)
        self = result
    }

    /// Subtract the product of two integers from this integer in place.
    ///
    /// Equivalent to `self = self - multiplicand * multiplier`, but potentially
    /// more efficient.
    ///
    /// - Parameters:
    ///   - multiplicand: The first factor of the product to subtract.
    ///   - multiplier: The second factor of the product to subtract.
    ///
    /// - Requires: All integers must be properly initialized.
    /// - Guarantees: After this call, `self` equals `self - multiplicand *
    /// multiplier`
    ///   (before the call).
    ///
    /// - Note: Wraps `mpz_submul`.
    public mutating func subtractProduct(
        _ multiplicand: GMPInteger,
        _ multiplier: GMPInteger
    ) {
        // Use immutable operations to avoid exclusivity violations when self,
        // multiplicand,
        // or multiplier are the same variable. Equivalent to: self = self -
        // multiplicand * multiplier
        let product = multiplicand.multiplied(by: multiplier)
        let result = subtracting(product)
        self = result
    }

    /// Subtract the product of a `GMPInteger` and an `Int` from this integer in
    /// place.
    ///
    /// - Parameters:
    ///   - multiplicand: The `GMPInteger` factor of the product to subtract.
    ///   - multiplier: The `Int` factor of the product to subtract.
    ///
    /// - Requires: This integer and `multiplicand` must be properly
    /// initialized.
    /// - Guarantees: After this call, `self` equals `self - multiplicand *
    /// multiplier`
    ///   (before the call).
    ///
    /// - Note: Wraps `mpz_submul_ui`.
    public mutating func subtractProduct(
        _ multiplicand: GMPInteger,
        _ multiplier: Int
    ) {
        // Use immutable operations to avoid exclusivity violations when self
        // === multiplicand
        let product = multiplicand.multiplied(by: multiplier)
        let result = subtracting(product)
        self = result
    }

    // MARK: - Power of 2 Operations

    /// Multiply this integer by 2 raised to the power of `exponent`, returning
    /// a new value.
    ///
    /// This is equivalent to a left shift by `exponent` bits. More efficient
    /// than
    /// general multiplication when multiplying by powers of 2.
    ///
    /// - Parameter exponent: The exponent for the power of 2. Can be negative
    /// for division.
    /// - Returns: A new `GMPInteger` equal to `self * 2^exponent`.
    ///
    /// - Requires: This integer must be properly initialized.
    /// - Guarantees: Returns a new `GMPInteger` with the result. `self` is
    /// unchanged.
    ///
    /// - Note: Wraps `mpz_mul_2exp`.
    public func multipliedByPowerOf2(_ exponent: Int) -> GMPInteger {
        let result = GMPInteger() // Mutated through pointer below
        if exponent >= 0 {
            __gmpz_mul_2exp(
                &result._storage.value,
                &_storage.value,
                mp_bitcnt_t(exponent)
            )
        } else {
            // For negative exponent, divide by 2^|exponent| using ceiling
            // division
            // (truncating toward zero, which is what we want for this
            // operation)
            __gmpz_cdiv_q_2exp(
                &result._storage.value,
                &_storage.value,
                mp_bitcnt_t(-exponent)
            )
        }
        return result
    }

    /// Multiply this integer by 2 raised to the power of `exponent` in place.
    ///
    /// - Parameter exponent: The exponent for the power of 2. Can be negative
    /// for division.
    ///
    /// - Requires: This integer must be properly initialized.
    /// - Guarantees: After this call, `self` equals `self * 2^exponent` (before
    /// the call).
    ///
    /// - Note: Wraps `mpz_mul_2exp`.
    public mutating func multiplyByPowerOf2(_ exponent: Int) {
        _ensureUnique()
        // Use withUnsafeMutablePointer to avoid Swift exclusivity violation
        // when
        // passing the same storage for both input and output parameters
        withUnsafeMutablePointer(to: &_storage.value) { rop in
            let op = UnsafePointer(rop)
            if exponent >= 0 {
                __gmpz_mul_2exp(rop, op, mp_bitcnt_t(exponent))
            } else {
                // For negative exponent, divide by 2^|exponent| using ceiling
                // division
                __gmpz_cdiv_q_2exp(rop, op, mp_bitcnt_t(-exponent))
            }
        }
    }

    // MARK: - Operator Overloads

    /// Add two `GMPInteger` values.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side integer.
    ///   - rhs: The right-hand side integer.
    /// - Returns: The sum of `lhs` and `rhs`.
    ///
    /// - Requires: Both integers must be properly initialized.
    /// - Guarantees: Returns a new `GMPInteger` with the sum.
    public static func + (lhs: GMPInteger, rhs: GMPInteger) -> GMPInteger {
        lhs.adding(rhs)
    }

    /// Add a `GMPInteger` and an `Int`.
    ///
    /// - Parameters:
    ///   - lhs: The `GMPInteger` value.
    ///   - rhs: The `Int` value.
    /// - Returns: The sum of `lhs` and `rhs`.
    ///
    /// - Requires: `lhs` must be properly initialized.
    /// - Guarantees: Returns a new `GMPInteger` with the sum.
    public static func + (lhs: GMPInteger, rhs: Int) -> GMPInteger {
        lhs.adding(rhs)
    }

    /// Add an `Int` and a `GMPInteger`.
    ///
    /// - Parameters:
    ///   - lhs: The `Int` value.
    ///   - rhs: The `GMPInteger` value.
    /// - Returns: The sum of `lhs` and `rhs`.
    ///
    /// - Requires: `rhs` must be properly initialized.
    /// - Guarantees: Returns a new `GMPInteger` with the sum.
    public static func + (lhs: Int, rhs: GMPInteger) -> GMPInteger {
        rhs.adding(lhs)
    }

    /// Subtract two `GMPInteger` values.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side integer.
    ///   - rhs: The right-hand side integer.
    /// - Returns: The difference of `lhs` and `rhs`.
    ///
    /// - Requires: Both integers must be properly initialized.
    /// - Guarantees: Returns a new `GMPInteger` with the difference.
    public static func - (lhs: GMPInteger, rhs: GMPInteger) -> GMPInteger {
        lhs.subtracting(rhs)
    }

    /// Subtract an `Int` from a `GMPInteger`.
    ///
    /// - Parameters:
    ///   - lhs: The `GMPInteger` value.
    ///   - rhs: The `Int` value.
    /// - Returns: The difference of `lhs` and `rhs`.
    ///
    /// - Requires: `lhs` must be properly initialized.
    /// - Guarantees: Returns a new `GMPInteger` with the difference.
    public static func - (lhs: GMPInteger, rhs: Int) -> GMPInteger {
        lhs.subtracting(rhs)
    }

    /// Subtract a `GMPInteger` from an `Int`.
    ///
    /// - Parameters:
    ///   - lhs: The `Int` value.
    ///   - rhs: The `GMPInteger` value.
    /// - Returns: The difference of `lhs` and `rhs`.
    ///
    /// - Requires: `rhs` must be properly initialized.
    /// - Guarantees: Returns a new `GMPInteger` with the difference.
    public static func - (lhs: Int, rhs: GMPInteger) -> GMPInteger {
        subtracting(lhs, rhs)
    }

    /// Multiply two `GMPInteger` values.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side integer.
    ///   - rhs: The right-hand side integer.
    /// - Returns: The product of `lhs` and `rhs`.
    ///
    /// - Requires: Both integers must be properly initialized.
    /// - Guarantees: Returns a new `GMPInteger` with the product.
    public static func * (lhs: GMPInteger, rhs: GMPInteger) -> GMPInteger {
        lhs.multiplied(by: rhs)
    }

    /// Multiply a `GMPInteger` and an `Int`.
    ///
    /// - Parameters:
    ///   - lhs: The `GMPInteger` value.
    ///   - rhs: The `Int` value.
    /// - Returns: The product of `lhs` and `rhs`.
    ///
    /// - Requires: `lhs` must be properly initialized.
    /// - Guarantees: Returns a new `GMPInteger` with the product.
    public static func * (lhs: GMPInteger, rhs: Int) -> GMPInteger {
        lhs.multiplied(by: rhs)
    }

    /// Multiply an `Int` and a `GMPInteger`.
    ///
    /// - Parameters:
    ///   - lhs: The `Int` value.
    ///   - rhs: The `GMPInteger` value.
    /// - Returns: The product of `lhs` and `rhs`.
    ///
    /// - Requires: `rhs` must be properly initialized.
    /// - Guarantees: Returns a new `GMPInteger` with the product.
    public static func * (lhs: Int, rhs: GMPInteger) -> GMPInteger {
        rhs.multiplied(by: lhs)
    }

    /// Negate a `GMPInteger` value.
    ///
    /// - Parameter value: The integer to negate.
    /// - Returns: The negation of `value`.
    ///
    /// - Requires: `value` must be properly initialized.
    /// - Guarantees: Returns a new `GMPInteger` with the negated value.
    public static prefix func - (value: GMPInteger) -> GMPInteger {
        value.negated()
    }

    /// Add a `GMPInteger` to another in place.
    ///
    /// - Parameters:
    ///   - lhs: The integer to modify.
    ///   - rhs: The integer to add.
    ///
    /// - Requires: Both integers must be properly initialized.
    /// - Guarantees: After this call, `lhs` equals `lhs + rhs` (before the
    /// call).
    public static func += (lhs: inout GMPInteger, rhs: GMPInteger) {
        lhs.add(rhs)
    }

    /// Add an `Int` to a `GMPInteger` in place.
    ///
    /// - Parameters:
    ///   - lhs: The integer to modify.
    ///   - rhs: The `Int` to add.
    ///
    /// - Requires: `lhs` must be properly initialized.
    /// - Guarantees: After this call, `lhs` equals `lhs + rhs` (before the
    /// call).
    public static func += (lhs: inout GMPInteger, rhs: Int) {
        lhs.add(rhs)
    }

    /// Subtract a `GMPInteger` from another in place.
    ///
    /// - Parameters:
    ///   - lhs: The integer to modify.
    ///   - rhs: The integer to subtract.
    ///
    /// - Requires: Both integers must be properly initialized.
    /// - Guarantees: After this call, `lhs` equals `lhs - rhs` (before the
    /// call).
    public static func -= (lhs: inout GMPInteger, rhs: GMPInteger) {
        lhs.subtract(rhs)
    }

    /// Subtract an `Int` from a `GMPInteger` in place.
    ///
    /// - Parameters:
    ///   - lhs: The integer to modify.
    ///   - rhs: The `Int` to subtract.
    ///
    /// - Requires: `lhs` must be properly initialized.
    /// - Guarantees: After this call, `lhs` equals `lhs - rhs` (before the
    /// call).
    public static func -= (lhs: inout GMPInteger, rhs: Int) {
        lhs.subtract(rhs)
    }

    /// Multiply a `GMPInteger` by another in place.
    ///
    /// - Parameters:
    ///   - lhs: The integer to modify.
    ///   - rhs: The integer to multiply by.
    ///
    /// - Requires: Both integers must be properly initialized.
    /// - Guarantees: After this call, `lhs` equals `lhs * rhs` (before the
    /// call).
    public static func *= (lhs: inout GMPInteger, rhs: GMPInteger) {
        lhs.multiply(by: rhs)
    }

    /// Multiply a `GMPInteger` by an `Int` in place.
    ///
    /// - Parameters:
    ///   - lhs: The integer to modify.
    ///   - rhs: The `Int` to multiply by.
    ///
    /// - Requires: `lhs` must be properly initialized.
    /// - Guarantees: After this call, `lhs` equals `lhs * rhs` (before the
    /// call).
    public static func *= (lhs: inout GMPInteger, rhs: Int) {
        lhs.multiply(by: rhs)
    }
}
