import CKalliope

/// Bitwise operations for `GMPInteger`.
///
/// GMP treats integers as two's complement for bitwise operations. Negative
/// values
/// are represented in two's complement form, extending infinitely to the left
/// with 1s.
extension GMPInteger {
    // MARK: - Bitwise Logical Operations

    /// Compute the bitwise AND of this integer and another, returning a new
    /// value.
    ///
    /// Performs bitwise AND operation on each bit position. For negative
    /// values,
    /// uses two's complement representation.
    ///
    /// - Parameter other: The other integer.
    /// - Returns: A new `GMPInteger` with the bitwise AND result.
    ///
    /// - Requires: Both integers must be properly initialized.
    /// - Guarantees: Returns a new `GMPInteger` with the bitwise AND. `self` is
    /// unchanged.
    ///
    /// - Wraps: `mpz_and`
    public func bitwiseAnd(_ other: GMPInteger) -> GMPInteger {
        let result = GMPInteger()
        __gmpz_and(
            &result._storage.value,
            &_storage.value,
            &other._storage.value
        )
        return result
    }

    /// Compute the bitwise OR of this integer and another, returning a new
    /// value.
    ///
    /// - Parameter other: The other integer.
    /// - Returns: A new `GMPInteger` with the bitwise OR result.
    ///
    /// - Requires: Both integers must be properly initialized.
    /// - Guarantees: Returns a new `GMPInteger` with the bitwise OR. `self` is
    /// unchanged.
    ///
    /// - Wraps: `mpz_ior`
    public func bitwiseOr(_ other: GMPInteger) -> GMPInteger {
        let result = GMPInteger()
        __gmpz_ior(
            &result._storage.value,
            &_storage.value,
            &other._storage.value
        )
        return result
    }

    /// Compute the bitwise XOR of this integer and another, returning a new
    /// value.
    ///
    /// - Parameter other: The other integer.
    /// - Returns: A new `GMPInteger` with the bitwise XOR result.
    ///
    /// - Requires: Both integers must be properly initialized.
    /// - Guarantees: Returns a new `GMPInteger` with the bitwise XOR. `self` is
    /// unchanged.
    ///
    /// - Wraps: `mpz_xor`
    public func bitwiseXor(_ other: GMPInteger) -> GMPInteger {
        let result = GMPInteger()
        __gmpz_xor(
            &result._storage.value,
            &_storage.value,
            &other._storage.value
        )
        return result
    }

    /// Compute the bitwise NOT (one's complement) of this integer.
    ///
    /// Inverts all bits. For negative values, uses two's complement
    /// representation.
    ///
    /// - Returns: A new `GMPInteger` with the bitwise NOT result.
    ///
    /// - Requires: This integer must be properly initialized.
    /// - Guarantees: Returns a new `GMPInteger` with the bitwise NOT. `self` is
    /// unchanged.
    ///
    /// - Wraps: `mpz_com`
    public var bitwiseNot: GMPInteger {
        let result = GMPInteger()
        __gmpz_com(&result._storage.value, &_storage.value)
        return result
    }

    /// Perform bitwise AND with another integer in place.
    ///
    /// - Parameter other: The other integer.
    ///
    /// - Requires: Both integers must be properly initialized.
    /// - Guarantees: After this call, `self` equals `self & other` (before the
    /// call).
    ///
    /// - Wraps: `mpz_and`
    public mutating func formBitwiseAnd(_ other: GMPInteger) {
        // Use immutable bitwiseAnd() to avoid exclusivity violations when self
        // === other
        let result = bitwiseAnd(other)
        self = result
    }

    /// Perform bitwise OR with another integer in place.
    ///
    /// - Parameter other: The other integer.
    ///
    /// - Requires: Both integers must be properly initialized.
    /// - Guarantees: After this call, `self` equals `self | other` (before the
    /// call).
    ///
    /// - Wraps: `mpz_ior`
    public mutating func formBitwiseOr(_ other: GMPInteger) {
        // Use immutable bitwiseOr() to avoid exclusivity violations when self
        // === other
        let result = bitwiseOr(other)
        self = result
    }

    /// Perform bitwise XOR with another integer in place.
    ///
    /// - Parameter other: The other integer.
    ///
    /// - Requires: Both integers must be properly initialized.
    /// - Guarantees: After this call, `self` equals `self ^ other` (before the
    /// call).
    ///
    /// - Wraps: `mpz_xor`
    public mutating func formBitwiseXor(_ other: GMPInteger) {
        // Use immutable bitwiseXor() to avoid exclusivity violations when self
        // === other
        let result = bitwiseXor(other)
        self = result
    }

    /// Perform bitwise NOT (one's complement) in place.
    ///
    /// - Requires: This integer must be properly initialized.
    /// - Guarantees: After this call, `self` equals `~self` (before the call).
    ///
    /// - Wraps: `mpz_com`
    public mutating func formBitwiseNot() {
        // Use immutable bitwiseNot to avoid exclusivity violations
        let result = bitwiseNot
        self = result
    }

    // MARK: - Bit Shifts

    /// Left shift this integer by `count` bits, returning a new value.
    ///
    /// Equivalent to multiplying by 2^count. Shifts in zeros from the right.
    ///
    /// - Parameter count: The number of bits to shift. Can be negative for
    /// right shift.
    ///   Must be non-negative for left shift.
    /// - Returns: A new `GMPInteger` with the shifted value.
    ///
    /// - Requires: This integer must be properly initialized. `count` must be
    /// non-negative.
    /// - Guarantees: Returns a new `GMPInteger` with the left-shifted value.
    /// `self` is unchanged.
    ///
    /// - Wraps: `mpz_mul_2exp`
    public func leftShifted(by count: Int) -> GMPInteger {
        precondition(count >= 0, "count must be non-negative for left shift")
        let result = GMPInteger()
        __gmpz_mul_2exp(
            &result._storage.value,
            &_storage.value,
            mp_bitcnt_t(count)
        )
        return result
    }

    /// Right shift this integer by `count` bits, returning a new value.
    ///
    /// For positive values, equivalent to floor division by 2^count. For
    /// negative values,
    /// performs arithmetic right shift (sign-extending with 1s).
    ///
    /// - Parameter count: The number of bits to shift. Can be negative for left
    /// shift.
    ///   Must be non-negative for right shift.
    /// - Returns: A new `GMPInteger` with the shifted value.
    ///
    /// - Requires: This integer must be properly initialized. `count` must be
    /// non-negative.
    /// - Guarantees: Returns a new `GMPInteger` with the right-shifted value.
    /// `self` is unchanged.
    ///
    /// - Wraps: `mpz_tdiv_q_2exp`
    public func rightShifted(by count: Int) -> GMPInteger {
        precondition(count >= 0, "count must be non-negative for right shift")
        let result = GMPInteger()
        __gmpz_tdiv_q_2exp(
            &result._storage.value,
            &_storage.value,
            mp_bitcnt_t(count)
        )
        return result
    }

    /// Left shift this integer by `count` bits in place.
    ///
    /// - Parameter count: The number of bits to shift. Must be non-negative.
    ///
    /// - Requires: This integer must be properly initialized. `count` must be
    /// non-negative.
    /// - Guarantees: After this call, `self` equals `self << count` (before the
    /// call).
    ///
    /// - Wraps: `mpz_mul_2exp`
    public mutating func leftShift(by count: Int) {
        precondition(count >= 0, "count must be non-negative for left shift")
        // Use immutable leftShifted() to avoid exclusivity violations
        let result = leftShifted(by: count)
        self = result
    }

    /// Right shift this integer by `count` bits in place.
    ///
    /// - Parameter count: The number of bits to shift. Must be non-negative.
    ///
    /// - Requires: This integer must be properly initialized. `count` must be
    /// non-negative.
    /// - Guarantees: After this call, `self` equals `self >> count` (before the
    /// call).
    ///
    /// - Wraps: `mpz_tdiv_q_2exp`
    public mutating func rightShift(by count: Int) {
        precondition(count >= 0, "count must be non-negative for right shift")
        // Use immutable rightShifted() to avoid exclusivity violations
        let result = rightShifted(by: count)
        self = result
    }

    // MARK: - Bit Tests and Manipulation

    /// Test if the bit at the given index is set.
    ///
    /// Bit indices start at 0 for the least significant bit. For negative
    /// values,
    /// uses two's complement representation (infinite sign extension).
    ///
    /// - Parameter index: The bit index. Must be non-negative.
    /// - Returns: `true` if the bit is set, `false` otherwise.
    ///
    /// - Requires: This integer must be properly initialized. `index` must be
    /// non-negative.
    /// - Guarantees: Returns `true` if bit `index` is 1, `false` if it's 0. For
    /// negative
    ///   values, bits beyond the most significant bit are considered set (sign
    /// extension).
    ///
    /// - Wraps: `mpz_tstbit`
    public func testBit(_ index: Int) -> Bool {
        precondition(index >= 0, "index must be non-negative")
        return __gmpz_tstbit(&_storage.value, mp_bitcnt_t(index)) != 0
    }

    /// Set the bit at the given index to 1.
    ///
    /// - Parameter index: The bit index. Must be non-negative.
    ///
    /// - Requires: This integer must be properly initialized. `index` must be
    /// non-negative.
    /// - Guarantees: After this call, bit `index` is set to 1. Other bits are
    /// unchanged.
    ///
    /// - Wraps: `mpz_setbit`
    public mutating func setBit(_ index: Int) {
        precondition(index >= 0, "index must be non-negative")
        _ensureUnique()
        __gmpz_setbit(&_storage.value, mp_bitcnt_t(index))
    }

    /// Clear the bit at the given index (set to 0).
    ///
    /// - Parameter index: The bit index. Must be non-negative.
    ///
    /// - Requires: This integer must be properly initialized. `index` must be
    /// non-negative.
    /// - Guarantees: After this call, bit `index` is set to 0. Other bits are
    /// unchanged.
    ///
    /// - Wraps: `mpz_clrbit`
    public mutating func clearBit(_ index: Int) {
        precondition(index >= 0, "index must be non-negative")
        _ensureUnique()
        __gmpz_clrbit(&_storage.value, mp_bitcnt_t(index))
    }

    /// Complement (flip) the bit at the given index.
    ///
    /// - Parameter index: The bit index. Must be non-negative.
    ///
    /// - Requires: This integer must be properly initialized. `index` must be
    /// non-negative.
    /// - Guarantees: After this call, bit `index` is flipped (0 becomes 1, 1
    /// becomes 0).
    ///   Other bits are unchanged.
    ///
    /// - Wraps: `mpz_combit`
    public mutating func complementBit(_ index: Int) {
        precondition(index >= 0, "index must be non-negative")
        _ensureUnique()
        __gmpz_combit(&_storage.value, mp_bitcnt_t(index))
    }

    // MARK: - Bit Scanning

    /// Find the first set bit (1) starting from the given index.
    ///
    /// Scans from bit `start` upward (toward more significant bits) to find the
    /// first
    /// bit that is set.
    ///
    /// - Parameter start: The starting bit index. Must be non-negative.
    /// - Returns: The index of the first set bit found, or `nil` if no set bit
    /// exists
    ///   from `start` onward.
    ///
    /// - Requires: This integer must be properly initialized. `start` must be
    /// non-negative.
    /// - Guarantees: Returns the index of the first set bit at or after
    /// `start`, or `nil`
    ///   if all bits from `start` onward are clear. For negative values, always
    /// returns
    ///   a value (due to sign extension).
    ///
    /// - Wraps: `mpz_scan1`
    public func scan1(startingFrom start: Int) -> Int? {
        precondition(start >= 0, "start must be non-negative")
        let result = __gmpz_scan1(&_storage.value, mp_bitcnt_t(start))
        if result == ~mp_bitcnt_t(0) {
            return nil
        }
        return Int(result)
    }

    /// Find the first clear bit (0) starting from the given index.
    ///
    /// Scans from bit `start` upward to find the first bit that is clear.
    ///
    /// - Parameter start: The starting bit index. Must be non-negative.
    /// - Returns: The index of the first clear bit found, or `nil` if no clear
    /// bit exists
    ///   from `start` onward.
    ///
    /// - Requires: This integer must be properly initialized. `start` must be
    /// non-negative.
    /// - Guarantees: Returns the index of the first clear bit at or after
    /// `start`, or `nil`
    ///   if all bits from `start` onward are set. For negative values, may
    /// return `nil`
    ///   (due to sign extension).
    ///
    /// - Wraps: `mpz_scan0`
    public func scan0(startingFrom start: Int) -> Int? {
        precondition(start >= 0, "start must be non-negative")
        let result = __gmpz_scan0(&_storage.value, mp_bitcnt_t(start))
        if result == ~mp_bitcnt_t(0) {
            return nil
        }
        return Int(result)
    }

    /// Find the index of the first (least significant) set bit.
    ///
    /// Equivalent to `scan1(startingFrom: 0)`, but more efficient.
    ///
    /// - Returns: The index of the least significant set bit, or `nil` if the
    /// value is zero.
    ///
    /// - Requires: This integer must be properly initialized.
    /// - Guarantees: Returns the index of the least significant set bit, or
    /// `nil` if `self == 0`.
    public var firstSetBit: Int? {
        scan1(startingFrom: 0)
    }

    /// Find the index of the last (most significant) set bit.
    ///
    /// - Returns: The index of the most significant set bit, or `nil` if the
    /// value is zero.
    ///
    /// - Requires: This integer must be properly initialized.
    /// - Guarantees: Returns the index of the most significant set bit, or
    /// `nil` if `self == 0`.
    public var lastSetBit: Int? {
        if isZero {
            return nil
        }
        // The last set bit is at index (bitCount - 1)
        return bitCount - 1
    }

    // MARK: - Population Count and Hamming Distance

    /// Get the population count (number of set bits).
    ///
    /// Also known as the Hamming weight. Counts the number of bits set to 1.
    ///
    /// - Returns: The number of set bits.
    ///
    /// - Requires: This integer must be properly initialized.
    /// - Guarantees: Returns a non-negative integer representing the number of
    /// set bits.
    ///   Returns 0 if `self == 0`. For negative values, counts bits in two's
    /// complement
    ///   representation (may be large due to sign extension).
    ///
    /// - Wraps: `mpz_popcount`
    public var populationCount: Int {
        Int(__gmpz_popcount(&_storage.value))
    }

    /// Compute the Hamming distance to another integer.
    ///
    /// The Hamming distance is the number of bit positions where the two
    /// integers differ.
    /// Equivalent to the population count of the XOR of the two values.
    ///
    /// - Parameter other: The other integer.
    /// - Returns: The Hamming distance (number of differing bits).
    ///
    /// - Requires: Both integers must be properly initialized.
    /// - Guarantees: Returns a non-negative integer. Returns 0 if and only if
    /// `self == other`.
    public func hammingDistance(to other: GMPInteger) -> Int {
        bitwiseXor(other).populationCount
    }

    // MARK: - Parity

    /// Check if this integer is odd.
    ///
    /// - Returns: `true` if the least significant bit is set, `false`
    /// otherwise.
    ///
    /// - Requires: This integer must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `self % 2 != 0`.
    public var isOdd: Bool {
        testBit(0)
    }

    /// Check if this integer is even.
    ///
    /// - Returns: `true` if the least significant bit is clear, `false`
    /// otherwise.
    ///
    /// - Requires: This integer must be properly initialized.
    /// - Guarantees: Returns `true` if and only if `self % 2 == 0`.
    public var isEven: Bool {
        !testBit(0)
    }

    // MARK: - Operator Overloads

    /// Bitwise AND operator.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side integer.
    ///   - rhs: The right-hand side integer.
    /// - Returns: A new `GMPInteger` with the bitwise AND result.
    ///
    /// - Requires: Both integers must be properly initialized.
    /// - Guarantees: Returns a new `GMPInteger` with the bitwise AND.
    ///
    /// - Wraps: `mpz_and`
    public static func & (lhs: GMPInteger, rhs: GMPInteger) -> GMPInteger {
        lhs.bitwiseAnd(rhs)
    }

    /// Bitwise OR operator.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side integer.
    ///   - rhs: The right-hand side integer.
    /// - Returns: A new `GMPInteger` with the bitwise OR result.
    ///
    /// - Requires: Both integers must be properly initialized.
    /// - Guarantees: Returns a new `GMPInteger` with the bitwise OR.
    ///
    /// - Wraps: `mpz_ior`
    public static func | (lhs: GMPInteger, rhs: GMPInteger) -> GMPInteger {
        lhs.bitwiseOr(rhs)
    }

    /// Bitwise XOR operator.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side integer.
    ///   - rhs: The right-hand side integer.
    /// - Returns: A new `GMPInteger` with the bitwise XOR result.
    ///
    /// - Requires: Both integers must be properly initialized.
    /// - Guarantees: Returns a new `GMPInteger` with the bitwise XOR.
    ///
    /// - Wraps: `mpz_xor`
    public static func ^ (lhs: GMPInteger, rhs: GMPInteger) -> GMPInteger {
        lhs.bitwiseXor(rhs)
    }

    /// Bitwise NOT (one's complement) operator.
    ///
    /// - Parameter value: The integer to complement.
    /// - Returns: A new `GMPInteger` with the bitwise NOT result.
    ///
    /// - Requires: `value` must be properly initialized.
    /// - Guarantees: Returns a new `GMPInteger` with the bitwise NOT.
    ///
    /// - Wraps: `mpz_com`
    public static prefix func ~ (value: GMPInteger) -> GMPInteger {
        value.bitwiseNot
    }

    /// Left shift operator.
    ///
    /// - Parameters:
    ///   - lhs: The integer to shift.
    ///   - rhs: The number of bits to shift. Must be non-negative.
    /// - Returns: A new `GMPInteger` with the left-shifted value.
    ///
    /// - Requires: `lhs` must be properly initialized. `rhs` must be
    /// non-negative.
    /// - Guarantees: Returns a new `GMPInteger` with the left-shifted value.
    ///
    /// - Wraps: `mpz_mul_2exp`
    public static func << (lhs: GMPInteger, rhs: Int) -> GMPInteger {
        lhs.leftShifted(by: rhs)
    }

    /// Right shift operator.
    ///
    /// - Parameters:
    ///   - lhs: The integer to shift.
    ///   - rhs: The number of bits to shift. Must be non-negative.
    /// - Returns: A new `GMPInteger` with the right-shifted value.
    ///
    /// - Requires: `lhs` must be properly initialized. `rhs` must be
    /// non-negative.
    /// - Guarantees: Returns a new `GMPInteger` with the right-shifted value.
    ///
    /// - Wraps: `mpz_tdiv_q_2exp`
    public static func >> (lhs: GMPInteger, rhs: Int) -> GMPInteger {
        lhs.rightShifted(by: rhs)
    }

    /// Bitwise AND assignment operator.
    ///
    /// - Parameters:
    ///   - lhs: The integer to modify.
    ///   - rhs: The other integer.
    ///
    /// - Requires: Both integers must be properly initialized.
    /// - Guarantees: After this call, `lhs` equals `lhs & rhs` (before the
    /// call).
    ///
    /// - Wraps: `mpz_and`
    public static func &= (lhs: inout GMPInteger, rhs: GMPInteger) {
        lhs.formBitwiseAnd(rhs)
    }

    /// Bitwise OR assignment operator.
    ///
    /// - Parameters:
    ///   - lhs: The integer to modify.
    ///   - rhs: The other integer.
    ///
    /// - Requires: Both integers must be properly initialized.
    /// - Guarantees: After this call, `lhs` equals `lhs | rhs` (before the
    /// call).
    ///
    /// - Wraps: `mpz_ior`
    public static func |= (lhs: inout GMPInteger, rhs: GMPInteger) {
        lhs.formBitwiseOr(rhs)
    }

    /// Bitwise XOR assignment operator.
    ///
    /// - Parameters:
    ///   - lhs: The integer to modify.
    ///   - rhs: The other integer.
    ///
    /// - Requires: Both integers must be properly initialized.
    /// - Guarantees: After this call, `lhs` equals `lhs ^ rhs` (before the
    /// call).
    ///
    /// - Wraps: `mpz_xor`
    public static func ^= (lhs: inout GMPInteger, rhs: GMPInteger) {
        lhs.formBitwiseXor(rhs)
    }

    /// Left shift assignment operator.
    ///
    /// - Parameters:
    ///   - lhs: The integer to modify.
    ///   - rhs: The number of bits to shift. Must be non-negative.
    ///
    /// - Requires: `lhs` must be properly initialized. `rhs` must be
    /// non-negative.
    /// - Guarantees: After this call, `lhs` equals `lhs << rhs` (before the
    /// call).
    ///
    /// - Wraps: `mpz_mul_2exp`
    public static func <<= (lhs: inout GMPInteger, rhs: Int) {
        lhs.leftShift(by: rhs)
    }

    /// Right shift assignment operator.
    ///
    /// - Parameters:
    ///   - lhs: The integer to modify.
    ///   - rhs: The number of bits to shift. Must be non-negative.
    ///
    /// - Requires: `lhs` must be properly initialized. `rhs` must be
    /// non-negative.
    /// - Guarantees: After this call, `lhs` equals `lhs >> rhs` (before the
    /// call).
    ///
    /// - Wraps: `mpz_tdiv_q_2exp`
    public static func >>= (lhs: inout GMPInteger, rhs: Int) {
        lhs.rightShift(by: rhs)
    }
}
