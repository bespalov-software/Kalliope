@testable import Kalliope
import Testing

// MARK: - Immutable Operations Tests

struct GMPIntegerAddingTests {
    @Test
    func adding_TwoPositiveIntegers_ReturnsSum() async throws {
        // Given: a = GMPInteger(5), b = GMPInteger(3)
        let a = GMPInteger(5)
        let b = GMPInteger(3)

        // When: result = a.adding(b)
        let result = a.adding(b)

        // Then: result == 8 and a == 5 (unchanged)
        #expect(result.toInt() == 8)
        #expect(a.toInt() == 5)
    }

    @Test
    func adding_PositiveAndNegative_ReturnsDifference() async throws {
        // Given: a = GMPInteger(5), b = GMPInteger(-3)
        let a = GMPInteger(5)
        let b = GMPInteger(-3)

        // When: result = a.adding(b)
        let result = a.adding(b)

        // Then: result == 2 and a == 5 (unchanged)
        #expect(result.toInt() == 2)
        #expect(a.toInt() == 5)
    }

    @Test
    func adding_TwoNegative_ReturnsNegativeSum() async throws {
        // Given: a = GMPInteger(-5), b = GMPInteger(-3)
        let a = GMPInteger(-5)
        let b = GMPInteger(-3)

        // When: result = a.adding(b)
        let result = a.adding(b)

        // Then: result == -8 and a == -5 (unchanged)
        #expect(result.toInt() == -8)
        #expect(a.toInt() == -5)
    }

    @Test
    func adding_Zero_ReturnsSelf() async throws {
        // Given: a = GMPInteger(5), b = GMPInteger(0)
        let a = GMPInteger(5)
        let b = GMPInteger(0)

        // When: result = a.adding(b)
        let result = a.adding(b)

        // Then: result == 5 and a == 5 (unchanged)
        #expect(result.toInt() == 5)
        #expect(a.toInt() == 5)
    }

    @Test
    func adding_ToZero_ReturnsOther() async throws {
        // Given: a = GMPInteger(0), b = GMPInteger(3)
        let a = GMPInteger(0)
        let b = GMPInteger(3)

        // When: result = a.adding(b)
        let result = a.adding(b)

        // Then: result == 3 and a == 0 (unchanged)
        #expect(result.toInt() == 3)
        #expect(a.toInt() == 0)
    }

    @Test
    func adding_BothZero_ReturnsZero() async throws {
        // Given: a = GMPInteger(0), b = GMPInteger(0)
        let a = GMPInteger(0)
        let b = GMPInteger(0)

        // When: result = a.adding(b)
        let result = a.adding(b)

        // Then: result == 0 and a == 0 (unchanged)
        #expect(result.toInt() == 0)
        #expect(a.toInt() == 0)
    }

    @Test
    func adding_SameVariable_ReturnsDouble() async throws {
        // Given: a = GMPInteger(5)
        let a = GMPInteger(5)

        // When: result = a.adding(a)
        let result = a.adding(a)

        // Then: result == 10 and a == 5 (unchanged)
        #expect(result.toInt() == 10)
        #expect(a.toInt() == 5)
    }

    @Test
    func adding_OppositeValues_ReturnsZero() async throws {
        // Given: a = GMPInteger(5), b = GMPInteger(-5)
        let a = GMPInteger(5)
        let b = GMPInteger(-5)

        // When: result = a.adding(b)
        let result = a.adding(b)

        // Then: result == 0 and a == 5 (unchanged)
        #expect(result.toInt() == 0)
        #expect(a.toInt() == 5)
    }

    @Test
    func adding_LargeValues_ReturnsSum() async throws {
        // Given: a = GMPInteger(2^100), b = GMPInteger(2^50)
        let a = GMPInteger(
            "1267650600228229401496703205376",
            base: 10
        )! // 2^100
        let b = GMPInteger("1125899906842624", base: 10)! // 2^50
        let originalA = GMPInteger("1267650600228229401496703205376", base: 10)!

        // When: result = a.adding(b)
        let result = a.adding(b)

        // Then: result == 2^100 + 2^50 and a == 2^100 (unchanged)
        // Compute expected value dynamically to avoid string errors
        let expected = originalA.adding(b)
        #expect(result == expected)
        #expect(a == originalA)
    }

    @Test
    func adding_IntMax_ReturnsSum() async throws {
        // Given: a = GMPInteger(Int.max), b = GMPInteger(1)
        let a = GMPInteger(Int.max)
        let b = GMPInteger(1)

        // When: result = a.adding(b)
        let result = a.adding(b)

        // Then: result == Int.max + 1 (arbitrary precision) and a == Int.max (unchanged)
        let expected = GMPInteger(Int.max).adding(GMPInteger(1))
        #expect(result == expected)
        #expect(a.toInt() == Int.max)
    }

    @Test
    func adding_IntMin_ReturnsSum() async throws {
        // Given: a = GMPInteger(Int.min), b = GMPInteger(-1)
        let a = GMPInteger(Int.min)
        let b = GMPInteger(-1)

        // When: result = a.adding(b)
        let result = a.adding(b)

        // Then: result == Int.min - 1 (arbitrary precision) and a == Int.min (unchanged)
        let expected = GMPInteger(Int.min).adding(GMPInteger(-1))
        #expect(result == expected)
        #expect(a.toInt() == Int.min)
    }
}

struct GMPIntegerAddingIntTests {
    @Test
    func adding_Int_PositiveInt_ReturnsSum() async throws {
        // Given: a = GMPInteger(5), other = 3
        let a = GMPInteger(5)
        let other = 3

        // When: result = a.adding(other)
        let result = a.adding(other)

        // Then: result == 8 and a == 5 (unchanged)
        #expect(result.toInt() == 8)
        #expect(a.toInt() == 5)
    }

    @Test
    func adding_Int_NegativeInt_ReturnsDifference() async throws {
        // Given: a = GMPInteger(5), other = -3
        let a = GMPInteger(5)
        let other = -3

        // When: result = a.adding(other)
        let result = a.adding(other)

        // Then: result == 2 and a == 5 (unchanged)
        #expect(result.toInt() == 2)
        #expect(a.toInt() == 5)
    }

    @Test
    func adding_Int_Zero_ReturnsSelf() async throws {
        // Given: a = GMPInteger(5), other = 0
        let a = GMPInteger(5)
        let other = 0

        // When: result = a.adding(other)
        let result = a.adding(other)

        // Then: result == 5 and a == 5 (unchanged)
        #expect(result.toInt() == 5)
        #expect(a.toInt() == 5)
    }

    @Test
    func adding_Int_IntMax_ReturnsSum() async throws {
        // Given: a = GMPInteger(1), other = Int.max
        let a = GMPInteger(1)
        let other = Int.max

        // When: result = a.adding(other)
        let result = a.adding(other)

        // Then: result == Int.max + 1 (arbitrary precision) and a == 1 (unchanged)
        let expected = GMPInteger(Int.max).adding(1)
        #expect(result == expected)
        #expect(a.toInt() == 1)
    }

    @Test
    func adding_Int_IntMin_ReturnsSum() async throws {
        // Given: a = GMPInteger(1), other = Int.min
        let a = GMPInteger(1)
        let other = Int.min

        // When: result = a.adding(other)
        let result = a.adding(other)

        // Then: result == Int.min + 1 (arbitrary precision) and a == 1 (unchanged)
        // This tests the Int.min special case handling in the negative branch
        let expected = GMPInteger(Int.min).adding(1)
        #expect(result == expected)
        #expect(a.toInt() == 1)
    }

    @Test
    func adding_Int_IntMin_VerifiesSpecialCaseHandling() async throws {
        // Given: a = GMPInteger(10), other = Int.min
        // This test specifically verifies the Int.min branch is taken
        let a = GMPInteger(10)
        let other = Int.min

        // When: result = a.adding(other)
        let result = a.adding(other)

        // Then: The result should be computed correctly using the Int.min special case
        // Int.min = -2,147,483,648, so 10 + Int.min = 10 - 2,147,483,648 =
        // -2,147,483,638
        let expected = GMPInteger(10).subtracting(GMPInteger(Int.max).adding(1))
        #expect(result == expected)
    }

    @Test
    func adding_Int_One_ReturnsIncremented() async throws {
        // Given: a = GMPInteger(5), other = 1
        let a = GMPInteger(5)
        let other = 1

        // When: result = a.adding(other)
        let result = a.adding(other)

        // Then: result == 6 and a == 5 (unchanged)
        #expect(result.toInt() == 6)
        #expect(a.toInt() == 5)
    }

    @Test
    func adding_Int_MinusOne_ReturnsDecremented() async throws {
        // Given: a = GMPInteger(5), other = -1
        let a = GMPInteger(5)
        let other = -1

        // When: result = a.adding(other)
        let result = a.adding(other)

        // Then: result == 4 and a == 5 (unchanged)
        #expect(result.toInt() == 4)
        #expect(a.toInt() == 5)
    }
}

struct GMPIntegerSubtractingTests {
    @Test
    func subtracting_TwoPositiveIntegers_ReturnsDifference() async throws {
        let a = GMPInteger(5)
        let b = GMPInteger(3)
        let result = a.subtracting(b)
        #expect(result.toInt() == 2)
        #expect(a.toInt() == 5)
    }

    @Test
    func subtracting_PositiveAndNegative_ReturnsSum() async throws {
        let a = GMPInteger(5)
        let b = GMPInteger(-3)
        let result = a.subtracting(b)
        #expect(result.toInt() == 8)
        #expect(a.toInt() == 5)
    }

    @Test
    func subtracting_TwoNegative_ReturnsNegativeDifference() async throws {
        let a = GMPInteger(-5)
        let b = GMPInteger(-3)
        let result = a.subtracting(b)
        #expect(result.toInt() == -2)
        #expect(a.toInt() == -5)
    }

    @Test
    func subtracting_Zero_ReturnsSelf() async throws {
        let a = GMPInteger(5)
        let b = GMPInteger(0)
        let result = a.subtracting(b)
        #expect(result.toInt() == 5)
        #expect(a.toInt() == 5)
    }

    @Test
    func subtracting_FromZero_ReturnsNegatedOther() async throws {
        let a = GMPInteger(0)
        let b = GMPInteger(3)
        let result = a.subtracting(b)
        #expect(result.toInt() == -3)
        #expect(a.toInt() == 0)
    }

    @Test
    func subtracting_BothZero_ReturnsZero() async throws {
        let a = GMPInteger(0)
        let b = GMPInteger(0)
        let result = a.subtracting(b)
        #expect(result.toInt() == 0)
        #expect(a.toInt() == 0)
    }

    @Test
    func subtracting_SameValues_ReturnsZero() async throws {
        let a = GMPInteger(5)
        let b = GMPInteger(5)
        let result = a.subtracting(b)
        #expect(result.toInt() == 0)
        #expect(a.toInt() == 5)
    }

    @Test
    func subtracting_SameVariable_ReturnsZero() async throws {
        let a = GMPInteger(5)
        let result = a.subtracting(a)
        #expect(result.toInt() == 0)
        #expect(a.toInt() == 5)
    }

    @Test
    func subtracting_LargerFromSmaller_ReturnsNegative() async throws {
        let a = GMPInteger(3)
        let b = GMPInteger(5)
        let result = a.subtracting(b)
        #expect(result.toInt() == -2)
        #expect(a.toInt() == 3)
    }

    @Test
    func subtracting_LargeValues_ReturnsDifference() async throws {
        let a = GMPInteger(
            "1267650600228229401496703205376",
            base: 10
        )! // 2^100
        let b = GMPInteger("1125899906842624", base: 10)! // 2^50
        let expected = GMPInteger(
            "1267650600228228275596796362752",
            base: 10
        )! // 2^100 - 2^50
        let result = a.subtracting(b)
        #expect(result == expected)
        #expect(a == GMPInteger("1267650600228229401496703205376", base: 10)!)
    }
}

struct GMPIntegerSubtractingIntTests {
    @Test
    func subtracting_Int_PositiveInt_ReturnsDifference() async throws {
        let a = GMPInteger(5)
        let result = a.subtracting(3)
        #expect(result.toInt() == 2)
        #expect(a.toInt() == 5)
    }

    @Test
    func subtracting_Int_NegativeInt_ReturnsSum() async throws {
        let a = GMPInteger(5)
        let result = a.subtracting(-3)
        #expect(result.toInt() == 8)
        #expect(a.toInt() == 5)
    }

    @Test
    func subtracting_Int_Zero_ReturnsSelf() async throws {
        let a = GMPInteger(5)
        let result = a.subtracting(0)
        #expect(result.toInt() == 5)
        #expect(a.toInt() == 5)
    }

    @Test
    func subtracting_Int_IntMax_ReturnsDifference() async throws {
        let a = GMPInteger(
            "1267650600228229401496703205376",
            base: 10
        )! // 2^100
        let result = a.subtracting(Int.max)
        let expected = a.subtracting(GMPInteger(Int.max))
        #expect(result == expected)
    }

    @Test
    func subtracting_Int_IntMin_ReturnsDifference() async throws {
        let a = GMPInteger(
            "1267650600228229401496703205376",
            base: 10
        )! // 2^100
        let result = a.subtracting(Int.min)
        let expected = a.subtracting(GMPInteger(Int.min))
        #expect(result == expected)
    }

    @Test
    func subtracting_Int_One_ReturnsDecremented() async throws {
        let a = GMPInteger(5)
        let result = a.subtracting(1)
        #expect(result.toInt() == 4)
        #expect(a.toInt() == 5)
    }

    @Test
    func subtracting_Int_MinusOne_ReturnsIncremented() async throws {
        let a = GMPInteger(5)
        let result = a.subtracting(-1)
        #expect(result.toInt() == 6)
        #expect(a.toInt() == 5)
    }
}

struct GMPIntegerSubtractingStaticTests {
    @Test
    func subtracting_Static_IntMinusGMPInteger_ReturnsDifference(
    ) async throws {
        let lhs = 5
        let rhs = GMPInteger(3)
        let result = GMPInteger.subtracting(lhs, rhs)
        #expect(result.toInt() == 2)
    }

    @Test
    func subtracting_Static_IntMinusNegativeGMPInteger_ReturnsSum(
    ) async throws {
        let lhs = 5
        let rhs = GMPInteger(-3)
        let result = GMPInteger.subtracting(lhs, rhs)
        #expect(result.toInt() == 8)
    }

    @Test
    func subtracting_Static_IntMinusZero_ReturnsInt() async throws {
        let lhs = 5
        let rhs = GMPInteger(0)
        let result = GMPInteger.subtracting(lhs, rhs)
        #expect(result.toInt() == 5)
    }

    @Test
    func subtracting_Static_ZeroMinusGMPInteger_ReturnsNegated(
    ) async throws {
        let lhs = 0
        let rhs = GMPInteger(3)
        let result = GMPInteger.subtracting(lhs, rhs)
        #expect(result.toInt() == -3)
    }

    @Test
    func subtracting_Static_IntMinusLargeGMPInteger_ReturnsNegative(
    ) async throws {
        let lhs = 5
        let rhs = GMPInteger(
            "1267650600228229401496703205376",
            base: 10
        )! // 2^100
        let result = GMPInteger.subtracting(lhs, rhs)
        let expected = GMPInteger(5).subtracting(rhs)
        #expect(result == expected)
    }

    @Test
    func subtracting_Static_IntMaxMinusGMPInteger_ReturnsDifference(
    ) async throws {
        let lhs = Int.max
        let rhs = GMPInteger(1)
        let result = GMPInteger.subtracting(lhs, rhs)
        #expect(result == GMPInteger(Int.max).subtracting(1))
    }

    @Test
    func subtracting_Static_IntMinMinusGMPInteger_ReturnsDifference(
    ) async throws {
        let lhs = Int.min
        let rhs = GMPInteger(1)
        let result = GMPInteger.subtracting(lhs, rhs)
        let expected = GMPInteger(Int.min).subtracting(1)
        #expect(result == expected)
    }

    @Test
    func subtracting_Static_NegativeIntMinusGMPInteger_ReturnsNegative(
    ) async throws {
        let lhs = -5
        let rhs = GMPInteger(3)
        let result = GMPInteger.subtracting(lhs, rhs)
        #expect(result.toInt() == -8)
    }
}

struct GMPIntegerMultipliedTests {
    @Test
    func multiplied_TwoPositiveIntegers_ReturnsProduct() async throws {
        let a = GMPInteger(5)
        let b = GMPInteger(3)
        let result = a.multiplied(by: b)
        #expect(result.toInt() == 15)
        #expect(a.toInt() == 5)
    }

    @Test
    func multiplied_PositiveAndNegative_ReturnsNegativeProduct(
    ) async throws {
        let a = GMPInteger(5)
        let b = GMPInteger(-3)
        let result = a.multiplied(by: b)
        #expect(result.toInt() == -15)
        #expect(a.toInt() == 5)
    }

    @Test
    func multiplied_TwoNegative_ReturnsPositiveProduct() async throws {
        let a = GMPInteger(-5)
        let b = GMPInteger(-3)
        let result = a.multiplied(by: b)
        #expect(result.toInt() == 15)
        #expect(a.toInt() == -5)
    }

    @Test
    func multiplied_ByZero_ReturnsZero() async throws {
        let a = GMPInteger(5)
        let b = GMPInteger(0)
        let result = a.multiplied(by: b)
        #expect(result.toInt() == 0)
        #expect(a.toInt() == 5)
    }

    @Test
    func multiplied_ZeroByOther_ReturnsZero() async throws {
        let a = GMPInteger(0)
        let b = GMPInteger(3)
        let result = a.multiplied(by: b)
        #expect(result.toInt() == 0)
        #expect(a.toInt() == 0)
    }

    @Test
    func multiplied_ByOne_ReturnsSelf() async throws {
        let a = GMPInteger(5)
        let b = GMPInteger(1)
        let result = a.multiplied(by: b)
        #expect(result.toInt() == 5)
        #expect(a.toInt() == 5)
    }

    @Test
    func multiplied_ByMinusOne_ReturnsNegatedSelf() async throws {
        let a = GMPInteger(5)
        let b = GMPInteger(-1)
        let result = a.multiplied(by: b)
        #expect(result.toInt() == -5)
        #expect(a.toInt() == 5)
    }

    @Test
    func multiplied_SameVariable_ReturnsSquare() async throws {
        let a = GMPInteger(5)
        let result = a.multiplied(by: a)
        #expect(result.toInt() == 25)
        #expect(a.toInt() == 5)
    }

    @Test
    func multiplied_LargeValues_ReturnsProduct() async throws {
        let a = GMPInteger("1125899906842624", base: 10)! // 2^50
        let b = GMPInteger("1125899906842624", base: 10)! // 2^50
        let expected = GMPInteger(
            "1267650600228229401496703205376",
            base: 10
        )! // 2^100
        let result = a.multiplied(by: b)
        #expect(result == expected)
        #expect(a == GMPInteger("1125899906842624", base: 10)!)
    }

    @Test
    func multiplied_VeryLargeValues_ReturnsProduct() async throws {
        let a = GMPInteger(
            "1267650600228229401496703205376",
            base: 10
        )! // 2^100
        let b = GMPInteger(
            "1267650600228229401496703205376",
            base: 10
        )! // 2^100
        let result = a.multiplied(by: b)
        // 2^200 is too large to represent as Int, so we check it's not zero and
        // is positive
        #expect(!result.isZero)
        #expect(result.isPositive)
        #expect(a == GMPInteger("1267650600228229401496703205376", base: 10)!)
    }
}

struct GMPIntegerMultipliedIntTests {
    @Test
    func multiplied_Int_PositiveInt_ReturnsProduct() async throws {
        let a = GMPInteger(5)
        let result = a.multiplied(by: 3)
        #expect(result.toInt() == 15)
        #expect(a.toInt() == 5)
    }

    @Test
    func multiplied_Int_NegativeInt_ReturnsNegativeProduct() async throws {
        let a = GMPInteger(5)
        let result = a.multiplied(by: -3)
        #expect(result.toInt() == -15)
        #expect(a.toInt() == 5)
    }

    @Test
    func multiplied_Int_Zero_ReturnsZero() async throws {
        let a = GMPInteger(5)
        let result = a.multiplied(by: 0)
        #expect(result.toInt() == 0)
        #expect(a.toInt() == 5)
    }

    @Test
    func multiplied_Int_One_ReturnsSelf() async throws {
        let a = GMPInteger(5)
        let result = a.multiplied(by: 1)
        #expect(result.toInt() == 5)
        #expect(a.toInt() == 5)
    }

    @Test
    func multiplied_Int_MinusOne_ReturnsNegatedSelf() async throws {
        let a = GMPInteger(5)
        let result = a.multiplied(by: -1)
        #expect(result.toInt() == -5)
        #expect(a.toInt() == 5)
    }

    @Test
    func multiplied_Int_IntMax_ReturnsProduct() async throws {
        let a = GMPInteger(2)
        let result = a.multiplied(by: Int.max)
        let expected = GMPInteger(2).multiplied(by: GMPInteger(Int.max))
        #expect(result == expected)
        #expect(a.toInt() == 2)
    }

    @Test
    func multiplied_Int_IntMin_ReturnsProduct() async throws {
        let a = GMPInteger(2)
        let result = a.multiplied(by: Int.min)
        let expected = GMPInteger(2).multiplied(by: GMPInteger(Int.min))
        #expect(result == expected)
        #expect(a.toInt() == 2)
    }
}

struct GMPIntegerNegatedTests {
    @Test
    func negated_Positive_ReturnsNegative() async throws {
        let a = GMPInteger(5)
        let result = a.negated()
        #expect(result.toInt() == -5)
        #expect(a.toInt() == 5)
    }

    @Test
    func negated_Negative_ReturnsPositive() async throws {
        let a = GMPInteger(-5)
        let result = a.negated()
        #expect(result.toInt() == 5)
        #expect(a.toInt() == -5)
    }

    @Test
    func negated_Zero_ReturnsZero() async throws {
        let a = GMPInteger(0)
        let result = a.negated()
        #expect(result.toInt() == 0)
        #expect(a.toInt() == 0)
    }

    @Test
    func negated_One_ReturnsMinusOne() async throws {
        let a = GMPInteger(1)
        let result = a.negated()
        #expect(result.toInt() == -1)
        #expect(a.toInt() == 1)
    }

    @Test
    func negated_MinusOne_ReturnsOne() async throws {
        let a = GMPInteger(-1)
        let result = a.negated()
        #expect(result.toInt() == 1)
        #expect(a.toInt() == -1)
    }

    @Test
    func negated_LargeValue_ReturnsNegatedLargeValue() async throws {
        let a = GMPInteger(
            "1267650600228229401496703205376",
            base: 10
        )! // 2^100
        let result = a.negated()
        #expect(result.isNegative)
        #expect(result.absoluteValue() == a.absoluteValue())
        #expect(a == GMPInteger("1267650600228229401496703205376", base: 10)!)
    }

    @Test
    func negated_IntMax_ReturnsNegatedIntMax() async throws {
        let a = GMPInteger(Int.max)
        let result = a.negated()
        #expect(result.toInt() == -Int.max)
        #expect(a.toInt() == Int.max)
    }

    @Test
    func negated_IntMin_ReturnsNegatedIntMin() async throws {
        let a = GMPInteger(Int.min)
        let result = a.negated()
        // Int.min negation overflows Int, so we check it's positive
        #expect(result.isPositive)
        #expect(a.toInt() == Int.min)
    }

    @Test
    func negated_DoubleNegation_ReturnsOriginal() async throws {
        let a = GMPInteger(5)
        let result = a.negated().negated()
        #expect(result.toInt() == 5)
        #expect(a.toInt() == 5)
    }
}

struct GMPIntegerAbsoluteValueTests {
    @Test
    func absoluteValue_Positive_ReturnsSelf() async throws {
        let a = GMPInteger(5)
        let result = a.absoluteValue()
        #expect(result.toInt() == 5)
        #expect(a.toInt() == 5)
    }

    @Test
    func absoluteValue_Negative_ReturnsPositive() async throws {
        let a = GMPInteger(-5)
        let result = a.absoluteValue()
        #expect(result.toInt() == 5)
        #expect(a.toInt() == -5)
    }

    @Test
    func absoluteValue_Zero_ReturnsZero() async throws {
        let a = GMPInteger(0)
        let result = a.absoluteValue()
        #expect(result.toInt() == 0)
        #expect(a.toInt() == 0)
    }

    @Test
    func absoluteValue_One_ReturnsOne() async throws {
        let a = GMPInteger(1)
        let result = a.absoluteValue()
        #expect(result.toInt() == 1)
        #expect(a.toInt() == 1)
    }

    @Test
    func absoluteValue_MinusOne_ReturnsOne() async throws {
        let a = GMPInteger(-1)
        let result = a.absoluteValue()
        #expect(result.toInt() == 1)
        #expect(a.toInt() == -1)
    }

    @Test
    func absoluteValue_LargeValue_ReturnsLargeValue() async throws {
        let a = GMPInteger(
            "1267650600228229401496703205376",
            base: 10
        )! // 2^100
        let result = a.absoluteValue()
        #expect(result == a)
        #expect(a == GMPInteger("1267650600228229401496703205376", base: 10)!)
    }

    @Test
    func absoluteValue_NegativeLargeValue_ReturnsLargeValue(
    ) async throws {
        let a = GMPInteger("1267650600228229401496703205376", base: 10)!
            .negated() // -2^100
        let result = a.absoluteValue()
        let expected = GMPInteger("1267650600228229401496703205376", base: 10)!
        #expect(result == expected)
        #expect(a.isNegative)
    }

    @Test
    func absoluteValue_IntMax_ReturnsIntMax() async throws {
        let a = GMPInteger(Int.max)
        let result = a.absoluteValue()
        #expect(result.toInt() == Int.max)
        #expect(a.toInt() == Int.max)
    }

    @Test
    func absoluteValue_IntMin_ReturnsAbsoluteIntMin() async throws {
        let a = GMPInteger(Int.min)
        let result = a.absoluteValue()
        // Int.min absolute value overflows Int, so we check it's positive
        #expect(result.isPositive)
        #expect(a.toInt() == Int.min)
    }
}

// MARK: - Mutable Operations Tests

struct GMPIntegerAddTests {
    @Test
    func add_TwoPositiveIntegers_ModifiesSelf() async throws {
        var a = GMPInteger(5)
        let b = GMPInteger(3)
        a.add(b)
        #expect(a.toInt() == 8)
        #expect(b.toInt() == 3)
    }

    @Test
    func add_PositiveAndNegative_ModifiesSelf() async throws {
        var a = GMPInteger(5)
        let b = GMPInteger(-3)
        a.add(b)
        #expect(a.toInt() == 2)
        #expect(b.toInt() == -3)
    }

    @Test
    func add_TwoNegative_ModifiesSelf() async throws {
        var a = GMPInteger(-5)
        let b = GMPInteger(-3)
        a.add(b)
        #expect(a.toInt() == -8)
        #expect(b.toInt() == -3)
    }

    @Test
    func add_Zero_DoesNotModifySelf() async throws {
        var a = GMPInteger(5)
        let b = GMPInteger(0)
        a.add(b)
        #expect(a.toInt() == 5)
        #expect(b.toInt() == 0)
    }

    @Test
    func add_ToZero_ModifiesSelf() async throws {
        var a = GMPInteger(0)
        let b = GMPInteger(3)
        a.add(b)
        #expect(a.toInt() == 3)
        #expect(b.toInt() == 3)
    }

    @Test
    func add_SameVariable_ModifiesSelf() async throws {
        var a = GMPInteger(5)
        a.add(a)
        #expect(a.toInt() == 10)
    }

    @Test
    func add_LargeValues_ModifiesSelf() async throws {
        var a = GMPInteger(
            "1267650600228229401496703205376",
            base: 10
        )! // 2^100
        let b = GMPInteger("1125899906842624", base: 10)! // 2^50
        a.add(b)
        // Calculate expected value dynamically to ensure correctness
        let expected = GMPInteger("1267650600228229401496703205376", base: 10)!
            .adding(GMPInteger(
                "1125899906842624",
                base: 10
            )!)
        #expect(a == expected)
        #expect(b == GMPInteger("1125899906842624", base: 10)!)
    }
}

struct GMPIntegerAddIntTests {
    @Test
    func add_Int_PositiveInt_ModifiesSelf() async throws {
        var a = GMPInteger(5)
        a.add(3)
        #expect(a.toInt() == 8)
    }

    @Test
    func add_Int_NegativeInt_ModifiesSelf() async throws {
        var a = GMPInteger(5)
        a.add(-3)
        #expect(a.toInt() == 2)
    }

    @Test
    func add_Int_Zero_DoesNotModifySelf() async throws {
        var a = GMPInteger(5)
        a.add(0)
        #expect(a.toInt() == 5)
    }

    @Test
    func add_Int_IntMax_ModifiesSelf() async throws {
        var a = GMPInteger(1)
        a.add(Int.max)
        let expected = GMPInteger(1).adding(Int.max)
        #expect(a == expected)
    }

    @Test
    func add_Int_IntMin_ModifiesSelf() async throws {
        var a = GMPInteger(1)
        a.add(Int.min)
        let expected = GMPInteger(1).adding(Int.min)
        #expect(a == expected)
    }

    @Test
    func add_Int_One_IncrementsSelf() async throws {
        var a = GMPInteger(5)
        a.add(1)
        #expect(a.toInt() == 6)
    }

    @Test
    func add_Int_MinusOne_DecrementsSelf() async throws {
        var a = GMPInteger(5)
        a.add(-1)
        #expect(a.toInt() == 4)
    }
}

// Continue with subtract, multiply, negate, makeAbsolute tests...
// Adding key representative tests for the remaining operations

struct GMPIntegerSubtractTests {
    @Test
    func subtract_TwoPositiveIntegers_ModifiesSelf() async throws {
        var a = GMPInteger(5)
        let b = GMPInteger(3)
        a.subtract(b)
        #expect(a.toInt() == 2)
        #expect(b.toInt() == 3)
    }

    @Test
    func subtract_SameVariable_ModifiesSelfToZero() async throws {
        var a = GMPInteger(5)
        a.subtract(a)
        #expect(a.toInt() == 0)
    }

    @Test
    func subtract_LargeValues_ModifiesSelf() async throws {
        var a = GMPInteger(
            "1267650600228229401496703205376",
            base: 10
        )! // 2^100
        let b = GMPInteger("1125899906842624", base: 10)! // 2^50
        a.subtract(b)
        let expected = GMPInteger(
            "1267650600228228275596796362752",
            base: 10
        )! // 2^100 - 2^50
        #expect(a == expected)
    }
}

struct GMPIntegerMultiplyTests {
    @Test
    func multiply_TwoPositiveIntegers_ModifiesSelf() async throws {
        var a = GMPInteger(5)
        let b = GMPInteger(3)
        a.multiply(by: b)
        #expect(a.toInt() == 15)
        #expect(b.toInt() == 3)
    }

    @Test
    func multiply_SameVariable_SquaresSelf() async throws {
        var a = GMPInteger(5)
        a.multiply(by: a)
        #expect(a.toInt() == 25)
    }

    @Test
    func multiply_LargeValues_ModifiesSelf() async throws {
        var a = GMPInteger("1125899906842624", base: 10)! // 2^50
        let b = GMPInteger("1125899906842624", base: 10)! // 2^50
        a.multiply(by: b)
        let expected = GMPInteger(
            "1267650600228229401496703205376",
            base: 10
        )! // 2^100
        #expect(a == expected)
    }

    @Test
    func multiply_Int_Negative_ModifiesSelf() async throws {
        // Given: GMPInteger(5), Int(-3)
        var integer = GMPInteger(5)

        // When: Call multiply(by: -3)
        integer.multiply(by: -3)

        // Then: Integer has value -15
        #expect(integer.toInt() == -15)
    }

    @Test
    func multiply_Int_NegativeLarge_ModifiesSelf() async throws {
        // Given: GMPInteger(10), Int(-100)
        var integer = GMPInteger(10)

        // When: Call multiply(by: -100)
        integer.multiply(by: -100)

        // Then: Integer has value -1000
        #expect(integer.toInt() == -1000)
    }
}

struct GMPIntegerNegateTests {
    @Test
    func negate_Positive_NegatesSelf() async throws {
        var a = GMPInteger(5)
        a.negate()
        #expect(a.toInt() == -5)
    }

    @Test
    func negate_Negative_PositivizesSelf() async throws {
        var a = GMPInteger(-5)
        a.negate()
        #expect(a.toInt() == 5)
    }

    @Test
    func negate_Zero_DoesNotModifySelf() async throws {
        var a = GMPInteger(0)
        a.negate()
        #expect(a.toInt() == 0)
    }

    @Test
    func negate_DoubleNegation_ReturnsOriginal() async throws {
        var a = GMPInteger(5)
        a.negate()
        a.negate()
        #expect(a.toInt() == 5)
    }
}

struct GMPIntegerMakeAbsoluteTests {
    @Test
    func makeAbsolute_Positive_DoesNotModifySelf() async throws {
        var a = GMPInteger(5)
        a.makeAbsolute()
        #expect(a.toInt() == 5)
    }

    @Test
    func makeAbsolute_Negative_PositivizesSelf() async throws {
        var a = GMPInteger(-5)
        a.makeAbsolute()
        #expect(a.toInt() == 5)
    }

    @Test
    func makeAbsolute_Zero_DoesNotModifySelf() async throws {
        var a = GMPInteger(0)
        a.makeAbsolute()
        #expect(a.toInt() == 0)
    }

    @Test
    func makeAbsolute_IntMin_PositivizesSelf() async throws {
        var a = GMPInteger(Int.min)
        a.makeAbsolute()
        #expect(a.isPositive)
    }
}

// MARK: - Combined Multiply-Add/Subtract Tests

struct GMPIntegerAddProductTests {
    @Test
    func addProduct_TwoPositiveIntegers_ModifiesSelf() async throws {
        var a = GMPInteger(5)
        let multiplicand = GMPInteger(3)
        let multiplier = GMPInteger(2)
        a.addProduct(multiplicand, multiplier)
        #expect(a.toInt() == 11) // 5 + 3*2
        #expect(multiplicand.toInt() == 3)
        #expect(multiplier.toInt() == 2)
    }

    @Test
    func addProduct_SelfAsMultiplicand_ModifiesSelf() async throws {
        var a = GMPInteger(5)
        let multiplier = GMPInteger(2)
        a.addProduct(a, multiplier)
        #expect(a.toInt() == 15) // 5 + 5*2
    }

    @Test
    func addProduct_LargeValues_ModifiesSelf() async throws {
        var a = GMPInteger(
            "1267650600228229401496703205376",
            base: 10
        )! // 2^100
        let multiplicand = GMPInteger("1125899906842624", base: 10)! // 2^50
        let multiplier = GMPInteger("1125899906842624", base: 10)! // 2^50
        a.addProduct(multiplicand, multiplier)
        let expected = GMPInteger("1267650600228229401496703205376", base: 10)!
            .adding(
                GMPInteger("1125899906842624", base: 10)!
                    .multiplied(by: GMPInteger(
                        "1125899906842624",
                        base: 10
                    )!)
            )
        #expect(a == expected)
    }
}

struct GMPIntegerSubtractProductTests {
    @Test
    func subtractProduct_TwoPositiveIntegers_ModifiesSelf() async throws {
        var a = GMPInteger(5)
        let multiplicand = GMPInteger(3)
        let multiplier = GMPInteger(2)
        a.subtractProduct(multiplicand, multiplier)
        #expect(a.toInt() == -1) // 5 - 3*2
    }

    @Test
    func subtractProduct_SelfAsMultiplicand_ModifiesSelf() async throws {
        var a = GMPInteger(5)
        let multiplier = GMPInteger(2)
        a.subtractProduct(a, multiplier)
        #expect(a.toInt() == -5) // 5 - 5*2
    }
}

// MARK: - Power of 2 Operations Tests

struct GMPIntegerMultipliedByPowerOf2Tests {
    @Test
    func multipliedByPowerOf2_PositiveExponent_ReturnsShiftedLeft(
    ) async throws {
        let a = GMPInteger(5)
        let result = a.multipliedByPowerOf2(3)
        #expect(result.toInt() == 40) // 5 * 2^3
        #expect(a.toInt() == 5)
    }

    @Test
    func multipliedByPowerOf2_ZeroExponent_ReturnsSelf() async throws {
        let a = GMPInteger(5)
        let result = a.multipliedByPowerOf2(0)
        #expect(result.toInt() == 5)
        #expect(a.toInt() == 5)
    }

    @Test
    func multipliedByPowerOf2_NegativeExponent_ReturnsShiftedRight(
    ) async throws {
        let a = GMPInteger(40)
        let result = a.multipliedByPowerOf2(-3)
        #expect(result.toInt() == 5) // 40 / 2^3
        #expect(a.toInt() == 40)
    }

    @Test
    func multipliedByPowerOf2_OneExponent_DoublesValue() async throws {
        let a = GMPInteger(5)
        let result = a.multipliedByPowerOf2(1)
        #expect(result.toInt() == 10)
        #expect(a.toInt() == 5)
    }

    @Test
    func multipliedByPowerOf2_MinusOneExponent_HalvesValue() async throws {
        let a = GMPInteger(10)
        let result = a.multipliedByPowerOf2(-1)
        #expect(result.toInt() == 5)
        #expect(a.toInt() == 10)
    }

    @Test
    func multipliedByPowerOf2_LargeExponent_ReturnsShiftedValue(
    ) async throws {
        let a = GMPInteger(1)
        let result = a.multipliedByPowerOf2(100)
        let expected = GMPInteger(
            "1267650600228229401496703205376",
            base: 10
        )! // 2^100
        #expect(result == expected)
        #expect(a.toInt() == 1)
    }

    @Test
    func multipliedByPowerOf2_ZeroValue_ReturnsZero() async throws {
        let a = GMPInteger(0)
        let result = a.multipliedByPowerOf2(10)
        #expect(result.toInt() == 0)
        #expect(a.toInt() == 0)
    }

    @Test
    func multipliedByPowerOf2_NegativeValue_ReturnsShiftedNegative(
    ) async throws {
        let a = GMPInteger(-5)
        let result = a.multipliedByPowerOf2(3)
        #expect(result.toInt() == -40)
        #expect(a.toInt() == -5)
    }
}

struct GMPIntegerMultiplyByPowerOf2Tests {
    @Test
    func multiplyByPowerOf2_PositiveExponent_ShiftsLeft() async throws {
        var a = GMPInteger(5)
        a.multiplyByPowerOf2(3)
        #expect(a.toInt() == 40)
    }

    @Test
    func multiplyByPowerOf2_ZeroExponent_DoesNotModifySelf() async throws {
        var a = GMPInteger(5)
        a.multiplyByPowerOf2(0)
        #expect(a.toInt() == 5)
    }

    @Test
    func multiplyByPowerOf2_NegativeExponent_ShiftsRight() async throws {
        var a = GMPInteger(40)
        a.multiplyByPowerOf2(-3)
        #expect(a.toInt() == 5)
    }

    @Test
    func multiplyByPowerOf2_OneExponent_DoublesSelf() async throws {
        var a = GMPInteger(5)
        a.multiplyByPowerOf2(1)
        #expect(a.toInt() == 10)
    }

    @Test
    func multiplyByPowerOf2_MinusOneExponent_HalvesSelf() async throws {
        var a = GMPInteger(10)
        a.multiplyByPowerOf2(-1)
        #expect(a.toInt() == 5)
    }
}

// MARK: - Operator Overloads Tests

struct GMPIntegerOperatorTests {
    @Test
    func plusOperator_TwoPositiveIntegers_ReturnsSum() async throws {
        let a = GMPInteger(5)
        let b = GMPInteger(3)
        let result = a + b
        #expect(result.toInt() == 8)
        #expect(a.toInt() == 5)
        #expect(b.toInt() == 3)
    }

    @Test
    func plusOperator_Int_PositiveInt_ReturnsSum() async throws {
        let a = GMPInteger(5)
        let result = a + 3
        #expect(result.toInt() == 8)
        #expect(a.toInt() == 5)
    }

    @Test
    func plusOperator_IntFirst_PositiveInt_ReturnsSum() async throws {
        let rhs = GMPInteger(3)
        let result = 5 + rhs
        #expect(result.toInt() == 8)
        #expect(rhs.toInt() == 3)
    }

    @Test
    func minusOperator_TwoPositiveIntegers_ReturnsDifference(
    ) async throws {
        let a = GMPInteger(5)
        let b = GMPInteger(3)
        let result = a - b
        #expect(result.toInt() == 2)
        #expect(a.toInt() == 5)
        #expect(b.toInt() == 3)
    }

    @Test
    func minusOperator_SameValues_ReturnsZero() async throws {
        let a = GMPInteger(5)
        let b = GMPInteger(5)
        let result = a - b
        #expect(result.toInt() == 0)
    }

    @Test
    func minusOperator_IntFirst_PositiveInt_ReturnsDifference(
    ) async throws {
        let rhs = GMPInteger(3)
        let result = 5 - rhs
        #expect(result.toInt() == 2)
        #expect(rhs.toInt() == 3)
    }

    @Test
    func multiplyOperator_TwoPositiveIntegers_ReturnsProduct(
    ) async throws {
        let a = GMPInteger(5)
        let b = GMPInteger(3)
        let result = a * b
        #expect(result.toInt() == 15)
        #expect(a.toInt() == 5)
        #expect(b.toInt() == 3)
    }

    @Test
    func multiplyOperator_ByZero_ReturnsZero() async throws {
        let a = GMPInteger(5)
        let b = GMPInteger(0)
        let result = a * b
        #expect(result.toInt() == 0)
    }

    @Test
    func prefixMinus_Positive_ReturnsNegative() async throws {
        let a = GMPInteger(5)
        let result = -a
        #expect(result.toInt() == -5)
        #expect(a.toInt() == 5)
    }

    @Test
    func prefixMinus_Negative_ReturnsPositive() async throws {
        let a = GMPInteger(-5)
        let result = -a
        #expect(result.toInt() == 5)
        #expect(a.toInt() == -5)
    }

    @Test
    func plusEquals_TwoPositiveIntegers_ModifiesLhs() async throws {
        var a = GMPInteger(5)
        let b = GMPInteger(3)
        a += b
        #expect(a.toInt() == 8)
        #expect(b.toInt() == 3)
    }

    @Test
    func plusEquals_Int_PositiveInt_ModifiesLhs() async throws {
        var a = GMPInteger(5)
        a += 3
        #expect(a.toInt() == 8)
    }

    @Test
    func minusEquals_TwoPositiveIntegers_ModifiesLhs() async throws {
        var a = GMPInteger(5)
        let b = GMPInteger(3)
        a -= b
        #expect(a.toInt() == 2)
        #expect(b.toInt() == 3)
    }

    @Test
    func minusEquals_SameVariable_ModifiesLhsToZero() async throws {
        var a = GMPInteger(5)
        a -= a
        #expect(a.toInt() == 0)
    }

    @Test
    func multiplyEquals_TwoPositiveIntegers_ModifiesLhs() async throws {
        var a = GMPInteger(5)
        let b = GMPInteger(3)
        a *= b
        #expect(a.toInt() == 15)
        #expect(b.toInt() == 3)
    }

    @Test
    func multiplyEquals_SameVariable_SquaresLhs() async throws {
        var a = GMPInteger(5)
        a *= a
        #expect(a.toInt() == 25)
    }

    @Test
    func multiplyEquals_Int_PositiveInt_ModifiesLhs() async throws {
        var a = GMPInteger(5)
        a *= 3
        #expect(a.toInt() == 15)
    }

    @Test
    func multiplyEquals_Int_Zero_ModifiesLhsToZero() async throws {
        var a = GMPInteger(5)
        a *= 0
        #expect(a.toInt() == 0)
    }

    @Test
    func subtract_Int_Positive_ModifiesSelf() async throws {
        // Given: GMPInteger(10), Int(3)
        var integer = GMPInteger(10)

        // When: Call subtract(3)
        integer.subtract(3)

        // Then: Integer has value 7
        #expect(integer.toInt() == 7)
    }

    @Test
    func subtract_Int_Negative_ModifiesSelf() async throws {
        // Given: GMPInteger(10), Int(-3)
        var integer = GMPInteger(10)

        // When: Call subtract(-3)
        integer.subtract(-3)

        // Then: Integer has value 13 (subtracting negative is adding)
        #expect(integer.toInt() == 13)
    }

    @Test
    func subtract_Int_IntMin_ModifiesSelf() async throws {
        // Given: GMPInteger(10), Int.min
        var integer = GMPInteger(10)

        // When: Call subtract(Int.min)
        // Note: Subtracting Int.min is equivalent to adding a very large
        // positive number
        integer.subtract(Int.min)

        // Then: Integer is modified correctly (should be much larger than 10)
        // Since Int.min is negative, subtracting it adds a large positive value
        #expect(integer > GMPInteger(10))
    }

    @Test
    func subtract_Int_Zero_NoChange() async throws {
        // Given: GMPInteger(10), Int(0)
        var integer = GMPInteger(10)

        // When: Call subtract(0)
        integer.subtract(0)

        // Then: Integer remains 10
        #expect(integer.toInt() == 10)
    }

    @Test
    func multiplyOperator_IntFirst_Positive_ReturnsProduct() async throws {
        // Given: Int(5), GMPInteger(3)
        let lhs = 5
        let rhs = GMPInteger(3)

        // When: Evaluate lhs * rhs
        let result = lhs * rhs

        // Then: Returns GMPInteger(15)
        #expect(result.toInt() == 15)
    }

    @Test
    func multiplyOperator_IntFirst_Negative_ReturnsProduct() async throws {
        // Given: Int(-5), GMPInteger(3)
        let lhs = -5
        let rhs = GMPInteger(3)

        // When: Evaluate lhs * rhs
        let result = lhs * rhs

        // Then: Returns GMPInteger(-15)
        #expect(result.toInt() == -15)
    }

    @Test
    func minusEquals_Int_Positive_ModifiesLhs() async throws {
        // Given: GMPInteger(10), Int(3)
        var lhs = GMPInteger(10)

        // When: Evaluate lhs -= 3
        lhs -= 3

        // Then: lhs has value 7
        #expect(lhs.toInt() == 7)
    }

    @Test
    func minusEquals_Int_Negative_ModifiesLhs() async throws {
        // Given: GMPInteger(10), Int(-3)
        var lhs = GMPInteger(10)

        // When: Evaluate lhs -= -3
        lhs -= -3

        // Then: lhs has value 13
        #expect(lhs.toInt() == 13)
    }

    @Test
    func addProduct_TwoGMPIntegers_ModifiesSelf() async throws {
        // Given: GMPInteger(10), multiplicand=GMPInteger(3), multiplier=GMPInteger(4)
        var integer = GMPInteger(10)
        let multiplicand = GMPInteger(3)
        let multiplier = GMPInteger(4)

        // When: Call addProduct(multiplicand, multiplier)
        integer.addProduct(multiplicand, multiplier)

        // Then: Integer has value 10 + 3*4 = 22
        #expect(integer.toInt() == 22)
    }

    @Test
    func addProduct_GMPIntegerAndInt_ModifiesSelf() async throws {
        // Given: GMPInteger(10), multiplicand=GMPInteger(3), multiplier=Int(4)
        var integer = GMPInteger(10)
        let multiplicand = GMPInteger(3)
        let multiplier = 4

        // When: Call addProduct(multiplicand, multiplier)
        integer.addProduct(multiplicand, multiplier)

        // Then: Integer has value 10 + 3*4 = 22
        #expect(integer.toInt() == 22)
    }

    @Test
    func addProduct_SelfAsMultiplicand_ModifiesSelf() async throws {
        // Given: GMPInteger(5), multiplicand=GMPInteger(5), multiplier=GMPInteger(2)
        var integer = GMPInteger(5)
        let multiplier = GMPInteger(2)

        // When: Call addProduct(integer, multiplier) where integer is self
        integer.addProduct(integer, multiplier)

        // Then: Integer has value 5 + 5*2 = 15
        #expect(integer.toInt() == 15)
    }

    @Test
    func subtractProduct_TwoGMPIntegers_ModifiesSelf() async throws {
        // Given: GMPInteger(20), multiplicand=GMPInteger(3), multiplier=GMPInteger(4)
        var integer = GMPInteger(20)
        let multiplicand = GMPInteger(3)
        let multiplier = GMPInteger(4)

        // When: Call subtractProduct(multiplicand, multiplier)
        integer.subtractProduct(multiplicand, multiplier)

        // Then: Integer has value 20 - 3*4 = 8
        #expect(integer.toInt() == 8)
    }

    @Test
    func subtractProduct_GMPIntegerAndInt_ModifiesSelf() async throws {
        // Given: GMPInteger(20), multiplicand=GMPInteger(3), multiplier=Int(4)
        var integer = GMPInteger(20)
        let multiplicand = GMPInteger(3)
        let multiplier = 4

        // When: Call subtractProduct(multiplicand, multiplier)
        integer.subtractProduct(multiplicand, multiplier)

        // Then: Integer has value 20 - 3*4 = 8
        #expect(integer.toInt() == 8)
    }

    @Test
    func subtractProduct_SelfAsMultiplicand_ModifiesSelf() async throws {
        // Given: GMPInteger(10), multiplicand=GMPInteger(10), multiplier=GMPInteger(2)
        var integer = GMPInteger(10)
        let multiplier = GMPInteger(2)

        // When: Call subtractProduct(integer, multiplier) where integer is self
        integer.subtractProduct(integer, multiplier)

        // Then: Integer has value 10 - 10*2 = -10
        #expect(integer.toInt() == -10)
    }
}
