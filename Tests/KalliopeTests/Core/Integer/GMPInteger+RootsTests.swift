@testable import Kalliope
import Testing

// MARK: - nthRoot(_: Int) Tests

struct GMPIntegerNthRootTests {
    @Test
    func nthRoot_PerfectPower() async throws {
        // Given: A GMPInteger that is a perfect nth power (e.g., 64) and n = 3 (cube root)
        let value = GMPInteger(64)

        // When: value.nthRoot(3) is called
        let result = value.nthRoot(3)

        // Then: Returns a tuple with root = 4 and isExact = true (since 4^3 = 64)
        #expect(result.root.toInt() == 4)
        #expect(result.isExact == true)
        #expect(value.toInt() == 64) // Original unchanged
    }

    @Test
    func nthRoot_NotPerfectPower() async throws {
        // Given: A GMPInteger that is not a perfect nth power (e.g., 10) and n = 3
        let value = GMPInteger(10)

        // When: value.nthRoot(3) is called
        let result = value.nthRoot(3)

        // Then: Returns a tuple with root = 2 and isExact = false (since 2^3 = 8 <= 10 < 3^3 = 27)
        #expect(result.root.toInt() == 2)
        #expect(result.isExact == false)
    }

    @Test
    func nthRoot_SquareRootPerfectSquare() async throws {
        // Given: A GMPInteger that is a perfect square (e.g., 25) and n = 2
        let value = GMPInteger(25)

        // When: value.nthRoot(2) is called
        let result = value.nthRoot(2)

        // Then: Returns a tuple with root = 5 and isExact = true
        #expect(result.root.toInt() == 5)
        #expect(result.isExact == true)
    }

    @Test
    func nthRoot_SquareRootNotPerfectSquare() async throws {
        // Given: A GMPInteger that is not a perfect square (e.g., 10) and n = 2
        let value = GMPInteger(10)

        // When: value.nthRoot(2) is called
        let result = value.nthRoot(2)

        // Then: Returns a tuple with root = 3 and isExact = false (since 3^2 = 9 <= 10 < 4^2 = 16)
        #expect(result.root.toInt() == 3)
        #expect(result.isExact == false)
    }

    @Test
    func nthRoot_ValueOne() async throws {
        // Given: A GMPInteger equal to 1 and any positive n (e.g., 5)
        let value = GMPInteger(1)

        // When: value.nthRoot(5) is called
        let result = value.nthRoot(5)

        // Then: Returns a tuple with root = 1 and isExact = true
        #expect(result.root.toInt() == 1)
        #expect(result.isExact == true)
    }

    @Test
    func nthRoot_ValueZero() async throws {
        // Given: A GMPInteger equal to 0 and any positive n (e.g., 3)
        let value = GMPInteger(0)

        // When: value.nthRoot(3) is called
        let result = value.nthRoot(3)

        // Then: Returns a tuple with root = 0 and isExact = true
        #expect(result.root.toInt() == 0)
        #expect(result.isExact == true)
    }

    @Test
    func nthRoot_ValueLessThanRoot() async throws {
        // Given: A GMPInteger value (e.g., 1) and n = 3
        let value = GMPInteger(1)

        // When: value.nthRoot(3) is called
        let result = value.nthRoot(3)

        // Then: Returns a tuple with root = 1 and isExact = true
        #expect(result.root.toInt() == 1)
        #expect(result.isExact == true)
    }

    @Test
    func nthRoot_LargeValue() async throws {
        // Given: A large GMPInteger value (e.g., 10^100) and n = 10
        let value = GMPInteger(
            "10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
        )!

        // When: value.nthRoot(10) is called
        let result = value.nthRoot(10)

        // Then: Returns a tuple with root equal to the truncated 10th root and isExact flag
        // 10^100 = (10^10)^10, so root should be 10^10 = 10000000000
        let expectedRoot = GMPInteger("10000000000")!
        #expect(result.root == expectedRoot)
        #expect(result.isExact == true)
    }

    @Test
    func nthRoot_NegativeValueOddRoot() async throws {
        // Given: A negative GMPInteger value (e.g., -8) and odd n = 3
        let value = GMPInteger(-8)

        // When: value.nthRoot(3) is called
        let result = value.nthRoot(3)

        // Then: Returns a tuple with root = -2 and isExact = true (since (-2)^3 = -8)
        #expect(result.root.toInt() == -2)
        #expect(result.isExact == true)
    }

    @Test
    func nthRoot_RootIndexOne() async throws {
        // Given: A GMPInteger value (e.g., 42) and n = 1
        let value = GMPInteger(42)

        // When: value.nthRoot(1) is called
        let result = value.nthRoot(1)

        // Then: Returns a tuple with root = 42 and isExact = true
        #expect(result.root.toInt() == 42)
        #expect(result.isExact == true)
    }

    @Test
    func nthRoot_Immutability() async throws {
        // Given: A GMPInteger value (e.g., 64) stored in a variable
        let value = GMPInteger(64)
        let originalValue = value.toInt()

        // When: value.nthRoot(3) is called
        let result = value.nthRoot(3)

        // Then: The original value is unchanged
        #expect(value.toInt() == originalValue)
        #expect(result.root.toInt() == 4)
    }

    @Test
    func nthRoot_BoundaryCondition() async throws {
        // Given: A GMPInteger value (e.g., 27) and n = 3, where 3^3 = 27
        let value = GMPInteger(27)

        // When: value.nthRoot(3) is called
        let result = value.nthRoot(3)

        // Then: Returns a tuple with root = 3 and isExact = true
        #expect(result.root.toInt() == 3)
        #expect(result.isExact == true)
    }

    @Test
    func nthRoot_BoundaryConditionMinusOne() async throws {
        // Given: A GMPInteger value (e.g., 26) and n = 3, where 2^3 = 8 <= 26 < 3^3 = 27
        let value = GMPInteger(26)

        // When: value.nthRoot(3) is called
        let result = value.nthRoot(3)

        // Then: Returns a tuple with root = 2 and isExact = false
        #expect(result.root.toInt() == 2)
        #expect(result.isExact == false)
    }
}

// MARK: - nthRootWithRemainder(_: Int) Tests

struct GMPIntegerNthRootWithRemainderTests {
    @Test
    func nthRootWithRemainder_PerfectPower() async throws {
        // Given: A GMPInteger that is a perfect nth power (e.g., 64) and n = 3
        let value = GMPInteger(64)

        // When: value.nthRootWithRemainder(3) is called
        let result = value.nthRootWithRemainder(3)

        // Then: Returns a tuple with root = 4 and remainder = 0 (since 64 = 4^3 + 0)
        #expect(result.root.toInt() == 4)
        #expect(result.remainder.toInt() == 0)
    }

    @Test
    func nthRootWithRemainder_NotPerfectPower() async throws {
        // Given: A GMPInteger that is not a perfect nth power (e.g., 10) and n = 3
        let value = GMPInteger(10)

        // When: value.nthRootWithRemainder(3) is called
        let result = value.nthRootWithRemainder(3)

        // Then: Returns a tuple with root = 2 and remainder = 2 (since 10 = 2^3 + 2)
        #expect(result.root.toInt() == 2)
        #expect(result.remainder.toInt() == 2)
    }

    @Test
    func nthRootWithRemainder_RemainderProperty() async throws {
        // Given: A GMPInteger value (e.g., 100) and n = 3
        let value = GMPInteger(100)

        // When: value.nthRootWithRemainder(3) is called, yielding (root, remainder)
        let result = value.nthRootWithRemainder(3)

        // Then: The values satisfy value == root^n + remainder
        let rootPower = result.root.raisedToPower(3)
        let sum = rootPower.adding(result.remainder)
        #expect(value == sum)
        #expect(result.remainder.toInt() >= 0)
    }

    @Test
    func nthRootWithRemainder_ValueOne() async throws {
        // Given: A GMPInteger equal to 1 and any positive n (e.g., 5)
        let value = GMPInteger(1)

        // When: value.nthRootWithRemainder(5) is called
        let result = value.nthRootWithRemainder(5)

        // Then: Returns a tuple with root = 1 and remainder = 0
        #expect(result.root.toInt() == 1)
        #expect(result.remainder.toInt() == 0)
    }

    @Test
    func nthRootWithRemainder_ValueZero() async throws {
        // Given: A GMPInteger equal to 0 and any positive n (e.g., 3)
        let value = GMPInteger(0)

        // When: value.nthRootWithRemainder(3) is called
        let result = value.nthRootWithRemainder(3)

        // Then: Returns a tuple with root = 0 and remainder = 0
        #expect(result.root.toInt() == 0)
        #expect(result.remainder.toInt() == 0)
    }

    @Test
    func nthRootWithRemainder_NegativeValueOddRoot() async throws {
        // Given: A negative GMPInteger value (e.g., -8) and odd n = 3
        let value = GMPInteger(-8)

        // When: value.nthRootWithRemainder(3) is called
        let result = value.nthRootWithRemainder(3)

        // Then: Returns a tuple with root = -2 and remainder = 0 (since -8 = (-2)^3 + 0)
        #expect(result.root.toInt() == -2)
        #expect(result.remainder.toInt() == 0)
    }

    @Test
    func nthRootWithRemainder_Immutability() async throws {
        // Given: A GMPInteger value (e.g., 64) stored in a variable
        let value = GMPInteger(64)
        let originalValue = value.toInt()

        // When: value.nthRootWithRemainder(3) is called
        let result = value.nthRootWithRemainder(3)

        // Then: The original value is unchanged
        #expect(value.toInt() == originalValue)
        #expect(result.root.toInt() == 4)
    }

    @Test
    func nthRootWithRemainder_LargeValue() async throws {
        // Given: A large GMPInteger value (e.g., 10^100) and n = 10
        let value = GMPInteger(
            "10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
        )!

        // When: value.nthRootWithRemainder(10) is called
        let result = value.nthRootWithRemainder(10)

        // Then: Returns a tuple with root and remainder satisfying the relationship value == root^n + remainder
        let rootPower = result.root.raisedToPower(10)
        let sum = rootPower.adding(result.remainder)
        #expect(value == sum)
    }
}

// MARK: - squareRoot Tests

struct GMPIntegerSquareRootTests {
    @Test
    func squareRoot_PerfectSquare() async throws {
        // Given: A GMPInteger that is a perfect square (e.g., 25)
        let value = GMPInteger(25)

        // When: value.squareRoot is accessed
        let result = value.squareRoot

        // Then: Returns a new GMPInteger equal to 5
        #expect(result.toInt() == 5)
        #expect(value.toInt() == 25) // Original unchanged
    }

    @Test
    func squareRoot_NotPerfectSquare() async throws {
        // Given: A GMPInteger that is not a perfect square (e.g., 10)
        let value = GMPInteger(10)

        // When: value.squareRoot is accessed
        let result = value.squareRoot

        // Then: Returns a new GMPInteger equal to 3 (since 3^2 = 9 <= 10 < 4^2 = 16)
        #expect(result.toInt() == 3)
    }

    @Test
    func squareRoot_ValueOne() async throws {
        // Given: A GMPInteger equal to 1
        let value = GMPInteger(1)

        // When: value.squareRoot is accessed
        let result = value.squareRoot

        // Then: Returns a new GMPInteger equal to 1
        #expect(result.toInt() == 1)
    }

    @Test
    func squareRoot_ValueZero() async throws {
        // Given: A GMPInteger equal to 0
        let value = GMPInteger(0)

        // When: value.squareRoot is accessed
        let result = value.squareRoot

        // Then: Returns a new GMPInteger equal to 0
        #expect(result.toInt() == 0)
    }

    @Test
    func squareRoot_LargeValue() async throws {
        // Given: A large GMPInteger value (e.g., 10^100)
        let value = GMPInteger(
            "10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
        )!

        // When: value.squareRoot is accessed
        let result = value.squareRoot

        // Then: Returns a new GMPInteger equal to the truncated integer square root
        // 10^100 = (10^50)^2, so result should be 10^50
        let expected =
            GMPInteger("100000000000000000000000000000000000000000000000000")!
        #expect(result == expected)
    }

    @Test
    func squareRoot_BoundaryCondition() async throws {
        // Given: A GMPInteger value (e.g., 16) where 4^2 = 16
        let value = GMPInteger(16)

        // When: value.squareRoot is accessed
        let result = value.squareRoot

        // Then: Returns a new GMPInteger equal to 4
        #expect(result.toInt() == 4)
    }

    @Test
    func squareRoot_BoundaryConditionMinusOne() async throws {
        // Given: A GMPInteger value (e.g., 15) where 3^2 = 9 <= 15 < 4^2 = 16
        let value = GMPInteger(15)

        // When: value.squareRoot is accessed
        let result = value.squareRoot

        // Then: Returns a new GMPInteger equal to 3
        #expect(result.toInt() == 3)
    }

    @Test
    func squareRoot_Immutability() async throws {
        // Given: A GMPInteger value (e.g., 25) stored in a variable
        let value = GMPInteger(25)
        let originalValue = value.toInt()

        // When: value.squareRoot is accessed
        let result = value.squareRoot

        // Then: The original value is unchanged
        #expect(value.toInt() == originalValue)
        #expect(result.toInt() == 5)
    }
}

// MARK: - squareRootWithRemainder Tests

struct GMPIntegerSquareRootWithRemainderTests {
    @Test
    func squareRootWithRemainder_PerfectSquare() async throws {
        // Given: A GMPInteger that is a perfect square (e.g., 25)
        let value = GMPInteger(25)

        // When: value.squareRootWithRemainder is accessed
        let result = value.squareRootWithRemainder

        // Then: Returns a tuple with root = 5 and remainder = 0 (since 25 = 5^2 + 0)
        #expect(result.root.toInt() == 5)
        #expect(result.remainder.toInt() == 0)
    }

    @Test
    func squareRootWithRemainder_NotPerfectSquare() async throws {
        // Given: A GMPInteger that is not a perfect square (e.g., 10)
        let value = GMPInteger(10)

        // When: value.squareRootWithRemainder is accessed
        let result = value.squareRootWithRemainder

        // Then: Returns a tuple with root = 3 and remainder = 1 (since 10 = 3^2 + 1)
        #expect(result.root.toInt() == 3)
        #expect(result.remainder.toInt() == 1)
    }

    @Test
    func squareRootWithRemainder_RemainderProperty() async throws {
        // Given: A GMPInteger value (e.g., 100)
        let value = GMPInteger(100)

        // When: value.squareRootWithRemainder is accessed, yielding (root, remainder)
        let result = value.squareRootWithRemainder

        // Then: The values satisfy value == root^2 + remainder and 0 <= remainder < 2*root + 1
        let rootSquared = result.root.multiplied(by: result.root)
        let sum = rootSquared.adding(result.remainder)
        #expect(value == sum)
        #expect(result.remainder.toInt() >= 0)
        let maxRemainder = result.root.multiplied(by: GMPInteger(2))
            .adding(GMPInteger(1))
        #expect(result.remainder.compare(to: maxRemainder) < 0)
    }

    @Test
    func squareRootWithRemainder_ValueOne() async throws {
        // Given: A GMPInteger equal to 1
        let value = GMPInteger(1)

        // When: value.squareRootWithRemainder is accessed
        let result = value.squareRootWithRemainder

        // Then: Returns a tuple with root = 1 and remainder = 0
        #expect(result.root.toInt() == 1)
        #expect(result.remainder.toInt() == 0)
    }

    @Test
    func squareRootWithRemainder_ValueZero() async throws {
        // Given: A GMPInteger equal to 0
        let value = GMPInteger(0)

        // When: value.squareRootWithRemainder is accessed
        let result = value.squareRootWithRemainder

        // Then: Returns a tuple with root = 0 and remainder = 0
        #expect(result.root.toInt() == 0)
        #expect(result.remainder.toInt() == 0)
    }

    @Test
    func squareRootWithRemainder_RemainderZeroIsPerfectSquare() async throws {
        // Given: A GMPInteger value (e.g., 16) where remainder is zero
        let value = GMPInteger(16)

        // When: value.squareRootWithRemainder is accessed
        let result = value.squareRootWithRemainder

        // Then: Returns a tuple with remainder = 0, indicating a perfect square
        #expect(result.remainder.toInt() == 0)
        #expect(result.root.toInt() == 4)
    }

    @Test
    func squareRootWithRemainder_Immutability() async throws {
        // Given: A GMPInteger value (e.g., 25) stored in a variable
        let value = GMPInteger(25)
        let originalValue = value.toInt()

        // When: value.squareRootWithRemainder is accessed
        let result = value.squareRootWithRemainder

        // Then: The original value is unchanged
        #expect(value.toInt() == originalValue)
        #expect(result.root.toInt() == 5)
    }

    @Test
    func squareRootWithRemainder_LargeValue() async throws {
        // Given: A large GMPInteger value (e.g., 10^100)
        let value = GMPInteger(
            "10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
        )!

        // When: value.squareRootWithRemainder is accessed
        let result = value.squareRootWithRemainder

        // Then: Returns a tuple with root and remainder satisfying value == root^2 + remainder
        let rootSquared = result.root.multiplied(by: result.root)
        let sum = rootSquared.adding(result.remainder)
        #expect(value == sum)
    }
}

// MARK: - isPerfectSquare Tests

struct GMPIntegerIsPerfectSquareTests {
    @Test
    func isPerfectSquare_True() async throws {
        // Given: A GMPInteger that is a perfect square (e.g., 25)
        let value = GMPInteger(25)

        // When: value.isPerfectSquare is accessed
        let result = value.isPerfectSquare

        // Then: Returns true
        #expect(result == true)
    }

    @Test
    func isPerfectSquare_False() async throws {
        // Given: A GMPInteger that is not a perfect square (e.g., 10)
        let value = GMPInteger(10)

        // When: value.isPerfectSquare is accessed
        let result = value.isPerfectSquare

        // Then: Returns false
        #expect(result == false)
    }

    @Test
    func isPerfectSquare_Zero() async throws {
        // Given: A GMPInteger equal to 0
        let value = GMPInteger(0)

        // When: value.isPerfectSquare is accessed
        let result = value.isPerfectSquare

        // Then: Returns true (zero is considered a perfect square)
        #expect(result == true)
    }

    @Test
    func isPerfectSquare_One() async throws {
        // Given: A GMPInteger equal to 1
        let value = GMPInteger(1)

        // When: value.isPerfectSquare is accessed
        let result = value.isPerfectSquare

        // Then: Returns true (one is considered a perfect square)
        #expect(result == true)
    }

    @Test
    func isPerfectSquare_LargePerfectSquare() async throws {
        // Given: A large GMPInteger that is a perfect square (e.g., 10^100, which is (10^50)^2)
        let value = GMPInteger(
            "10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
        )!

        // When: value.isPerfectSquare is accessed
        let result = value.isPerfectSquare

        // Then: Returns true
        #expect(result == true)
    }

    @Test
    func isPerfectSquare_LargeNotPerfectSquare() async throws {
        // Given: A large GMPInteger that is not a perfect square (e.g., 10^100 + 1)
        let value = GMPInteger(
            "10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001"
        )!

        // When: value.isPerfectSquare is accessed
        let result = value.isPerfectSquare

        // Then: Returns false
        #expect(result == false)
    }

    @Test
    func isPerfectSquare_BoundaryCondition() async throws {
        // Given: A GMPInteger value (e.g., 16) where 4^2 = 16
        let value = GMPInteger(16)

        // When: value.isPerfectSquare is accessed
        let result = value.isPerfectSquare

        // Then: Returns true
        #expect(result == true)
    }

    @Test
    func isPerfectSquare_BoundaryConditionMinusOne() async throws {
        // Given: A GMPInteger value (e.g., 15) where 3^2 = 9 < 15 < 4^2 = 16
        let value = GMPInteger(15)

        // When: value.isPerfectSquare is accessed
        let result = value.isPerfectSquare

        // Then: Returns false
        #expect(result == false)
    }

    @Test
    func isPerfectSquare_BoundaryConditionPlusOne() async throws {
        // Given: A GMPInteger value (e.g., 17) where 4^2 = 16 < 17 < 5^2 = 25
        let value = GMPInteger(17)

        // When: value.isPerfectSquare is accessed
        let result = value.isPerfectSquare

        // Then: Returns false
        #expect(result == false)
    }

    @Test
    func isPerfectSquare_Immutability() async throws {
        // Given: A GMPInteger value (e.g., 25) stored in a variable
        let value = GMPInteger(25)
        let originalValue = value.toInt()

        // When: value.isPerfectSquare is accessed
        _ = value.isPerfectSquare

        // Then: The original value is unchanged
        #expect(value.toInt() == originalValue)
    }
}

// MARK: - isPerfectPower Tests

struct GMPIntegerIsPerfectPowerTests {
    @Test
    func isPerfectPower_TrueSquare() async throws {
        // Given: A GMPInteger that is a perfect square (e.g., 25 = 5^2)
        let value = GMPInteger(25)

        // When: value.isPerfectPower is accessed
        let result = value.isPerfectPower

        // Then: Returns true
        #expect(result == true)
    }

    @Test
    func isPerfectPower_TrueCube() async throws {
        // Given: A GMPInteger that is a perfect cube (e.g., 8 = 2^3)
        let value = GMPInteger(8)

        // When: value.isPerfectPower is accessed
        let result = value.isPerfectPower

        // Then: Returns true
        #expect(result == true)
    }

    @Test
    func isPerfectPower_TrueHigherPower() async throws {
        // Given: A GMPInteger that is a perfect higher power (e.g., 16 = 2^4)
        let value = GMPInteger(16)

        // When: value.isPerfectPower is accessed
        let result = value.isPerfectPower

        // Then: Returns true
        #expect(result == true)
    }

    @Test
    func isPerfectPower_False() async throws {
        // Given: A GMPInteger that is not a perfect power (e.g., 10)
        let value = GMPInteger(10)

        // When: value.isPerfectPower is accessed
        let result = value.isPerfectPower

        // Then: Returns false
        #expect(result == false)
    }

    @Test
    func isPerfectPower_Zero() async throws {
        // Given: A GMPInteger equal to 0
        let value = GMPInteger(0)

        // When: value.isPerfectPower is accessed
        let result = value.isPerfectPower

        // Then: Returns true (zero is considered a perfect power)
        #expect(result == true)
    }

    @Test
    func isPerfectPower_One() async throws {
        // Given: A GMPInteger equal to 1
        let value = GMPInteger(1)

        // When: value.isPerfectPower is accessed
        let result = value.isPerfectPower

        // Then: Returns true (one is considered a perfect power)
        #expect(result == true)
    }

    @Test
    func isPerfectPower_NegativeOddPower() async throws {
        // Given: A negative GMPInteger that is an odd perfect power (e.g., -8 = (-2)^3)
        let value = GMPInteger(-8)

        // When: value.isPerfectPower is accessed
        let result = value.isPerfectPower

        // Then: Returns true
        #expect(result == true)
    }

    @Test
    func isPerfectPower_NegativeEvenPower() async throws {
        // Given: A negative GMPInteger (e.g., -4)
        let value = GMPInteger(-4)

        // When: value.isPerfectPower is accessed
        let result = value.isPerfectPower

        // Then: Returns false (negative values can only be odd perfect powers, and -4 is not an odd perfect power)
        #expect(result == false)
    }

    @Test
    func isPerfectPower_PrimeNumber() async throws {
        // Given: A GMPInteger that is a prime number (e.g., 7)
        let value = GMPInteger(7)

        // When: value.isPerfectPower is accessed
        let result = value.isPerfectPower

        // Then: Returns false (primes are not perfect powers except for 1)
        #expect(result == false)
    }

    @Test
    func isPerfectPower_LargePerfectPower() async throws {
        // Given: A large GMPInteger that is a perfect power (e.g., 2^100)
        let value = GMPInteger.power(base: 2, exponent: 100)

        // When: value.isPerfectPower is accessed
        let result = value.isPerfectPower

        // Then: Returns true
        #expect(result == true)
    }

    @Test
    func isPerfectPower_LargeNotPerfectPower() async throws {
        // Given: A large GMPInteger that is not a perfect power (e.g., 2^100 + 1)
        let base = GMPInteger.power(base: 2, exponent: 100)
        let value = base.adding(GMPInteger(1))

        // When: value.isPerfectPower is accessed
        let result = value.isPerfectPower

        // Then: Returns false
        #expect(result == false)
    }

    @Test
    func isPerfectPower_Immutability() async throws {
        // Given: A GMPInteger value (e.g., 8) stored in a variable
        let value = GMPInteger(8)
        let originalValue = value.toInt()

        // When: value.isPerfectPower is accessed
        _ = value.isPerfectPower

        // Then: The original value is unchanged
        #expect(value.toInt() == originalValue)
    }
}
