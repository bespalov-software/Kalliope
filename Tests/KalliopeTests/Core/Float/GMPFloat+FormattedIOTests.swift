import CKalliope
import Foundation
@testable import Kalliope
import Testing

/// Tests for GMPFloat formatted I/O pointer accessors.
struct GMPFloatFormattedIOTests {
    // MARK: - cPointer Tests

    @Test
    func cPointer_ReturnsValidPointer() async throws {
        // Given: A GMPFloat initialized to 3.14
        let float = GMPFloat(3.14)

        // When: cPointer is accessed using withCPointer
        // Then: Pointer is valid and points to the correct value
        // Verify by using it with a GMP function
        let result = try GMPFloat(precision: float.precision)
        float.withCPointer { pointer in
            __gmpf_set(&result._storage.value, pointer)
        }
        #expect(abs(result.toDouble() - 3.14) < 0.01)
    }

    @Test
    func cPointer_ZeroValue_ReturnsValidPointer() async throws {
        // Given: A GMPFloat initialized to 0.0
        let float = GMPFloat(0.0)

        // When: cPointer is accessed using withCPointer
        // Then: Pointer is valid and points to zero
        let result = try GMPFloat(precision: float.precision)
        float.withCPointer { pointer in
            __gmpf_set(&result._storage.value, pointer)
        }
        #expect(result.toDouble() == 0.0)
    }

    @Test
    func cPointer_LargeValue_ReturnsValidPointer() async throws {
        // Given: A GMPFloat initialized to a large value
        let float = GMPFloat(1.234567890123456789e100)

        // When: cPointer is accessed using withCPointer
        // Then: Pointer is valid and points to the correct value
        let result = try GMPFloat(precision: float.precision)
        float.withCPointer { pointer in
            __gmpf_set(&result._storage.value, pointer)
        }
        // For very large numbers, use relative tolerance instead of absolute
        // Double has ~15-17 significant digits, so relative error should be
        // small
        let expected = 1.234567890123456789e100
        let actual = result.toDouble()
        let relativeError = abs(actual - expected) / abs(expected)
        #expect(relativeError <
            1e-10) // Should be accurate to ~10 significant digits
    }

    @Test
    func cPointer_NegativeValue_ReturnsValidPointer() async throws {
        // Given: A GMPFloat initialized to a negative value
        let float = GMPFloat(-3.14)

        // When: cPointer is accessed using withCPointer
        // Then: Pointer is valid and points to the correct value
        let result = try GMPFloat(precision: float.precision)
        float.withCPointer { pointer in
            __gmpf_set(&result._storage.value, pointer)
        }
        #expect(abs(result.toDouble() - -3.14) < 0.01)
    }

    // MARK: - mutableCPointer Tests

    @Test
    func mutableCPointer_ReturnsValidMutablePointer() async throws {
        // Given: A GMPFloat initialized to 3.14
        var float = GMPFloat(3.14) // Mutated through pointer below

        // When: mutableCPointer is accessed using withMutableCPointer
        // Then: Pointer is valid and can be used to modify the value
        float.withMutableCPointer { pointer in
            __gmpf_add_ui(pointer, pointer, 1)
        }
        #expect(abs(float.toDouble() - 4.14) < 0.01)
    }

    @Test
    func mutableCPointer_ZeroValue_ReturnsValidMutablePointer() async throws {
        // Given: A GMPFloat initialized to 0.0
        var float = GMPFloat(0.0) // Mutated through pointer below

        // When: mutableCPointer is accessed and used to set a value
        float.withMutableCPointer { pointer in
            __gmpf_set_d(pointer, 42.0)
        }

        // Then: The value is updated correctly
        #expect(float.toDouble() == 42.0)
    }

    @Test
    func mutableCPointer_LargeValue_ReturnsValidMutablePointer() async throws {
        // Given: A GMPFloat initialized to a large value
        var float =
            GMPFloat(1.234567890123456789e50) // Mutated through pointer below

        // When: mutableCPointer is accessed and used to modify the value
        let one = GMPFloat(1.0)
        float.withMutableCPointer { pointer in
            __gmpf_add(pointer, pointer, &one._storage.value)
        }

        // Then: The value is updated correctly
        // For very large numbers, use relative tolerance instead of absolute
        // Double has ~15-17 significant digits, so relative error should be
        // small
        let expected = 1.234567890123456789e50 + 1.0
        let actual = float.toDouble()
        let relativeError = abs(actual - expected) / abs(expected)
        #expect(relativeError <
            1e-10) // Should be accurate to ~10 significant digits
    }

    @Test
    func mutableCPointer_NegativeValue_ReturnsValidMutablePointer(
    ) async throws {
        // Given: A GMPFloat initialized to a negative value
        var float = GMPFloat(-3.14) // Mutated through pointer below

        // When: mutableCPointer is accessed and used to modify the value
        float.withMutableCPointer { pointer in
            __gmpf_abs(pointer, pointer)
        }

        // Then: The value is updated correctly (absolute value)
        #expect(abs(float.toDouble() - 3.14) < 0.01)
    }

    @Test
    func mutableCPointer_ModificationPreservesValue() async throws {
        // Given: A GMPFloat initialized to 3.14
        var float = GMPFloat(3.14) // Mutated through pointer below
        let originalValue = float.toDouble()

        // When: mutableCPointer is accessed and used to modify, then read back
        float.withMutableCPointer { pointer in
            __gmpf_add_ui(pointer, pointer, 100)
        }
        let newValue = float.toDouble()

        // Then: The value is correctly modified
        #expect(abs(originalValue - 3.14) < 0.01)
        #expect(abs(newValue - 103.14) < 0.01)
    }
}
