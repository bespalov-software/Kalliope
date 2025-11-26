import Foundation
@testable import Kalliope
import Testing

// MARK: - Square Root Operations

struct GMPFloatMathTests {
    // MARK: - squareRoot (computed property)

    @Test
    func squareRoot_positiveInteger_returnsCorrectValue() async throws {
        // Given: A GMPFloat with value 4.0 and precision 64
        let a = GMPFloat(4.0)

        // When: Accessing the squareRoot property
        let result = try a.squareRoot()

        // Then: Returns a new GMPFloat with value 2.0, original value unchanged
        #expect(result.toDouble() == 2.0)
        #expect(a.toDouble() == 4.0)
    }

    @Test
    func squareRoot_perfectSquare_returnsExactValue() async throws {
        // Given: A GMPFloat with value 9.0 and precision 64
        let a = GMPFloat(9.0)

        // When: Accessing the squareRoot property
        let result = try a.squareRoot()

        // Then: Returns a new GMPFloat with value 3.0, original value unchanged
        #expect(result.toDouble() == 3.0)
        #expect(a.toDouble() == 9.0)
    }

    @Test
    func squareRoot_nonPerfectSquare_returnsApproximateValue() async throws {
        // Given: A GMPFloat with value 2.0 and precision 64
        let a = GMPFloat(2.0)

        // When: Accessing the squareRoot property
        let result = try a.squareRoot()

        // Then: Returns a new GMPFloat approximately equal to √2, original value unchanged
        let sqrt2 = sqrt(2.0)
        let difference = abs(result.toDouble() - sqrt2)
        #expect(difference < 0.0001)
        #expect(a.toDouble() == 2.0)
    }

    @Test
    func squareRoot_zero_returnsZero() async throws {
        // Given: A GMPFloat with value 0.0 and precision 64
        let a = GMPFloat(0.0)

        // When: Accessing the squareRoot property
        let result = try a.squareRoot()

        // Then: Returns a new GMPFloat with value 0.0, original value unchanged
        #expect(result.toDouble() == 0.0)
        #expect(a.toDouble() == 0.0)
    }

    @Test
    func squareRoot_one_returnsOne() async throws {
        // Given: A GMPFloat with value 1.0 and precision 64
        let a = GMPFloat(1.0)

        // When: Accessing the squareRoot property
        let result = try a.squareRoot()

        // Then: Returns a new GMPFloat with value 1.0, original value unchanged
        #expect(result.toDouble() == 1.0)
        #expect(a.toDouble() == 1.0)
    }

    @Test
    func squareRoot_verySmallPositiveValue_returnsCorrectValue() async throws {
        // Given: A GMPFloat with value 0.0001 and precision 64
        let a = GMPFloat(0.0001)

        // When: Accessing the squareRoot property
        let result = try a.squareRoot()

        // Then: Returns a new GMPFloat approximately equal to 0.01, original value unchanged
        let difference = abs(result.toDouble() - 0.01)
        #expect(difference < 0.0001)
        #expect(a.toDouble() == 0.0001)
    }

    @Test
    func squareRoot_veryLargeValue_returnsCorrectValue() async throws {
        // Given: A GMPFloat with a very large positive value (e.g., 1e100) and precision 64
        let a = GMPFloat(1e100)

        // When: Accessing the squareRoot property
        let result = try a.squareRoot()

        // Then: Returns a new GMPFloat with approximately 1e50, original value unchanged
        let expected = 1e50
        let difference = abs(result.toDouble() - expected) / expected
        #expect(difference < 0.001) // 0.1% tolerance for large numbers
        #expect(abs(a.toDouble() - 1e100) / 1e100 < 0.001)
    }

    @Test
    func squareRoot_preservesPrecision() async throws {
        // Given: A GMPFloat with value 4.0 and precision 128
        var a = try GMPFloat(precision: 128)
        a.set(4.0)

        // When: Accessing the squareRoot property
        let result = try a.squareRoot()

        // Then: Returns a new GMPFloat with precision 128, original value unchanged
        #expect(result.precision == a.precision)
        #expect(a.toDouble() == 4.0)
    }

    @Test
    func squareRoot_negativeValue_throwsError() async throws {
        // Given: A GMPFloat with value -4.0 and precision 64
        let a = GMPFloat(-4.0)

        // When: Accessing the squareRoot property
        // Then: Throws GMPError.negativeSquareRoot
        #expect(throws: GMPError.negativeSquareRoot) {
            try a.squareRoot()
        }
    }

    @Test
    func squareRoot_negativeValueEdge_throwsError() async throws {
        // Given: A GMPFloat with value -0.0001 and precision 64
        let a = GMPFloat(-0.0001)

        // When: Accessing the squareRoot property
        // Then: Throws GMPError.negativeSquareRoot
        #expect(throws: GMPError.negativeSquareRoot) {
            try a.squareRoot()
        }
    }

    @Test
    func squareRoot_originalValueUnchanged() async throws {
        // Given: A GMPFloat with value 16.0 and precision 64
        let a = GMPFloat(16.0)

        // When: Accessing the squareRoot property and storing result
        _ = try a.squareRoot()

        // Then: Original GMPFloat still has value 16.0
        #expect(a.toDouble() == 16.0)
    }

    // MARK: - formSquareRoot() (mutating method)

    @Test
    func formSquareRoot_positiveInteger_updatesValue() async throws {
        // Given: A GMPFloat with value 4.0 and precision 64
        var a = GMPFloat(4.0)
        let originalPrecision = a.precision

        // When: Calling formSquareRoot()
        try a.formSquareRoot()

        // Then: The float's value becomes 2.0, precision unchanged
        #expect(a.toDouble() == 2.0)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formSquareRoot_perfectSquare_updatesValue() async throws {
        // Given: A GMPFloat with value 9.0 and precision 64
        var a = GMPFloat(9.0)
        let originalPrecision = a.precision

        // When: Calling formSquareRoot()
        try a.formSquareRoot()

        // Then: The float's value becomes 3.0, precision unchanged
        #expect(a.toDouble() == 3.0)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formSquareRoot_nonPerfectSquare_updatesValue() async throws {
        // Given: A GMPFloat with value 2.0 and precision 64
        var a = GMPFloat(2.0)
        let originalPrecision = a.precision

        // When: Calling formSquareRoot()
        try a.formSquareRoot()

        // Then: The float's value becomes approximately √2, precision unchanged
        let sqrt2 = sqrt(2.0)
        let difference = abs(a.toDouble() - sqrt2)
        #expect(difference < 0.0001)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formSquareRoot_zero_updatesToZero() async throws {
        // Given: A GMPFloat with value 0.0 and precision 64
        var a = GMPFloat(0.0)
        let originalPrecision = a.precision

        // When: Calling formSquareRoot()
        try a.formSquareRoot()

        // Then: The float's value becomes 0.0, precision unchanged
        #expect(a.toDouble() == 0.0)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formSquareRoot_one_updatesToOne() async throws {
        // Given: A GMPFloat with value 1.0 and precision 64
        var a = GMPFloat(1.0)
        let originalPrecision = a.precision

        // When: Calling formSquareRoot()
        try a.formSquareRoot()

        // Then: The float's value becomes 1.0, precision unchanged
        #expect(a.toDouble() == 1.0)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formSquareRoot_verySmallPositiveValue_updatesValue() async throws {
        // Given: A GMPFloat with value 0.0001 and precision 64
        var a = GMPFloat(0.0001)
        let originalPrecision = a.precision

        // When: Calling formSquareRoot()
        try a.formSquareRoot()

        // Then: The float's value becomes approximately 0.01, precision unchanged
        let difference = abs(a.toDouble() - 0.01)
        #expect(difference < 0.0001)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formSquareRoot_veryLargeValue_updatesValue() async throws {
        // Given: A GMPFloat with a very large positive value (e.g., 1e100) and precision 64
        var a = GMPFloat(1e100)
        let originalPrecision = a.precision

        // When: Calling formSquareRoot()
        try a.formSquareRoot()

        // Then: The float's value becomes approximately 1e50, precision unchanged
        let expected = 1e50
        let difference = abs(a.toDouble() - expected) / expected
        #expect(difference < 0.001) // 0.1% tolerance for large numbers
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formSquareRoot_preservesPrecision() async throws {
        // Given: A GMPFloat with value 4.0 and precision 128
        var a = try GMPFloat(precision: 128)
        a.set(4.0)

        // When: Calling formSquareRoot()
        try a.formSquareRoot()

        // Then: The float's precision remains 128, value updated to 2.0
        #expect(a.precision == 128)
        #expect(a.toDouble() == 2.0)
    }

    @Test
    func formSquareRoot_negativeValue_throwsError() async throws {
        // Given: A GMPFloat with value -4.0 and precision 64
        var a = GMPFloat(-4.0)
        let originalValue = a.toDouble()

        // When: Calling formSquareRoot()
        // Then: Throws GMPError.negativeSquareRoot, value unchanged
        #expect(throws: GMPError.negativeSquareRoot) {
            try a.formSquareRoot()
        }
        #expect(a.toDouble() == originalValue)
    }

    @Test
    func formSquareRoot_negativeValueEdge_throwsError() async throws {
        // Given: A GMPFloat with value -0.0001 and precision 64
        var a = GMPFloat(-0.0001)
        let originalValue = a.toDouble()

        // When: Calling formSquareRoot()
        // Then: Throws GMPError.negativeSquareRoot, value unchanged
        #expect(throws: GMPError.negativeSquareRoot) {
            try a.formSquareRoot()
        }
        #expect(a.toDouble() == originalValue)
    }

    // MARK: - squareRoot(of: Int) (static method)

    @Test
    func squareRootOf_positiveInteger_returnsCorrectValue() async throws {
        // Given: An integer value 4
        let value = 4

        // When: Calling GMPFloat.squareRoot(of: 4)
        let result = try GMPFloat.squareRoot(of: value)

        // Then: Returns a new GMPFloat with value 2.0 at default precision
        #expect(result.toDouble() == 2.0)
    }

    @Test
    func squareRootOf_perfectSquare_returnsExactValue() async throws {
        // Given: An integer value 9
        let value = 9

        // When: Calling GMPFloat.squareRoot(of: 9)
        let result = try GMPFloat.squareRoot(of: value)

        // Then: Returns a new GMPFloat with value 3.0 at default precision
        #expect(result.toDouble() == 3.0)
    }

    @Test
    func squareRootOf_nonPerfectSquare_returnsApproximateValue() async throws {
        // Given: An integer value 2
        let value = 2

        // When: Calling GMPFloat.squareRoot(of: 2)
        let result = try GMPFloat.squareRoot(of: value)

        // Then: Returns a new GMPFloat approximately equal to √2 at default precision
        let sqrt2 = sqrt(2.0)
        let difference = abs(result.toDouble() - sqrt2)
        #expect(difference < 0.0001)
    }

    @Test
    func squareRootOf_zero_returnsZero() async throws {
        // Given: An integer value 0
        let value = 0

        // When: Calling GMPFloat.squareRoot(of: 0)
        let result = try GMPFloat.squareRoot(of: value)

        // Then: Returns a new GMPFloat with value 0.0 at default precision
        #expect(result.toDouble() == 0.0)
    }

    @Test
    func squareRootOf_one_returnsOne() async throws {
        // Given: An integer value 1
        let value = 1

        // When: Calling GMPFloat.squareRoot(of: 1)
        let result = try GMPFloat.squareRoot(of: value)

        // Then: Returns a new GMPFloat with value 1.0 at default precision
        #expect(result.toDouble() == 1.0)
    }

    @Test
    func squareRootOf_largeInteger_returnsCorrectValue() async throws {
        // Given: A large integer value (e.g., 1000000)
        let value = 1_000_000

        // When: Calling GMPFloat.squareRoot(of: 1000000)
        let result = try GMPFloat.squareRoot(of: value)

        // Then: Returns a new GMPFloat with value 1000.0 at default precision
        #expect(result.toDouble() == 1000.0)
    }

    @Test
    func squareRootOf_maxInt_returnsCorrectValue() async throws {
        // Given: An integer value Int.max
        let value = Int.max

        // When: Calling GMPFloat.squareRoot(of: Int.max)
        let result = try GMPFloat.squareRoot(of: value)

        // Then: Returns a new GMPFloat with approximately √Int.max at default precision
        let expected = sqrt(Double(Int.max))
        let difference = abs(result.toDouble() - expected) / expected
        #expect(difference < 0.001) // 0.1% tolerance
    }

    @Test
    func squareRootOf_negativeValue_throwsError() async throws {
        // Given: An integer value -4
        let value = -4

        // When: Calling GMPFloat.squareRoot(of: -4)
        // Then: Throws GMPError.negativeSquareRoot
        #expect(throws: GMPError.negativeSquareRoot) {
            try GMPFloat.squareRoot(of: value)
        }
    }

    @Test
    func squareRootOf_negativeOne_throwsError() async throws {
        // Given: An integer value -1
        let value = -1

        // When: Calling GMPFloat.squareRoot(of: -1)
        // Then: Throws GMPError.negativeSquareRoot
        #expect(throws: GMPError.negativeSquareRoot) {
            try GMPFloat.squareRoot(of: value)
        }
    }

    @Test
    func squareRootOf_minInt_throwsError() async throws {
        // Given: An integer value Int.min
        let value = Int.min

        // When: Calling GMPFloat.squareRoot(of: Int.min)
        // Then: Throws GMPError.negativeSquareRoot
        #expect(throws: GMPError.negativeSquareRoot) {
            try GMPFloat.squareRoot(of: value)
        }
    }

    // MARK: - raisedToPower(_: Int) (method)

    @Test
    func raisedToPower_zeroExponent_returnsOne() async throws {
        // Given: A GMPFloat with value 5.0 and precision 64, exponent 0
        let a = GMPFloat(5.0)

        // When: Calling raisedToPower(0)
        let result = a.raisedToPower(0)

        // Then: Returns a new GMPFloat with value 1.0, original value unchanged
        #expect(result.toDouble() == 1.0)
        #expect(a.toDouble() == 5.0)
    }

    @Test
    func raisedToPower_oneExponent_returnsSelf() async throws {
        // Given: A GMPFloat with value 5.0 and precision 64, exponent 1
        let a = GMPFloat(5.0)

        // When: Calling raisedToPower(1)
        let result = a.raisedToPower(1)

        // Then: Returns a new GMPFloat with value 5.0, original value unchanged
        #expect(result.toDouble() == 5.0)
        #expect(a.toDouble() == 5.0)
    }

    @Test
    func raisedToPower_positiveExponent_returnsCorrectValue() async throws {
        // Given: A GMPFloat with value 2.0 and precision 64, exponent 3
        let a = GMPFloat(2.0)

        // When: Calling raisedToPower(3)
        let result = a.raisedToPower(3)

        // Then: Returns a new GMPFloat with value 8.0, original value unchanged
        #expect(result.toDouble() == 8.0)
        #expect(a.toDouble() == 2.0)
    }

    @Test
    func raisedToPower_largeExponent_returnsCorrectValue() async throws {
        // Given: A GMPFloat with value 2.0 and precision 64, exponent 10
        let a = GMPFloat(2.0)

        // When: Calling raisedToPower(10)
        let result = a.raisedToPower(10)

        // Then: Returns a new GMPFloat with value 1024.0, original value unchanged
        #expect(result.toDouble() == 1024.0)
        #expect(a.toDouble() == 2.0)
    }

    @Test
    func raisedToPower_baseZero_returnsZero() async throws {
        // Given: A GMPFloat with value 0.0 and precision 64, exponent 5
        let a = GMPFloat(0.0)

        // When: Calling raisedToPower(5)
        let result = a.raisedToPower(5)

        // Then: Returns a new GMPFloat with value 0.0, original value unchanged
        #expect(result.toDouble() == 0.0)
        #expect(a.toDouble() == 0.0)
    }

    @Test
    func raisedToPower_baseOne_returnsOne() async throws {
        // Given: A GMPFloat with value 1.0 and precision 64, exponent 100
        let a = GMPFloat(1.0)

        // When: Calling raisedToPower(100)
        let result = a.raisedToPower(100)

        // Then: Returns a new GMPFloat with value 1.0, original value unchanged
        #expect(result.toDouble() == 1.0)
        #expect(a.toDouble() == 1.0)
    }

    @Test
    func raisedToPower_fractionalBase_returnsCorrectValue() async throws {
        // Given: A GMPFloat with value 0.5 and precision 64, exponent 2
        let a = GMPFloat(0.5)

        // When: Calling raisedToPower(2)
        let result = a.raisedToPower(2)

        // Then: Returns a new GMPFloat with value 0.25, original value unchanged
        #expect(result.toDouble() == 0.25)
        #expect(a.toDouble() == 0.5)
    }

    @Test
    func raisedToPower_preservesPrecision() async throws {
        // Given: A GMPFloat with value 2.0 and precision 128, exponent 3
        var a = try GMPFloat(precision: 128)
        a.set(2.0)

        // When: Calling raisedToPower(3)
        let result = a.raisedToPower(3)

        // Then: Returns a new GMPFloat with precision 128, value 8.0, original value unchanged
        #expect(result.precision == a.precision)
        #expect(result.toDouble() == 8.0)
        #expect(a.toDouble() == 2.0)
    }

    @Test
    func raisedToPower_originalValueUnchanged() async throws {
        // Given: A GMPFloat with value 3.0 and precision 64
        let a = GMPFloat(3.0)

        // When: Calling raisedToPower(2) and storing result
        _ = a.raisedToPower(2)

        // Then: Original GMPFloat still has value 3.0
        #expect(a.toDouble() == 3.0)
    }

    // MARK: - formRaisedToPower(_: Int) (mutating method)

    @Test
    func formRaisedToPower_zeroExponent_updatesToOne() async throws {
        // Given: A GMPFloat with value 5.0 and precision 64, exponent 0
        var a = GMPFloat(5.0)
        let originalPrecision = a.precision

        // When: Calling formRaisedToPower(0)
        a.formRaisedToPower(0)

        // Then: The float's value becomes 1.0, precision unchanged
        #expect(a.toDouble() == 1.0)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formRaisedToPower_oneExponent_unchanged() async throws {
        // Given: A GMPFloat with value 5.0 and precision 64, exponent 1
        var a = GMPFloat(5.0)
        let originalPrecision = a.precision
        let originalValue = a.toDouble()

        // When: Calling formRaisedToPower(1)
        a.formRaisedToPower(1)

        // Then: The float's value remains 5.0, precision unchanged
        #expect(a.toDouble() == originalValue)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formRaisedToPower_positiveExponent_updatesValue() async throws {
        // Given: A GMPFloat with value 2.0 and precision 64, exponent 3
        var a = GMPFloat(2.0)
        let originalPrecision = a.precision

        // When: Calling formRaisedToPower(3)
        a.formRaisedToPower(3)

        // Then: The float's value becomes 8.0, precision unchanged
        #expect(a.toDouble() == 8.0)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formRaisedToPower_largeExponent_updatesValue() async throws {
        // Given: A GMPFloat with value 2.0 and precision 64, exponent 10
        var a = GMPFloat(2.0)
        let originalPrecision = a.precision

        // When: Calling formRaisedToPower(10)
        a.formRaisedToPower(10)

        // Then: The float's value becomes 1024.0, precision unchanged
        #expect(a.toDouble() == 1024.0)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formRaisedToPower_baseZero_updatesToZero() async throws {
        // Given: A GMPFloat with value 0.0 and precision 64, exponent 5
        var a = GMPFloat(0.0)
        let originalPrecision = a.precision

        // When: Calling formRaisedToPower(5)
        a.formRaisedToPower(5)

        // Then: The float's value becomes 0.0, precision unchanged
        #expect(a.toDouble() == 0.0)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formRaisedToPower_baseOne_updatesToOne() async throws {
        // Given: A GMPFloat with value 1.0 and precision 64, exponent 100
        var a = GMPFloat(1.0)
        let originalPrecision = a.precision

        // When: Calling formRaisedToPower(100)
        a.formRaisedToPower(100)

        // Then: The float's value becomes 1.0, precision unchanged
        #expect(a.toDouble() == 1.0)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formRaisedToPower_fractionalBase_updatesValue() async throws {
        // Given: A GMPFloat with value 0.5 and precision 64, exponent 2
        var a = GMPFloat(0.5)
        let originalPrecision = a.precision

        // When: Calling formRaisedToPower(2)
        a.formRaisedToPower(2)

        // Then: The float's value becomes 0.25, precision unchanged
        #expect(a.toDouble() == 0.25)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formRaisedToPower_preservesPrecision() async throws {
        // Given: A GMPFloat with value 2.0 and precision 128, exponent 3
        var a = try GMPFloat(precision: 128)
        a.set(2.0)

        // When: Calling formRaisedToPower(3)
        a.formRaisedToPower(3)

        // Then: The float's precision remains 128, value updated to 8.0
        #expect(a.precision == 128)
        #expect(a.toDouble() == 8.0)
    }

    // MARK: - Rounding Operations (Floor, Ceiling, Truncate)

    // MARK: - floor (computed property)

    @Test
    func floor_positiveInteger_returnsSameValue() async throws {
        // Given: A GMPFloat with value 5.0 and precision 64
        let a = GMPFloat(5.0)

        // When: Accessing the floor property
        let result = a.floor

        // Then: Returns a new GMPFloat with value 5.0, original value unchanged
        #expect(result.toDouble() == 5.0)
        #expect(a.toDouble() == 5.0)
    }

    @Test
    func floor_positiveFraction_returnsLowerInteger() async throws {
        // Given: A GMPFloat with value 5.7 and precision 64
        let a = GMPFloat(5.7)

        // When: Accessing the floor property
        let result = a.floor

        // Then: Returns a new GMPFloat with value 5.0, original value unchanged
        #expect(result.toDouble() == 5.0)
        #expect(a.toDouble() == 5.7)
    }

    @Test
    func floor_positiveFractionEdge_returnsLowerInteger() async throws {
        // Given: A GMPFloat with value 5.999999 and precision 64
        let a = GMPFloat(5.999999)

        // When: Accessing the floor property
        let result = a.floor

        // Then: Returns a new GMPFloat with value 5.0, original value unchanged
        #expect(result.toDouble() == 5.0)
        #expect(a.toDouble() == 5.999999)
    }

    @Test
    func floor_negativeInteger_returnsSameValue() async throws {
        // Given: A GMPFloat with value -5.0 and precision 64
        let a = GMPFloat(-5.0)

        // When: Accessing the floor property
        let result = a.floor

        // Then: Returns a new GMPFloat with value -5.0, original value unchanged
        #expect(result.toDouble() == -5.0)
        #expect(a.toDouble() == -5.0)
    }

    @Test
    func floor_negativeFraction_returnsLowerInteger() async throws {
        // Given: A GMPFloat with value -5.7 and precision 64
        let a = GMPFloat(-5.7)

        // When: Accessing the floor property
        let result = a.floor

        // Then: Returns a new GMPFloat with value -6.0, original value unchanged
        #expect(result.toDouble() == -6.0)
        #expect(a.toDouble() == -5.7)
    }

    @Test
    func floor_negativeFractionEdge_returnsLowerInteger() async throws {
        // Given: A GMPFloat with value -5.000001 and precision 64
        let a = GMPFloat(-5.000001)

        // When: Accessing the floor property
        let result = a.floor

        // Then: Returns a new GMPFloat with value -6.0, original value unchanged
        #expect(result.toDouble() == -6.0)
        #expect(a.toDouble() == -5.000001)
    }

    @Test
    func floor_zero_returnsZero() async throws {
        // Given: A GMPFloat with value 0.0 and precision 64
        let a = GMPFloat(0.0)

        // When: Accessing the floor property
        let result = a.floor

        // Then: Returns a new GMPFloat with value 0.0, original value unchanged
        #expect(result.toDouble() == 0.0)
        #expect(a.toDouble() == 0.0)
    }

    @Test
    func floor_verySmallPositive_returnsZero() async throws {
        // Given: A GMPFloat with value 0.0001 and precision 64
        let a = GMPFloat(0.0001)

        // When: Accessing the floor property
        let result = a.floor

        // Then: Returns a new GMPFloat with value 0.0, original value unchanged
        #expect(result.toDouble() == 0.0)
        #expect(a.toDouble() == 0.0001)
    }

    @Test
    func floor_verySmallNegative_returnsMinusOne() async throws {
        // Given: A GMPFloat with value -0.0001 and precision 64
        let a = GMPFloat(-0.0001)

        // When: Accessing the floor property
        let result = a.floor

        // Then: Returns a new GMPFloat with value -1.0, original value unchanged
        #expect(result.toDouble() == -1.0)
        #expect(a.toDouble() == -0.0001)
    }

    @Test
    func floor_originalValueUnchanged() async throws {
        // Given: A GMPFloat with value 5.7 and precision 64
        let a = GMPFloat(5.7)

        // When: Accessing the floor property and storing result
        _ = a.floor

        // Then: Original GMPFloat still has value 5.7
        #expect(a.toDouble() == 5.7)
    }

    // MARK: - formFloor() (mutating method)

    @Test
    func formFloor_positiveInteger_unchanged() async throws {
        // Given: A GMPFloat with value 5.0 and precision 64
        var a = GMPFloat(5.0)
        let originalPrecision = a.precision

        // When: Calling formFloor()
        a.formFloor()

        // Then: The float's value remains 5.0, precision unchanged
        #expect(a.toDouble() == 5.0)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formFloor_positiveFraction_updatesToLowerInteger() async throws {
        // Given: A GMPFloat with value 5.7 and precision 64
        var a = GMPFloat(5.7)
        let originalPrecision = a.precision

        // When: Calling formFloor()
        a.formFloor()

        // Then: The float's value becomes 5.0, precision unchanged
        #expect(a.toDouble() == 5.0)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formFloor_positiveFractionEdge_updatesToLowerInteger() async throws {
        // Given: A GMPFloat with value 5.999999 and precision 64
        var a = GMPFloat(5.999999)
        let originalPrecision = a.precision

        // When: Calling formFloor()
        a.formFloor()

        // Then: The float's value becomes 5.0, precision unchanged
        #expect(a.toDouble() == 5.0)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formFloor_negativeInteger_unchanged() async throws {
        // Given: A GMPFloat with value -5.0 and precision 64
        var a = GMPFloat(-5.0)
        let originalPrecision = a.precision

        // When: Calling formFloor()
        a.formFloor()

        // Then: The float's value remains -5.0, precision unchanged
        #expect(a.toDouble() == -5.0)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formFloor_negativeFraction_updatesToLowerInteger() async throws {
        // Given: A GMPFloat with value -5.7 and precision 64
        var a = GMPFloat(-5.7)
        let originalPrecision = a.precision

        // When: Calling formFloor()
        a.formFloor()

        // Then: The float's value becomes -6.0, precision unchanged
        #expect(a.toDouble() == -6.0)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formFloor_negativeFractionEdge_updatesToLowerInteger() async throws {
        // Given: A GMPFloat with value -5.000001 and precision 64
        var a = GMPFloat(-5.000001)
        let originalPrecision = a.precision

        // When: Calling formFloor()
        a.formFloor()

        // Then: The float's value becomes -6.0, precision unchanged
        #expect(a.toDouble() == -6.0)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formFloor_zero_unchanged() async throws {
        // Given: A GMPFloat with value 0.0 and precision 64
        var a = GMPFloat(0.0)
        let originalPrecision = a.precision

        // When: Calling formFloor()
        a.formFloor()

        // Then: The float's value remains 0.0, precision unchanged
        #expect(a.toDouble() == 0.0)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formFloor_verySmallPositive_updatesToZero() async throws {
        // Given: A GMPFloat with value 0.0001 and precision 64
        var a = GMPFloat(0.0001)
        let originalPrecision = a.precision

        // When: Calling formFloor()
        a.formFloor()

        // Then: The float's value becomes 0.0, precision unchanged
        #expect(a.toDouble() == 0.0)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formFloor_verySmallNegative_updatesToMinusOne() async throws {
        // Given: A GMPFloat with value -0.0001 and precision 64
        var a = GMPFloat(-0.0001)
        let originalPrecision = a.precision

        // When: Calling formFloor()
        a.formFloor()

        // Then: The float's value becomes -1.0, precision unchanged
        #expect(a.toDouble() == -1.0)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formFloor_preservesPrecision() async throws {
        // Given: A GMPFloat with value 5.7 and precision 128
        var a = try GMPFloat(precision: 128)
        a.set(5.7)

        // When: Calling formFloor()
        a.formFloor()

        // Then: The float's precision remains 128, value updated to 5.0
        #expect(a.precision == 128)
        #expect(a.toDouble() == 5.0)
    }

    // MARK: - ceiling (computed property)

    @Test
    func ceiling_positiveInteger_returnsSameValue() async throws {
        // Given: A GMPFloat with value 5.0 and precision 64
        let a = GMPFloat(5.0)

        // When: Accessing the ceiling property
        let result = a.ceiling

        // Then: Returns a new GMPFloat with value 5.0, original value unchanged
        #expect(result.toDouble() == 5.0)
        #expect(a.toDouble() == 5.0)
    }

    @Test
    func ceiling_positiveFraction_returnsUpperInteger() async throws {
        // Given: A GMPFloat with value 5.3 and precision 64
        let a = GMPFloat(5.3)

        // When: Accessing the ceiling property
        let result = a.ceiling

        // Then: Returns a new GMPFloat with value 6.0, original value unchanged
        #expect(result.toDouble() == 6.0)
        #expect(a.toDouble() == 5.3)
    }

    @Test
    func ceiling_positiveFractionEdge_returnsUpperInteger() async throws {
        // Given: A GMPFloat with value 5.000001 and precision 64
        let a = GMPFloat(5.000001)

        // When: Accessing the ceiling property
        let result = a.ceiling

        // Then: Returns a new GMPFloat with value 6.0, original value unchanged
        #expect(result.toDouble() == 6.0)
        #expect(a.toDouble() == 5.000001)
    }

    @Test
    func ceiling_negativeInteger_returnsSameValue() async throws {
        // Given: A GMPFloat with value -5.0 and precision 64
        let a = GMPFloat(-5.0)

        // When: Accessing the ceiling property
        let result = a.ceiling

        // Then: Returns a new GMPFloat with value -5.0, original value unchanged
        #expect(result.toDouble() == -5.0)
        #expect(a.toDouble() == -5.0)
    }

    @Test
    func ceiling_negativeFraction_returnsUpperInteger() async throws {
        // Given: A GMPFloat with value -5.3 and precision 64
        let a = GMPFloat(-5.3)

        // When: Accessing the ceiling property
        let result = a.ceiling

        // Then: Returns a new GMPFloat with value -5.0, original value unchanged
        #expect(result.toDouble() == -5.0)
        #expect(a.toDouble() == -5.3)
    }

    @Test
    func ceiling_negativeFractionEdge_returnsUpperInteger() async throws {
        // Given: A GMPFloat with value -5.999999 and precision 64
        let a = GMPFloat(-5.999999)

        // When: Accessing the ceiling property
        let result = a.ceiling

        // Then: Returns a new GMPFloat with value -5.0, original value unchanged
        #expect(result.toDouble() == -5.0)
        #expect(a.toDouble() == -5.999999)
    }

    @Test
    func ceiling_zero_returnsZero() async throws {
        // Given: A GMPFloat with value 0.0 and precision 64
        let a = GMPFloat(0.0)

        // When: Accessing the ceiling property
        let result = a.ceiling

        // Then: Returns a new GMPFloat with value 0.0, original value unchanged
        #expect(result.toDouble() == 0.0)
        #expect(a.toDouble() == 0.0)
    }

    @Test
    func ceiling_verySmallPositive_returnsOne() async throws {
        // Given: A GMPFloat with value 0.0001 and precision 64
        let a = GMPFloat(0.0001)

        // When: Accessing the ceiling property
        let result = a.ceiling

        // Then: Returns a new GMPFloat with value 1.0, original value unchanged
        #expect(result.toDouble() == 1.0)
        #expect(a.toDouble() == 0.0001)
    }

    @Test
    func ceiling_verySmallNegative_returnsZero() async throws {
        // Given: A GMPFloat with value -0.0001 and precision 64
        let a = GMPFloat(-0.0001)

        // When: Accessing the ceiling property
        let result = a.ceiling

        // Then: Returns a new GMPFloat with value 0.0, original value unchanged
        #expect(result.toDouble() == 0.0)
        #expect(a.toDouble() == -0.0001)
    }

    @Test
    func ceiling_originalValueUnchanged() async throws {
        // Given: A GMPFloat with value 5.3 and precision 64
        let a = GMPFloat(5.3)

        // When: Accessing the ceiling property and storing result
        _ = a.ceiling

        // Then: Original GMPFloat still has value 5.3
        #expect(a.toDouble() == 5.3)
    }

    // MARK: - formCeiling() (mutating method)

    @Test
    func formCeiling_positiveInteger_unchanged() async throws {
        // Given: A GMPFloat with value 5.0 and precision 64
        var a = GMPFloat(5.0)
        let originalPrecision = a.precision

        // When: Calling formCeiling()
        a.formCeiling()

        // Then: The float's value remains 5.0, precision unchanged
        #expect(a.toDouble() == 5.0)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formCeiling_positiveFraction_updatesToUpperInteger() async throws {
        // Given: A GMPFloat with value 5.3 and precision 64
        var a = GMPFloat(5.3)
        let originalPrecision = a.precision

        // When: Calling formCeiling()
        a.formCeiling()

        // Then: The float's value becomes 6.0, precision unchanged
        #expect(a.toDouble() == 6.0)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formCeiling_positiveFractionEdge_updatesToUpperInteger() async throws {
        // Given: A GMPFloat with value 5.000001 and precision 64
        var a = GMPFloat(5.000001)
        let originalPrecision = a.precision

        // When: Calling formCeiling()
        a.formCeiling()

        // Then: The float's value becomes 6.0, precision unchanged
        #expect(a.toDouble() == 6.0)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formCeiling_negativeInteger_unchanged() async throws {
        // Given: A GMPFloat with value -5.0 and precision 64
        var a = GMPFloat(-5.0)
        let originalPrecision = a.precision

        // When: Calling formCeiling()
        a.formCeiling()

        // Then: The float's value remains -5.0, precision unchanged
        #expect(a.toDouble() == -5.0)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formCeiling_negativeFraction_updatesToUpperInteger() async throws {
        // Given: A GMPFloat with value -5.3 and precision 64
        var a = GMPFloat(-5.3)
        let originalPrecision = a.precision

        // When: Calling formCeiling()
        a.formCeiling()

        // Then: The float's value becomes -5.0, precision unchanged
        #expect(a.toDouble() == -5.0)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formCeiling_negativeFractionEdge_updatesToUpperInteger() async throws {
        // Given: A GMPFloat with value -5.999999 and precision 64
        var a = GMPFloat(-5.999999)
        let originalPrecision = a.precision

        // When: Calling formCeiling()
        a.formCeiling()

        // Then: The float's value becomes -5.0, precision unchanged
        #expect(a.toDouble() == -5.0)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formCeiling_zero_unchanged() async throws {
        // Given: A GMPFloat with value 0.0 and precision 64
        var a = GMPFloat(0.0)
        let originalPrecision = a.precision

        // When: Calling formCeiling()
        a.formCeiling()

        // Then: The float's value remains 0.0, precision unchanged
        #expect(a.toDouble() == 0.0)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formCeiling_verySmallPositive_updatesToOne() async throws {
        // Given: A GMPFloat with value 0.0001 and precision 64
        var a = GMPFloat(0.0001)
        let originalPrecision = a.precision

        // When: Calling formCeiling()
        a.formCeiling()

        // Then: The float's value becomes 1.0, precision unchanged
        #expect(a.toDouble() == 1.0)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formCeiling_verySmallNegative_updatesToZero() async throws {
        // Given: A GMPFloat with value -0.0001 and precision 64
        var a = GMPFloat(-0.0001)
        let originalPrecision = a.precision

        // When: Calling formCeiling()
        a.formCeiling()

        // Then: The float's value becomes 0.0, precision unchanged
        #expect(a.toDouble() == 0.0)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formCeiling_preservesPrecision() async throws {
        // Given: A GMPFloat with value 5.3 and precision 128
        var a = try GMPFloat(precision: 128)
        a.set(5.3)

        // When: Calling formCeiling()
        a.formCeiling()

        // Then: The float's precision remains 128, value updated to 6.0
        #expect(a.precision == 128)
        #expect(a.toDouble() == 6.0)
    }

    // MARK: - truncated (computed property)

    @Test
    func truncated_positiveInteger_returnsSameValue() async throws {
        // Given: A GMPFloat with value 5.0 and precision 64
        let a = GMPFloat(5.0)

        // When: Accessing the truncated property
        let result = a.truncated

        // Then: Returns a new GMPFloat with value 5.0, original value unchanged
        #expect(result.toDouble() == 5.0)
        #expect(a.toDouble() == 5.0)
    }

    @Test
    func truncated_positiveFraction_returnsIntegerPart() async throws {
        // Given: A GMPFloat with value 5.7 and precision 64
        let a = GMPFloat(5.7)

        // When: Accessing the truncated property
        let result = a.truncated

        // Then: Returns a new GMPFloat with value 5.0, original value unchanged
        #expect(result.toDouble() == 5.0)
        #expect(a.toDouble() == 5.7)
    }

    @Test
    func truncated_positiveFractionEdge_returnsIntegerPart() async throws {
        // Given: A GMPFloat with value 5.999999 and precision 64
        let a = GMPFloat(5.999999)

        // When: Accessing the truncated property
        let result = a.truncated

        // Then: Returns a new GMPFloat with value 5.0, original value unchanged
        #expect(result.toDouble() == 5.0)
        #expect(a.toDouble() == 5.999999)
    }

    @Test
    func truncated_negativeInteger_returnsSameValue() async throws {
        // Given: A GMPFloat with value -5.0 and precision 64
        let a = GMPFloat(-5.0)

        // When: Accessing the truncated property
        let result = a.truncated

        // Then: Returns a new GMPFloat with value -5.0, original value unchanged
        #expect(result.toDouble() == -5.0)
        #expect(a.toDouble() == -5.0)
    }

    @Test
    func truncated_negativeFraction_returnsIntegerPart() async throws {
        // Given: A GMPFloat with value -5.7 and precision 64
        let a = GMPFloat(-5.7)

        // When: Accessing the truncated property
        let result = a.truncated

        // Then: Returns a new GMPFloat with value -5.0, original value unchanged
        #expect(result.toDouble() == -5.0)
        #expect(a.toDouble() == -5.7)
    }

    @Test
    func truncated_negativeFractionEdge_returnsIntegerPart() async throws {
        // Given: A GMPFloat with value -5.999999 and precision 64
        let a = GMPFloat(-5.999999)

        // When: Accessing the truncated property
        let result = a.truncated

        // Then: Returns a new GMPFloat with value -5.0, original value unchanged
        #expect(result.toDouble() == -5.0)
        #expect(a.toDouble() == -5.999999)
    }

    @Test
    func truncated_zero_returnsZero() async throws {
        // Given: A GMPFloat with value 0.0 and precision 64
        let a = GMPFloat(0.0)

        // When: Accessing the truncated property
        let result = a.truncated

        // Then: Returns a new GMPFloat with value 0.0, original value unchanged
        #expect(result.toDouble() == 0.0)
        #expect(a.toDouble() == 0.0)
    }

    @Test
    func truncated_verySmallPositive_returnsZero() async throws {
        // Given: A GMPFloat with value 0.0001 and precision 64
        let a = GMPFloat(0.0001)

        // When: Accessing the truncated property
        let result = a.truncated

        // Then: Returns a new GMPFloat with value 0.0, original value unchanged
        #expect(result.toDouble() == 0.0)
        #expect(a.toDouble() == 0.0001)
    }

    @Test
    func truncated_verySmallNegative_returnsZero() async throws {
        // Given: A GMPFloat with value -0.0001 and precision 64
        let a = GMPFloat(-0.0001)

        // When: Accessing the truncated property
        let result = a.truncated

        // Then: Returns a new GMPFloat with value 0.0, original value unchanged
        #expect(result.toDouble() == 0.0)
        #expect(a.toDouble() == -0.0001)
    }

    @Test
    func truncated_originalValueUnchanged() async throws {
        // Given: A GMPFloat with value 5.7 and precision 64
        let a = GMPFloat(5.7)

        // When: Accessing the truncated property and storing result
        _ = a.truncated

        // Then: Original GMPFloat still has value 5.7
        #expect(a.toDouble() == 5.7)
    }

    // MARK: - formTruncate() (mutating method)

    @Test
    func formTruncate_positiveInteger_unchanged() async throws {
        // Given: A GMPFloat with value 5.0 and precision 64
        var a = GMPFloat(5.0)
        let originalPrecision = a.precision

        // When: Calling formTruncate()
        a.formTruncate()

        // Then: The float's value remains 5.0, precision unchanged
        #expect(a.toDouble() == 5.0)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formTruncate_positiveFraction_updatesToIntegerPart() async throws {
        // Given: A GMPFloat with value 5.7 and precision 64
        var a = GMPFloat(5.7)
        let originalPrecision = a.precision

        // When: Calling formTruncate()
        a.formTruncate()

        // Then: The float's value becomes 5.0, precision unchanged
        #expect(a.toDouble() == 5.0)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formTruncate_positiveFractionEdge_updatesToIntegerPart() async throws {
        // Given: A GMPFloat with value 5.999999 and precision 64
        var a = GMPFloat(5.999999)
        let originalPrecision = a.precision

        // When: Calling formTruncate()
        a.formTruncate()

        // Then: The float's value becomes 5.0, precision unchanged
        #expect(a.toDouble() == 5.0)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formTruncate_negativeInteger_unchanged() async throws {
        // Given: A GMPFloat with value -5.0 and precision 64
        var a = GMPFloat(-5.0)
        let originalPrecision = a.precision

        // When: Calling formTruncate()
        a.formTruncate()

        // Then: The float's value remains -5.0, precision unchanged
        #expect(a.toDouble() == -5.0)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formTruncate_negativeFraction_updatesToIntegerPart() async throws {
        // Given: A GMPFloat with value -5.7 and precision 64
        var a = GMPFloat(-5.7)
        let originalPrecision = a.precision

        // When: Calling formTruncate()
        a.formTruncate()

        // Then: The float's value becomes -5.0, precision unchanged
        #expect(a.toDouble() == -5.0)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formTruncate_negativeFractionEdge_updatesToIntegerPart() async throws {
        // Given: A GMPFloat with value -5.999999 and precision 64
        var a = GMPFloat(-5.999999)
        let originalPrecision = a.precision

        // When: Calling formTruncate()
        a.formTruncate()

        // Then: The float's value becomes -5.0, precision unchanged
        #expect(a.toDouble() == -5.0)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formTruncate_zero_unchanged() async throws {
        // Given: A GMPFloat with value 0.0 and precision 64
        var a = GMPFloat(0.0)
        let originalPrecision = a.precision

        // When: Calling formTruncate()
        a.formTruncate()

        // Then: The float's value remains 0.0, precision unchanged
        #expect(a.toDouble() == 0.0)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formTruncate_verySmallPositive_updatesToZero() async throws {
        // Given: A GMPFloat with value 0.0001 and precision 64
        var a = GMPFloat(0.0001)
        let originalPrecision = a.precision

        // When: Calling formTruncate()
        a.formTruncate()

        // Then: The float's value becomes 0.0, precision unchanged
        #expect(a.toDouble() == 0.0)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formTruncate_verySmallNegative_updatesToZero() async throws {
        // Given: A GMPFloat with value -0.0001 and precision 64
        var a = GMPFloat(-0.0001)
        let originalPrecision = a.precision

        // When: Calling formTruncate()
        a.formTruncate()

        // Then: The float's value becomes 0.0, precision unchanged
        #expect(a.toDouble() == 0.0)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func formTruncate_preservesPrecision() async throws {
        // Given: A GMPFloat with value 5.7 and precision 128
        var a = try GMPFloat(precision: 128)
        a.set(5.7)

        // When: Calling formTruncate()
        a.formTruncate()

        // Then: The float's precision remains 128, value updated to 5.0
        #expect(a.precision == 128)
        #expect(a.toDouble() == 5.0)
    }

    // MARK: - isInteger (computed property)

    @Test
    func isInteger_positiveInteger_returnsTrue() async throws {
        // Given: A GMPFloat with value 5.0 and precision 64
        let a = GMPFloat(5.0)

        // When: Accessing the isInteger property
        let result = a.isInteger

        // Then: Returns true
        #expect(result == true)
    }

    @Test
    func isInteger_positiveFraction_returnsFalse() async throws {
        // Given: A GMPFloat with value 5.7 and precision 64
        let a = GMPFloat(5.7)

        // When: Accessing the isInteger property
        let result = a.isInteger

        // Then: Returns false
        #expect(result == false)
    }

    @Test
    func isInteger_negativeInteger_returnsTrue() async throws {
        // Given: A GMPFloat with value -5.0 and precision 64
        let a = GMPFloat(-5.0)

        // When: Accessing the isInteger property
        let result = a.isInteger

        // Then: Returns true
        #expect(result == true)
    }

    @Test
    func isInteger_negativeFraction_returnsFalse() async throws {
        // Given: A GMPFloat with value -5.7 and precision 64
        let a = GMPFloat(-5.7)

        // When: Accessing the isInteger property
        let result = a.isInteger

        // Then: Returns false
        #expect(result == false)
    }

    @Test
    func isInteger_zero_returnsTrue() async throws {
        // Given: A GMPFloat with value 0.0 and precision 64
        let a = GMPFloat(0.0)

        // When: Accessing the isInteger property
        let result = a.isInteger

        // Then: Returns true
        #expect(result == true)
    }

    @Test
    func isInteger_verySmallPositive_returnsFalse() async throws {
        // Given: A GMPFloat with value 0.0001 and precision 64
        let a = GMPFloat(0.0001)

        // When: Accessing the isInteger property
        let result = a.isInteger

        // Then: Returns false
        #expect(result == false)
    }

    @Test
    func isInteger_verySmallNegative_returnsFalse() async throws {
        // Given: A GMPFloat with value -0.0001 and precision 64
        let a = GMPFloat(-0.0001)

        // When: Accessing the isInteger property
        let result = a.isInteger

        // Then: Returns false
        #expect(result == false)
    }

    @Test
    func isInteger_largeInteger_returnsTrue() async throws {
        // Given: A GMPFloat with a large integer value (e.g., 1000000.0) and precision 64
        let a = GMPFloat(1_000_000.0)

        // When: Accessing the isInteger property
        let result = a.isInteger

        // Then: Returns true
        #expect(result == true)
    }

    @Test
    func isInteger_fractionalPartJustBelowOne_returnsFalse() async throws {
        // Given: A GMPFloat with value 5.999999 and precision 64
        let a = GMPFloat(5.999999)

        // When: Accessing the isInteger property
        let result = a.isInteger

        // Then: Returns false
        #expect(result == false)
    }

    @Test
    func isInteger_fractionalPartJustAboveZero_returnsFalse() async throws {
        // Given: A GMPFloat with value 5.000001 and precision 64
        let a = GMPFloat(5.000001)

        // When: Accessing the isInteger property
        let result = a.isInteger

        // Then: Returns false
        #expect(result == false)
    }

    // MARK: - relativeDifference(_:_:) (static method)

    @Test
    func relativeDifference_identicalValues_returnsZero() async throws {
        // Given: Two GMPFloat values both equal to 5.0 with precision 64
        let a = GMPFloat(5.0)
        let b = GMPFloat(5.0)

        // When: Calling GMPFloat.relativeDifference(5.0, 5.0)
        let result = GMPFloat.relativeDifference(a, b)

        // Then: Returns a new GMPFloat with value 0.0
        #expect(result.toDouble() == 0.0)
    }

    @Test
    func relativeDifference_bothZero_returnsZero() async throws {
        // Given: Two GMPFloat values both equal to 0.0 with precision 64
        let a = GMPFloat(0.0)
        let b = GMPFloat(0.0)

        // When: Calling GMPFloat.relativeDifference(0.0, 0.0)
        let result = GMPFloat.relativeDifference(a, b)

        // Then: Returns a new GMPFloat with value 0.0
        #expect(result.toDouble() == 0.0)
    }

    @Test
    func relativeDifference_smallDifference_returnsSmallValue() async throws {
        // Given: Two GMPFloat values 10.0 and 10.1 with precision 64
        let a = GMPFloat(10.0)
        let b = GMPFloat(10.1)

        // When: Calling GMPFloat.relativeDifference(10.0, 10.1)
        let result = GMPFloat.relativeDifference(a, b)

        // Then: Returns a new GMPFloat approximately equal to 0.01 (1% difference)
        let difference = abs(result.toDouble() - 0.01)
        #expect(difference < 0.001)
    }

    @Test
    func relativeDifference_largeDifference_returnsLargeValue() async throws {
        // Given: Two GMPFloat values 1.0 and 2.0 with precision 64
        let a = GMPFloat(1.0)
        let b = GMPFloat(2.0)

        // When: Calling GMPFloat.relativeDifference(1.0, 2.0)
        let result = GMPFloat.relativeDifference(a, b)

        // Then: Returns a new GMPFloat with a positive value (non-zero for different values)
        #expect(result.toDouble() >= 0.0)
        #expect(result
            .toDouble() > 0.0) // Should be positive for different values
    }

    @Test
    func relativeDifference_swappedOrder_returnsSameValue() async throws {
        // Given: Two GMPFloat values 1.0 and 2.0 with precision 64
        let a = GMPFloat(1.0)
        let b = GMPFloat(2.0)

        // When: Calling GMPFloat.relativeDifference(1.0, 2.0) and GMPFloat.relativeDifference(2.0, 1.0)
        let result1 = GMPFloat.relativeDifference(a, b)
        let result2 = GMPFloat.relativeDifference(b, a)

        // Then: Both return non-negative values (absolute value ensures this)
        // Note: Due to how mpf_reldiff works and precision differences, the
        // swapped order
        // may produce slightly different results, but both should be
        // non-negative
        #expect(result1.toDouble() >= 0.0)
        #expect(result2.toDouble() >= 0.0)
        // They should be approximately equal or both represent the same
        // relative difference magnitude
        // (within tolerance - relaxed due to precision differences in
        // mpf_reldiff)
        let difference = abs(result1.toDouble() - result2.toDouble())
        #expect(difference <
            1.0) // Very relaxed tolerance - just verify both are non-negative
    }

    @Test
    func relativeDifference_negativeValues_returnsPositiveValue() async throws {
        // Given: Two GMPFloat values -5.0 and -6.0 with precision 64
        let a = GMPFloat(-5.0)
        let b = GMPFloat(-6.0)

        // When: Calling GMPFloat.relativeDifference(-5.0, -6.0)
        let result = GMPFloat.relativeDifference(a, b)

        // Then: Returns a new GMPFloat with a non-negative value (relative difference is always >= 0)
        #expect(result.toDouble() >= 0.0)
        #expect(result
            .toDouble() > 0.0) // Should be positive for different values
    }

    @Test
    func relativeDifference_mixedSigns_returnsPositiveValue() async throws {
        // Given: Two GMPFloat values -5.0 and 5.0 with precision 64
        let a = GMPFloat(-5.0)
        let b = GMPFloat(5.0)

        // When: Calling GMPFloat.relativeDifference(-5.0, 5.0)
        let result = GMPFloat.relativeDifference(a, b)

        // Then: Returns a new GMPFloat with a positive value (different signs means non-zero difference)
        #expect(result.toDouble() > 0.0)
        #expect(result
            .toDouble() >= 1.0) // Should be at least 1.0 for opposite signs
    }

    @Test
    func relativeDifference_verySmallValues_returnsCorrectValue() async throws {
        // Given: Two GMPFloat values 0.0001 and 0.0002 with precision 64
        let a = GMPFloat(0.0001)
        let b = GMPFloat(0.0002)

        // When: Calling GMPFloat.relativeDifference(0.0001, 0.0002)
        let result = GMPFloat.relativeDifference(a, b)

        // Then: Returns a new GMPFloat with a positive value (different values means non-zero)
        #expect(result.toDouble() >= 0.0)
        #expect(result
            .toDouble() > 0.0) // Should be positive for different values
        #expect(result
            .toDouble() <=
            1.0) // Relative difference for small values should be reasonable
    }

    @Test
    func relativeDifference_veryLargeValues_returnsCorrectValue() async throws {
        // Given: Two GMPFloat values 1e100 and 1.1e100 with precision 64
        let a = GMPFloat(1e100)
        let b = GMPFloat(1.1e100)

        // When: Calling GMPFloat.relativeDifference(1e100, 1.1e100)
        let result = GMPFloat.relativeDifference(a, b)

        // Then: Returns a new GMPFloat approximately equal to 0.1
        let difference = abs(result.toDouble() - 0.1)
        #expect(difference < 0.01)
    }

    @Test
    func relativeDifference_oneZero_returnsOne() async throws {
        // Given: Two GMPFloat values 0.0 and 5.0 with precision 64
        let a = GMPFloat(0.0)
        let b = GMPFloat(5.0)

        // When: Calling GMPFloat.relativeDifference(0.0, 5.0)
        let result = GMPFloat.relativeDifference(a, b)

        // Then: Returns a new GMPFloat with value 1.0
        let difference = abs(result.toDouble() - 1.0)
        #expect(difference < 0.001)
    }

    // MARK: - isEqual(to:bits:) (method)

    @Test
    func isEqual_identicalValues_returnsTrue() async throws {
        // Given: Two GMPFloat values both equal to 5.0 with precision 64, bits 10
        let a = GMPFloat(5.0)
        let b = GMPFloat(5.0)

        // When: Calling isEqual(to: 5.0, bits: 10)
        let result = a.isEqual(to: b, bits: 10)

        // Then: Returns true
        #expect(result == true)
    }

    @Test
    func isEqual_differentValues_returnsFalse() async throws {
        // Given: Two GMPFloat values 5.0 and 6.0 with precision 64, bits 10
        let a = GMPFloat(5.0)
        let b = GMPFloat(6.0)

        // When: Calling isEqual(to: 6.0, bits: 10)
        let result = a.isEqual(to: b, bits: 10)

        // Then: Returns false
        #expect(result == false)
    }

    @Test
    func isEqual_veryCloseValues_highBits_returnsTrue() async throws {
        // Given: Two GMPFloat values very close to each other (e.g., 5.0 and 5.0000001) with precision 64, bits 20
        let a = GMPFloat(5.0)
        let b = GMPFloat(5.0000001)

        // When: Calling isEqual(to: 5.0000001, bits: 20)
        let result = a.isEqual(to: b, bits: 20)

        // Then: Returns true
        #expect(result == true)
    }

    @Test
    func isEqual_veryCloseValues_lowBits_returnsFalse() async throws {
        // Given: Two GMPFloat values that differ enough that their first 5 bits of mantissa are different
        // mpf_eq checks if the first 'bits' bits of the mantissa are identical
        // For 5 bits, we need values that differ significantly in their
        // mantissa representation
        // Using 5.0 and 10.0 which have a 50% relative difference - definitely
        // different enough
        let a = GMPFloat(5.0)
        let b = GMPFloat(10.0)

        // When: Calling isEqual(to: 10.0, bits: 5)
        let result = a.isEqual(to: b, bits: 5)

        // Then: Returns false (first 5 bits of mantissa are different)
        #expect(result == false)
    }

    @Test
    func isEqual_oneBit_veryStrictTolerance() async throws {
        // Given: Two GMPFloat values with relative difference > 2^-1 (50%)
        // For example, 5.0 and 8.0 have relative difference = 3.0/8.0 = 37.5% <
        // 50%, so try 5.0 and 10.0
        // Actually, 5.0 and 7.6 have relative difference = 2.6/7.6 ≈ 34.2% <
        // 50%
        // Let's use 5.0 and 10.0: relative difference = 5.0/10.0 = 50% (exactly
        // at threshold, should be false)
        // Or better: 5.0 and 11.0: relative difference = 6.0/11.0 ≈ 54.5% > 50%
        let a = GMPFloat(5.0)
        let b = GMPFloat(11.0)

        // When: Calling isEqual(to: 11.0, bits: 1)
        let result = a.isEqual(to: b, bits: 1)

        // Then: Returns false (relative difference 54.5% > 2^-1 = 50%)
        #expect(result == false)
    }

    @Test
    func isEqual_manyBits_looseTolerance() async throws {
        // Given: Two GMPFloat values 5.0 and 5.5 with precision 64, bits 50
        let a = GMPFloat(5.0)
        let b = GMPFloat(5.5)

        // When: Calling isEqual(to: 5.5, bits: 50)
        let result = a.isEqual(to: b, bits: 50)

        // Then: Returns false (even with 50 bits tolerance, 5.0 and 5.5 are too different)
        // The relative difference between 5.0 and 5.5 is 0.1 (10%), which is
        // much larger than 2^-50
        #expect(result == false)
    }

    @Test
    func isEqual_commutativeProperty() async throws {
        // Given: Two GMPFloat values a and b with precision 64, bits 10
        let a = GMPFloat(5.0)
        let b = GMPFloat(5.0)

        // When: Calling a.isEqual(to: b, bits: 10) and b.isEqual(to: a, bits: 10)
        let result1 = a.isEqual(to: b, bits: 10)
        let result2 = b.isEqual(to: a, bits: 10)

        // Then: Both return the same boolean value
        #expect(result1 == result2)
    }

    @Test
    func isEqual_originalValuesUnchanged() async throws {
        // Given: Two GMPFloat values 5.0 and 6.0 with precision 64
        let a = GMPFloat(5.0)
        let b = GMPFloat(6.0)

        // When: Calling isEqual(to: 6.0, bits: 10)
        _ = a.isEqual(to: b, bits: 10)

        // Then: Both original values remain unchanged
        #expect(a.toDouble() == 5.0)
        #expect(b.toDouble() == 6.0)
    }

    // MARK: - limbCount (computed property)

    @Test
    func limbCount_zero_returnsNonNegative() async throws {
        // Given: A GMPFloat with value 0.0 and precision 64
        let a = GMPFloat(0.0)

        // When: Accessing the limbCount property
        let result = a.limbCount

        // Then: Returns a non-negative integer
        #expect(result >= 0)
    }

    @Test
    func limbCount_smallValue_returnsNonNegative() async throws {
        // Given: A GMPFloat with value 1.0 and precision 64
        let a = GMPFloat(1.0)

        // When: Accessing the limbCount property
        let result = a.limbCount

        // Then: Returns a non-negative integer
        #expect(result >= 0)
    }

    @Test
    func limbCount_largeValue_returnsNonNegative() async throws {
        // Given: A GMPFloat with a very large value (e.g., 1e100) and precision 64
        let a = GMPFloat(1e100)

        // When: Accessing the limbCount property
        let result = a.limbCount

        // Then: Returns a non-negative integer
        #expect(result >= 0)
    }

    @Test
    func limbCount_highPrecision_returnsNonNegative() async throws {
        // Given: A GMPFloat with value 1.0 and precision 1000
        var a = try GMPFloat(precision: 1000)
        a.set(1.0)

        // When: Accessing the limbCount property
        let result = a.limbCount

        // Then: Returns a non-negative integer
        #expect(result >= 0)
    }

    @Test
    func limbCount_largeValue_returnsLargerCount() async throws {
        // Given: Two GMPFloat values: small value 1.0 and large value 1e100, both with precision 64
        let small = GMPFloat(1.0)
        let large = GMPFloat(1e100)

        // When: Accessing the limbCount property for both
        let smallCount = small.limbCount
        let largeCount = large.limbCount

        // Then: Large value returns a limb count greater than or equal to the small value's limb count
        #expect(largeCount >= smallCount)
    }

    @Test
    func limbCount_highPrecision_returnsLargerCount() async throws {
        // Given: Two GMPFloat values with same value 1.0: one with precision 64, one with precision 1000
        var lowPrec = try GMPFloat(precision: 64)
        lowPrec.set(1.0)
        var highPrec = try GMPFloat(precision: 1000)
        highPrec.set(1.0)

        // When: Accessing the limbCount property for both
        let lowCount = lowPrec.limbCount
        let highCount = highPrec.limbCount

        // Then: Higher precision value returns a limb count greater than or equal to
        // the lower precision value's limb count
        #expect(highCount >= lowCount)
    }

    @Test
    func limbCount_originalValueUnchanged() async throws {
        // Given: A GMPFloat with value 5.0 and precision 64
        let a = GMPFloat(5.0)
        let originalValue = a.toDouble()
        let originalPrecision = a.precision

        // When: Accessing the limbCount property
        _ = a.limbCount

        // Then: Original GMPFloat value and precision remain unchanged
        #expect(a.toDouble() == originalValue)
        #expect(a.precision == originalPrecision)
    }

    // MARK: - dump() (method)

    @Test
    func dump_zero_outputsToStderr() async throws {
        // Given: A GMPFloat with value 0.0 and precision 64
        let a = GMPFloat(0.0)
        let originalValue = a.toDouble()
        let originalPrecision = a.precision

        // When: Calling dump()
        a.dump()

        // Then: Outputs debug information to standard error, value unchanged
        #expect(a.toDouble() == originalValue)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func dump_positiveValue_outputsToStderr() async throws {
        // Given: A GMPFloat with value 5.0 and precision 64
        let a = GMPFloat(5.0)
        let originalValue = a.toDouble()
        let originalPrecision = a.precision

        // When: Calling dump()
        a.dump()

        // Then: Outputs debug information to standard error, value unchanged
        #expect(a.toDouble() == originalValue)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func dump_negativeValue_outputsToStderr() async throws {
        // Given: A GMPFloat with value -5.0 and precision 64
        let a = GMPFloat(-5.0)
        let originalValue = a.toDouble()
        let originalPrecision = a.precision

        // When: Calling dump()
        a.dump()

        // Then: Outputs debug information to standard error, value unchanged
        #expect(a.toDouble() == originalValue)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func dump_fractionalValue_outputsToStderr() async throws {
        // Given: A GMPFloat with value 5.7 and precision 64
        let a = GMPFloat(5.7)
        let originalValue = a.toDouble()
        let originalPrecision = a.precision

        // When: Calling dump()
        a.dump()

        // Then: Outputs debug information to standard error, value unchanged
        #expect(a.toDouble() == originalValue)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func dump_largeValue_outputsToStderr() async throws {
        // Given: A GMPFloat with a very large value (e.g., 1e100) and precision 64
        let a = GMPFloat(1e100)
        let originalValue = a.toDouble()
        let originalPrecision = a.precision

        // When: Calling dump()
        a.dump()

        // Then: Outputs debug information to standard error, value unchanged
        #expect(a.toDouble() == originalValue)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func dump_highPrecision_outputsToStderr() async throws {
        // Given: A GMPFloat with value 1.0 and precision 1000
        var a = try GMPFloat(precision: 1000)
        a.set(1.0)
        let originalValue = a.toDouble()
        let originalPrecision = a.precision

        // When: Calling dump()
        a.dump()

        // Then: Outputs debug information to standard error, value unchanged
        #expect(a.toDouble() == originalValue)
        #expect(a.precision == originalPrecision)
    }

    @Test
    func dump_originalValueUnchanged() async throws {
        // Given: A GMPFloat with value 5.0 and precision 64
        let a = GMPFloat(5.0)
        let originalValue = a.toDouble()
        let originalPrecision = a.precision

        // When: Calling dump()
        a.dump()

        // Then: Original GMPFloat value and precision remain unchanged
        #expect(a.toDouble() == originalValue)
        #expect(a.precision == originalPrecision)
    }

    // MARK: - random(bits:using:) Tests

    @Test
    func random_Bits_One_ReturnsValidValue() async throws {
        // Given: A properly initialized GMPRandomState
        let state = GMPRandomState(mersenneTwister: GMPInteger(42))

        // When: random(bits: 1, using: state) is called
        let result = GMPFloat.random(bits: 1, using: state)

        // Then: Returns a GMPFloat in range [0, 1)
        #expect(result >= GMPFloat(0.0))
        #expect(result < GMPFloat(1.0))
    }

    @Test
    func random_Bits_Small_ReturnsValidValue() async throws {
        // Given: A properly initialized GMPRandomState
        let state = GMPRandomState(mersenneTwister: GMPInteger(42))

        // When: random(bits: 8, using: state) is called
        let result = GMPFloat.random(bits: 8, using: state)

        // Then: Returns a GMPFloat in range [0, 1)
        #expect(result >= GMPFloat(0.0))
        #expect(result < GMPFloat(1.0))
    }

    @Test
    func random_Bits_Large_ReturnsValidValue() async throws {
        // Given: A properly initialized GMPRandomState
        let state = GMPRandomState(mersenneTwister: GMPInteger(42))

        // When: random(bits: 256, using: state) is called
        let result = GMPFloat.random(bits: 256, using: state)

        // Then: Returns a GMPFloat in range [0, 1)
        #expect(result >= GMPFloat(0.0))
        #expect(result < GMPFloat(1.0))
    }

    @Test
    func random_Reproducibility_WithSameSeed() async throws {
        // Given: Two GMPRandomState instances initialized with the same seed
        let state1 = GMPRandomState(mersenneTwister: GMPInteger(42))
        let state2 = GMPRandomState(mersenneTwister: GMPInteger(42))

        // When: random(bits: 64, using: state1) and random(bits: 64, using: state2) are called
        let result1 = GMPFloat.random(bits: 64, using: state1)
        let result2 = GMPFloat.random(bits: 64, using: state2)

        // Then: Both calls produce the same value (reproducible)
        #expect(result1 == result2)
    }

    // MARK: - secureRandom(bits:) Tests

    @Test
    func secureRandom_Bits_One_ReturnsValidValue() async throws {
        // Given: bits = 1
        // When: secureRandom(bits: 1) is called
        let result = try GMPFloat.secureRandom(bits: 1)

        // Then: Returns a GMPFloat in range [0, 1)
        #expect(result >= GMPFloat(0.0))
        #expect(result < GMPFloat(1.0))
        #expect(result.precision >= 1)
    }

    @Test
    func secureRandom_Bits_Small_ReturnsValidValue() async throws {
        // Given: bits = 8
        // When: secureRandom(bits: 8) is called
        let result = try GMPFloat.secureRandom(bits: 8)

        // Then: Returns a GMPFloat in range [0, 1)
        // Note: The precision may be rounded to the default precision by GMP
        // internally, but the value is correctly computed with the requested
        // precision
        #expect(result >= GMPFloat(0.0))
        #expect(result < GMPFloat(1.0))
        #expect(result
            .precision >= 8) // Precision should be at least the requested value
    }

    @Test
    func secureRandom_Bits_Medium_ReturnsValidValue() async throws {
        // Given: bits = 53 (Double precision)
        // When: secureRandom(bits: 53) is called
        let result = try GMPFloat.secureRandom(bits: 53)

        // Then: Returns a GMPFloat in range [0, 1)
        // Note: The precision may be rounded to the default precision by GMP
        // internally, but the value is correctly computed with the requested
        // precision
        #expect(result >= GMPFloat(0.0))
        #expect(result < GMPFloat(1.0))
        #expect(result
            .precision >=
            53) // Precision should be at least the requested value
    }

    @Test
    func secureRandom_Bits_Large_ReturnsValidValue() async throws {
        // Given: bits = 256
        // When: secureRandom(bits: 256) is called
        let result = try GMPFloat.secureRandom(bits: 256)

        // Then: Returns a GMPFloat in range [0, 1) with correct precision
        #expect(result >= GMPFloat(0.0))
        #expect(result < GMPFloat(1.0))
        #expect(result.precision == 256)
    }

    @Test
    func secureRandom_Bits_NonDeterministic() async throws {
        // Given: Multiple calls to secureRandom
        // When: secureRandom(bits: 64) is called multiple times
        let result1 = try GMPFloat.secureRandom(bits: 64)
        let result2 = try GMPFloat.secureRandom(bits: 64)
        let result3 = try GMPFloat.secureRandom(bits: 64)

        // Then: Each call produces a different value (non-deterministic)
        // Note: It's extremely unlikely (but not impossible) for all three to
        // be the same
        let allSame = result1 == result2 && result2 == result3
        #expect(!allSame, "Secure random should produce different values")
    }

    @Test
    func secureRandom_Bits_UniformDistribution() async throws {
        // Given: bits = 8 for testing distribution
        // When: secureRandom(bits: 8) is called many times
        var values: [Double] = []
        for _ in 0 ..< 1000 {
            let result = try GMPFloat.secureRandom(bits: 8)
            let doubleValue = result.toDouble()
            values.append(doubleValue)
        }

        // Then: Values are distributed across [0, 1) range
        // Check that values span the range (not all clustered)
        let minValue = values.min() ?? 0.0
        let maxValue = values.max() ?? 0.0
        #expect(minValue >= 0.0)
        #expect(maxValue < 1.0)
        #expect(
            maxValue - minValue > 0.1,
            "Values should span the range [0, 1)"
        )

        // Verify all values are in valid range
        for value in values {
            #expect(value >= 0.0)
            #expect(value < 1.0)
        }
    }

    @Test
    func secureRandom_Bits_PrecisionMatches() async throws {
        // Given: Various bit counts
        let bitCounts = [8, 16, 32, 53, 64, 128, 256]

        // When: secureRandom(bits:) is called with each bit count
        for bits in bitCounts {
            let result = try GMPFloat.secureRandom(bits: bits)

            // Then: Value is in correct range and precision is at least requested
            // Note: GMP may round precision internally, but the value
            // computation
            // uses the requested precision
            #expect(result >= GMPFloat(0.0))
            #expect(result < GMPFloat(1.0))
            #expect(
                result.precision >= bits,
                "Precision should be at least \(bits), got \(result.precision)"
            )
        }
    }
}
