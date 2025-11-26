import CKalliope
import Foundation
@testable import Kalliope
import Testing

/// Tests for GMPInteger formatted I/O pointer accessors.
struct GMPIntegerFormattedIOTests {
    // MARK: - cPointer Tests

    @Test
    func cPointer_ReturnsValidPointer() async throws {
        // Given: A GMPInteger initialized to 1234
        let integer = GMPInteger(1234)

        // When: cPointer is accessed using withCPointer
        // Then: Pointer is valid and points to the correct value
        // Verify by using it with a GMP function
        let result = GMPInteger()
        integer.withCPointer { pointer in
            __gmpz_set(&result._storage.value, pointer)
        }
        #expect(result.toInt() == 1234)
    }

    @Test
    func cPointer_ZeroValue_ReturnsValidPointer() async throws {
        // Given: A GMPInteger initialized to 0
        let integer = GMPInteger(0)

        // When: cPointer is accessed using withCPointer
        // Then: Pointer is valid and points to zero
        let result = GMPInteger()
        integer.withCPointer { pointer in
            __gmpz_set(&result._storage.value, pointer)
        }
        #expect(result.toInt() == 0)
    }

    @Test
    func cPointer_LargeValue_ReturnsValidPointer() async throws {
        // Given: A GMPInteger initialized to a large value
        let integer = GMPInteger("123456789012345678901234567890")!

        // When: cPointer is accessed using withCPointer
        // Then: Pointer is valid and points to the correct value
        let result = GMPInteger()
        integer.withCPointer { pointer in
            __gmpz_set(&result._storage.value, pointer)
        }
        #expect(result == integer)
    }

    @Test
    func cPointer_NegativeValue_ReturnsValidPointer() async throws {
        // Given: A GMPInteger initialized to a negative value
        let integer = GMPInteger(-1234)

        // When: cPointer is accessed using withCPointer
        // Then: Pointer is valid and points to the correct value
        let result = GMPInteger()
        integer.withCPointer { pointer in
            __gmpz_set(&result._storage.value, pointer)
        }
        #expect(result.toInt() == -1234)
    }

    // MARK: - mutableCPointer Tests

    @Test
    func mutableCPointer_ReturnsValidMutablePointer() async throws {
        // Given: A GMPInteger initialized to 1234
        var integer = GMPInteger(1234) // Mutated through pointer below

        // When: mutableCPointer is accessed using withMutableCPointer
        // Then: Pointer is valid and can be used to modify the value
        integer.withMutableCPointer { pointer in
            __gmpz_add_ui(pointer, pointer, 1)
        }
        #expect(integer.toInt() == 1235)
    }

    @Test
    func mutableCPointer_ZeroValue_ReturnsValidMutablePointer() async throws {
        // Given: A GMPInteger initialized to 0
        var integer = GMPInteger(0) // Mutated through pointer below

        // When: mutableCPointer is accessed and used to set a value
        integer.withMutableCPointer { pointer in
            __gmpz_set_ui(pointer, 42)
        }

        // Then: The value is updated correctly
        #expect(integer.toInt() == 42)
    }

    @Test
    func mutableCPointer_LargeValue_ReturnsValidMutablePointer() async throws {
        // Given: A GMPInteger initialized to a large value
        var integer =
            GMPInteger("123456789012345678901234567890")! // Mutated through
        // pointer below

        // When: mutableCPointer is accessed and used to modify the value
        let one = GMPInteger(1)
        integer.withMutableCPointer { pointer in
            __gmpz_add(pointer, pointer, &one._storage.value)
        }

        // Then: The value is updated correctly
        let expected = GMPInteger("123456789012345678901234567891")!
        #expect(integer == expected)
    }

    @Test
    func mutableCPointer_NegativeValue_ReturnsValidMutablePointer(
    ) async throws {
        // Given: A GMPInteger initialized to a negative value
        var integer = GMPInteger(-1234) // Mutated through pointer below

        // When: mutableCPointer is accessed and used to modify the value
        integer.withMutableCPointer { pointer in
            __gmpz_abs(pointer, pointer)
        }

        // Then: The value is updated correctly (absolute value)
        #expect(integer.toInt() == 1234)
    }

    @Test
    func mutableCPointer_ModificationPreservesValue() async throws {
        // Given: A GMPInteger initialized to 1234
        var integer = GMPInteger(1234) // Mutated through pointer below
        let originalValue = integer.toInt()

        // When: mutableCPointer is accessed and used to modify, then read back
        integer.withMutableCPointer { pointer in
            __gmpz_add_ui(pointer, pointer, 100)
        }
        let newValue = integer.toInt()

        // Then: The value is correctly modified
        #expect(originalValue == 1234)
        #expect(newValue == 1334)
    }
}
