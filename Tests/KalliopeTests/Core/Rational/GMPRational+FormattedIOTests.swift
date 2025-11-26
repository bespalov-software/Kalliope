import CKalliope
import Foundation
@testable import Kalliope
import Testing

/// Tests for GMPRational formatted I/O pointer accessors.
struct GMPRationalFormattedIOTests {
    // MARK: - cPointer Tests

    @Test
    func cPointer_ReturnsValidPointer() async throws {
        // Given: A GMPRational initialized to 1/2
        let rational = try GMPRational(numerator: 1, denominator: 2)

        // When: cPointer is accessed using withCPointer
        // Then: Pointer is valid and points to the correct value
        // Verify by using it with a GMP function
        let result = GMPRational()
        rational.withCPointer { pointer in
            __gmpq_set(&result._storage.value, pointer)
        }
        #expect(result.numerator.toInt() == 1)
        #expect(result.denominator.toInt() == 2)
    }

    @Test
    func cPointer_ZeroValue_ReturnsValidPointer() async throws {
        // Given: A GMPRational initialized to 0/1
        let rational = GMPRational()

        // When: cPointer is accessed using withCPointer
        // Then: Pointer is valid and points to zero
        let result = GMPRational()
        rational.withCPointer { pointer in
            __gmpq_set(&result._storage.value, pointer)
        }
        #expect(result.numerator.toInt() == 0)
        #expect(result.denominator.toInt() == 1)
    }

    @Test
    func cPointer_LargeValue_ReturnsValidPointer() async throws {
        // Given: A GMPRational initialized to a large value
        let num = GMPInteger("123456789012345678901234567890")!
        let den = GMPInteger("987654321098765432109876543210")!
        let rational = try GMPRational(numerator: num, denominator: den)

        // When: cPointer is accessed using withCPointer
        // Then: Pointer is valid and points to the correct value
        // Note: The rational may be canonicalized, so compare the actual value
        let result = GMPRational()
        rational.withCPointer { pointer in
            __gmpq_set(&result._storage.value, pointer)
        }
        // Compare the rational values (they should be equal even if
        // canonicalized)
        #expect(result == rational)
    }

    @Test
    func cPointer_NegativeValue_ReturnsValidPointer() async throws {
        // Given: A GMPRational initialized to a negative value
        let rational = try GMPRational(numerator: -1, denominator: 2)

        // When: cPointer is accessed using withCPointer
        // Then: Pointer is valid and points to the correct value
        let result = GMPRational()
        rational.withCPointer { pointer in
            __gmpq_set(&result._storage.value, pointer)
        }
        #expect(result.numerator.toInt() == -1)
        #expect(result.denominator.toInt() == 2)
    }

    // MARK: - mutableCPointer Tests

    @Test
    func mutableCPointer_ReturnsValidMutablePointer() async throws {
        // Given: A GMPRational initialized to 1/2
        var rational = try GMPRational(
            numerator: 1,
            denominator: 2
        ) // Mutated through pointer below

        // When: mutableCPointer is accessed using withMutableCPointer
        // Then: Pointer is valid and can be used to modify the value
        let one = try GMPRational(numerator: 1, denominator: 1)
        rational.withMutableCPointer { pointer in
            __gmpq_add(pointer, pointer, &one._storage.value)
        }
        #expect(rational.numerator.toInt() == 3)
        #expect(rational.denominator.toInt() == 2)
    }

    @Test
    func mutableCPointer_ZeroValue_ReturnsValidMutablePointer() async throws {
        // Given: A GMPRational initialized to 0/1
        var rational = GMPRational() // Mutated through pointer below

        // When: mutableCPointer is accessed and used to set a value
        let oneHalf = try GMPRational(numerator: 1, denominator: 2)
        rational.withMutableCPointer { pointer in
            __gmpq_set(pointer, &oneHalf._storage.value)
        }

        // Then: The value is updated correctly
        #expect(rational.numerator.toInt() == 1)
        #expect(rational.denominator.toInt() == 2)
    }

    @Test
    func mutableCPointer_LargeValue_ReturnsValidMutablePointer() async throws {
        // Given: A GMPRational initialized to a large value
        let num = GMPInteger("123456789012345678901234567890")!
        let den = GMPInteger("987654321098765432109876543210")!
        var rational = try GMPRational(
            numerator: num,
            denominator: den
        ) // Mutated through pointer below
        let originalNum = rational.numerator
        let originalDen = rational.denominator

        // When: mutableCPointer is accessed and used to modify the value
        let one = try GMPRational(numerator: 1, denominator: 1)
        rational.withMutableCPointer { pointer in
            __gmpq_add(pointer, pointer, &one._storage.value)
        }

        // Then: The value is updated correctly (rational + 1 = (num + den) / den)
        // The numerator should be num + den, denominator should be den
        let expectedNum = originalNum.adding(originalDen)
        #expect(rational.numerator == expectedNum)
        #expect(rational.denominator == originalDen)
    }

    @Test
    func mutableCPointer_NegativeValue_ReturnsValidMutablePointer(
    ) async throws {
        // Given: A GMPRational initialized to a negative value
        var rational = try GMPRational(
            numerator: -1,
            denominator: 2
        ) // Mutated through pointer below

        // When: mutableCPointer is accessed and used to modify the value
        rational.withMutableCPointer { pointer in
            __gmpq_neg(pointer, pointer)
        }

        // Then: The value is updated correctly (absolute value)
        #expect(rational.numerator.toInt() == 1)
        #expect(rational.denominator.toInt() == 2)
    }

    @Test
    func mutableCPointer_ModificationPreservesValue() async throws {
        // Given: A GMPRational initialized to 1/2
        var rational = try GMPRational(
            numerator: 1,
            denominator: 2
        ) // Mutated through pointer below
        let originalNum = rational.numerator.toInt()
        let originalDen = rational.denominator.toInt()

        // When: mutableCPointer is accessed and used to modify, then read back
        let one = try GMPRational(numerator: 1, denominator: 1)
        rational.withMutableCPointer { pointer in
            __gmpq_add(pointer, pointer, &one._storage.value)
        }
        let newNum = rational.numerator.toInt()
        let newDen = rational.denominator.toInt()

        // Then: The value is correctly modified
        #expect(originalNum == 1)
        #expect(originalDen == 2)
        #expect(newNum == 3)
        #expect(newDen == 2)
    }
}
