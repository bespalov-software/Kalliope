@testable import Kalliope
import Testing

// MARK: - raisedToPower(_: Int) Tests

struct GMPIntegerRaisedToPowerTests {
    @Test
    func raisedToPower_PositiveBasePositiveExponent() async throws {
        // Given: A positive GMPInteger base (e.g., 5) and a positive exponent (e.g., 3)
        let base = GMPInteger(5)

        // When: base.raisedToPower(3) is called
        let result = base.raisedToPower(3)

        // Then: Returns a new GMPInteger equal to 125 (5^3)
        #expect(result.toInt() == 125)
        #expect(base.toInt() == 5) // Original unchanged
    }

    @Test
    func raisedToPower_BaseZero() async throws {
        // Given: A GMPInteger base equal to 0 and any non-negative exponent (e.g., 5)
        let base = GMPInteger(0)

        // When: base.raisedToPower(5) is called
        let result = base.raisedToPower(5)

        // Then: Returns a new GMPInteger equal to 0
        #expect(result.toInt() == 0)
        #expect(base.toInt() == 0) // Original unchanged
    }

    @Test
    func raisedToPower_ExponentZero() async throws {
        // Given: Any GMPInteger base (e.g., 7) and exponent 0
        let base = GMPInteger(7)

        // When: base.raisedToPower(0) is called
        let result = base.raisedToPower(0)

        // Then: Returns a new GMPInteger equal to 1 (even if base is 0)
        #expect(result.toInt() == 1)
        #expect(base.toInt() == 7) // Original unchanged
    }

    @Test
    func raisedToPower_ZeroToZero() async throws {
        // Given: A GMPInteger base equal to 0 and exponent 0
        let base = GMPInteger(0)

        // When: base.raisedToPower(0) is called
        let result = base.raisedToPower(0)

        // Then: Returns a new GMPInteger equal to 1
        #expect(result.toInt() == 1)
        #expect(base.toInt() == 0) // Original unchanged
    }

    @Test
    func raisedToPower_BaseOne() async throws {
        // Given: A GMPInteger base equal to 1 and any non-negative exponent (e.g., 100)
        let base = GMPInteger(1)

        // When: base.raisedToPower(100) is called
        let result = base.raisedToPower(100)

        // Then: Returns a new GMPInteger equal to 1
        #expect(result.toInt() == 1)
        #expect(base.toInt() == 1) // Original unchanged
    }

    @Test
    func raisedToPower_ExponentOne() async throws {
        // Given: Any GMPInteger base (e.g., 42) and exponent 1
        let base = GMPInteger(42)

        // When: base.raisedToPower(1) is called
        let result = base.raisedToPower(1)

        // Then: Returns a new GMPInteger equal to the base (42)
        #expect(result.toInt() == 42)
        #expect(base.toInt() == 42) // Original unchanged
    }

    @Test
    func raisedToPower_LargeBaseSmallExponent() async throws {
        // Given: A large GMPInteger base (e.g., 10^100) and a small exponent (e.g., 2)
        let base =
            GMPInteger(
                "10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
            )!

        // When: base.raisedToPower(2) is called
        let result = base.raisedToPower(2)

        // Then: Returns a new GMPInteger equal to the base squared
        let expected = base.multiplied(by: base)
        #expect(result == expected)
    }

    @Test
    func raisedToPower_SmallBaseLargeExponent() async throws {
        // Given: A small GMPInteger base (e.g., 2) and a large exponent (e.g., 100)
        let base = GMPInteger(2)

        // When: base.raisedToPower(100) is called
        let result = base.raisedToPower(100)

        // Then: Returns a new GMPInteger equal to 2^100
        // 2^100 = 1267650600228229401496703205376
        let expected = GMPInteger("1267650600228229401496703205376")!
        #expect(result == expected)
    }

    @Test
    func raisedToPower_Immutability() async throws {
        // Given: A GMPInteger base (e.g., 5) stored in a variable
        let base = GMPInteger(5)
        let originalValue = base.toInt()

        // When: base.raisedToPower(3) is called
        let result = base.raisedToPower(3)

        // Then: The original base value is unchanged
        #expect(base.toInt() == originalValue)
        #expect(result.toInt() == 125)
    }
}

// MARK: - power(base:exponent:) Tests

struct GMPIntegerPowerTests {
    @Test
    func power_PositiveBasePositiveExponent() async throws {
        // Given: A positive base (e.g., 3) and a positive exponent (e.g., 4)
        // When: GMPInteger.power(base: 3, exponent: 4) is called
        let result = GMPInteger.power(base: 3, exponent: 4)

        // Then: Returns a new GMPInteger equal to 81 (3^4)
        #expect(result.toInt() == 81)
    }

    @Test
    func power_BaseZero() async throws {
        // Given: Base 0 and any non-negative exponent (e.g., 10)
        // When: GMPInteger.power(base: 0, exponent: 10) is called
        let result = GMPInteger.power(base: 0, exponent: 10)

        // Then: Returns a new GMPInteger equal to 0
        #expect(result.toInt() == 0)
    }

    @Test
    func power_ExponentZero() async throws {
        // Given: Any base (e.g., 7) and exponent 0
        // When: GMPInteger.power(base: 7, exponent: 0) is called
        let result = GMPInteger.power(base: 7, exponent: 0)

        // Then: Returns a new GMPInteger equal to 1 (even if base is 0)
        #expect(result.toInt() == 1)
    }

    @Test
    func power_ZeroToZero() async throws {
        // Given: Base 0 and exponent 0
        // When: GMPInteger.power(base: 0, exponent: 0) is called
        let result = GMPInteger.power(base: 0, exponent: 0)

        // Then: Returns a new GMPInteger equal to 1
        #expect(result.toInt() == 1)
    }

    @Test
    func power_BaseOne() async throws {
        // Given: Base 1 and any non-negative exponent (e.g., 50)
        // When: GMPInteger.power(base: 1, exponent: 50) is called
        let result = GMPInteger.power(base: 1, exponent: 50)

        // Then: Returns a new GMPInteger equal to 1
        #expect(result.toInt() == 1)
    }

    @Test
    func power_ExponentOne() async throws {
        // Given: Any base (e.g., 42) and exponent 1
        // When: GMPInteger.power(base: 42, exponent: 1) is called
        let result = GMPInteger.power(base: 42, exponent: 1)

        // Then: Returns a new GMPInteger equal to the base (42)
        #expect(result.toInt() == 42)
    }

    @Test
    func power_NegativeBase() async throws {
        // Given: A negative base (e.g., -3) and a positive exponent (e.g., 4)
        // When: GMPInteger.power(base: -3, exponent: 4) is called
        let result = GMPInteger.power(base: -3, exponent: 4)

        // Then: Returns a new GMPInteger equal to 81 (negative base with even exponent)
        #expect(result.toInt() == 81)
    }

    @Test
    func power_NegativeBaseOddExponent() async throws {
        // Given: A negative base (e.g., -3) and an odd positive exponent (e.g., 3)
        // When: GMPInteger.power(base: -3, exponent: 3) is called
        let result = GMPInteger.power(base: -3, exponent: 3)

        // Then: Returns a new GMPInteger equal to -27 (negative result)
        #expect(result.toInt() == -27)
    }

    @Test
    func power_LargeValues() async throws {
        // Given: Large base and exponent values (e.g., base: 2, exponent: 64)
        // When: GMPInteger.power(base: 2, exponent: 64) is called
        let result = GMPInteger.power(base: 2, exponent: 64)

        // Then: Returns a new GMPInteger equal to 2^64
        // 2^64 = 18446744073709551616
        let expected = GMPInteger("18446744073709551616")!
        #expect(result == expected)
    }

    @Test
    func power_IntMinBase() async throws {
        // Given: Base is Int.min and a positive exponent (e.g., 2)
        // When: GMPInteger.power(base: Int.min, exponent: 2) is called
        let result = GMPInteger.power(base: Int.min, exponent: 2)

        // Then: Returns a new GMPInteger equal to (Int.min)^2
        // Int.min = -2,147,483,648, so (Int.min)^2 = 4,611,686,018,427,387,904
        // This tests the Int.min special case handling
        // Compute expected value using GMPInteger to avoid calculation errors
        let minGMP = GMPInteger(Int.min)
        let expected = minGMP.multiplied(by: minGMP)
        #expect(result == expected)
    }

    @Test
    func power_IntMinBaseOddExponent() async throws {
        // Given: Base is Int.min and an odd positive exponent (e.g., 3)
        // When: GMPInteger.power(base: Int.min, exponent: 3) is called
        let result = GMPInteger.power(base: Int.min, exponent: 3)

        // Then: Returns a new GMPInteger equal to (Int.min)^3 (negative result)
        // This tests the Int.min special case handling with odd exponent
        // Compute expected value using GMPInteger to avoid calculation errors
        let minGMP = GMPInteger(Int.min)
        let square = minGMP.multiplied(by: minGMP)
        let expected = square.multiplied(by: minGMP)
        #expect(result == expected)
    }
}

// MARK: - raisedToPower(_:modulo:) Tests

struct GMPIntegerRaisedToPowerModuloTests {
    @Test
    func raisedToPowerModulo_PositiveValues() async throws {
        // Given: A positive GMPInteger base (e.g., 5), positive exponent (e.g., 3), and modulus (e.g., 13)
        let base = GMPInteger(5)
        let exponent = GMPInteger(3)
        let modulus = GMPInteger(13)

        // When: base.raisedToPower(3, modulo: 13) is called
        let result = base.raisedToPower(exponent, modulo: modulus)

        // Then: Returns a new GMPInteger equal to (5^3) mod 13 = 125 mod 13 = 8
        #expect(result.toInt() == 8)
        #expect(base.toInt() == 5) // Original unchanged
    }

    @Test
    func raisedToPowerModulo_ExponentZero() async throws {
        // Given: Any GMPInteger base (e.g., 7), exponent 0, and modulus (e.g., 11)
        let base = GMPInteger(7)
        let exponent = GMPInteger(0)
        let modulus = GMPInteger(11)

        // When: base.raisedToPower(0, modulo: 11) is called
        let result = base.raisedToPower(exponent, modulo: modulus)

        // Then: Returns a new GMPInteger equal to 1 mod 11 = 1
        #expect(result.toInt() == 1)
    }

    @Test
    func raisedToPowerModulo_BaseZero() async throws {
        // Given: Base 0, any positive exponent (e.g., 5), and modulus (e.g., 7)
        let base = GMPInteger(0)
        let exponent = GMPInteger(5)
        let modulus = GMPInteger(7)

        // When: base.raisedToPower(5, modulo: 7) is called
        let result = base.raisedToPower(exponent, modulo: modulus)

        // Then: Returns a new GMPInteger equal to 0
        #expect(result.toInt() == 0)
    }

    @Test
    func raisedToPowerModulo_BaseOne() async throws {
        // Given: Base 1, any exponent (e.g., 100), and modulus (e.g., 17)
        let base = GMPInteger(1)
        let exponent = GMPInteger(100)
        let modulus = GMPInteger(17)

        // When: base.raisedToPower(100, modulo: 17) is called
        let result = base.raisedToPower(exponent, modulo: modulus)

        // Then: Returns a new GMPInteger equal to 1
        #expect(result.toInt() == 1)
    }

    @Test
    func raisedToPowerModulo_ResultLessThanModulus() async throws {
        // Given: A GMPInteger base (e.g., 3), exponent (e.g., 2), and modulus (e.g., 10)
        let base = GMPInteger(3)
        let exponent = GMPInteger(2)
        let modulus = GMPInteger(10)

        // When: base.raisedToPower(2, modulo: 10) is called
        let result = base.raisedToPower(exponent, modulo: modulus)

        // Then: Returns a new GMPInteger where 0 <= result < 10
        #expect(result.toInt() >= 0)
        #expect(result.toInt() < 10)
    }

    @Test
    func raisedToPowerModulo_LargeExponent() async throws {
        // Given: A GMPInteger base (e.g., 2), large exponent (e.g., 1000), and modulus (e.g., 97)
        let base = GMPInteger(2)
        let exponent = GMPInteger(1000)
        let modulus = GMPInteger(97)

        // When: base.raisedToPower(1000, modulo: 97) is called
        let result = base.raisedToPower(exponent, modulo: modulus)

        // Then: Returns a new GMPInteger equal to (2^1000) mod 97, computed efficiently
        // We can verify it's in the correct range
        #expect(result.toInt() >= 0)
        #expect(result.toInt() < 97)
    }

    @Test
    func raisedToPowerModulo_NegativeExponentWithInverse() async throws {
        // Given: A GMPInteger base (e.g., 3), negative exponent (e.g., -1),
        // and modulus (e.g., 11) where 3 has modular inverse mod 11
        let base = GMPInteger(3)
        let exponent = GMPInteger(-1)
        let modulus = GMPInteger(11)

        // When: base.raisedToPower(-1, modulo: 11) is called
        let result = base.raisedToPower(exponent, modulo: modulus)

        // Then: Returns a new GMPInteger equal to the modular inverse of 3 mod 11
        // (which is 4, since 3*4 = 12 ≡ 1 mod 11)
        #expect(result.toInt() == 4)
    }

    @Test
    func raisedToPowerModulo_ModulusOne() async throws {
        // Given: A GMPInteger base (e.g., 7), exponent (e.g., 100), and modulus 1
        let base = GMPInteger(7)
        let exponent = GMPInteger(100)
        let modulus = GMPInteger(1)

        // When: base.raisedToPower(100, modulo: 1) is called
        let result = base.raisedToPower(exponent, modulo: modulus)

        // Then: Returns a new GMPInteger equal to 0 (any number mod 1 = 0)
        #expect(result.toInt() == 0)
    }

    @Test
    func raisedToPowerModulo_BaseEqualToModulus() async throws {
        // Given: A GMPInteger base (e.g., 13), exponent (e.g., 5), and modulus 13
        let base = GMPInteger(13)
        let exponent = GMPInteger(5)
        let modulus = GMPInteger(13)

        // When: base.raisedToPower(5, modulo: 13) is called
        let result = base.raisedToPower(exponent, modulo: modulus)

        // Then: Returns a new GMPInteger equal to 0 (base mod modulus = 0)
        #expect(result.toInt() == 0)
    }

    @Test
    func raisedToPowerModulo_BaseGreaterThanModulus() async throws {
        // Given: A GMPInteger base (e.g., 20), exponent (e.g., 3), and modulus (e.g., 7)
        let base = GMPInteger(20)
        let exponent = GMPInteger(3)
        let modulus = GMPInteger(7)

        // When: base.raisedToPower(3, modulo: 7) is called
        let result = base.raisedToPower(exponent, modulo: modulus)

        // Then: Returns a new GMPInteger equal to (20^3) mod 7 = (6^3) mod 7 = 216 mod 7 = 6
        #expect(result.toInt() == 6)
    }

    @Test
    func raisedToPowerModulo_Immutability() async throws {
        // Given: A GMPInteger base (e.g., 5) stored in a variable
        let base = GMPInteger(5)
        let originalValue = base.toInt()
        let exponent = GMPInteger(3)
        let modulus = GMPInteger(13)

        // When: base.raisedToPower(3, modulo: 13) is called
        let result = base.raisedToPower(exponent, modulo: modulus)

        // Then: The original base value is unchanged
        #expect(base.toInt() == originalValue)
        #expect(result.toInt() == 8)
    }
}

// MARK: - raisedToPower(_:Int, modulo:) Tests

struct GMPIntegerRaisedToPowerIntModuloTests {
    @Test
    func raisedToPowerIntModulo_PositiveValues() async throws {
        // Given: A positive GMPInteger base (e.g., 5), positive Int exponent (e.g., 3), and modulus (e.g., 13)
        let base = GMPInteger(5)
        let modulus = GMPInteger(13)

        // When: base.raisedToPower(3, modulo: 13) is called
        let result = base.raisedToPower(3, modulo: modulus)

        // Then: Returns a new GMPInteger equal to (5^3) mod 13 = 8
        #expect(result.toInt() == 8)
    }

    @Test
    func raisedToPowerIntModulo_ExponentZero() async throws {
        // Given: Any GMPInteger base (e.g., 7), Int exponent 0, and modulus (e.g., 11)
        let base = GMPInteger(7)
        let modulus = GMPInteger(11)

        // When: base.raisedToPower(0, modulo: 11) is called
        let result = base.raisedToPower(0, modulo: modulus)

        // Then: Returns a new GMPInteger equal to 1
        #expect(result.toInt() == 1)
    }

    @Test
    func raisedToPowerIntModulo_NegativeExponentWithInverse(
    ) async throws {
        // Given: A GMPInteger base (e.g., 3), negative Int exponent (e.g., -1),
        // and modulus (e.g., 11) where inverse exists
        let base = GMPInteger(3)
        let modulus = GMPInteger(11)

        // When: base.raisedToPower(-1, modulo: 11) is called
        let result = base.raisedToPower(-1, modulo: modulus)

        // Then: Returns a new GMPInteger equal to the modular inverse of 3 mod 11
        #expect(result.toInt() == 4)
    }

    @Test
    func raisedToPowerIntModulo_LargeIntExponent() async throws {
        // Given: A GMPInteger base (e.g., 2), large Int exponent (e.g., 100), and modulus (e.g., 97)
        let base = GMPInteger(2)
        let modulus = GMPInteger(97)

        // When: base.raisedToPower(100, modulo: 97) is called
        let result = base.raisedToPower(100, modulo: modulus)

        // Then: Returns a new GMPInteger equal to (2^100) mod 97
        #expect(result.toInt() >= 0)
        #expect(result.toInt() < 97)
    }

    @Test
    func raisedToPowerIntModulo_Immutability() async throws {
        // Given: A GMPInteger base (e.g., 5) stored in a variable
        let base = GMPInteger(5)
        let originalValue = base.toInt()
        let modulus = GMPInteger(13)

        // When: base.raisedToPower(3, modulo: 13) is called
        let result = base.raisedToPower(3, modulo: modulus)

        // Then: The original base value is unchanged
        #expect(base.toInt() == originalValue)
        #expect(result.toInt() == 8)
    }
}

// MARK: - raisedToPowerSecure(_:modulo:) Tests

struct GMPIntegerRaisedToPowerSecureTests {
    @Test
    func raisedToPowerSecure_PositiveExponent() async throws {
        // Given: A positive GMPInteger base (e.g., 5), positive exponent (e.g., 3), and odd modulus (e.g., 13)
        let base = GMPInteger(5)
        let exponent = GMPInteger(3)
        let modulus = GMPInteger(13)

        // When: base.raisedToPowerSecure(3, modulo: 13) is called
        let result = base.raisedToPowerSecure(exponent, modulo: modulus)

        // Then: Returns a new GMPInteger equal to (5^3) mod 13 = 8
        #expect(result.toInt() == 8)
    }

    @Test
    func raisedToPowerSecure_ExponentOne() async throws {
        // Given: A GMPInteger base (e.g., 5), exponent 1, and odd modulus (e.g., 13)
        let base = GMPInteger(5)
        let exponent = GMPInteger(1)
        let modulus = GMPInteger(13)

        // When: base.raisedToPowerSecure(1, modulo: 13) is called
        let result = base.raisedToPowerSecure(exponent, modulo: modulus)

        // Then: Returns a new GMPInteger equal to 5 mod 13 = 5
        #expect(result.toInt() == 5)
    }

    @Test
    func raisedToPowerSecure_LargeExponent() async throws {
        // Given: A GMPInteger base (e.g., 2), large exponent (e.g., 1000), and odd modulus (e.g., 97)
        let base = GMPInteger(2)
        let exponent = GMPInteger(1000)
        let modulus = GMPInteger(97)

        // When: base.raisedToPowerSecure(1000, modulo: 97) is called
        let result = base.raisedToPowerSecure(exponent, modulo: modulus)

        // Then: Returns a new GMPInteger equal to (2^1000) mod 97, computed using constant-time algorithm
        #expect(result.toInt() >= 0)
        #expect(result.toInt() < 97)
    }

    @Test
    func raisedToPowerSecure_Immutability() async throws {
        // Given: A GMPInteger base (e.g., 5) stored in a variable
        let base = GMPInteger(5)
        let originalValue = base.toInt()
        let exponent = GMPInteger(3)
        let modulus = GMPInteger(13)

        // When: base.raisedToPowerSecure(3, modulo: 13) is called
        let result = base.raisedToPowerSecure(exponent, modulo: modulus)

        // Then: The original base value is unchanged
        #expect(base.toInt() == originalValue)
        #expect(result.toInt() == 8)
    }
}

// MARK: - ** Operator Tests

struct GMPIntegerPowerOperatorTests {
    @Test
    func powerOperator_PositiveBasePositiveExponent() async throws {
        // Given: A positive GMPInteger base (e.g., 5) and a positive Int exponent (e.g., 3)
        let base = GMPInteger(5)

        // When: base ** 3 is called
        let result = base ** 3

        // Then: Returns a new GMPInteger equal to 125 (5^3)
        #expect(result.toInt() == 125)
    }

    @Test
    func powerOperator_BaseZero() async throws {
        // Given: A GMPInteger base equal to 0 and any non-negative Int exponent (e.g., 5)
        let base = GMPInteger(0)

        // When: base ** 5 is called
        let result = base ** 5

        // Then: Returns a new GMPInteger equal to 0
        #expect(result.toInt() == 0)
    }

    @Test
    func powerOperator_ExponentZero() async throws {
        // Given: Any GMPInteger base (e.g., 7) and Int exponent 0
        let base = GMPInteger(7)

        // When: base ** 0 is called
        let result = base ** 0

        // Then: Returns a new GMPInteger equal to 1
        #expect(result.toInt() == 1)
    }

    @Test
    func powerOperator_ZeroToZero() async throws {
        // Given: A GMPInteger base equal to 0 and Int exponent 0
        let base = GMPInteger(0)

        // When: base ** 0 is called
        let result = base ** 0

        // Then: Returns a new GMPInteger equal to 1
        #expect(result.toInt() == 1)
    }

    @Test
    func powerOperator_ExponentOne() async throws {
        // Given: Any GMPInteger base (e.g., 42) and Int exponent 1
        let base = GMPInteger(42)

        // When: base ** 1 is called
        let result = base ** 1

        // Then: Returns a new GMPInteger equal to the base (42)
        #expect(result.toInt() == 42)
    }

    @Test
    func powerOperator_Immutability() async throws {
        // Given: A GMPInteger base (e.g., 5) stored in a variable
        let base = GMPInteger(5)
        let originalValue = base.toInt()

        // When: base ** 3 is called
        let result = base ** 3

        // Then: The original base value is unchanged
        #expect(base.toInt() == originalValue)
        #expect(result.toInt() == 125)
    }
}
