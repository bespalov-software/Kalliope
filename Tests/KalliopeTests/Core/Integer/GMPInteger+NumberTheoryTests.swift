@testable import Kalliope
import Testing

// MARK: - Greatest Common Divisor Tests

struct GMPIntegerGCDTests {
    @Test
    func gCD_TwoPositiveNumbers_ReturnsGCD() async throws {
        // Given: a = 48, b = 18
        let a = GMPInteger(48)
        let b = GMPInteger(18)

        // When: result = GMPInteger.gcd(a, b)
        let result = GMPInteger.gcd(a, b)

        // Then: result == 6
        #expect(result == GMPInteger(6))
    }

    @Test
    func gCD_TwoLargeCoprimeNumbers_ReturnsOne() async throws {
        // Given: a = 17, b = 19 (both prime)
        let a = GMPInteger(17)
        let b = GMPInteger(19)

        // When: result = GMPInteger.gcd(a, b)
        let result = GMPInteger.gcd(a, b)

        // Then: result == 1
        #expect(result == GMPInteger(1))
    }

    @Test
    func gCD_OneNumberIsMultiple_ReturnsSmallerNumber() async throws {
        // Given: a = 12, b = 36
        let a = GMPInteger(12)
        let b = GMPInteger(36)

        // When: result = GMPInteger.gcd(a, b)
        let result = GMPInteger.gcd(a, b)

        // Then: result == 12
        #expect(result == GMPInteger(12))
    }

    @Test
    func gCD_OneNumberIsMultipleReversed_ReturnsSmallerNumber(
    ) async throws {
        // Given: a = 36, b = 12
        let a = GMPInteger(36)
        let b = GMPInteger(12)

        // When: result = GMPInteger.gcd(a, b)
        let result = GMPInteger.gcd(a, b)

        // Then: result == 12
        #expect(result == GMPInteger(12))
    }

    @Test
    func gCD_BothNumbersEqual_ReturnsNumber() async throws {
        // Given: a = 15, b = 15
        let a = GMPInteger(15)
        let b = GMPInteger(15)

        // When: result = GMPInteger.gcd(a, b)
        let result = GMPInteger.gcd(a, b)

        // Then: result == 15
        #expect(result == GMPInteger(15))
    }

    @Test
    func gCD_OneIsZero_ReturnsOtherNumber() async throws {
        // Given: a = 0, b = 7
        let a = GMPInteger(0)
        let b = GMPInteger(7)

        // When: result = GMPInteger.gcd(a, b)
        let result = GMPInteger.gcd(a, b)

        // Then: result == 7
        #expect(result == GMPInteger(7))
    }

    @Test
    func gCD_OtherIsZero_ReturnsFirstNumber() async throws {
        // Given: a = 7, b = 0
        let a = GMPInteger(7)
        let b = GMPInteger(0)

        // When: result = GMPInteger.gcd(a, b)
        let result = GMPInteger.gcd(a, b)

        // Then: result == 7
        #expect(result == GMPInteger(7))
    }

    @Test
    func gCD_BothZero_ReturnsZero() async throws {
        // Given: a = 0, b = 0
        let a = GMPInteger(0)
        let b = GMPInteger(0)

        // When: result = GMPInteger.gcd(a, b)
        let result = GMPInteger.gcd(a, b)

        // Then: result == 0
        #expect(result == GMPInteger(0))
    }

    @Test
    func gCD_OneIsNegative_ReturnsPositiveGCD() async throws {
        // Given: a = -48, b = 18
        let a = GMPInteger(-48)
        let b = GMPInteger(18)

        // When: result = GMPInteger.gcd(a, b)
        let result = GMPInteger.gcd(a, b)

        // Then: result == 6 and result >= 0
        #expect(result == GMPInteger(6))
        #expect(result >= GMPInteger(0))
    }

    @Test
    func gCD_BothNegative_ReturnsPositiveGCD() async throws {
        // Given: a = -48, b = -18
        let a = GMPInteger(-48)
        let b = GMPInteger(-18)

        // When: result = GMPInteger.gcd(a, b)
        let result = GMPInteger.gcd(a, b)

        // Then: result == 6 and result >= 0
        #expect(result == GMPInteger(6))
        #expect(result >= GMPInteger(0))
    }

    @Test
    func gCD_OneIsOne_ReturnsOne() async throws {
        // Given: a = 1, b = 100
        let a = GMPInteger(1)
        let b = GMPInteger(100)

        // When: result = GMPInteger.gcd(a, b)
        let result = GMPInteger.gcd(a, b)

        // Then: result == 1
        #expect(result == GMPInteger(1))
    }

    @Test
    func gCD_BothAreOne_ReturnsOne() async throws {
        // Given: a = 1, b = 1
        let a = GMPInteger(1)
        let b = GMPInteger(1)

        // When: result = GMPInteger.gcd(a, b)
        let result = GMPInteger.gcd(a, b)

        // Then: result == 1
        #expect(result == GMPInteger(1))
    }

    @Test
    func gCD_VeryLargeNumbers_ReturnsGCD() async throws {
        // Given: a = 2^100, b = 2^100 * 3
        let a = GMPInteger(1) << 100
        var b = GMPInteger(1) << 100
        b = b * 3

        // When: result = GMPInteger.gcd(a, b)
        let result = GMPInteger.gcd(a, b)

        // Then: result == 2^100
        let expected = GMPInteger(1) << 100
        #expect(result == expected)
    }

    // MARK: - GCD with Int Tests

    @Test
    func gCD_Int_PositiveNumbers_ReturnsGCD() async throws {
        // Given: a = GMPInteger(48), b = 18
        let a = GMPInteger(48)
        let b = 18

        // When: result = GMPInteger.gcd(a, b)
        let result = GMPInteger.gcd(a, b)

        // Then: result == 6 and result >= 0
        #expect(result == 6)
        #expect(result >= 0)
    }

    @Test
    func gCD_Int_CoprimeNumbers_ReturnsOne() async throws {
        // Given: a = GMPInteger(17), b = 19
        let a = GMPInteger(17)
        let b = 19

        // When: result = GMPInteger.gcd(a, b)
        let result = GMPInteger.gcd(a, b)

        // Then: result == 1
        #expect(result == 1)
    }

    @Test
    func gCD_Int_SecondIsZero_ReturnsAbsoluteFirst() async throws {
        // Given: a = GMPInteger(7), b = 0
        let a = GMPInteger(7)
        let b = 0

        // When: result = GMPInteger.gcd(a, b)
        let result = GMPInteger.gcd(a, b)

        // Then: result == 7 and result >= 0
        #expect(result == 7)
        #expect(result >= 0)
    }

    @Test
    func gCD_Int_SecondIsNegative_ReturnsPositiveGCD() async throws {
        // Given: a = GMPInteger(48), b = -18
        let a = GMPInteger(48)
        let b: Int = -18

        // When: result = GMPInteger.gcd(a, b)
        let result = GMPInteger.gcd(a, b)

        // Then: result == 6 and result >= 0
        #expect(result == 6)
        #expect(result >= 0)
    }

    @Test
    func gCD_Int_SecondIsOne_ReturnsOne() async throws {
        // Given: a = GMPInteger(100), b = 1
        let a = GMPInteger(100)
        let b = 1

        // When: result = GMPInteger.gcd(a, b)
        let result = GMPInteger.gcd(a, b)

        // Then: result == 1
        #expect(result == 1)
    }

    @Test
    func gCD_Int_SecondIsIntMax_ReturnsGCD() async throws {
        // Given: a = GMPInteger(Int.max), b = Int.max
        let a = GMPInteger(Int.max)
        let b = Int.max

        // When: result = GMPInteger.gcd(a, b)
        let result = GMPInteger.gcd(a, b)

        // Then: result == Int.max
        #expect(result == Int.max)
    }

    @Test
    func gCD_Int_SecondIsIntMin_ReturnsGCD() async throws {
        // Given: a = GMPInteger(Int.max), b = Int.min
        let a = GMPInteger(Int.max)
        let b = Int.min

        // When: result = GMPInteger.gcd(a, b)
        let result = GMPInteger.gcd(a, b)

        // Then: result >= 0 (result is non-negative)
        #expect(result >= 0)
    }

    @Test
    func gCD_Int_VeryLargeA_ReturnsIntMax() async throws {
        // Given: a = very large GMPInteger that doesn't fit in Int, b = 0
        // When a doesn't fit in Int and b is 0, the function should return
        // Int.max as fallback
        var a = GMPInteger(1)
        a = a << 100 // Create a very large number that doesn't fit in Int
        let b = 0

        // When: result = GMPInteger.gcd(a, b)
        let result = GMPInteger.gcd(a, b)

        // Then: result == Int.max (fallback for very large values that don't fit in Int)
        #expect(result == Int.max)
    }
}

// MARK: - Extended GCD Tests

struct GMPIntegerExtendedGCDTests {
    @Test
    func extendedGCD_TwoPositiveNumbers_ReturnsGCDAndCoefficients(
    ) async throws {
        // Given: a = 48, b = 18
        let a = GMPInteger(48)
        let b = GMPInteger(18)

        // When: (gcd, s, t) = GMPInteger.extendedGCD(a, b)
        let (gcd, s, t) = GMPInteger.extendedGCD(a, b)

        // Then: gcd == 6 and a * s + b * t == gcd and gcd >= 0
        #expect(gcd == GMPInteger(6))
        #expect(gcd >= GMPInteger(0))
        let check = a * s + b * t
        #expect(check == gcd)
    }

    @Test
    func extendedGCD_CoprimeNumbers_ReturnsOneAndCoefficients(
    ) async throws {
        // Given: a = 17, b = 19
        let a = GMPInteger(17)
        let b = GMPInteger(19)

        // When: (gcd, s, t) = GMPInteger.extendedGCD(a, b)
        let (gcd, s, t) = GMPInteger.extendedGCD(a, b)

        // Then: gcd == 1 and a * s + b * t == 1 and gcd >= 0
        #expect(gcd == GMPInteger(1))
        #expect(gcd >= GMPInteger(0))
        let check = a * s + b * t
        #expect(check == GMPInteger(1))
    }

    @Test
    func extendedGCD_OneIsMultiple_ReturnsGCDAndCoefficients(
    ) async throws {
        // Given: a = 12, b = 36
        let a = GMPInteger(12)
        let b = GMPInteger(36)

        // When: (gcd, s, t) = GMPInteger.extendedGCD(a, b)
        let (gcd, s, t) = GMPInteger.extendedGCD(a, b)

        // Then: gcd == 12 and a * s + b * t == gcd and gcd >= 0
        #expect(gcd == GMPInteger(12))
        #expect(gcd >= GMPInteger(0))
        let check = a * s + b * t
        #expect(check == gcd)
    }

    @Test
    func extendedGCD_BothEqual_ReturnsGCDAndCoefficients() async throws {
        // Given: a = 15, b = 15
        let a = GMPInteger(15)
        let b = GMPInteger(15)

        // When: (gcd, s, t) = GMPInteger.extendedGCD(a, b)
        let (gcd, s, t) = GMPInteger.extendedGCD(a, b)

        // Then: gcd == 15 and a * s + b * t == gcd and gcd >= 0
        #expect(gcd == GMPInteger(15))
        #expect(gcd >= GMPInteger(0))
        let check = a * s + b * t
        #expect(check == gcd)
    }

    @Test
    func extendedGCD_OneIsZero_ReturnsOtherAndCoefficients() async throws {
        // Given: a = 0, b = 7
        let a = GMPInteger(0)
        let b = GMPInteger(7)

        // When: (gcd, s, t) = GMPInteger.extendedGCD(a, b)
        let (gcd, s, t) = GMPInteger.extendedGCD(a, b)

        // Then: gcd == 7 and a * s + b * t == gcd and gcd >= 0
        #expect(gcd == GMPInteger(7))
        #expect(gcd >= GMPInteger(0))
        let check = a * s + b * t
        #expect(check == gcd)
    }

    @Test
    func extendedGCD_BothZero_ReturnsZeroAndZeroCoefficients(
    ) async throws {
        // Given: a = 0, b = 0
        let a = GMPInteger(0)
        let b = GMPInteger(0)

        // When: (gcd, s, t) = GMPInteger.extendedGCD(a, b)
        let (gcd, s, t) = GMPInteger.extendedGCD(a, b)

        // Then: gcd == 0 and a * s + b * t == gcd
        #expect(gcd == GMPInteger(0))
        let check = a * s + b * t
        #expect(check == gcd)
    }

    @Test
    func extendedGCD_OneIsNegative_ReturnsPositiveGCD() async throws {
        // Given: a = -48, b = 18
        let a = GMPInteger(-48)
        let b = GMPInteger(18)

        // When: (gcd, s, t) = GMPInteger.extendedGCD(a, b)
        let (gcd, s, t) = GMPInteger.extendedGCD(a, b)

        // Then: gcd == 6 and gcd >= 0 and a * s + b * t == gcd
        #expect(gcd == GMPInteger(6))
        #expect(gcd >= GMPInteger(0))
        let check = a * s + b * t
        #expect(check == gcd)
    }

    @Test
    func extendedGCD_BothNegative_ReturnsPositiveGCD() async throws {
        // Given: a = -48, b = -18
        let a = GMPInteger(-48)
        let b = GMPInteger(-18)

        // When: (gcd, s, t) = GMPInteger.extendedGCD(a, b)
        let (gcd, s, t) = GMPInteger.extendedGCD(a, b)

        // Then: gcd == 6 and gcd >= 0 and a * s + b * t == gcd
        #expect(gcd == GMPInteger(6))
        #expect(gcd >= GMPInteger(0))
        let check = a * s + b * t
        #expect(check == gcd)
    }

    @Test
    func extendedGCD_OneIsOne_ReturnsOneAndCoefficients() async throws {
        // Given: a = 1, b = 100
        let a = GMPInteger(1)
        let b = GMPInteger(100)

        // When: (gcd, s, t) = GMPInteger.extendedGCD(a, b)
        let (gcd, s, t) = GMPInteger.extendedGCD(a, b)

        // Then: gcd == 1 and a * s + b * t == 1
        #expect(gcd == GMPInteger(1))
        let check = a * s + b * t
        #expect(check == GMPInteger(1))
    }

    @Test
    func extendedGCD_VeryLargeNumbers_ReturnsGCDAndCoefficients(
    ) async throws {
        // Given: a = 2^100, b = 2^100 * 3
        let a = GMPInteger(1) << 100
        var b = GMPInteger(1) << 100
        b = b * 3

        // When: (gcd, s, t) = GMPInteger.extendedGCD(a, b)
        let (gcd, s, t) = GMPInteger.extendedGCD(a, b)

        // Then: gcd == 2^100 and a * s + b * t == gcd
        let expected = GMPInteger(1) << 100
        #expect(gcd == expected)
        let check = a * s + b * t
        #expect(check == gcd)
    }
}

// MARK: - Least Common Multiple Tests

struct GMPIntegerLCMTests {
    @Test
    func lCM_TwoPositiveNumbers_ReturnsLCM() async throws {
        // Given: a = 12, b = 18
        let a = GMPInteger(12)
        let b = GMPInteger(18)

        // When: result = GMPInteger.lcm(a, b)
        let result = GMPInteger.lcm(a, b)

        // Then: result == 36 and result >= 0
        #expect(result == GMPInteger(36))
        #expect(result >= GMPInteger(0))
    }

    @Test
    func lCM_CoprimeNumbers_ReturnsProduct() async throws {
        // Given: a = 7, b = 11
        let a = GMPInteger(7)
        let b = GMPInteger(11)

        // When: result = GMPInteger.lcm(a, b)
        let result = GMPInteger.lcm(a, b)

        // Then: result == 77 and result >= 0
        #expect(result == GMPInteger(77))
        #expect(result >= GMPInteger(0))
    }

    @Test
    func lCM_OneIsMultiple_ReturnsLargerNumber() async throws {
        // Given: a = 12, b = 36
        let a = GMPInteger(12)
        let b = GMPInteger(36)

        // When: result = GMPInteger.lcm(a, b)
        let result = GMPInteger.lcm(a, b)

        // Then: result == 36 and result >= 0
        #expect(result == GMPInteger(36))
        #expect(result >= GMPInteger(0))
    }

    @Test
    func lCM_BothEqual_ReturnsNumber() async throws {
        // Given: a = 15, b = 15
        let a = GMPInteger(15)
        let b = GMPInteger(15)

        // When: result = GMPInteger.lcm(a, b)
        let result = GMPInteger.lcm(a, b)

        // Then: result == 15 and result >= 0
        #expect(result == GMPInteger(15))
        #expect(result >= GMPInteger(0))
    }

    @Test
    func lCM_FirstIsZero_ReturnsZero() async throws {
        // Given: a = 0, b = 7
        let a = GMPInteger(0)
        let b = GMPInteger(7)

        // When: result = GMPInteger.lcm(a, b)
        let result = GMPInteger.lcm(a, b)

        // Then: result == 0
        #expect(result == GMPInteger(0))
    }

    @Test
    func lCM_SecondIsZero_ReturnsZero() async throws {
        // Given: a = 7, b = 0
        let a = GMPInteger(7)
        let b = GMPInteger(0)

        // When: result = GMPInteger.lcm(a, b)
        let result = GMPInteger.lcm(a, b)

        // Then: result == 0
        #expect(result == GMPInteger(0))
    }

    @Test
    func lCM_BothZero_ReturnsZero() async throws {
        // Given: a = 0, b = 0
        let a = GMPInteger(0)
        let b = GMPInteger(0)

        // When: result = GMPInteger.lcm(a, b)
        let result = GMPInteger.lcm(a, b)

        // Then: result == 0
        #expect(result == GMPInteger(0))
    }

    @Test
    func lCM_OneIsNegative_ReturnsPositiveLCM() async throws {
        // Given: a = -12, b = 18
        let a = GMPInteger(-12)
        let b = GMPInteger(18)

        // When: result = GMPInteger.lcm(a, b)
        let result = GMPInteger.lcm(a, b)

        // Then: result == 36 and result >= 0
        #expect(result == GMPInteger(36))
        #expect(result >= GMPInteger(0))
    }

    @Test
    func lCM_BothNegative_ReturnsPositiveLCM() async throws {
        // Given: a = -12, b = -18
        let a = GMPInteger(-12)
        let b = GMPInteger(-18)

        // When: result = GMPInteger.lcm(a, b)
        let result = GMPInteger.lcm(a, b)

        // Then: result == 36 and result >= 0
        #expect(result == GMPInteger(36))
        #expect(result >= GMPInteger(0))
    }

    @Test
    func lCM_OneIsOne_ReturnsOtherNumber() async throws {
        // Given: a = 1, b = 100
        let a = GMPInteger(1)
        let b = GMPInteger(100)

        // When: result = GMPInteger.lcm(a, b)
        let result = GMPInteger.lcm(a, b)

        // Then: result == 100 and result >= 0
        #expect(result == GMPInteger(100))
        #expect(result >= GMPInteger(0))
    }

    @Test
    func lCM_BothAreOne_ReturnsOne() async throws {
        // Given: a = 1, b = 1
        let a = GMPInteger(1)
        let b = GMPInteger(1)

        // When: result = GMPInteger.lcm(a, b)
        let result = GMPInteger.lcm(a, b)

        // Then: result == 1 and result >= 0
        #expect(result == GMPInteger(1))
        #expect(result >= GMPInteger(0))
    }

    @Test
    func lCM_VeryLargeNumbers_ReturnsLCM() async throws {
        // Given: a = 2^50, b = 3^40
        let a = GMPInteger(1) << 50
        var b = GMPInteger(1)
        for _ in 0 ..< 40 {
            b = b * 3
        }

        // When: result = GMPInteger.lcm(a, b)
        let result = GMPInteger.lcm(a, b)

        // Then: result >= 0 and result % a == 0 and result % b == 0
        #expect(result >= GMPInteger(0))
        let remainderA = try? result.modulo(a)
        let remainderB = try? result.modulo(b)
        #expect(remainderA == GMPInteger(0))
        #expect(remainderB == GMPInteger(0))
    }

    // MARK: - LCM with Int Tests

    @Test
    func lCM_Int_PositiveNumbers_ReturnsLCM() async throws {
        // Given: a = GMPInteger(12), b = 18
        let a = GMPInteger(12)
        let b = 18

        // When: result = GMPInteger.lcm(a, b)
        let result = GMPInteger.lcm(a, b)

        // Then: result == 36 and result >= 0
        #expect(result == GMPInteger(36))
        #expect(result >= GMPInteger(0))
    }

    @Test
    func lCM_Int_CoprimeNumbers_ReturnsProduct() async throws {
        // Given: a = GMPInteger(7), b = 11
        let a = GMPInteger(7)
        let b = 11

        // When: result = GMPInteger.lcm(a, b)
        let result = GMPInteger.lcm(a, b)

        // Then: result == 77 and result >= 0
        #expect(result == GMPInteger(77))
        #expect(result >= GMPInteger(0))
    }

    @Test
    func lCM_Int_SecondIsZero_ReturnsZero() async throws {
        // Given: a = GMPInteger(7), b = 0
        let a = GMPInteger(7)
        let b = 0

        // When: result = GMPInteger.lcm(a, b)
        let result = GMPInteger.lcm(a, b)

        // Then: result == 0
        #expect(result == GMPInteger(0))
    }

    @Test
    func lCM_Int_SecondIsNegative_ReturnsPositiveLCM() async throws {
        // Given: a = GMPInteger(12), b = -18
        let a = GMPInteger(12)
        let b: Int = -18

        // When: result = GMPInteger.lcm(a, b)
        let result = GMPInteger.lcm(a, b)

        // Then: result == 36 and result >= 0
        #expect(result == GMPInteger(36))
        #expect(result >= GMPInteger(0))
    }

    @Test
    func lCM_Int_SecondIsOne_ReturnsFirst() async throws {
        // Given: a = GMPInteger(100), b = 1
        let a = GMPInteger(100)
        let b = 1

        // When: result = GMPInteger.lcm(a, b)
        let result = GMPInteger.lcm(a, b)

        // Then: result == 100 and result >= 0
        #expect(result == GMPInteger(100))
        #expect(result >= GMPInteger(0))
    }

    @Test
    func lCM_Int_SecondIsIntMax_ReturnsLCM() async throws {
        // Given: a = GMPInteger(Int.max), b = Int.max
        let a = GMPInteger(Int.max)
        let b = Int.max

        // When: result = GMPInteger.lcm(a, b)
        let result = GMPInteger.lcm(a, b)

        // Then: result == Int.max and result >= 0
        #expect(result == GMPInteger(Int.max))
        #expect(result >= GMPInteger(0))
    }

    @Test
    func lCM_Int_SecondIsIntMin_ReturnsLCM() async throws {
        // Given: a = GMPInteger(12), b = Int.min
        // This tests the special case handling for Int.min to avoid arithmetic
        // overflow
        let a = GMPInteger(12)
        let b = Int.min

        // When: result = GMPInteger.lcm(a, b)
        let result = GMPInteger.lcm(a, b)

        // Then: result >= 0 and result is a valid LCM (handles Int.min specially)
        #expect(result >= GMPInteger(0))
        // Int.min = -2,147,483,648, abs(Int.min) = 2,147,483,648
        // LCM(12, 2,147,483,648) should be computed correctly
        let absB = GMPInteger(Int.max) + 1 // abs(Int.min)
        let remainder = try? result.modulo(a)
        #expect(remainder == GMPInteger(0))
        let remainderB = try? result.modulo(absB)
        #expect(remainderB == GMPInteger(0))
    }
}

// MARK: - Modular Inverse Tests

struct GMPIntegerModularInverseTests {
    @Test
    func modularInverse_CoprimeNumbers_ReturnsInverse() async throws {
        // Given: a = GMPInteger(3), modulus = GMPInteger(7)
        let a = GMPInteger(3)
        let modulus = GMPInteger(7)

        // When: result = a.modularInverse(modulo: modulus)
        let result = a.modularInverse(modulo: modulus)

        // Then: result != nil and (a * result!) % modulus == 1 and result! >= 0 and result! < modulus
        #expect(result != nil)
        if let inv = result {
            let product = a * inv
            let remainder = try? product.modulo(modulus)
            #expect(remainder == GMPInteger(1))
            #expect(inv >= GMPInteger(0))
            #expect(inv < modulus)
        }
    }

    @Test
    func modularInverse_NotCoprime_ReturnsNil() async throws {
        // Given: a = GMPInteger(4), modulus = GMPInteger(8)
        let a = GMPInteger(4)
        let modulus = GMPInteger(8)

        // When: result = a.modularInverse(modulo: modulus)
        let result = a.modularInverse(modulo: modulus)

        // Then: result == nil
        #expect(result == nil)
    }

    @Test
    func modularInverse_SelfIsOne_ReturnsOne() async throws {
        // Given: a = GMPInteger(1), modulus = GMPInteger(7)
        let a = GMPInteger(1)
        let modulus = GMPInteger(7)

        // When: result = a.modularInverse(modulo: modulus)
        let result = a.modularInverse(modulo: modulus)

        // Then: result == 1 and (a * result!) % modulus == 1
        #expect(result == GMPInteger(1))
        if let inv = result {
            let product = a * inv
            let remainder = try? product.modulo(modulus)
            #expect(remainder == GMPInteger(1))
        }
    }

    @Test
    func modularInverse_SelfEqualsModulusMinusOne_ReturnsModulusMinusOne(
    ) async throws {
        // Given: a = GMPInteger(6), modulus = GMPInteger(7)
        let a = GMPInteger(6)
        let modulus = GMPInteger(7)

        // When: result = a.modularInverse(modulo: modulus)
        let result = a.modularInverse(modulo: modulus)

        // Then: result == 6 and (a * result!) % modulus == 1
        #expect(result == GMPInteger(6))
        if let inv = result {
            let product = a * inv
            let remainder = try? product.modulo(modulus)
            #expect(remainder == GMPInteger(1))
        }
    }

    @Test
    func modularInverse_SelfIsNegative_Coprime_ReturnsInverse(
    ) async throws {
        // Given: a = GMPInteger(-3), modulus = GMPInteger(7)
        let a = GMPInteger(-3)
        let modulus = GMPInteger(7)

        // When: result = a.modularInverse(modulo: modulus)
        let result = a.modularInverse(modulo: modulus)

        // Then: result != nil and ((a % modulus + modulus) % modulus * result!) % modulus == 1
        #expect(result != nil)
        if let inv = result {
            let aMod = try? a.modulo(modulus)
            let aPos = (aMod ?? GMPInteger(0)) < GMPInteger(0) ?
                (aMod ?? GMPInteger(0)) + modulus : (aMod ?? GMPInteger(0))
            let product = aPos * inv
            let remainder = try? product.modulo(modulus)
            #expect(remainder == GMPInteger(1))
        }
    }

    @Test
    func modularInverse_SelfIsZero_ReturnsNil() async throws {
        // Given: a = GMPInteger(0), modulus = GMPInteger(7)
        let a = GMPInteger(0)
        let modulus = GMPInteger(7)

        // When: result = a.modularInverse(modulo: modulus)
        let result = a.modularInverse(modulo: modulus)

        // Then: result == nil
        #expect(result == nil)
    }

    @Test
    func modularInverse_ModulusZero_ReturnsNil() async throws {
        // Given: a = GMPInteger(5), modulus = GMPInteger(0)
        let a = GMPInteger(5)
        let modulus = GMPInteger(0)

        // When: result = a.modularInverse(modulo: modulus)
        let result = a.modularInverse(modulo: modulus)

        // Then: result == nil (modulus must not be zero)
        #expect(result == nil)
    }

    @Test
    func modularInverse_ModulusIsOne_ReturnsZero() async throws {
        // Given: a = GMPInteger(5), modulus = GMPInteger(1)
        let a = GMPInteger(5)
        let modulus = GMPInteger(1)

        // When: result = a.modularInverse(modulo: modulus)
        let result = a.modularInverse(modulo: modulus)

        // Then: result == 0 (since 5 * 0 ≡ 0 ≡ 1 (mod 1))
        #expect(result == GMPInteger(0))
    }

    @Test
    func modularInverse_ModulusIsTwo_SelfIsOne_ReturnsOne() async throws {
        // Given: a = GMPInteger(1), modulus = GMPInteger(2)
        let a = GMPInteger(1)
        let modulus = GMPInteger(2)

        // When: result = a.modularInverse(modulo: modulus)
        let result = a.modularInverse(modulo: modulus)

        // Then: result == 1 and (a * result!) % modulus == 1
        #expect(result == GMPInteger(1))
        if let inv = result {
            let product = a * inv
            let remainder = try? product.modulo(modulus)
            #expect(remainder == GMPInteger(1))
        }
    }

    @Test
    func modularInverse_LargeCoprimeNumbers_ReturnsInverse() async throws {
        // Given: a = GMPInteger(2^100 + 1), modulus = GMPInteger(2^101) (coprime)
        var a = GMPInteger(1) << 100
        a = a + 1
        let modulus = GMPInteger(1) << 101

        // When: result = a.modularInverse(modulo: modulus)
        let result = a.modularInverse(modulo: modulus)

        // Then: result != nil and (a * result!) % modulus == 1
        #expect(result != nil)
        if let inv = result {
            let product = a * inv
            let remainder = try? product.modulo(modulus)
            #expect(remainder == GMPInteger(1))
        }
    }

    @Test
    func modularInverse_ResultIsInRange() async throws {
        // Given: a = GMPInteger(5), modulus = GMPInteger(13)
        let a = GMPInteger(5)
        let modulus = GMPInteger(13)

        // When: result = a.modularInverse(modulo: modulus)
        let result = a.modularInverse(modulo: modulus)

        // Then: result != nil and result! >= 0 and result! < modulus
        #expect(result != nil)
        if let inv = result {
            #expect(inv >= GMPInteger(0))
            #expect(inv < modulus)
        }
    }

    @Test
    func modularInverse_SelfUnchangedAfterCall() async throws {
        // Given: a = GMPInteger(3), modulus = GMPInteger(7), originalValue = a
        let a = GMPInteger(3)
        let modulus = GMPInteger(7)
        let originalValue = a

        // When: result = a.modularInverse(modulo: modulus)
        _ = a.modularInverse(modulo: modulus)

        // Then: a == originalValue
        #expect(a == originalValue)
    }
}

// MARK: - Jacobi Symbol Tests

struct GMPIntegerJacobiSymbolTests {
    @Test
    func jacobiSymbol_PositiveOddDenominator_ReturnsSymbol() async throws {
        // Given: a = GMPInteger(15), n = GMPInteger(7) (odd positive)
        let a = GMPInteger(15)
        let n = GMPInteger(7)

        // When: result = GMPInteger.jacobiSymbol(a, n)
        let result = GMPInteger.jacobiSymbol(a, n)

        // Then: result == -1 or result == 0 or result == 1
        #expect(result == -1 || result == 0 || result == 1)
    }

    @Test
    func jacobiSymbol_Coprime_ReturnsNonZero() async throws {
        // Given: a = GMPInteger(5), n = GMPInteger(7) (coprime)
        let a = GMPInteger(5)
        let n = GMPInteger(7)

        // When: result = GMPInteger.jacobiSymbol(a, n)
        let result = GMPInteger.jacobiSymbol(a, n)

        // Then: result != 0
        #expect(result != 0)
    }

    @Test
    func jacobiSymbol_NotCoprime_ReturnsZero() async throws {
        // Given: a = GMPInteger(14), n = GMPInteger(7) (not coprime, 7 divides 14)
        let a = GMPInteger(14)
        let n = GMPInteger(7)

        // When: result = GMPInteger.jacobiSymbol(a, n)
        let result = GMPInteger.jacobiSymbol(a, n)

        // Then: result == 0
        #expect(result == 0)
    }

    @Test
    func jacobiSymbol_QuadraticResidue_ReturnsOne() async throws {
        // Given: a = GMPInteger(1), n = GMPInteger(3)
        let a = GMPInteger(1)
        let n = GMPInteger(3)

        // When: result = GMPInteger.jacobiSymbol(a, n)
        let result = GMPInteger.jacobiSymbol(a, n)

        // Then: result == 1
        #expect(result == 1)
    }

    @Test
    func jacobiSymbol_NonQuadraticResidue_ReturnsMinusOne() async throws {
        // Given: a = GMPInteger(2), n = GMPInteger(3)
        let a = GMPInteger(2)
        let n = GMPInteger(3)

        // When: result = GMPInteger.jacobiSymbol(a, n)
        let result = GMPInteger.jacobiSymbol(a, n)

        // Then: result == -1
        #expect(result == -1)
    }

    @Test
    func jacobiSymbol_ASquare_ReturnsOneOrZero() async throws {
        // Given: a = GMPInteger(4), n = GMPInteger(7)
        let a = GMPInteger(4)
        let n = GMPInteger(7)

        // When: result = GMPInteger.jacobiSymbol(a, n)
        let result = GMPInteger.jacobiSymbol(a, n)

        // Then: result == 0 or result == 1
        #expect(result == 0 || result == 1)
    }

    @Test
    func jacobiSymbol_NIsOne_ReturnsOne() async throws {
        // Given: a = GMPInteger(5), n = GMPInteger(1)
        let a = GMPInteger(5)
        let n = GMPInteger(1)

        // When: result = GMPInteger.jacobiSymbol(a, n)
        let result = GMPInteger.jacobiSymbol(a, n)

        // Then: result == 1
        #expect(result == 1)
    }

    @Test
    func jacobiSymbol_NIsThree_ReturnsCorrectSymbol() async throws {
        // Given: a = GMPInteger(1), n = GMPInteger(3)
        let a = GMPInteger(1)
        let n = GMPInteger(3)

        // When: result = GMPInteger.jacobiSymbol(a, n)
        let result = GMPInteger.jacobiSymbol(a, n)

        // Then: result == 1
        #expect(result == 1)
    }

    @Test
    func jacobiSymbol_ANegative_ReturnsCorrectSymbol() async throws {
        // Given: a = GMPInteger(-1), n = GMPInteger(7)
        let a = GMPInteger(-1)
        let n = GMPInteger(7)

        // When: result = GMPInteger.jacobiSymbol(a, n)
        let result = GMPInteger.jacobiSymbol(a, n)

        // Then: result == -1 or result == 0 or result == 1
        #expect(result == -1 || result == 0 || result == 1)
    }

    @Test
    func jacobiSymbol_VeryLargeNumbers_ReturnsValidSymbol() async throws {
        // Given: a = GMPInteger(2^100), n = GMPInteger(2^101 - 1) (odd positive)
        let a = GMPInteger(1) << 100
        var n = GMPInteger(1) << 101
        n = n - 1

        // When: result = GMPInteger.jacobiSymbol(a, n)
        let result = GMPInteger.jacobiSymbol(a, n)

        // Then: result == -1 or result == 0 or result == 1
        #expect(result == -1 || result == 0 || result == 1)
    }

    // MARK: - Jacobi Symbol with Int Tests

    @Test
    func jacobiSymbol_Int_PositiveOddDenominator_ReturnsSymbol(
    ) async throws {
        // Given: a = 15, n = GMPInteger(7)
        let a = 15
        let n = GMPInteger(7)

        // When: result = GMPInteger.jacobiSymbol(a, n)
        let result = GMPInteger.jacobiSymbol(a, n)

        // Then: result == -1 or result == 0 or result == 1
        #expect(result == -1 || result == 0 || result == 1)
    }

    @Test
    func jacobiSymbol_Int_NotCoprime_ReturnsZero() async throws {
        // Given: a = 14, n = GMPInteger(7)
        let a = 14
        let n = GMPInteger(7)

        // When: result = GMPInteger.jacobiSymbol(a, n)
        let result = GMPInteger.jacobiSymbol(a, n)

        // Then: result == 0
        #expect(result == 0)
    }

    @Test
    func jacobiSymbol_Int_ACoprime_ReturnsNonZero() async throws {
        // Given: a = 5, n = GMPInteger(7)
        let a = 5
        let n = GMPInteger(7)

        // When: result = GMPInteger.jacobiSymbol(a, n)
        let result = GMPInteger.jacobiSymbol(a, n)

        // Then: result != 0
        #expect(result != 0)
    }

    @Test
    func jacobiSymbol_Int_ANegative_ReturnsValidSymbol() async throws {
        // Given: a = -1, n = GMPInteger(7)
        let a: Int = -1
        let n = GMPInteger(7)

        // When: result = GMPInteger.jacobiSymbol(a, n)
        let result = GMPInteger.jacobiSymbol(a, n)

        // Then: result == -1 or result == 0 or result == 1
        #expect(result == -1 || result == 0 || result == 1)
    }

    @Test
    func jacobiSymbol_Int_IntMax_ReturnsValidSymbol() async throws {
        // Given: a = Int.max, n = GMPInteger(Int.max) (if odd)
        let a = Int.max
        let n = GMPInteger(Int.max)

        // When: result = GMPInteger.jacobiSymbol(a, n)
        let result = GMPInteger.jacobiSymbol(a, n)

        // Then: result == -1 or result == 0 or result == 1
        #expect(result == -1 || result == 0 || result == 1)
    }
}

// MARK: - Kronecker Symbol Tests

struct GMPIntegerKroneckerSymbolTests {
    @Test
    func kroneckerSymbol_TwoPositiveNumbers_ReturnsSymbol() async throws {
        let a = GMPInteger(15)
        let n = GMPInteger(7)
        let result = GMPInteger.kroneckerSymbol(a, n)
        #expect(result == -1 || result == 0 || result == 1)
    }

    @Test
    func kroneckerSymbol_EvenDenominator_ReturnsSymbol() async throws {
        let a = GMPInteger(5)
        let n = GMPInteger(8)
        let result = GMPInteger.kroneckerSymbol(a, n)
        #expect(result == -1 || result == 0 || result == 1)
    }

    @Test
    func kroneckerSymbol_Int_PositiveNumbers_ReturnsSymbol() async throws {
        let a = 15
        let n = GMPInteger(7)
        let result = GMPInteger.kroneckerSymbol(a, n)
        #expect(result == -1 || result == 0 || result == 1)
    }

    @Test
    func kroneckerSymbol_IntDenominator_PositiveNumbers_ReturnsSymbol(
    ) async throws {
        let a = GMPInteger(15)
        let n = 7
        let result = GMPInteger.kroneckerSymbol(a, n)
        #expect(result == -1 || result == 0 || result == 1)
    }

    @Test
    func kroneckerSymbol_TwoInt_PositiveNumbers_ReturnsSymbol(
    ) async throws {
        let a = 15
        let n = 7
        let result = GMPInteger.kroneckerSymbol(a, n)
        #expect(result == -1 || result == 0 || result == 1)
    }

    @Test
    func kroneckerSymbol_Int_NegativeA_ReturnsSymbol() async throws {
        // Given: Negative a, positive n
        let a = -15
        let n = GMPInteger(7)

        // When: Call kroneckerSymbol(a, n)
        let result = GMPInteger.kroneckerSymbol(a, n)

        // Then: Returns valid symbol (-1, 0, or 1)
        #expect(result == -1 || result == 0 || result == 1)
    }

    @Test
    func kroneckerSymbol_IntDenominator_NegativeN_ReturnsSymbol() async throws {
        // Given: Positive a, negative n
        let a = GMPInteger(15)
        let n = -7

        // When: Call kroneckerSymbol(a, n)
        let result = GMPInteger.kroneckerSymbol(a, n)

        // Then: Returns valid symbol (-1, 0, or 1)
        #expect(result == -1 || result == 0 || result == 1)
    }

    @Test
    func kroneckerSymbol_TwoInt_NegativeN_ReturnsSymbol() async throws {
        // Given: Positive a, negative n
        let a = 15
        let n = -7

        // When: Call kroneckerSymbol(a, n)
        let result = GMPInteger.kroneckerSymbol(a, n)

        // Then: Returns valid symbol (-1, 0, or 1)
        #expect(result == -1 || result == 0 || result == 1)
    }

    @Test
    func kroneckerSymbol_TwoInt_BothNegative_ReturnsSymbol() async throws {
        // Given: Negative a, negative n
        let a = -15
        let n = -7

        // When: Call kroneckerSymbol(a, n)
        let result = GMPInteger.kroneckerSymbol(a, n)

        // Then: Returns valid symbol (-1, 0, or 1)
        #expect(result == -1 || result == 0 || result == 1)
    }
}

// MARK: - Primality Testing Tests

struct GMPIntegerPrimalityTests {
    @Test
    func isProbablePrime_SmallPrime_ReturnsTwo() async throws {
        let a = GMPInteger(2)
        let result = a.isProbablePrime()
        #expect(result == 2)
    }

    @Test
    func isProbablePrime_CompositeFour_ReturnsZero() async throws {
        let a = GMPInteger(4)
        let result = a.isProbablePrime()
        #expect(result == 0)
    }

    @Test
    func nextPrime_SmallNumber_ReturnsNextPrime() async throws {
        let a = GMPInteger(10)
        let result = a.nextPrime
        #expect(result > a)
        #expect(result.isProbablePrime() >= 1)
    }

    @Test
    func previousPrime_NumberGreaterThanTwo_ReturnsPreviousPrime(
    ) async throws {
        let a = GMPInteger(10)
        let result = a.previousPrime
        #expect(result != nil)
        if let (prime, certainty) = result {
            #expect(prime < a)
            #expect(certainty >= 0 && certainty <= 2)
            #expect(prime.isProbablePrime() >= 1)
        }
    }

    @Test
    func previousPrime_Two_ReturnsNil() async throws {
        let a = GMPInteger(2)
        let result = a.previousPrime
        #expect(result == nil)
    }

    @Test
    func millerRabinTest_Prime_ReturnsOne() async throws {
        // Given: A prime number
        let prime = GMPInteger(7)
        let reps = 10

        // When: Call millerRabinTest(reps:)
        let result = prime.millerRabinTest(reps: reps)

        // Then: Returns 1 (probably prime)
        #expect(result == 1)
    }

    @Test
    func millerRabinTest_Composite_ReturnsZero() async throws {
        // Given: A composite number
        let composite = GMPInteger(4)
        let reps = 10

        // When: Call millerRabinTest(reps:)
        let result = composite.millerRabinTest(reps: reps)

        // Then: Returns 0 (composite)
        #expect(result == 0)
    }

    @Test
    func millerRabinTest_LargePrime_ReturnsOne() async throws {
        // Given: A larger prime number
        let prime = GMPInteger(101)
        let reps = 10

        // When: Call millerRabinTest(reps:)
        let result = prime.millerRabinTest(reps: reps)

        // Then: Returns 1 (probably prime)
        #expect(result == 1)
    }
}

// MARK: - Factorials and Binomials Tests

struct GMPIntegerFactorialTests {
    @Test
    func factorial_Zero_ReturnsOne() async throws {
        let result = GMPInteger.factorial(0)
        #expect(result == GMPInteger(1))
    }

    @Test
    func factorial_Five_ReturnsOneHundredTwenty() async throws {
        let result = GMPInteger.factorial(5)
        #expect(result == GMPInteger(120))
    }

    @Test
    func binomial_FiveChooseTwo_ReturnsTen() async throws {
        let result = GMPInteger.binomial(5, 2)
        #expect(result == GMPInteger(10))
    }

    @Test
    func doubleFactorial_Five_ReturnsFifteen() async throws {
        let result = GMPInteger.doubleFactorial(5)
        #expect(result == GMPInteger(15))
    }

    @Test
    func primorial_Five_ReturnsThirty() async throws {
        let result = GMPInteger.primorial(5)
        #expect(result == GMPInteger(30))
    }

    @Test
    func multiFactorial_SmallValues_ReturnsCorrect() async throws {
        // Given: n=5, k=2 (double factorial)
        // When: Call multiFactorial(5, 2)
        let result = GMPInteger.multiFactorial(5, 2)

        // Then: Returns 5!! = 5 * 3 * 1 = 15
        #expect(result == GMPInteger(15))
    }

    @Test
    func multiFactorial_Zero_ReturnsOne() async throws {
        // Given: n=0, k=2
        // When: Call multiFactorial(0, 2)
        let result = GMPInteger.multiFactorial(0, 2)

        // Then: Returns 1
        #expect(result == GMPInteger(1))
    }

    @Test
    func multiFactorial_RegularFactorial_ReturnsFactorial() async throws {
        // Given: n=5, k=1 (regular factorial)
        // When: Call multiFactorial(5, 1)
        let result = GMPInteger.multiFactorial(5, 1)

        // Then: Returns 5! = 120
        #expect(result == GMPInteger(120))
    }

    @Test
    func multiFactorial_TripleFactorial_ReturnsCorrect() async throws {
        // Given: n=7, k=3 (triple factorial)
        // When: Call multiFactorial(7, 3)
        let result = GMPInteger.multiFactorial(7, 3)

        // Then: Returns 7!!! = 7 * 4 * 1 = 28
        #expect(result == GMPInteger(28))
    }
}

// MARK: - Fibonacci and Lucas Tests

struct GMPIntegerFibonacciTests {
    @Test
    func fibonacci_Zero_ReturnsZero() async throws {
        let result = GMPInteger.fibonacci(0)
        #expect(result == GMPInteger(0))
    }

    @Test
    func fibonacci_Ten_ReturnsFiftyFive() async throws {
        let result = GMPInteger.fibonacci(10)
        #expect(result == GMPInteger(55))
    }

    @Test
    func fibonacci2_Ten_ReturnsCorrectValues() async throws {
        let (fn, fn1) = GMPInteger.fibonacci2(10)
        #expect(fn == GMPInteger(55))
        #expect(fn1 == GMPInteger(34))
    }

    @Test
    func lucas_Ten_ReturnsCorrectValue() async throws {
        let result = GMPInteger.lucas(10)
        #expect(result == GMPInteger(123))
    }

    @Test
    func lucas2_Ten_ReturnsCorrectValues() async throws {
        let (ln, ln1) = GMPInteger.lucas2(10)
        #expect(ln == GMPInteger(123))
        #expect(ln1 == GMPInteger(76))
    }
}

// MARK: - Factor Removal Tests

struct GMPIntegerFactorRemovalTests {
    @Test
    func remove_DividesOnce_ReturnsOne() async throws {
        var a = GMPInteger(12)
        let factor = GMPInteger(3)
        let count = a.remove(factor: factor)
        #expect(count == 1)
        #expect(a == GMPInteger(4))
    }

    @Test
    func remove_DividesMultipleTimes_ReturnsCount() async throws {
        var a = GMPInteger(72)
        let factor = GMPInteger(2)
        let count = a.remove(factor: factor)
        #expect(count == 3)
        #expect(a == GMPInteger(9))
    }

    @Test
    func remove_DoesNotDivide_ReturnsZero() async throws {
        var a = GMPInteger(15)
        let factor = GMPInteger(7)
        let originalValue = a
        let count = a.remove(factor: factor)
        #expect(count == 0)
        #expect(a == originalValue)
    }
}
