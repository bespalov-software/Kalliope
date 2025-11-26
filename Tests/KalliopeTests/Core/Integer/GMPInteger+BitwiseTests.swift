@testable import Kalliope
import Testing

// MARK: - Bitwise Logical Operations Tests

struct GMPIntegerBitwiseAndTests {
    @Test
    func aND_two_positive_integers() async throws {
        // Given: Two positive GMPInteger values with known bit patterns
        let a = GMPInteger(0b1010) // 10
        let b = GMPInteger(0b1100) // 12

        // When: result = a.bitwiseAnd(b)
        let result = a.bitwiseAnd(b)

        // Then: result equals the bitwise AND of the two values, a and b are unchanged
        #expect(result.toInt() == 0b1000) // 8
        #expect(a.toInt() == 10)
        #expect(b.toInt() == 12)
    }

    @Test
    func aND_positive_and_negative_integers() async throws {
        // Given: A positive GMPInteger a and a negative GMPInteger b
        let a = GMPInteger(0b1010) // 10
        let b = GMPInteger(-3) // -3 in two's complement

        // When: result = a.bitwiseAnd(b)
        let result = a.bitwiseAnd(b)

        // Then: result equals the bitwise AND using two's complement representation, a and b are unchanged
        // 10 & -3 = 8 (in Swift/standard two's complement)
        // GMP uses infinite sign extension, so result should match Swift's
        // behavior
        #expect(result.toInt() == (10 & -3))
        #expect(a.toInt() == 10)
        #expect(b.toInt() == -3)
    }

    @Test
    func aND_two_negative_integers() async throws {
        // Given: Two negative GMPInteger values
        let a = GMPInteger(-5)
        let b = GMPInteger(-3)

        // When: result = a.bitwiseAnd(b)
        let result = a.bitwiseAnd(b)

        // Then: result equals the bitwise AND using two's complement representation, a and b are unchanged
        #expect(a.toInt() == -5)
        #expect(b.toInt() == -3)
        // Result should be negative (AND of two negatives in two's complement)
        #expect(result.toInt() < 0)
    }

    @Test
    func aND_with_zero() async throws {
        // Given: A GMPInteger a and zero GMPInteger
        let a = GMPInteger(42)
        let zero = GMPInteger(0)

        // When: result = a.bitwiseAnd(zero)
        let result = a.bitwiseAnd(zero)

        // Then: result equals zero, a and zero are unchanged
        #expect(result.toInt() == 0)
        #expect(a.toInt() == 42)
        #expect(zero.toInt() == 0)
    }

    @Test
    func aND_with_ones_complement() async throws {
        // Given: A GMPInteger a and -1 (all bits set)
        let a = GMPInteger(42)
        let minusOne = GMPInteger(-1)

        // When: result = a.bitwiseAnd(-1)
        let result = a.bitwiseAnd(minusOne)

        // Then: result equals a, a is unchanged
        #expect(result.toInt() == 42)
        #expect(a.toInt() == 42)
    }

    @Test
    func aND_identical_values() async throws {
        // Given: Two identical GMPInteger values
        let a = GMPInteger(42)

        // When: result = a.bitwiseAnd(a)
        let result = a.bitwiseAnd(a)

        // Then: result equals a, a is unchanged
        #expect(result.toInt() == 42)
        #expect(a.toInt() == 42)
    }

    @Test
    func aND_large_values() async throws {
        // Given: Two large GMPInteger values with many bits
        let a = GMPInteger("123456789012345678901234567890")!
        let b = GMPInteger("987654321098765432109876543210")!

        // When: result = a.bitwiseAnd(b)
        let result = a.bitwiseAnd(b)

        // Then: result equals the bitwise AND, a and b are unchanged
        // Verify operands unchanged
        #expect(a.toString() == "123456789012345678901234567890")
        #expect(b.toString() == "987654321098765432109876543210")
        // Result should be less than or equal to both operands
        #expect(result <= a)
        #expect(result <= b)
    }
}

struct GMPIntegerBitwiseOrTests {
    @Test
    func oR_two_positive_integers() async throws {
        // Given: Two positive GMPInteger values with known bit patterns
        let a = GMPInteger(0b1010) // 10
        let b = GMPInteger(0b1100) // 12

        // When: result = a.bitwiseOr(b)
        let result = a.bitwiseOr(b)

        // Then: result equals the bitwise OR of the two values, a and b are unchanged
        #expect(result.toInt() == 0b1110) // 14
        #expect(a.toInt() == 10)
        #expect(b.toInt() == 12)
    }

    @Test
    func oR_positive_and_negative_integers() async throws {
        // Given: A positive GMPInteger a and a negative GMPInteger b
        let a = GMPInteger(10)
        let b = GMPInteger(-3)

        // When: result = a.bitwiseOr(b)
        let result = a.bitwiseOr(b)

        // Then: result equals the bitwise OR using two's complement representation, a and b are unchanged
        #expect(a.toInt() == 10)
        #expect(b.toInt() == -3)
        // Result should be negative (OR with negative in two's complement)
        #expect(result.toInt() < 0)
    }

    @Test
    func oR_two_negative_integers() async throws {
        // Given: Two negative GMPInteger values
        let a = GMPInteger(-5)
        let b = GMPInteger(-3)

        // When: result = a.bitwiseOr(b)
        let result = a.bitwiseOr(b)

        // Then: result equals the bitwise OR using two's complement representation, a and b are unchanged
        #expect(a.toInt() == -5)
        #expect(b.toInt() == -3)
        // Result should be negative
        #expect(result.toInt() < 0)
    }

    @Test
    func oR_with_zero() async throws {
        // Given: A GMPInteger a and zero GMPInteger
        let a = GMPInteger(42)
        let zero = GMPInteger(0)

        // When: result = a.bitwiseOr(zero)
        let result = a.bitwiseOr(zero)

        // Then: result equals a, a and zero are unchanged
        #expect(result.toInt() == 42)
        #expect(a.toInt() == 42)
        #expect(zero.toInt() == 0)
    }

    @Test
    func oR_with_ones_complement() async throws {
        // Given: A GMPInteger a and -1 (all bits set)
        let a = GMPInteger(42)
        let minusOne = GMPInteger(-1)

        // When: result = a.bitwiseOr(-1)
        let result = a.bitwiseOr(minusOne)

        // Then: result equals -1, a is unchanged
        #expect(result.toInt() == -1)
        #expect(a.toInt() == 42)
    }

    @Test
    func oR_identical_values() async throws {
        // Given: Two identical GMPInteger values
        let a = GMPInteger(42)

        // When: result = a.bitwiseOr(a)
        let result = a.bitwiseOr(a)

        // Then: result equals a, a is unchanged
        #expect(result.toInt() == 42)
        #expect(a.toInt() == 42)
    }
}

struct GMPIntegerBitwiseXorTests {
    @Test
    func xOR_two_positive_integers() async throws {
        // Given: Two positive GMPInteger values with known bit patterns
        let a = GMPInteger(0b1010) // 10
        let b = GMPInteger(0b1100) // 12

        // When: result = a.bitwiseXor(b)
        let result = a.bitwiseXor(b)

        // Then: result equals the bitwise XOR of the two values, a and b are unchanged
        #expect(result.toInt() == 0b0110) // 6
        #expect(a.toInt() == 10)
        #expect(b.toInt() == 12)
    }

    @Test
    func xOR_positive_and_negative_integers() async throws {
        // Given: A positive GMPInteger a and a negative GMPInteger b
        let a = GMPInteger(10)
        let b = GMPInteger(-3)

        // When: result = a.bitwiseXor(b)
        let result = a.bitwiseXor(b)

        // Then: result equals the bitwise XOR using two's complement representation, a and b are unchanged
        // 10 ^ -3 = -9 (in Swift/standard two's complement)
        // GMP uses infinite sign extension, so result should match Swift's
        // behavior
        #expect(result.toInt() == (10 ^ -3))
        #expect(a.toInt() == 10)
        #expect(b.toInt() == -3)
    }

    @Test
    func xOR_two_negative_integers() async throws {
        // Given: Two negative GMPInteger values
        let a = GMPInteger(-5)
        let b = GMPInteger(-3)

        // When: result = a.bitwiseXor(b)
        let result = a.bitwiseXor(b)

        // Then: result equals the bitwise XOR using two's complement representation, a and b are unchanged
        // -5 ^ -3 = 6 (in Swift/standard two's complement)
        // GMP uses infinite sign extension, so result should match Swift's
        // behavior
        #expect(result.toInt() == ((-5) ^ -3))
        #expect(a.toInt() == -5)
        #expect(b.toInt() == -3)
    }

    @Test
    func xOR_with_zero() async throws {
        // Given: A GMPInteger a and zero GMPInteger
        let a = GMPInteger(42)
        let zero = GMPInteger(0)

        // When: result = a.bitwiseXor(zero)
        let result = a.bitwiseXor(zero)

        // Then: result equals a, a and zero are unchanged
        #expect(result.toInt() == 42)
        #expect(a.toInt() == 42)
        #expect(zero.toInt() == 0)
    }

    @Test
    func xOR_with_self() async throws {
        // Given: A GMPInteger a
        let a = GMPInteger(42)

        // When: result = a.bitwiseXor(a)
        let result = a.bitwiseXor(a)

        // Then: result equals zero, a is unchanged
        #expect(result.toInt() == 0)
        #expect(a.toInt() == 42)
    }

    @Test
    func xOR_is_commutative() async throws {
        // Given: Two GMPInteger values a and b
        let a = GMPInteger(42)
        let b = GMPInteger(17)

        // When: result1 = a.bitwiseXor(b) and result2 = b.bitwiseXor(a)
        let result1 = a.bitwiseXor(b)
        let result2 = b.bitwiseXor(a)

        // Then: result1 equals result2
        #expect(result1.toInt() == result2.toInt())
    }
}

struct GMPIntegerBitwiseNotTests {
    @Test
    func nOT_positive_integer() async throws {
        // Given: A positive GMPInteger value
        let a = GMPInteger(42)

        // When: result = a.bitwiseNot
        let result = a.bitwiseNot

        // Then: result equals the bitwise NOT (one's complement), a is unchanged
        #expect(a.toInt() == 42)
        // For positive values, NOT should be negative
        #expect(result.toInt() < 0)
    }

    @Test
    func nOT_negative_integer() async throws {
        // Given: A negative GMPInteger value
        let a = GMPInteger(-5)

        // When: result = a.bitwiseNot
        let result = a.bitwiseNot

        // Then: result equals the bitwise NOT using two's complement representation, a is unchanged
        #expect(a.toInt() == -5)
        // NOT of negative should be positive (approximately)
        #expect(result.toInt() >= 0)
    }

    @Test
    func nOT_zero() async throws {
        // Given: Zero GMPInteger
        let zero = GMPInteger(0)

        // When: result = zero.bitwiseNot
        let result = zero.bitwiseNot

        // Then: result equals -1 (all bits set), zero is unchanged
        #expect(result.toInt() == -1)
        #expect(zero.toInt() == 0)
    }

    @Test
    func nOT_ones_complement() async throws {
        // Given: -1 GMPInteger (all bits set)
        let minusOne = GMPInteger(-1)

        // When: result = minusOne.bitwiseNot
        let result = minusOne.bitwiseNot

        // Then: result equals zero, minusOne is unchanged
        #expect(result.toInt() == 0)
        #expect(minusOne.toInt() == -1)
    }

    @Test
    func nOT_double_complement() async throws {
        // Given: A GMPInteger a
        let a = GMPInteger(42)

        // When: result = a.bitwiseNot.bitwiseNot
        let result = a.bitwiseNot.bitwiseNot

        // Then: result equals a (NOT is its own inverse for one's complement representation)
        #expect(result.toInt() == 42)
        #expect(a.toInt() == 42)
    }
}

struct GMPIntegerFormBitwiseAndTests {
    @Test
    func formBitwiseAnd_two_positive_integers() async throws {
        // Given: A positive GMPInteger a and another positive GMPInteger b
        var a = GMPInteger(0b1010) // 10
        let b = GMPInteger(0b1100) // 12

        // When: a.formBitwiseAnd(b)
        a.formBitwiseAnd(b)

        // Then: a equals the bitwise AND of original a and b, b is unchanged
        #expect(a.toInt() == 0b1000) // 8
        #expect(b.toInt() == 12)
    }

    @Test
    func formBitwiseAnd_with_zero() async throws {
        // Given: A GMPInteger a and zero GMPInteger
        var a = GMPInteger(42)
        let zero = GMPInteger(0)

        // When: a.formBitwiseAnd(zero)
        a.formBitwiseAnd(zero)

        // Then: a equals zero, zero is unchanged
        #expect(a.toInt() == 0)
        #expect(zero.toInt() == 0)
    }

    @Test
    func formBitwiseAnd_self_modification() async throws {
        // Given: A GMPInteger a with a copy original = a
        var a = GMPInteger(42)
        let original = a

        // When: a.formBitwiseAnd(a)
        a.formBitwiseAnd(a)

        // Then: a equals original, a is unchanged
        #expect(a.toInt() == original.toInt())
    }
}

struct GMPIntegerFormBitwiseOrTests {
    @Test
    func formBitwiseOr_two_positive_integers() async throws {
        // Given: A positive GMPInteger a and another positive GMPInteger b
        var a = GMPInteger(0b1010) // 10
        let b = GMPInteger(0b1100) // 12

        // When: a.formBitwiseOr(b)
        a.formBitwiseOr(b)

        // Then: a equals the bitwise OR of original a and b, b is unchanged
        #expect(a.toInt() == 0b1110) // 14
        #expect(b.toInt() == 12)
    }

    @Test
    func formBitwiseOr_with_zero() async throws {
        // Given: A GMPInteger a and zero GMPInteger
        var a = GMPInteger(42)
        let zero = GMPInteger(0)

        // When: a.formBitwiseOr(zero)
        a.formBitwiseOr(zero)

        // Then: a remains unchanged, zero is unchanged
        #expect(a.toInt() == 42)
        #expect(zero.toInt() == 0)
    }
}

struct GMPIntegerFormBitwiseXorTests {
    @Test
    func formBitwiseXor_two_positive_integers() async throws {
        // Given: A positive GMPInteger a and another positive GMPInteger b
        var a = GMPInteger(0b1010) // 10
        let b = GMPInteger(0b1100) // 12

        // When: a.formBitwiseXor(b)
        a.formBitwiseXor(b)

        // Then: a equals the bitwise XOR of original a and b, b is unchanged
        #expect(a.toInt() == 0b0110) // 6
        #expect(b.toInt() == 12)
    }

    @Test
    func formBitwiseXor_with_self() async throws {
        // Given: A GMPInteger a
        var a = GMPInteger(42)

        // When: a.formBitwiseXor(a)
        a.formBitwiseXor(a)

        // Then: a equals zero
        #expect(a.toInt() == 0)
    }
}

struct GMPIntegerFormBitwiseNotTests {
    @Test
    func formBitwiseNot_positive_integer() async throws {
        // Given: A positive GMPInteger a with original value stored
        var a = GMPInteger(42)
        let originalValue = a.toInt()

        // When: a.formBitwiseNot()
        a.formBitwiseNot()

        // Then: a equals the bitwise NOT of the original value
        let expected = GMPInteger(originalValue).bitwiseNot
        #expect(a.toInt() == expected.toInt())
    }

    @Test
    func formBitwiseNot_zero() async throws {
        // Given: Zero GMPInteger a
        var a = GMPInteger(0)

        // When: a.formBitwiseNot()
        a.formBitwiseNot()

        // Then: a equals -1 (all bits set)
        #expect(a.toInt() == -1)
    }
}

// MARK: - Bit Shifts Tests

struct GMPIntegerLeftShiftedTests {
    @Test
    func leftShifted_positive_integer_by_positive_count() async throws {
        // Given: A positive GMPInteger a and a positive shift count
        let a = GMPInteger(5)
        let count = 3

        // When: result = a.leftShifted(by: count)
        let result = a.leftShifted(by: count)

        // Then: result equals a * (2^count), a is unchanged
        #expect(result.toInt() == 5 * (1 << 3)) // 5 * 8 = 40
        #expect(a.toInt() == 5)
    }

    @Test
    func leftShifted_by_zero() async throws {
        // Given: A GMPInteger a and shift count of 0
        let a = GMPInteger(42)

        // When: result = a.leftShifted(by: 0)
        let result = a.leftShifted(by: 0)

        // Then: result equals a, a is unchanged
        #expect(result.toInt() == 42)
        #expect(a.toInt() == 42)
    }

    @Test
    func leftShifted_by_one() async throws {
        // Given: A GMPInteger a
        let a = GMPInteger(7)

        // When: result = a.leftShifted(by: 1)
        let result = a.leftShifted(by: 1)

        // Then: result equals a * 2, a is unchanged
        #expect(result.toInt() == 14)
        #expect(a.toInt() == 7)
    }

    @Test
    func leftShifted_negative_integer() async throws {
        // Given: A negative GMPInteger a and a positive shift count
        let a = GMPInteger(-5)
        let count = 2

        // When: result = a.leftShifted(by: count)
        let result = a.leftShifted(by: count)

        // Then: result equals a * (2^count) (preserving sign), a is unchanged
        #expect(result.toInt() == -5 * (1 << 2)) // -5 * 4 = -20
        #expect(a.toInt() == -5)
    }

    @Test
    func leftShifted_large_count() async throws {
        // Given: A GMPInteger a and a large shift count (e.g., 1000)
        let a = GMPInteger(1)
        let count = 100

        // When: result = a.leftShifted(by: count)
        let result = a.leftShifted(by: count)

        // Then: result equals a * (2^count), a is unchanged
        let expected = a.multipliedByPowerOf2(100)
        #expect(result == expected)
        #expect(a.toInt() == 1)
    }

    @Test
    func leftShifted_zero_value() async throws {
        // Given: Zero GMPInteger and a positive shift count
        let zero = GMPInteger(0)
        let count = 10

        // When: result = zero.leftShifted(by: count)
        let result = zero.leftShifted(by: count)

        // Then: result equals zero, zero is unchanged
        #expect(result.toInt() == 0)
        #expect(zero.toInt() == 0)
    }
}

struct GMPIntegerRightShiftedTests {
    @Test
    func rightShifted_positive_integer_by_positive_count() async throws {
        // Given: A positive GMPInteger a and a positive shift count
        let a = GMPInteger(40)
        let count = 3

        // When: result = a.rightShifted(by: count)
        let result = a.rightShifted(by: count)

        // Then: result equals floor division a / (2^count), a is unchanged
        #expect(result.toInt() == 40 / (1 << 3)) // 40 / 8 = 5
        #expect(a.toInt() == 40)
    }

    @Test
    func rightShifted_by_zero() async throws {
        // Given: A GMPInteger a and shift count of 0
        let a = GMPInteger(42)

        // When: result = a.rightShifted(by: 0)
        let result = a.rightShifted(by: 0)

        // Then: result equals a, a is unchanged
        #expect(result.toInt() == 42)
        #expect(a.toInt() == 42)
    }

    @Test
    func rightShifted_by_one() async throws {
        // Given: A GMPInteger a
        let a = GMPInteger(14)

        // When: result = a.rightShifted(by: 1)
        let result = a.rightShifted(by: 1)

        // Then: result equals floor division a / 2, a is unchanged
        #expect(result.toInt() == 7)
        #expect(a.toInt() == 14)
    }

    @Test
    func rightShifted_negative_integer_arithmetic_shift() async throws {
        // Given: A negative GMPInteger a and a positive shift count
        let a = GMPInteger(-20)
        let count = 2

        // When: result = a.rightShifted(by: count)
        let result = a.rightShifted(by: count)

        // Then: result performs arithmetic right shift (sign-extending with 1s), a is unchanged
        // -20 >> 2 = -5 (arithmetic right shift)
        #expect(result.toInt() == -5)
        #expect(a.toInt() == -20)
    }

    @Test
    func rightShifted_odd_value_by_one() async throws {
        // Given: An odd positive GMPInteger (e.g., 7)
        let odd = GMPInteger(7)

        // When: result = odd.rightShifted(by: 1)
        let result = odd.rightShifted(by: 1)

        // Then: result equals 3 (floor division), odd is unchanged
        #expect(result.toInt() == 3)
        #expect(odd.toInt() == 7)
    }
}

struct GMPIntegerLeftShiftTests {
    @Test
    func leftShift_positive_integer_by_positive_count() async throws {
        // Given: A positive GMPInteger a and a positive shift count
        var a = GMPInteger(5)
        let count = 3

        // When: a.leftShift(by: count)
        a.leftShift(by: count)

        // Then: a equals original a * (2^count)
        #expect(a.toInt() == 5 * (1 << 3)) // 40
    }

    @Test
    func leftShift_by_zero() async throws {
        // Given: A GMPInteger a with original value stored
        var a = GMPInteger(42)
        let original = a.toInt()

        // When: a.leftShift(by: 0)
        a.leftShift(by: 0)

        // Then: a equals the original value (unchanged)
        #expect(a.toInt() == original)
    }

    @Test
    func leftShift_negative_integer() async throws {
        // Given: A negative GMPInteger a with original value stored
        var a = GMPInteger(-5)
        let count = 2

        // When: a.leftShift(by: count)
        a.leftShift(by: count)

        // Then: a equals original a * (2^count) (preserving sign)
        #expect(a.toInt() == -5 * (1 << 2)) // -20
    }
}

struct GMPIntegerRightShiftTests {
    @Test
    func rightShift_positive_integer_by_positive_count() async throws {
        // Given: A positive GMPInteger a and a positive shift count
        var a = GMPInteger(40)
        let count = 3

        // When: a.rightShift(by: count)
        a.rightShift(by: count)

        // Then: a equals floor division of original a / (2^count)
        #expect(a.toInt() == 5)
    }

    @Test
    func rightShift_by_zero() async throws {
        // Given: A GMPInteger a with original value stored
        var a = GMPInteger(42)
        let original = a.toInt()

        // When: a.rightShift(by: 0)
        a.rightShift(by: 0)

        // Then: a equals the original value (unchanged)
        #expect(a.toInt() == original)
    }

    @Test
    func rightShift_negative_integer_arithmetic_shift() async throws {
        // Given: A negative GMPInteger a with original value stored
        var a = GMPInteger(-20)
        let count = 2

        // When: a.rightShift(by: count)
        a.rightShift(by: count)

        // Then: a equals arithmetic right shift result (sign-extending)
        #expect(a.toInt() == -5)
    }
}

// MARK: - Bit Manipulation Tests

struct GMPIntegerBitManipulationTests {
    @Test
    func bit_Zero_ReturnsFalse() async throws {
        // Given: GMPInteger(42), index 0
        let integer = GMPInteger(42)

        // When: Call testBit(0)
        let result = integer.testBit(0)

        // Then: Returns false (42 is even, bit 0 is 0)
        #expect(result == false)
    }

    @Test
    func bit_One_ReturnsTrue() async throws {
        // Given: GMPInteger(43), index 0
        let integer = GMPInteger(43)

        // When: Call testBit(0)
        let result = integer.testBit(0)

        // Then: Returns true (43 is odd, bit 0 is 1)
        #expect(result == true)
    }

    @Test
    func bit_HigherBit_ReturnsCorrect() async throws {
        // Given: GMPInteger(42) = 0b101010, index 1
        let integer = GMPInteger(42)

        // When: Call testBit(1)
        let result = integer.testBit(1)

        // Then: Returns true (bit 1 is set)
        #expect(result == true)
    }

    @Test
    func setBit_Zero_ModifiesSelf() async throws {
        // Given: GMPInteger(42), index 0
        var integer = GMPInteger(42)

        // When: Call setBit(0)
        integer.setBit(0)

        // Then: Integer becomes 43 (bit 0 is set)
        #expect(integer.toInt() == 43)
    }

    @Test
    func setBit_AlreadySet_NoChange() async throws {
        // Given: GMPInteger(43), index 0
        var integer = GMPInteger(43)

        // When: Call setBit(0)
        integer.setBit(0)

        // Then: Integer remains 43
        #expect(integer.toInt() == 43)
    }

    @Test
    func clearBit_One_ModifiesSelf() async throws {
        // Given: GMPInteger(43), index 0
        var integer = GMPInteger(43)

        // When: Call clearBit(0)
        integer.clearBit(0)

        // Then: Integer becomes 42 (bit 0 is cleared)
        #expect(integer.toInt() == 42)
    }

    @Test
    func clearBit_AlreadyClear_NoChange() async throws {
        // Given: GMPInteger(42), index 0
        var integer = GMPInteger(42)

        // When: Call clearBit(0)
        integer.clearBit(0)

        // Then: Integer remains 42
        #expect(integer.toInt() == 42)
    }

    @Test
    func complementBit_Zero_ModifiesSelf() async throws {
        // Given: GMPInteger(42), index 0
        var integer = GMPInteger(42)

        // When: Call complementBit(0)
        integer.complementBit(0)

        // Then: Integer becomes 43 (bit 0 is flipped)
        #expect(integer.toInt() == 43)
    }

    @Test
    func complementBit_One_ModifiesSelf() async throws {
        // Given: GMPInteger(43), index 0
        var integer = GMPInteger(43)

        // When: Call complementBit(0)
        integer.complementBit(0)

        // Then: Integer becomes 42 (bit 0 is flipped)
        #expect(integer.toInt() == 42)
    }

    @Test
    func scan1_StartingFromZero_FindsFirstSetBit() async throws {
        // Given: GMPInteger(42) = 0b101010, start 0
        let integer = GMPInteger(42)

        // When: Call scan1(startingFrom: 0)
        let result = integer.scan1(startingFrom: 0)

        // Then: Returns 1 (first set bit is at index 1)
        #expect(result == 1)
    }

    @Test
    func scan1_StartingFromHigher_FindsNextSetBit() async throws {
        // Given: GMPInteger(42) = 0b101010, start 2
        let integer = GMPInteger(42)

        // When: Call scan1(startingFrom: 2)
        let result = integer.scan1(startingFrom: 2)

        // Then: Returns 3 (next set bit is at index 3)
        #expect(result == 3)
    }

    @Test
    func scan1_Zero_ReturnsNil() async throws {
        // Given: GMPInteger(0), start 0
        let integer = GMPInteger(0)

        // When: Call scan1(startingFrom: 0)
        let result = integer.scan1(startingFrom: 0)

        // Then: Returns nil (no set bits)
        #expect(result == nil)
    }

    @Test
    func scan0_StartingFromZero_FindsFirstClearBit() async throws {
        // Given: GMPInteger(42) = 0b101010, start 0
        let integer = GMPInteger(42)

        // When: Call scan0(startingFrom: 0)
        let result = integer.scan0(startingFrom: 0)

        // Then: Returns 0 (first clear bit is at index 0)
        #expect(result == 0)
    }

    @Test
    func scan0_AllBitsSet_ReturnsNil() async throws {
        // Given: GMPInteger(-1) (all bits set), start 0
        let integer = GMPInteger(-1)

        // When: Call scan0(startingFrom: 0)
        let result = integer.scan0(startingFrom: 0)

        // Then: Returns nil (no clear bits in negative numbers due to sign extension)
        // For -1 (all bits set), scan0 should return nil since there are no
        // clear bits
        #expect(result == nil)
    }

    @Test
    func firstSetBit_Positive_ReturnsIndex() async throws {
        // Given: GMPInteger(42) = 0b101010
        let integer = GMPInteger(42)

        // When: Access firstSetBit
        let result = integer.firstSetBit

        // Then: Returns 1 (first set bit is at index 1)
        #expect(result == 1)
    }

    @Test
    func firstSetBit_Zero_ReturnsNil() async throws {
        // Given: GMPInteger(0)
        let integer = GMPInteger(0)

        // When: Access firstSetBit
        let result = integer.firstSetBit

        // Then: Returns nil
        #expect(result == nil)
    }

    @Test
    func lastSetBit_Positive_ReturnsIndex() async throws {
        // Given: GMPInteger(42) = 0b101010 (6 bits)
        let integer = GMPInteger(42)

        // When: Access lastSetBit
        let result = integer.lastSetBit

        // Then: Returns bitCount - 1
        #expect(result == integer.bitCount - 1)
    }

    @Test
    func lastSetBit_Zero_ReturnsNil() async throws {
        // Given: GMPInteger(0)
        let integer = GMPInteger(0)

        // When: Access lastSetBit
        let result = integer.lastSetBit

        // Then: Returns nil
        #expect(result == nil)
    }

    @Test
    func populationCount_Positive_ReturnsCount() async throws {
        // Given: GMPInteger(42) = 0b101010
        let integer = GMPInteger(42)

        // When: Access populationCount
        let result = integer.populationCount

        // Then: Returns 3 (three bits are set)
        #expect(result == 3)
    }

    @Test
    func populationCount_Zero_ReturnsZero() async throws {
        // Given: GMPInteger(0)
        let integer = GMPInteger(0)

        // When: Access populationCount
        let result = integer.populationCount

        // Then: Returns 0
        #expect(result == 0)
    }

    @Test
    func hammingDistance_TwoDifferent_ReturnsDistance() async throws {
        // Given: GMPInteger(42) = 0b101010, GMPInteger(15) = 0b1111
        let a = GMPInteger(42)
        let b = GMPInteger(15)

        // When: Call hammingDistance(to: b)
        let result = a.hammingDistance(to: b)

        // Then: Returns positive value (number of differing bits)
        #expect(result > 0)
    }

    @Test
    func hammingDistance_Identical_ReturnsZero() async throws {
        // Given: GMPInteger(42), GMPInteger(42)
        let a = GMPInteger(42)
        let b = GMPInteger(42)

        // When: Call hammingDistance(to: b)
        let result = a.hammingDistance(to: b)

        // Then: Returns 0
        #expect(result == 0)
    }

    @Test
    func isOdd_Odd_ReturnsTrue() async throws {
        // Given: GMPInteger(43)
        let integer = GMPInteger(43)

        // When: Access isOdd
        let result = integer.isOdd

        // Then: Returns true
        #expect(result == true)
    }

    @Test
    func isOdd_Even_ReturnsFalse() async throws {
        // Given: GMPInteger(42)
        let integer = GMPInteger(42)

        // When: Access isOdd
        let result = integer.isOdd

        // Then: Returns false
        #expect(result == false)
    }

    @Test
    func isEven_Even_ReturnsTrue() async throws {
        // Given: GMPInteger(42)
        let integer = GMPInteger(42)

        // When: Access isEven
        let result = integer.isEven

        // Then: Returns true
        #expect(result == true)
    }

    @Test
    func isEven_Odd_ReturnsFalse() async throws {
        // Given: GMPInteger(43)
        let integer = GMPInteger(43)

        // When: Access isEven
        let result = integer.isEven

        // Then: Returns false
        #expect(result == false)
    }
}

// MARK: - Bitwise Operator Tests

struct GMPIntegerBitwiseOperatorTests {
    @Test
    func bitwiseAndOperator_TwoPositive_ReturnsResult() async throws {
        // Given: Two GMPInteger values
        let a = GMPInteger(0b1010) // 10
        let b = GMPInteger(0b1100) // 12

        // When: Evaluate a & b
        let result = a & b

        // Then: Returns bitwise AND
        #expect(result.toInt() == 0b1000) // 8
    }

    @Test
    func bitwiseOrOperator_TwoPositive_ReturnsResult() async throws {
        // Given: Two GMPInteger values
        let a = GMPInteger(0b1010) // 10
        let b = GMPInteger(0b1100) // 12

        // When: Evaluate a | b
        let result = a | b

        // Then: Returns bitwise OR
        #expect(result.toInt() == 0b1110) // 14
    }

    @Test
    func bitwiseXorOperator_TwoPositive_ReturnsResult() async throws {
        // Given: Two GMPInteger values
        let a = GMPInteger(0b1010) // 10
        let b = GMPInteger(0b1100) // 12

        // When: Evaluate a ^ b
        let result = a ^ b

        // Then: Returns bitwise XOR
        #expect(result.toInt() == 0b0110) // 6
    }

    @Test
    func bitwiseNotOperator_Positive_ReturnsResult() async throws {
        // Given: GMPInteger(42)
        let integer = GMPInteger(42)

        // When: Evaluate ~integer
        let result = ~integer

        // Then: Returns bitwise NOT
        #expect(result.toInt() != 42)
    }

    @Test
    func rightShiftOperator_Positive_ReturnsResult() async throws {
        // Given: GMPInteger(42), shift 2
        let integer = GMPInteger(42)

        // When: Evaluate integer >> 2
        let result = integer >> 2

        // Then: Returns right-shifted value
        #expect(result.toInt() == 10) // 42 / 4 = 10
    }

    @Test
    func bitwiseAndAssignmentOperator_ModifiesLhs() async throws {
        // Given: var a = GMPInteger(0b1010), b = GMPInteger(0b1100)
        var a = GMPInteger(0b1010) // 10
        let b = GMPInteger(0b1100) // 12

        // When: Evaluate a &= b
        a &= b

        // Then: a is modified to bitwise AND result
        #expect(a.toInt() == 0b1000) // 8
    }

    @Test
    func bitwiseOrAssignmentOperator_ModifiesLhs() async throws {
        // Given: var a = GMPInteger(0b1010), b = GMPInteger(0b1100)
        var a = GMPInteger(0b1010) // 10
        let b = GMPInteger(0b1100) // 12

        // When: Evaluate a |= b
        a |= b

        // Then: a is modified to bitwise OR result
        #expect(a.toInt() == 0b1110) // 14
    }

    @Test
    func bitwiseXorAssignmentOperator_ModifiesLhs() async throws {
        // Given: var a = GMPInteger(0b1010), b = GMPInteger(0b1100)
        var a = GMPInteger(0b1010) // 10
        let b = GMPInteger(0b1100) // 12

        // When: Evaluate a ^= b
        a ^= b

        // Then: a is modified to bitwise XOR result
        #expect(a.toInt() == 0b0110) // 6
    }

    @Test
    func leftShiftAssignmentOperator_ModifiesLhs() async throws {
        // Given: var a = GMPInteger(10), shift 2
        var a = GMPInteger(10)

        // When: Evaluate a <<= 2
        a <<= 2

        // Then: a is modified to left-shifted value
        #expect(a.toInt() == 40) // 10 * 4 = 40
    }

    @Test
    func rightShiftAssignmentOperator_ModifiesLhs() async throws {
        // Given: var a = GMPInteger(42), shift 2
        var a = GMPInteger(42)

        // When: Evaluate a >>= 2
        a >>= 2

        // Then: a is modified to right-shifted value
        #expect(a.toInt() == 10) // 42 / 4 = 10
    }
}
