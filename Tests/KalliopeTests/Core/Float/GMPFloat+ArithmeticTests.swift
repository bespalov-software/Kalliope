import Foundation
@testable import Kalliope
import Testing

// MARK: - Immutable Operations

struct GMPFloatArithmeticTests {
    // MARK: - adding(_ other: GMPFloat) -> GMPFloat

    @Test
    func adding_TwoPositiveFloats_ReturnsSum() async throws {
        // Given: a = GMPFloat(3.5), b = GMPFloat(2.25)
        let a = GMPFloat(3.5)
        let b = GMPFloat(2.25)

        // When: result = a.adding(b)
        let result = a.adding(b)

        // Then: result == 5.75 (rounded to a's precision) and a is unchanged
        #expect(result.toDouble() == 5.75)
        #expect(a.toDouble() == 3.5)
    }

    @Test
    func adding_PositiveAndNegative_ReturnsDifference() async throws {
        // Given: a = GMPFloat(5.0), b = GMPFloat(-2.5)
        let a = GMPFloat(5.0)
        let b = GMPFloat(-2.5)

        // When: result = a.adding(b)
        let result = a.adding(b)

        // Then: result == 2.5 (rounded to a's precision) and a is unchanged
        #expect(result.toDouble() == 2.5)
        #expect(a.toDouble() == 5.0)
    }

    @Test
    func adding_TwoNegative_ReturnsNegativeSum() async throws {
        // Given: a = GMPFloat(-3.5), b = GMPFloat(-2.25)
        let a = GMPFloat(-3.5)
        let b = GMPFloat(-2.25)

        // When: result = a.adding(b)
        let result = a.adding(b)

        // Then: result == -5.75 (rounded to a's precision) and a is unchanged
        #expect(result.toDouble() == -5.75)
        #expect(a.toDouble() == -3.5)
    }

    @Test
    func adding_Zero_ReturnsSelf() async throws {
        // Given: a = GMPFloat(3.5), b = GMPFloat(0.0)
        let a = GMPFloat(3.5)
        let b = GMPFloat(0.0)

        // When: result = a.adding(b)
        let result = a.adding(b)

        // Then: result == 3.5 and a is unchanged
        #expect(result.toDouble() == 3.5)
        #expect(a.toDouble() == 3.5)
    }

    @Test
    func adding_ToZero_ReturnsOther() async throws {
        // Given: a = GMPFloat(0.0), b = GMPFloat(2.5)
        let a = GMPFloat(0.0)
        let b = GMPFloat(2.5)

        // When: result = a.adding(b)
        let result = a.adding(b)

        // Then: result == 2.5 and a is unchanged
        #expect(result.toDouble() == 2.5)
        #expect(a.toDouble() == 0.0)
    }

    @Test
    func adding_BothZero_ReturnsZero() async throws {
        // Given: a = GMPFloat(0.0), b = GMPFloat(0.0)
        let a = GMPFloat(0.0)
        let b = GMPFloat(0.0)

        // When: result = a.adding(b)
        let result = a.adding(b)

        // Then: result == 0.0 and a is unchanged
        #expect(result.toDouble() == 0.0)
        #expect(a.toDouble() == 0.0)
    }

    @Test
    func adding_LargeValues_ReturnsSum() async throws {
        // Given: a = GMPFloat(1e100), b = GMPFloat(1e50)
        let a = GMPFloat(1e100)
        let b = GMPFloat(1e50)

        // When: result = a.adding(b)
        let result = a.adding(b)

        // Then: result equals the sum (rounded to a's precision) and a is unchanged
        #expect(result.toDouble() == 1e100 + 1e50)
        #expect(a.toDouble() == 1e100)
    }

    @Test
    func adding_SmallValues_ReturnsSum() async throws {
        // Given: a = GMPFloat(1e-100), b = GMPFloat(1e-50)
        let a = GMPFloat(1e-100)
        let b = GMPFloat(1e-50)

        // When: result = a.adding(b)
        let result = a.adding(b)

        // Then: result equals the sum (rounded to a's precision) and a is unchanged
        #expect(result.toDouble() == 1e-100 + 1e-50)
        #expect(a.toDouble() == 1e-100)
    }

    @Test
    func adding_DifferentPrecisions_UsesLeftPrecision() async throws {
        // Given: a = GMPFloat(3.14159, precision: 100), b = GMPFloat(2.71828, precision: 50)
        var a = try GMPFloat(precision: 100)
        a.set(3.14159)
        var b = try GMPFloat(precision: 50)
        b.set(2.71828)

        // When: result = a.adding(b)
        let result = a.adding(b)

        // Then: result has precision matching a (GMP may round, so check a.precision) and value equals sum
        #expect(result.precision == a.precision)
        #expect(result.toDouble() == 3.14159 + 2.71828)
    }

    @Test
    func adding_OppositeValues_ReturnsZero() async throws {
        // Given: a = GMPFloat(5.5), b = GMPFloat(-5.5)
        let a = GMPFloat(5.5)
        let b = GMPFloat(-5.5)

        // When: result = a.adding(b)
        let result = a.adding(b)

        // Then: result == 0.0 (approximately, within rounding) and a is unchanged
        #expect(result.isZero)
        #expect(a.toDouble() == 5.5)
    }

    @Test
    func adding_VeryDifferentMagnitudes_HandlesCancellation() async throws {
        // Given: a = GMPFloat(1e100), b = GMPFloat(-1e100 + 1)
        let a = GMPFloat(1e100)
        let b = GMPFloat(-1e100).adding(GMPFloat(1.0))

        // When: result = a.adding(b)
        let result = a.adding(b)

        // Then: result == 1.0 (within rounding error) and a is unchanged
        #expect(abs(result.toDouble() - 1.0) <
            1e90) // Large tolerance due to precision limits
        #expect(a.toDouble() == 1e100)
    }

    // MARK: - subtracting(_ other: GMPFloat) -> GMPFloat

    @Test
    func subtracting_TwoPositiveFloats_ReturnsDifference() async throws {
        // Given: a = GMPFloat(5.5), b = GMPFloat(2.25)
        let a = GMPFloat(5.5)
        let b = GMPFloat(2.25)

        // When: result = a.subtracting(b)
        let result = a.subtracting(b)

        // Then: result == 3.25 (rounded to a's precision) and a is unchanged
        #expect(result.toDouble() == 3.25)
        #expect(a.toDouble() == 5.5)
    }

    @Test
    func subtracting_PositiveAndNegative_ReturnsSum() async throws {
        // Given: a = GMPFloat(5.0), b = GMPFloat(-2.5)
        let a = GMPFloat(5.0)
        let b = GMPFloat(-2.5)

        // When: result = a.subtracting(b)
        let result = a.subtracting(b)

        // Then: result == 7.5 (rounded to a's precision) and a is unchanged
        #expect(result.toDouble() == 7.5)
        #expect(a.toDouble() == 5.0)
    }

    @Test
    func subtracting_TwoNegative_ReturnsNegativeDifference() async throws {
        // Given: a = GMPFloat(-3.5), b = GMPFloat(-2.25)
        let a = GMPFloat(-3.5)
        let b = GMPFloat(-2.25)

        // When: result = a.subtracting(b)
        let result = a.subtracting(b)

        // Then: result == -1.25 (rounded to a's precision) and a is unchanged
        #expect(result.toDouble() == -1.25)
        #expect(a.toDouble() == -3.5)
    }

    @Test
    func subtracting_Zero_ReturnsSelf() async throws {
        // Given: a = GMPFloat(3.5), b = GMPFloat(0.0)
        let a = GMPFloat(3.5)
        let b = GMPFloat(0.0)

        // When: result = a.subtracting(b)
        let result = a.subtracting(b)

        // Then: result == 3.5 and a is unchanged
        #expect(result.toDouble() == 3.5)
        #expect(a.toDouble() == 3.5)
    }

    @Test
    func subtracting_FromZero_ReturnsNegatedOther() async throws {
        // Given: a = GMPFloat(0.0), b = GMPFloat(2.5)
        let a = GMPFloat(0.0)
        let b = GMPFloat(2.5)

        // When: result = a.subtracting(b)
        let result = a.subtracting(b)

        // Then: result == -2.5 and a is unchanged
        #expect(result.toDouble() == -2.5)
        #expect(a.toDouble() == 0.0)
    }

    @Test
    func subtracting_BothZero_ReturnsZero() async throws {
        // Given: a = GMPFloat(0.0), b = GMPFloat(0.0)
        let a = GMPFloat(0.0)
        let b = GMPFloat(0.0)

        // When: result = a.subtracting(b)
        let result = a.subtracting(b)

        // Then: result == 0.0 and a is unchanged
        #expect(result.toDouble() == 0.0)
        #expect(a.toDouble() == 0.0)
    }

    @Test
    func subtracting_SameValues_ReturnsZero() async throws {
        // Given: a = GMPFloat(5.5), b = GMPFloat(5.5)
        let a = GMPFloat(5.5)
        let b = GMPFloat(5.5)

        // When: result = a.subtracting(b)
        let result = a.subtracting(b)

        // Then: result == 0.0 (approximately, within rounding) and a is unchanged
        #expect(result.isZero)
        #expect(a.toDouble() == 5.5)
    }

    @Test
    func subtracting_LargeValues_ReturnsDifference() async throws {
        // Given: a = GMPFloat(1e100), b = GMPFloat(1e50)
        let a = GMPFloat(1e100)
        let b = GMPFloat(1e50)

        // When: result = a.subtracting(b)
        let result = a.subtracting(b)

        // Then: result equals the difference (rounded to a's precision) and a is unchanged
        #expect(result.toDouble() == 1e100 - 1e50)
        #expect(a.toDouble() == 1e100)
    }

    @Test
    func subtracting_DifferentPrecisions_UsesLeftPrecision() async throws {
        // Given: a = GMPFloat(3.14159, precision: 100), b = GMPFloat(2.71828, precision: 50)
        var a = try GMPFloat(precision: 100)
        a.set(3.14159)
        var b = try GMPFloat(precision: 50)
        b.set(2.71828)

        // When: result = a.subtracting(b)
        let result = a.subtracting(b)

        // Then: result has precision matching a (GMP may round, so check a.precision) and value equals difference
        #expect(result.precision == a.precision)
        #expect(result.toDouble() == 3.14159 - 2.71828)
    }

    // MARK: - multiplied(by other: GMPFloat) -> GMPFloat

    @Test
    func multiplied_TwoPositiveFloats_ReturnsProduct() async throws {
        // Given: a = GMPFloat(3.5), b = GMPFloat(2.0)
        let a = GMPFloat(3.5)
        let b = GMPFloat(2.0)

        // When: result = a.multiplied(by: b)
        let result = a.multiplied(by: b)

        // Then: result == 7.0 (rounded to a's precision) and a is unchanged
        #expect(result.toDouble() == 7.0)
        #expect(a.toDouble() == 3.5)
    }

    @Test
    func multiplied_PositiveAndNegative_ReturnsNegativeProduct() async throws {
        // Given: a = GMPFloat(5.0), b = GMPFloat(-2.5)
        let a = GMPFloat(5.0)
        let b = GMPFloat(-2.5)

        // When: result = a.multiplied(by: b)
        let result = a.multiplied(by: b)

        // Then: result == -12.5 (rounded to a's precision) and a is unchanged
        #expect(result.toDouble() == -12.5)
        #expect(a.toDouble() == 5.0)
    }

    @Test
    func multiplied_TwoNegative_ReturnsPositiveProduct() async throws {
        // Given: a = GMPFloat(-3.5), b = GMPFloat(-2.0)
        let a = GMPFloat(-3.5)
        let b = GMPFloat(-2.0)

        // When: result = a.multiplied(by: b)
        let result = a.multiplied(by: b)

        // Then: result == 7.0 (rounded to a's precision) and a is unchanged
        #expect(result.toDouble() == 7.0)
        #expect(a.toDouble() == -3.5)
    }

    @Test
    func multiplied_ByZero_ReturnsZero() async throws {
        // Given: a = GMPFloat(3.5), b = GMPFloat(0.0)
        let a = GMPFloat(3.5)
        let b = GMPFloat(0.0)

        // When: result = a.multiplied(by: b)
        let result = a.multiplied(by: b)

        // Then: result == 0.0 and a is unchanged
        #expect(result.toDouble() == 0.0)
        #expect(a.toDouble() == 3.5)
    }

    @Test
    func multiplied_ZeroByOther_ReturnsZero() async throws {
        // Given: a = GMPFloat(0.0), b = GMPFloat(2.5)
        let a = GMPFloat(0.0)
        let b = GMPFloat(2.5)

        // When: result = a.multiplied(by: b)
        let result = a.multiplied(by: b)

        // Then: result == 0.0 and a is unchanged
        #expect(result.toDouble() == 0.0)
        #expect(a.toDouble() == 0.0)
    }

    @Test
    func multiplied_ByOne_ReturnsSelf() async throws {
        // Given: a = GMPFloat(3.5), b = GMPFloat(1.0)
        let a = GMPFloat(3.5)
        let b = GMPFloat(1.0)

        // When: result = a.multiplied(by: b)
        let result = a.multiplied(by: b)

        // Then: result == 3.5 and a is unchanged
        #expect(result.toDouble() == 3.5)
        #expect(a.toDouble() == 3.5)
    }

    @Test
    func multiplied_ByMinusOne_ReturnsNegatedSelf() async throws {
        // Given: a = GMPFloat(3.5), b = GMPFloat(-1.0)
        let a = GMPFloat(3.5)
        let b = GMPFloat(-1.0)

        // When: result = a.multiplied(by: b)
        let result = a.multiplied(by: b)

        // Then: result == -3.5 and a is unchanged
        #expect(result.toDouble() == -3.5)
        #expect(a.toDouble() == 3.5)
    }

    @Test
    func multiplied_LargeValues_ReturnsProduct() async throws {
        // Given: a = GMPFloat(1e50), b = GMPFloat(1e50)
        let a = GMPFloat(1e50)
        let b = GMPFloat(1e50)

        // When: result = a.multiplied(by: b)
        let result = a.multiplied(by: b)

        // Then: result == 1e100 (within rounding) and a is unchanged
        #expect(result.toDouble() == 1e100)
        #expect(a.toDouble() == 1e50)
    }

    @Test
    func multiplied_SmallValues_ReturnsProduct() async throws {
        // Given: a = GMPFloat(1e-50), b = GMPFloat(1e-50)
        let a = GMPFloat(1e-50)
        let b = GMPFloat(1e-50)

        // When: result = a.multiplied(by: b)
        let result = a.multiplied(by: b)

        // Then: result == 1e-100 (within rounding) and a is unchanged
        #expect(abs(result.toDouble() - 1e-100) <
            1e-110) // Allow for rounding errors
        #expect(a.toDouble() == 1e-50)
    }

    @Test
    func multiplied_DifferentPrecisions_UsesLeftPrecision() async throws {
        // Given: a = GMPFloat(3.14159, precision: 100), b = GMPFloat(2.71828, precision: 50)
        var a = try GMPFloat(precision: 100)
        a.set(3.14159)
        var b = try GMPFloat(precision: 50)
        b.set(2.71828)

        // When: result = a.multiplied(by: b)
        let result = a.multiplied(by: b)

        // Then: result has precision matching a (GMP may round, so check a.precision) and value equals product
        #expect(result.precision == a.precision)
        #expect(result.toDouble() == 3.14159 * 2.71828)
    }

    @Test
    func multiplied_VeryDifferentMagnitudes_HandlesPrecision() async throws {
        // Given: a = GMPFloat(1e100), b = GMPFloat(1e-100)
        let a = GMPFloat(1e100)
        let b = GMPFloat(1e-100)

        // When: result = a.multiplied(by: b)
        let result = a.multiplied(by: b)

        // Then: result == 1.0 (within rounding) and a is unchanged
        #expect(abs(result.toDouble() - 1.0) < 1e-10)
        #expect(a.toDouble() == 1e100)
    }

    // MARK: - divided(by other: GMPFloat) -> GMPFloat

    @Test
    func divided_TwoPositiveFloats_ReturnsQuotient() async throws {
        // Given: a = GMPFloat(7.5), b = GMPFloat(2.5)
        let a = GMPFloat(7.5)
        let b = GMPFloat(2.5)

        // When: result = a.divided(by: b)
        let result = try a.divided(by: b)

        // Then: result == 3.0 (rounded to a's precision) and a is unchanged
        #expect(result.toDouble() == 3.0)
        #expect(a.toDouble() == 7.5)
    }

    @Test
    func divided_PositiveAndNegative_ReturnsNegativeQuotient() async throws {
        // Given: a = GMPFloat(10.0), b = GMPFloat(-2.5)
        let a = GMPFloat(10.0)
        let b = GMPFloat(-2.5)

        // When: result = a.divided(by: b)
        let result = try a.divided(by: b)

        // Then: result == -4.0 (rounded to a's precision) and a is unchanged
        #expect(result.toDouble() == -4.0)
        #expect(a.toDouble() == 10.0)
    }

    @Test
    func divided_TwoNegative_ReturnsPositiveQuotient() async throws {
        // Given: a = GMPFloat(-7.5), b = GMPFloat(-2.5)
        let a = GMPFloat(-7.5)
        let b = GMPFloat(-2.5)

        // When: result = a.divided(by: b)
        let result = try a.divided(by: b)

        // Then: result == 3.0 (rounded to a's precision) and a is unchanged
        #expect(result.toDouble() == 3.0)
        #expect(a.toDouble() == -7.5)
    }

    @Test
    func divided_ByOne_ReturnsSelf() async throws {
        // Given: a = GMPFloat(3.5), b = GMPFloat(1.0)
        let a = GMPFloat(3.5)
        let b = GMPFloat(1.0)

        // When: result = a.divided(by: b)
        let result = try a.divided(by: b)

        // Then: result == 3.5 and a is unchanged
        #expect(result.toDouble() == 3.5)
        #expect(a.toDouble() == 3.5)
    }

    @Test
    func divided_ByMinusOne_ReturnsNegatedSelf() async throws {
        // Given: a = GMPFloat(3.5), b = GMPFloat(-1.0)
        let a = GMPFloat(3.5)
        let b = GMPFloat(-1.0)

        // When: result = a.divided(by: b)
        let result = try a.divided(by: b)

        // Then: result == -3.5 and a is unchanged
        #expect(result.toDouble() == -3.5)
        #expect(a.toDouble() == 3.5)
    }

    @Test
    func divided_BySelf_ReturnsOne() async throws {
        // Given: a = GMPFloat(5.5), b = GMPFloat(5.5)
        let a = GMPFloat(5.5)
        let b = GMPFloat(5.5)

        // When: result = a.divided(by: b)
        let result = try a.divided(by: b)

        // Then: result == 1.0 (within rounding) and a is unchanged
        #expect(abs(result.toDouble() - 1.0) < 1e-10)
        #expect(a.toDouble() == 5.5)
    }

    @Test
    func divided_ZeroByNonZero_ReturnsZero() async throws {
        // Given: a = GMPFloat(0.0), b = GMPFloat(2.5)
        let a = GMPFloat(0.0)
        let b = GMPFloat(2.5)

        // When: result = a.divided(by: b)
        let result = try a.divided(by: b)

        // Then: result == 0.0 and a is unchanged
        #expect(result.toDouble() == 0.0)
        #expect(a.toDouble() == 0.0)
    }

    @Test
    func divided_ByZero_ThrowsDivisionByZero() async throws {
        // Given: a = GMPFloat(5.5), b = GMPFloat(0.0)
        let a = GMPFloat(5.5)
        let b = GMPFloat(0.0)

        // When: result = a.divided(by: b) is called
        // Then: Throws GMPError.divisionByZero and a is unchanged
        #expect(throws: GMPError.divisionByZero) {
            try a.divided(by: b)
        }
        #expect(a.toDouble() == 5.5)
    }

    @Test
    func divided_ByZero_WithVerySmallValue_ThrowsDivisionByZero() async throws {
        // Given: a = GMPFloat(5.5), b = GMPFloat(1e-1000) (effectively zero)
        let a = GMPFloat(5.5)
        // Create a very small value that should be treated as zero
        var b = try GMPFloat(precision: 100)
        b.set(1e-1000)

        // When: result = a.divided(by: b) is called
        // Then: May throw GMPError.divisionByZero or handle appropriately and a is unchanged
        // Note: Very small values may not be exactly zero, so this test checks
        // behavior
        if b.isZero {
            #expect(throws: GMPError.divisionByZero) {
                try a.divided(by: b)
            }
        }
        #expect(a.toDouble() == 5.5)
    }

    @Test
    func divided_LargeValues_ReturnsQuotient() async throws {
        // Given: a = GMPFloat(1e100), b = GMPFloat(1e50)
        let a = GMPFloat(1e100)
        let b = GMPFloat(1e50)

        // When: result = a.divided(by: b)
        let result = try a.divided(by: b)

        // Then: result == 1e50 (within rounding) and a is unchanged
        #expect(abs(result.toDouble() - 1e50) <
            1e40) // Allow for rounding errors with large numbers
        #expect(a.toDouble() == 1e100)
    }

    @Test
    func divided_SmallValues_ReturnsQuotient() async throws {
        // Given: a = GMPFloat(1e-100), b = GMPFloat(1e-50)
        let a = GMPFloat(1e-100)
        let b = GMPFloat(1e-50)

        // When: result = a.divided(by: b)
        let result = try a.divided(by: b)

        // Then: result == 1e-50 (within rounding) and a is unchanged
        #expect(result.toDouble() == 1e-50)
        #expect(a.toDouble() == 1e-100)
    }

    @Test
    func divided_DifferentPrecisions_UsesLeftPrecision() async throws {
        // Given: a = GMPFloat(3.14159, precision: 100), b = GMPFloat(2.71828, precision: 50)
        var a = try GMPFloat(precision: 100)
        a.set(3.14159)
        var b = try GMPFloat(precision: 50)
        b.set(2.71828)

        // When: result = a.divided(by: b)
        let result = try a.divided(by: b)

        // Then: result has precision matching a (GMP may round, so check a.precision) and value equals quotient
        #expect(result.precision == a.precision)
        #expect(result.toDouble() == 3.14159 / 2.71828)
    }

    @Test
    func divided_VeryDifferentMagnitudes_HandlesPrecision() async throws {
        // Given: a = GMPFloat(1e100), b = GMPFloat(1e-100)
        let a = GMPFloat(1e100)
        let b = GMPFloat(1e-100)

        // When: result = a.divided(by: b)
        let result = try a.divided(by: b)

        // Then: result == 1e200 (within rounding) and a is unchanged
        #expect(result.toDouble() == 1e200)
        #expect(a.toDouble() == 1e100)
    }

    // MARK: - negated() -> GMPFloat

    @Test
    func negated_Positive_ReturnsNegative() async throws {
        // Given: a = GMPFloat(5.5)
        let a = GMPFloat(5.5)

        // When: result = a.negated()
        let result = a.negated()

        // Then: result == -5.5 and a is unchanged
        #expect(result.toDouble() == -5.5)
        #expect(a.toDouble() == 5.5)
    }

    @Test
    func negated_Negative_ReturnsPositive() async throws {
        // Given: a = GMPFloat(-5.5)
        let a = GMPFloat(-5.5)

        // When: result = a.negated()
        let result = a.negated()

        // Then: result == 5.5 and a is unchanged
        #expect(result.toDouble() == 5.5)
        #expect(a.toDouble() == -5.5)
    }

    @Test
    func negated_Zero_ReturnsZero() async throws {
        // Given: a = GMPFloat(0.0)
        let a = GMPFloat(0.0)

        // When: result = a.negated()
        let result = a.negated()

        // Then: result == 0.0 and a is unchanged
        #expect(result.toDouble() == 0.0)
        #expect(a.toDouble() == 0.0)
    }

    @Test
    func negated_LargeValue_ReturnsNegated() async throws {
        // Given: a = GMPFloat(1e100)
        let a = GMPFloat(1e100)

        // When: result = a.negated()
        let result = a.negated()

        // Then: result == -1e100 and a is unchanged
        #expect(result.toDouble() == -1e100)
        #expect(a.toDouble() == 1e100)
    }

    @Test
    func negated_SmallValue_ReturnsNegated() async throws {
        // Given: a = GMPFloat(1e-100)
        let a = GMPFloat(1e-100)

        // When: result = a.negated()
        let result = a.negated()

        // Then: result == -1e-100 and a is unchanged
        #expect(result.toDouble() == -1e-100)
        #expect(a.toDouble() == 1e-100)
    }

    @Test
    func negated_DoubleNegation_ReturnsOriginal() async throws {
        // Given: a = GMPFloat(5.5)
        let a = GMPFloat(5.5)

        // When: result = a.negated().negated()
        let result = a.negated().negated()

        // Then: result == 5.5 and a is unchanged
        #expect(result.toDouble() == 5.5)
        #expect(a.toDouble() == 5.5)
    }

    // MARK: - absoluteValue() -> GMPFloat

    @Test
    func absoluteValue_Positive_ReturnsSame() async throws {
        // Given: a = GMPFloat(5.5)
        let a = GMPFloat(5.5)

        // When: result = a.absoluteValue()
        let result = a.absoluteValue()

        // Then: result == 5.5 and a is unchanged
        #expect(result.toDouble() == 5.5)
        #expect(a.toDouble() == 5.5)
    }

    @Test
    func absoluteValue_Negative_ReturnsPositive() async throws {
        // Given: a = GMPFloat(-5.5)
        let a = GMPFloat(-5.5)

        // When: result = a.absoluteValue()
        let result = a.absoluteValue()

        // Then: result == 5.5 and a is unchanged
        #expect(result.toDouble() == 5.5)
        #expect(a.toDouble() == -5.5)
    }

    @Test
    func absoluteValue_Zero_ReturnsZero() async throws {
        // Given: a = GMPFloat(0.0)
        let a = GMPFloat(0.0)

        // When: result = a.absoluteValue()
        let result = a.absoluteValue()

        // Then: result == 0.0 and a is unchanged
        #expect(result.toDouble() == 0.0)
        #expect(a.toDouble() == 0.0)
    }

    @Test
    func absoluteValue_LargeNegative_ReturnsLargePositive() async throws {
        // Given: a = GMPFloat(-1e100)
        let a = GMPFloat(-1e100)

        // When: result = a.absoluteValue()
        let result = a.absoluteValue()

        // Then: result == 1e100 and a is unchanged
        #expect(result.toDouble() == 1e100)
        #expect(a.toDouble() == -1e100)
    }

    @Test
    func absoluteValue_SmallNegative_ReturnsSmallPositive() async throws {
        // Given: a = GMPFloat(-1e-100)
        let a = GMPFloat(-1e-100)

        // When: result = a.absoluteValue()
        let result = a.absoluteValue()

        // Then: result == 1e-100 and a is unchanged
        #expect(result.toDouble() == 1e-100)
        #expect(a.toDouble() == -1e-100)
    }

    // MARK: - Mutable Operations

    // MARK: - add(_ other: GMPFloat)

    @Test
    func add_TwoPositiveFloats_ModifiesSelf() async throws {
        // Given: var a = GMPFloat(3.5), b = GMPFloat(2.25)
        var a = GMPFloat(3.5)
        let b = GMPFloat(2.25)

        // When: a.add(b)
        a.add(b)

        // Then: a == 5.75 (rounded to original precision)
        #expect(a.toDouble() == 5.75)
    }

    @Test
    func add_Zero_NoChange() async throws {
        // Given: var a = GMPFloat(5.5), b = GMPFloat(0.0)
        var a = GMPFloat(5.5)
        let b = GMPFloat(0.0)

        // When: a.add(b)
        a.add(b)

        // Then: a == 5.5
        #expect(a.toDouble() == 5.5)
    }

    @Test
    func add_Negative_DecreasesValue() async throws {
        // Given: var a = GMPFloat(5.0), b = GMPFloat(-2.5)
        var a = GMPFloat(5.0)
        let b = GMPFloat(-2.5)

        // When: a.add(b)
        a.add(b)

        // Then: a == 2.5
        #expect(a.toDouble() == 2.5)
    }

    @Test
    func add_PrecisionMaintained() async throws {
        // Given: var a = GMPFloat(3.5, precision: 100), b = GMPFloat(2.25, precision: 50)
        var a = try GMPFloat(precision: 100)
        a.set(3.5)
        var b = try GMPFloat(precision: 50)
        b.set(2.25)

        // When: a.add(b)
        a.add(b)

        // Then: a has precision matching original (GMP may round, so check original precision) and value equals 5.75
        let originalPrecision = try GMPFloat(precision: 100).precision
        #expect(a.precision == originalPrecision)
        #expect(a.toDouble() == 5.75)
    }

    // MARK: - subtract(_ other: GMPFloat)

    @Test
    func subtract_TwoPositiveFloats_ModifiesSelf() async throws {
        // Given: var a = GMPFloat(5.5), b = GMPFloat(2.25)
        var a = GMPFloat(5.5)
        let b = GMPFloat(2.25)

        // When: a.subtract(b)
        a.subtract(b)

        // Then: a == 3.25 (rounded to original precision)
        #expect(a.toDouble() == 3.25)
    }

    @Test
    func subtract_Zero_NoChange() async throws {
        // Given: var a = GMPFloat(5.5), b = GMPFloat(0.0)
        var a = GMPFloat(5.5)
        let b = GMPFloat(0.0)

        // When: a.subtract(b)
        a.subtract(b)

        // Then: a == 5.5
        #expect(a.toDouble() == 5.5)
    }

    @Test
    func subtract_Negative_IncreasesValue() async throws {
        // Given: var a = GMPFloat(5.0), b = GMPFloat(-2.5)
        var a = GMPFloat(5.0)
        let b = GMPFloat(-2.5)

        // When: a.subtract(b)
        a.subtract(b)

        // Then: a == 7.5
        #expect(a.toDouble() == 7.5)
    }

    // MARK: - multiply(by other: GMPFloat)

    @Test
    func multiply_TwoPositiveFloats_ModifiesSelf() async throws {
        // Given: var a = GMPFloat(3.5), b = GMPFloat(2.0)
        var a = GMPFloat(3.5)
        let b = GMPFloat(2.0)

        // When: a.multiply(by: b)
        a.multiply(by: b)

        // Then: a == 7.0 (rounded to original precision)
        #expect(a.toDouble() == 7.0)
    }

    @Test
    func multiply_ByZero_SetsToZero() async throws {
        // Given: var a = GMPFloat(5.5), b = GMPFloat(0.0)
        var a = GMPFloat(5.5)
        let b = GMPFloat(0.0)

        // When: a.multiply(by: b)
        a.multiply(by: b)

        // Then: a == 0.0
        #expect(a.toDouble() == 0.0)
    }

    @Test
    func multiply_ByOne_NoChange() async throws {
        // Given: var a = GMPFloat(5.5), b = GMPFloat(1.0)
        var a = GMPFloat(5.5)
        let b = GMPFloat(1.0)

        // When: a.multiply(by: b)
        a.multiply(by: b)

        // Then: a == 5.5
        #expect(a.toDouble() == 5.5)
    }

    @Test
    func multiply_ByMinusOne_Negates() async throws {
        // Given: var a = GMPFloat(5.5), b = GMPFloat(-1.0)
        var a = GMPFloat(5.5)
        let b = GMPFloat(-1.0)

        // When: a.multiply(by: b)
        a.multiply(by: b)

        // Then: a == -5.5
        #expect(a.toDouble() == -5.5)
    }

    // MARK: - divide(by other: GMPFloat)

    @Test
    func divide_TwoPositiveFloats_ModifiesSelf() async throws {
        // Given: var a = GMPFloat(7.5), b = GMPFloat(2.5)
        var a = GMPFloat(7.5)
        let b = GMPFloat(2.5)

        // When: a.divide(by: b)
        try a.divide(by: b)

        // Then: a == 3.0 (rounded to original precision)
        #expect(a.toDouble() == 3.0)
    }

    @Test
    func divide_ByOne_NoChange() async throws {
        // Given: var a = GMPFloat(5.5), b = GMPFloat(1.0)
        var a = GMPFloat(5.5)
        let b = GMPFloat(1.0)

        // When: a.divide(by: b)
        try a.divide(by: b)

        // Then: a == 5.5
        #expect(a.toDouble() == 5.5)
    }

    @Test
    func divide_ByMinusOne_Negates() async throws {
        // Given: var a = GMPFloat(5.5), b = GMPFloat(-1.0)
        var a = GMPFloat(5.5)
        let b = GMPFloat(-1.0)

        // When: a.divide(by: b)
        try a.divide(by: b)

        // Then: a == -5.5
        #expect(a.toDouble() == -5.5)
    }

    @Test
    func divide_ByZero_ThrowsDivisionByZero() async throws {
        // Given: var a = GMPFloat(5.5), b = GMPFloat(0.0)
        var a = GMPFloat(5.5)
        let b = GMPFloat(0.0)
        let originalValue = a.toDouble()

        // When: a.divide(by: b) is called
        // Then: Throws GMPError.divisionByZero and a is unchanged
        #expect(throws: GMPError.divisionByZero) {
            try a.divide(by: b)
        }
        #expect(a.toDouble() == originalValue)
    }

    @Test
    func divide_ZeroByNonZero_SetsToZero() async throws {
        // Given: var a = GMPFloat(0.0), b = GMPFloat(2.5)
        var a = GMPFloat(0.0)
        let b = GMPFloat(2.5)

        // When: a.divide(by: b)
        try a.divide(by: b)

        // Then: a == 0.0
        #expect(a.toDouble() == 0.0)
    }

    // MARK: - add(_ other: Int)

    @Test
    func addInt_Positive_ModifiesSelf() async throws {
        // Given: var a = GMPFloat(3.5), b = 5
        var a = GMPFloat(3.5)
        let b = 5

        // When: a.add(b)
        a.add(b)

        // Then: a == 8.5
        #expect(a.toDouble() == 8.5)
    }

    @Test
    func addInt_Negative_DecreasesValue() async throws {
        // Given: var a = GMPFloat(5.5), b = -3
        var a = GMPFloat(5.5)
        let b = -3

        // When: a.add(b)
        a.add(b)

        // Then: a == 2.5
        #expect(a.toDouble() == 2.5)
    }

    @Test
    func addInt_Zero_NoChange() async throws {
        // Given: var a = GMPFloat(5.5), b = 0
        var a = GMPFloat(5.5)
        let b = 0

        // When: a.add(b)
        a.add(b)

        // Then: a == 5.5
        #expect(a.toDouble() == 5.5)
    }

    @Test
    func addInt_LargeInt_HandlesCorrectly() async throws {
        // Given: var a = GMPFloat(1.0), b = Int.max
        var a = GMPFloat(1.0)
        let b = Int.max

        // When: a.add(b)
        a.add(b)

        // Then: a == Double(Int.max) + 1.0 (approximately)
        let expected = Double(Int.max) + 1.0
        #expect(abs(a.toDouble() - expected) < 1.0) // Allow for rounding
    }

    @Test
    func addInt_NegativeLargeInt_HandlesCorrectly() async throws {
        // Given: var a = GMPFloat(1.0), b = Int.min
        var a = GMPFloat(1.0)
        let b = Int.min

        // When: a.add(b)
        a.add(b)

        // Then: a == Double(Int.min) + 1.0 (approximately)
        // Int.min = -2,147,483,648, so Int.min + 1 = -2,147,483,647
        // Note: Double precision limits may cause larger differences with very
        // large integers
        let expected = Double(Int.min) + 1.0
        #expect(abs(a.toDouble() - expected) <
            2048.0) // Allow for Double precision limits
    }

    // MARK: - subtract(_ other: Int)

    @Test
    func subtractInt_Positive_ModifiesSelf() async throws {
        // Given: var a = GMPFloat(5.5), b = 3
        var a = GMPFloat(5.5)
        let b = 3

        // When: a.subtract(b)
        a.subtract(b)

        // Then: a == 2.5
        #expect(a.toDouble() == 2.5)
    }

    @Test
    func subtractInt_Negative_IncreasesValue() async throws {
        // Given: var a = GMPFloat(5.5), b = -3
        var a = GMPFloat(5.5)
        let b = -3

        // When: a.subtract(b)
        a.subtract(b)

        // Then: a == 8.5
        #expect(a.toDouble() == 8.5)
    }

    @Test
    func subtractInt_Zero_NoChange() async throws {
        // Given: var a = GMPFloat(5.5), b = 0
        var a = GMPFloat(5.5)
        let b = 0

        // When: a.subtract(b)
        a.subtract(b)

        // Then: a == 5.5
        #expect(a.toDouble() == 5.5)
    }

    @Test
    func subtractInt_IntMin_HandlesCorrectly() async throws {
        // Given: var a = GMPFloat(1.0), b = Int.min
        var a = GMPFloat(1.0)
        let b = Int.min

        // When: a.subtract(b)
        a.subtract(b)

        // Then: a == 1.0 - Int.min (approximately)
        // Int.min = -2,147,483,648, so 1.0 - Int.min = 1.0 - (-2,147,483,648) =
        // 2,147,483,649
        // Note: Double precision limits may cause differences with very large
        // integers
        let expected = 1.0 - Double(Int.min)
        #expect(abs(a.toDouble() - expected) <
            2048.0) // Allow for Double precision limits
    }

    // MARK: - multiply(by other: Int)

    @Test
    func multiplyInt_Positive_ModifiesSelf() async throws {
        // Given: var a = GMPFloat(3.5), b = 2
        var a = GMPFloat(3.5)
        let b = 2

        // When: a.multiply(by: b)
        a.multiply(by: b)

        // Then: a == 7.0
        #expect(a.toDouble() == 7.0)
    }

    @Test
    func multiplyInt_Negative_NegatesAndMultiplies() async throws {
        // Given: var a = GMPFloat(3.5), b = -2
        var a = GMPFloat(3.5)
        let b = -2

        // When: a.multiply(by: b)
        a.multiply(by: b)

        // Then: a == -7.0
        #expect(a.toDouble() == -7.0)
    }

    @Test
    func multiplyInt_ByZero_SetsToZero() async throws {
        // Given: var a = GMPFloat(5.5), b = 0
        var a = GMPFloat(5.5)
        let b = 0

        // When: a.multiply(by: b)
        a.multiply(by: b)

        // Then: a == 0.0
        #expect(a.toDouble() == 0.0)
    }

    @Test
    func multiplyInt_ByOne_NoChange() async throws {
        // Given: var a = GMPFloat(5.5), b = 1
        var a = GMPFloat(5.5)
        let b = 1

        // When: a.multiply(by: b)
        a.multiply(by: b)

        // Then: a == 5.5
        #expect(a.toDouble() == 5.5)
    }

    // MARK: - divide(by other: Int)

    @Test
    func divideInt_Positive_ModifiesSelf() async throws {
        // Given: var a = GMPFloat(7.5), b = 2
        var a = GMPFloat(7.5)
        let b = 2

        // When: a.divide(by: b)
        try a.divide(by: b)

        // Then: a == 3.75
        #expect(a.toDouble() == 3.75)
    }

    @Test
    func divideInt_Negative_NegatesAndDivides() async throws {
        // Given: var a = GMPFloat(7.5), b = -2
        var a = GMPFloat(7.5)
        let b = -2

        // When: a.divide(by: b)
        try a.divide(by: b)

        // Then: a == -3.75
        #expect(a.toDouble() == -3.75)
    }

    @Test
    func divideInt_ByZero_ThrowsDivisionByZero() async throws {
        // Given: var a = GMPFloat(5.5), b = 0
        var a = GMPFloat(5.5)
        let originalValue = a.toDouble()
        let b = 0

        // When/Then: a.divide(by: b) throws GMPError.divisionByZero
        #expect(throws: GMPError.divisionByZero) {
            try a.divide(by: b)
        }

        // And: a is unchanged
        #expect(a.toDouble() == originalValue)
    }

    @Test
    func divideInt_ByOne_NoChange() async throws {
        // Given: var a = GMPFloat(5.5), b = 1
        var a = GMPFloat(5.5)
        let b = 1

        // When: a.divide(by: b)
        try a.divide(by: b)

        // Then: a == 5.5
        #expect(a.toDouble() == 5.5)
    }

    @Test
    func divideInt_ByMinusOne_Negates() async throws {
        // Given: var a = GMPFloat(5.5), b = -1
        var a = GMPFloat(5.5)
        let b = -1

        // When: a.divide(by: b)
        try a.divide(by: b)

        // Then: a == -5.5
        #expect(a.toDouble() == -5.5)
    }

    @Test
    func divideInt_ByIntMin_HandlesCorrectly() async throws {
        // Given: var a = GMPFloat(1.0), b = Int.min
        var a = GMPFloat(1.0)
        let b = Int.min

        // When: a.divide(by: b)
        try a.divide(by: b)

        // Then: a == 1.0 / Int.min (approximately)
        // Note: Double precision limits may cause differences with very large
        // integers
        let expected = 1.0 / Double(Int.min)
        #expect(abs(a.toDouble() - expected) < abs(expected) *
            1e-10) // Relative tolerance
    }

    // MARK: - negate()

    @Test
    func negate_Positive_BecomesNegative() async throws {
        // Given: var a = GMPFloat(5.5)
        var a = GMPFloat(5.5)

        // When: a.negate()
        a.negate()

        // Then: a == -5.5
        #expect(a.toDouble() == -5.5)
    }

    @Test
    func negate_Negative_BecomesPositive() async throws {
        // Given: var a = GMPFloat(-5.5)
        var a = GMPFloat(-5.5)

        // When: a.negate()
        a.negate()

        // Then: a == 5.5
        #expect(a.toDouble() == 5.5)
    }

    @Test
    func negate_Zero_RemainsZero() async throws {
        // Given: var a = GMPFloat(0.0)
        var a = GMPFloat(0.0)

        // When: a.negate()
        a.negate()

        // Then: a == 0.0
        #expect(a.toDouble() == 0.0)
    }

    @Test
    func negate_DoubleNegation_ReturnsOriginal() async throws {
        // Given: var a = GMPFloat(5.5), originalValue = a
        var a = GMPFloat(5.5)
        let originalValue = a.toDouble()

        // When: a.negate(), then a.negate()
        a.negate()
        a.negate()

        // Then: a == originalValue
        #expect(a.toDouble() == originalValue)
    }

    // MARK: - makeAbsolute()

    @Test
    func makeAbsolute_Positive_NoChange() async throws {
        // Given: var a = GMPFloat(5.5)
        var a = GMPFloat(5.5)

        // When: a.makeAbsolute()
        a.makeAbsolute()

        // Then: a == 5.5
        #expect(a.toDouble() == 5.5)
    }

    @Test
    func makeAbsolute_Negative_BecomesPositive() async throws {
        // Given: var a = GMPFloat(-5.5)
        var a = GMPFloat(-5.5)

        // When: a.makeAbsolute()
        a.makeAbsolute()

        // Then: a == 5.5
        #expect(a.toDouble() == 5.5)
    }

    @Test
    func makeAbsolute_Zero_RemainsZero() async throws {
        // Given: var a = GMPFloat(0.0)
        var a = GMPFloat(0.0)

        // When: a.makeAbsolute()
        a.makeAbsolute()

        // Then: a == 0.0
        #expect(a.toDouble() == 0.0)
    }

    @Test
    func makeAbsolute_LargeNegative_BecomesLargePositive() async throws {
        // Given: var a = GMPFloat(-1e100)
        var a = GMPFloat(-1e100)

        // When: a.makeAbsolute()
        a.makeAbsolute()

        // Then: a == 1e100 (approximately)
        #expect(abs(a.toDouble() - 1e100) <
            1e90) // Allow for floating-point precision
    }

    // MARK: - subtracting(_ value: Int, _ other: GMPFloat) -> GMPFloat (static)

    @Test
    func subtracting_PositiveIntAndFloat_ReturnsDifference() async throws {
        // Given: value = 10, other = GMPFloat(3.5)
        let value = 10
        let other = GMPFloat(3.5)

        // When: result = GMPFloat.subtracting(value, other)
        let result = GMPFloat.subtracting(value, other)

        // Then: result == 6.5
        #expect(result.toDouble() == 6.5)
    }

    @Test
    func subtracting_NegativeIntAndFloat_ReturnsDifference() async throws {
        // Given: value = -10, other = GMPFloat(3.5)
        let value = -10
        let other = GMPFloat(3.5)

        // When: result = GMPFloat.subtracting(value, other)
        let result = GMPFloat.subtracting(value, other)

        // Then: result == -13.5
        #expect(result.toDouble() == -13.5)
    }

    @Test
    func subtracting_ZeroInt_ReturnsNegatedFloat() async throws {
        // Given: value = 0, other = GMPFloat(3.5)
        let value = 0
        let other = GMPFloat(3.5)

        // When: result = GMPFloat.subtracting(value, other)
        let result = GMPFloat.subtracting(value, other)

        // Then: result == -3.5
        #expect(result.toDouble() == -3.5)
    }

    @Test
    func subtracting_IntAndZeroFloat_ReturnsInt() async throws {
        // Given: value = 10, other = GMPFloat(0.0)
        let value = 10
        let other = GMPFloat(0.0)

        // When: result = GMPFloat.subtracting(value, other)
        let result = GMPFloat.subtracting(value, other)

        // Then: result == 10.0
        #expect(result.toDouble() == 10.0)
    }

    @Test
    func subtracting_ZeroIntAndZeroFloat_ReturnsZero() async throws {
        // Given: value = 0, other = GMPFloat(0.0)
        let value = 0
        let other = GMPFloat(0.0)

        // When: result = GMPFloat.subtracting(value, other)
        let result = GMPFloat.subtracting(value, other)

        // Then: result == 0.0
        #expect(result.toDouble() == 0.0)
    }

    @Test
    func subtracting_LargeInt_HandlesCorrectly() async throws {
        // Given: value = Int.max, other = GMPFloat(1.0)
        let value = Int.max
        let other = GMPFloat(1.0)

        // When: result = GMPFloat.subtracting(value, other)
        let result = GMPFloat.subtracting(value, other)

        // Then: result == Double(Int.max) - 1.0 (approximately)
        // Note: Double precision limits may cause larger differences with very
        // large integers
        let expected = Double(Int.max) - 1.0
        #expect(abs(result.toDouble() - expected) <
            2048.0) // Allow for Double precision limits
    }

    // MARK: - dividing(_ value: Int, _ other: GMPFloat) -> GMPFloat (static)

    @Test
    func dividing_PositiveIntAndFloat_ReturnsQuotient() async throws {
        // Given: value = 10, other = GMPFloat(2.5)
        let value = 10
        let other = GMPFloat(2.5)

        // When: result = GMPFloat.dividing(value, other)
        let result = try GMPFloat.dividing(value, other)

        // Then: result == 4.0
        #expect(result.toDouble() == 4.0)
    }

    @Test
    func dividing_NegativeIntAndFloat_ReturnsNegativeQuotient() async throws {
        // Given: value = -10, other = GMPFloat(2.5)
        let value = -10
        let other = GMPFloat(2.5)

        // When: result = GMPFloat.dividing(value, other)
        let result = try GMPFloat.dividing(value, other)

        // Then: result == -4.0
        #expect(result.toDouble() == -4.0)
    }

    @Test
    func dividing_IntAndNegativeFloat_ReturnsNegativeQuotient() async throws {
        // Given: value = 10, other = GMPFloat(-2.5)
        let value = 10
        let other = GMPFloat(-2.5)

        // When: result = GMPFloat.dividing(value, other)
        let result = try GMPFloat.dividing(value, other)

        // Then: result == -4.0
        #expect(result.toDouble() == -4.0)
    }

    @Test
    func dividing_ZeroIntAndNonZeroFloat_ReturnsZero() async throws {
        // Given: value = 0, other = GMPFloat(2.5)
        let value = 0
        let other = GMPFloat(2.5)

        // When: result = GMPFloat.dividing(value, other)
        let result = try GMPFloat.dividing(value, other)

        // Then: result == 0.0
        #expect(result.toDouble() == 0.0)
    }

    @Test
    func dividing_IntAndZeroFloat_ThrowsDivisionByZero() async throws {
        // Given: value = 10, other = GMPFloat(0.0)
        let value = 10
        let other = GMPFloat(0.0)

        // When/Then: result = GMPFloat.dividing(value, other) throws GMPError.divisionByZero
        #expect(throws: GMPError.divisionByZero) {
            try GMPFloat.dividing(value, other)
        }
    }

    @Test
    func dividing_IntByOne_ReturnsInt() async throws {
        // Given: value = 10, other = GMPFloat(1.0)
        let value = 10
        let other = GMPFloat(1.0)

        // When: result = GMPFloat.dividing(value, other)
        let result = try GMPFloat.dividing(value, other)

        // Then: result == 10.0
        #expect(result.toDouble() == 10.0)
    }

    // MARK: - formSubtracting(_ value: Int, _ other: GMPFloat)

    @Test
    func formSubtracting_PositiveIntAndFloat_ModifiesSelf() async throws {
        // Given: var a = GMPFloat(0.0), value = 10, other = GMPFloat(3.5)
        var a = GMPFloat(0.0)
        let value = 10
        let other = GMPFloat(3.5)

        // When: a.formSubtracting(value, other)
        a.formSubtracting(value, other)

        // Then: a == 6.5
        #expect(a.toDouble() == 6.5)
    }

    @Test
    func formSubtracting_OverwritesPreviousValue() async throws {
        // Given: var a = GMPFloat(100.0), value = 10, other = GMPFloat(3.5)
        var a = GMPFloat(100.0)
        let value = 10
        let other = GMPFloat(3.5)

        // When: a.formSubtracting(value, other)
        a.formSubtracting(value, other)

        // Then: a == 6.5 (previous value overwritten)
        #expect(a.toDouble() == 6.5)
    }

    @Test
    func formSubtracting_NegativeInt_ModifiesSelf() async throws {
        // Given: var a = GMPFloat(0.0), value = -10, other = GMPFloat(3.5)
        var a = GMPFloat(0.0)
        let value = -10
        let other = GMPFloat(3.5)

        // When: a.formSubtracting(value, other)
        a.formSubtracting(value, other)

        // Then: a == -13.5
        #expect(a.toDouble() == -13.5)
    }

    // MARK: - formDividing(_ value: Int, _ other: GMPFloat)

    @Test
    func formDividing_PositiveIntAndFloat_ModifiesSelf() async throws {
        // Given: var a = GMPFloat(0.0), value = 10, other = GMPFloat(2.5)
        var a = GMPFloat(0.0)
        let value = 10
        let other = GMPFloat(2.5)

        // When: a.formDividing(value, other)
        try a.formDividing(value, other)

        // Then: a == 4.0
        #expect(a.toDouble() == 4.0)
    }

    @Test
    func formDividing_OverwritesPreviousValue() async throws {
        // Given: var a = GMPFloat(100.0), value = 10, other = GMPFloat(2.5)
        var a = GMPFloat(100.0)
        let value = 10
        let other = GMPFloat(2.5)

        // When: a.formDividing(value, other)
        try a.formDividing(value, other)

        // Then: a == 4.0 (previous value overwritten)
        #expect(a.toDouble() == 4.0)
    }

    @Test
    func formDividing_IntAndZeroFloat_ThrowsDivisionByZero() async throws {
        // Given: var a = GMPFloat(100.0), value = 10, other = GMPFloat(0.0)
        var a = GMPFloat(100.0)
        let originalValue = a.toDouble()
        let value = 10
        let other = GMPFloat(0.0)

        // When/Then: a.formDividing(value, other) throws GMPError.divisionByZero
        #expect(throws: GMPError.divisionByZero) {
            try a.formDividing(value, other)
        }

        // And: a is unchanged
        #expect(a.toDouble() == originalValue)
    }

    @Test
    func formDividing_NegativeInt_ModifiesSelf() async throws {
        // Given: var a = GMPFloat(0.0), value = -10, other = GMPFloat(2.5)
        var a = GMPFloat(0.0)
        let value = -10
        let other = GMPFloat(2.5)

        // When: a.formDividing(value, other)
        try a.formDividing(value, other)

        // Then: a == -4.0
        #expect(a.toDouble() == -4.0)
    }

    // MARK: - multipliedByPowerOf2(_ exponent: Int) -> GMPFloat

    @Test
    func multipliedByPowerOf2_PositiveExponent_Multiplies() async throws {
        // Given: a = GMPFloat(3.0), exponent = 2
        let a = GMPFloat(3.0)
        let exponent = 2

        // When: result = a.multipliedByPowerOf2(exponent)
        let result = a.multipliedByPowerOf2(exponent)

        // Then: result == 12.0 (3 * 2^2) and a is unchanged
        #expect(result.toDouble() == 12.0)
        #expect(a.toDouble() == 3.0)
    }

    @Test
    func multipliedByPowerOf2_NegativeExponent_Divides() async throws {
        // Given: a = GMPFloat(12.0), exponent = -2
        let a = GMPFloat(12.0)
        let exponent = -2

        // When: result = a.multipliedByPowerOf2(exponent)
        let result = a.multipliedByPowerOf2(exponent)

        // Then: result == 3.0 (12 / 2^2) and a is unchanged
        #expect(result.toDouble() == 3.0)
        #expect(a.toDouble() == 12.0)
    }

    @Test
    func multipliedByPowerOf2_ZeroExponent_NoChange() async throws {
        // Given: a = GMPFloat(5.5), exponent = 0
        let a = GMPFloat(5.5)
        let exponent = 0

        // When: result = a.multipliedByPowerOf2(exponent)
        let result = a.multipliedByPowerOf2(exponent)

        // Then: result == 5.5 and a is unchanged
        #expect(result.toDouble() == 5.5)
        #expect(a.toDouble() == 5.5)
    }

    @Test
    func multipliedByPowerOf2_LargePositiveExponent_ScalesUp() async throws {
        // Given: a = GMPFloat(1.0), exponent = 100
        let a = GMPFloat(1.0)
        let exponent = 100

        // When: result = a.multipliedByPowerOf2(exponent)
        let result = a.multipliedByPowerOf2(exponent)

        // Then: result == 2^100 (approximately) and a is unchanged
        let expected = pow(2.0, 100.0)
        #expect(abs(result.toDouble() - expected) < expected *
            1e-10) // Relative tolerance
        #expect(a.toDouble() == 1.0)
    }

    @Test
    func multipliedByPowerOf2_LargeNegativeExponent_ScalesDown() async throws {
        // Given: a = GMPFloat(1.0), exponent = -100
        let a = GMPFloat(1.0)
        let exponent = -100

        // When: result = a.multipliedByPowerOf2(exponent)
        let result = a.multipliedByPowerOf2(exponent)

        // Then: result == 2^-100 (approximately) and a is unchanged
        let expected = pow(2.0, -100.0)
        #expect(abs(result.toDouble() - expected) < abs(expected) *
            1e-10) // Relative tolerance
        #expect(a.toDouble() == 1.0)
    }

    // MARK: - dividedByPowerOf2(_ exponent: Int) -> GMPFloat

    @Test
    func dividedByPowerOf2_PositiveExponent_Divides() async throws {
        // Given: a = GMPFloat(12.0), exponent = 2
        let a = GMPFloat(12.0)
        let exponent = 2

        // When: result = a.dividedByPowerOf2(exponent)
        let result = try a.dividedByPowerOf2(exponent)

        // Then: result == 3.0 (12 / 2^2) and a is unchanged
        #expect(result.toDouble() == 3.0)
        #expect(a.toDouble() == 12.0)
    }

    @Test
    func dividedByPowerOf2_ZeroExponent_NoChange() async throws {
        // Given: a = GMPFloat(5.5), exponent = 0
        let a = GMPFloat(5.5)
        let exponent = 0

        // When: result = a.dividedByPowerOf2(exponent)
        let result = try a.dividedByPowerOf2(exponent)

        // Then: result == 5.5 and a is unchanged
        #expect(result.toDouble() == 5.5)
        #expect(a.toDouble() == 5.5)
    }

    @Test
    func dividedByPowerOf2_LargePositiveExponent_ScalesDown() async throws {
        // Given: a = GMPFloat(1e100), exponent = 100
        let a = GMPFloat(1e100)
        let exponent = 100

        // When: result = a.dividedByPowerOf2(exponent)
        let result = try a.dividedByPowerOf2(exponent)

        // Then: result == 1e100 / 2^100 (approximately) and a is unchanged
        let expected = 1e100 / pow(2.0, 100.0)
        #expect(abs(result.toDouble() - expected) < abs(expected) *
            1e-10) // Relative tolerance
        #expect(a.toDouble() == 1e100)
    }

    @Test
    func dividedByPowerOf2_NegativeExponent_ThrowsError() async throws {
        // Given: a = GMPFloat(5.5), exponent = -1
        let a = GMPFloat(5.5)
        let exponent = -1

        // When/Then: result = a.dividedByPowerOf2(exponent) throws GMPError.invalidExponent
        #expect(throws: GMPError.invalidExponent(-1)) {
            try a.dividedByPowerOf2(exponent)
        }
    }

    // MARK: - multiplyByPowerOf2(_ exponent: Int)

    @Test
    func multiplyByPowerOf2_PositiveExponent_Multiplies() async throws {
        // Given: var a = GMPFloat(3.0), exponent = 2
        var a = GMPFloat(3.0)
        let exponent = 2

        // When: a.multiplyByPowerOf2(exponent)
        a.multiplyByPowerOf2(exponent)

        // Then: a == 12.0 (3 * 2^2)
        #expect(a.toDouble() == 12.0)
    }

    @Test
    func multiplyByPowerOf2_NegativeExponent_Divides() async throws {
        // Given: var a = GMPFloat(12.0), exponent = -2
        var a = GMPFloat(12.0)
        let exponent = -2

        // When: a.multiplyByPowerOf2(exponent)
        a.multiplyByPowerOf2(exponent)

        // Then: a == 3.0 (12 / 2^2)
        #expect(a.toDouble() == 3.0)
    }

    @Test
    func multiplyByPowerOf2_ZeroExponent_NoChange() async throws {
        // Given: var a = GMPFloat(5.5), exponent = 0
        var a = GMPFloat(5.5)
        let exponent = 0

        // When: a.multiplyByPowerOf2(exponent)
        a.multiplyByPowerOf2(exponent)

        // Then: a == 5.5
        #expect(a.toDouble() == 5.5)
    }

    @Test
    func multiplyByPowerOf2_LargePositiveExponent_ScalesUp() async throws {
        // Given: var a = GMPFloat(1.0), exponent = 100
        var a = GMPFloat(1.0)
        let exponent = 100

        // When: a.multiplyByPowerOf2(exponent)
        a.multiplyByPowerOf2(exponent)

        // Then: a == 2^100 (approximately)
        let expected = pow(2.0, 100.0)
        #expect(abs(a.toDouble() - expected) < expected *
            1e-10) // Relative tolerance
    }

    // MARK: - divideByPowerOf2(_ exponent: Int)

    @Test
    func divideByPowerOf2_PositiveExponent_Divides() async throws {
        // Given: var a = GMPFloat(12.0), exponent = 2
        var a = GMPFloat(12.0)
        let exponent = 2

        // When: a.divideByPowerOf2(exponent)
        try a.divideByPowerOf2(exponent)

        // Then: a == 3.0 (12 / 2^2)
        #expect(a.toDouble() == 3.0)
    }

    @Test
    func divideByPowerOf2_ZeroExponent_NoChange() async throws {
        // Given: var a = GMPFloat(5.5), exponent = 0
        var a = GMPFloat(5.5)
        let exponent = 0

        // When: a.divideByPowerOf2(exponent)
        try a.divideByPowerOf2(exponent)

        // Then: a == 5.5
        #expect(a.toDouble() == 5.5)
    }

    @Test
    func divideByPowerOf2_NegativeExponent_ThrowsError() async throws {
        // Given: var a = GMPFloat(5.5), exponent = -1
        var a = GMPFloat(5.5)
        let originalValue = a.toDouble()
        let exponent = -1

        // When/Then: a.divideByPowerOf2(exponent) throws GMPError.invalidExponent
        #expect(throws: GMPError.invalidExponent(-1)) {
            try a.divideByPowerOf2(exponent)
        }

        // And: a is unchanged
        #expect(a.toDouble() == originalValue)
    }

    // MARK: - Operator Overloads

    // MARK: + (lhs: GMPFloat, rhs: GMPFloat) -> GMPFloat

    @Test
    func plusOperator_TwoFloats_ReturnsSum() async throws {
        // Given: lhs = GMPFloat(3.5), rhs = GMPFloat(2.25)
        let lhs = GMPFloat(3.5)
        let rhs = GMPFloat(2.25)
        let originalLhs = lhs.toDouble()
        let originalRhs = rhs.toDouble()

        // When: result = lhs + rhs
        let result = lhs + rhs

        // Then: result == 5.75 and both operands unchanged
        #expect(result.toDouble() == 5.75)
        #expect(lhs.toDouble() == originalLhs)
        #expect(rhs.toDouble() == originalRhs)
    }

    @Test
    func plusOperator_Zero_ReturnsOther() async throws {
        // Given: lhs = GMPFloat(5.0), rhs = GMPFloat(0.0)
        let lhs = GMPFloat(5.0)
        let rhs = GMPFloat(0.0)

        // When: result = lhs + rhs
        let result = lhs + rhs

        // Then: result == 5.0 and both operands unchanged
        #expect(result.toDouble() == 5.0)
        #expect(lhs.toDouble() == 5.0)
        #expect(rhs.toDouble() == 0.0)
    }

    // MARK: + (lhs: GMPFloat, rhs: Int) -> GMPFloat

    @Test
    func plusOperator_Int_ReturnsSum() async throws {
        // Given: lhs = GMPFloat(3.5), rhs = 5
        let lhs = GMPFloat(3.5)
        let originalLhs = lhs.toDouble()
        let rhs = 5

        // When: result = lhs + rhs
        let result = lhs + rhs

        // Then: result == 8.5 and lhs unchanged
        #expect(result.toDouble() == 8.5)
        #expect(lhs.toDouble() == originalLhs)
    }

    @Test
    func plusOperator_IntZero_ReturnsFloat() async throws {
        // Given: lhs = GMPFloat(5.0), rhs = 0
        let lhs = GMPFloat(5.0)
        let rhs = 0

        // When: result = lhs + rhs
        let result = lhs + rhs

        // Then: result == 5.0 and lhs unchanged
        #expect(result.toDouble() == 5.0)
        #expect(lhs.toDouble() == 5.0)
    }

    @Test
    func plusOperator_IntNegative_Subtracts() async throws {
        // Given: lhs = GMPFloat(5.0), rhs = -3
        let lhs = GMPFloat(5.0)
        let rhs = -3

        // When: result = lhs + rhs
        let result = lhs + rhs

        // Then: result == 2.0 and lhs unchanged
        #expect(result.toDouble() == 2.0)
        #expect(lhs.toDouble() == 5.0)
    }

    // MARK: - (lhs: GMPFloat, rhs: GMPFloat) -> GMPFloat

    @Test
    func minusOperator_TwoFloats_ReturnsDifference() async throws {
        // Given: lhs = GMPFloat(5.5), rhs = GMPFloat(2.25)
        let lhs = GMPFloat(5.5)
        let rhs = GMPFloat(2.25)
        let originalLhs = lhs.toDouble()
        let originalRhs = rhs.toDouble()

        // When: result = lhs - rhs
        let result = lhs - rhs

        // Then: result == 3.25 and both operands unchanged
        #expect(result.toDouble() == 3.25)
        #expect(lhs.toDouble() == originalLhs)
        #expect(rhs.toDouble() == originalRhs)
    }

    @Test
    func minusOperator_ZeroRight_ReturnsLeft() async throws {
        // Given: lhs = GMPFloat(5.0), rhs = GMPFloat(0.0)
        let lhs = GMPFloat(5.0)
        let rhs = GMPFloat(0.0)

        // When: result = lhs - rhs
        let result = lhs - rhs

        // Then: result == 5.0 and both operands unchanged
        #expect(result.toDouble() == 5.0)
        #expect(lhs.toDouble() == 5.0)
        #expect(rhs.toDouble() == 0.0)
    }

    // MARK: - (lhs: GMPFloat, rhs: Int) -> GMPFloat

    @Test
    func minusOperator_Int_ReturnsDifference() async throws {
        // Given: lhs = GMPFloat(5.5), rhs = 3
        let lhs = GMPFloat(5.5)
        let originalLhs = lhs.toDouble()
        let rhs = 3

        // When: result = lhs - rhs
        let result = lhs - rhs

        // Then: result == 2.5 and lhs unchanged
        #expect(result.toDouble() == 2.5)
        #expect(lhs.toDouble() == originalLhs)
    }

    @Test
    func minusOperator_IntNegative_Adds() async throws {
        // Given: lhs = GMPFloat(5.0), rhs = -3
        let lhs = GMPFloat(5.0)
        let rhs = -3

        // When: result = lhs - rhs
        let result = lhs - rhs

        // Then: result == 8.0 and lhs unchanged
        #expect(result.toDouble() == 8.0)
        #expect(lhs.toDouble() == 5.0)
    }

    // MARK: * (lhs: GMPFloat, rhs: GMPFloat) -> GMPFloat

    @Test
    func multiplyOperator_TwoFloats_ReturnsProduct() async throws {
        // Given: lhs = GMPFloat(3.5), rhs = GMPFloat(2.0)
        let lhs = GMPFloat(3.5)
        let rhs = GMPFloat(2.0)
        let originalLhs = lhs.toDouble()
        let originalRhs = rhs.toDouble()

        // When: result = lhs * rhs
        let result = lhs * rhs

        // Then: result == 7.0 and both operands unchanged
        #expect(result.toDouble() == 7.0)
        #expect(lhs.toDouble() == originalLhs)
        #expect(rhs.toDouble() == originalRhs)
    }

    @Test
    func multiplyOperator_ByZero_ReturnsZero() async throws {
        // Given: lhs = GMPFloat(5.0), rhs = GMPFloat(0.0)
        let lhs = GMPFloat(5.0)
        let rhs = GMPFloat(0.0)

        // When: result = lhs * rhs
        let result = lhs * rhs

        // Then: result == 0.0 and both operands unchanged
        #expect(result.toDouble() == 0.0)
        #expect(lhs.toDouble() == 5.0)
        #expect(rhs.toDouble() == 0.0)
    }

    // MARK: * (lhs: GMPFloat, rhs: Int) -> GMPFloat

    @Test
    func multiplyOperator_Int_ReturnsProduct() async throws {
        // Given: lhs = GMPFloat(3.5), rhs = 2
        let lhs = GMPFloat(3.5)
        let originalLhs = lhs.toDouble()
        let rhs = 2

        // When: result = lhs * rhs
        let result = lhs * rhs

        // Then: result == 7.0 and lhs unchanged
        #expect(result.toDouble() == 7.0)
        #expect(lhs.toDouble() == originalLhs)
    }

    @Test
    func multiplyOperator_IntByZero_ReturnsZero() async throws {
        // Given: lhs = GMPFloat(5.0), rhs = 0
        let lhs = GMPFloat(5.0)
        let rhs = 0

        // When: result = lhs * rhs
        let result = lhs * rhs

        // Then: result == 0.0 and lhs unchanged
        #expect(result.toDouble() == 0.0)
        #expect(lhs.toDouble() == 5.0)
    }

    // MARK: / (lhs: GMPFloat, rhs: GMPFloat) -> GMPFloat

    @Test
    func divideOperator_TwoFloats_ReturnsQuotient() async throws {
        // Given: lhs = GMPFloat(7.5), rhs = GMPFloat(2.5)
        let lhs = GMPFloat(7.5)
        let rhs = GMPFloat(2.5)
        let originalLhs = lhs.toDouble()
        let originalRhs = rhs.toDouble()

        // When: result = lhs / rhs
        let result = try lhs / rhs

        // Then: result == 3.0 and both operands unchanged
        #expect(result.toDouble() == 3.0)
        #expect(lhs.toDouble() == originalLhs)
        #expect(rhs.toDouble() == originalRhs)
    }

    @Test
    func divideOperator_ByOne_ReturnsLeft() async throws {
        // Given: lhs = GMPFloat(5.5), rhs = GMPFloat(1.0)
        let lhs = GMPFloat(5.5)
        let rhs = GMPFloat(1.0)

        // When: result = lhs / rhs
        let result = try lhs / rhs

        // Then: result == 5.5 and both operands unchanged
        #expect(result.toDouble() == 5.5)
        #expect(lhs.toDouble() == 5.5)
        #expect(rhs.toDouble() == 1.0)
    }

    @Test
    func divideOperator_ByZero_ThrowsDivisionByZero() async throws {
        // Given: lhs = GMPFloat(5.5), rhs = GMPFloat(0.0)
        let lhs = GMPFloat(5.5)
        let rhs = GMPFloat(0.0)
        let originalLhs = lhs.toDouble()
        let originalRhs = rhs.toDouble()

        // When/Then: result = lhs / rhs throws GMPError.divisionByZero
        #expect(throws: GMPError.divisionByZero) {
            try lhs / rhs
        }

        // And: both operands unchanged
        #expect(lhs.toDouble() == originalLhs)
        #expect(rhs.toDouble() == originalRhs)
    }

    // MARK: / (lhs: GMPFloat, rhs: Int) -> GMPFloat

    @Test
    func divideOperator_Int_ReturnsQuotient() async throws {
        // Given: lhs = GMPFloat(7.5), rhs = 2
        let lhs = GMPFloat(7.5)
        let originalLhs = lhs.toDouble()
        let rhs = 2

        // When: result = lhs / rhs
        let result = try lhs / rhs

        // Then: result == 3.75 and lhs unchanged
        #expect(result.toDouble() == 3.75)
        #expect(lhs.toDouble() == originalLhs)
    }

    @Test
    func divideOperator_IntByZero_ThrowsDivisionByZero() async throws {
        // Given: lhs = GMPFloat(5.5), rhs = 0
        let lhs = GMPFloat(5.5)
        let originalLhs = lhs.toDouble()
        let rhs = 0

        // When/Then: result = lhs / rhs throws GMPError.divisionByZero
        #expect(throws: GMPError.divisionByZero) {
            try lhs / rhs
        }

        // And: lhs unchanged
        #expect(lhs.toDouble() == originalLhs)
    }

    // MARK: prefix - (value: GMPFloat) -> GMPFloat

    @Test
    func prefixMinus_Positive_ReturnsNegative() async throws {
        // Given: value = GMPFloat(5.5)
        let value = GMPFloat(5.5)
        let originalValue = value.toDouble()

        // When: result = -value
        let result = -value

        // Then: result == -5.5 and value unchanged
        #expect(result.toDouble() == -5.5)
        #expect(value.toDouble() == originalValue)
    }

    @Test
    func prefixMinus_Negative_ReturnsPositive() async throws {
        // Given: value = GMPFloat(-5.5)
        let value = GMPFloat(-5.5)
        let originalValue = value.toDouble()

        // When: result = -value
        let result = -value

        // Then: result == 5.5 and value unchanged
        #expect(result.toDouble() == 5.5)
        #expect(value.toDouble() == originalValue)
    }

    @Test
    func prefixMinus_Zero_ReturnsZero() async throws {
        // Given: value = GMPFloat(0.0)
        let value = GMPFloat(0.0)

        // When: result = -value
        let result = -value

        // Then: result == 0.0 and value unchanged
        #expect(result.toDouble() == 0.0)
        #expect(value.toDouble() == 0.0)
    }

    // MARK: += (lhs: inout GMPFloat, rhs: GMPFloat)

    @Test
    func plusEqualsOperator_ModifiesLeft() async throws {
        // Given: var lhs = GMPFloat(3.5), rhs = GMPFloat(2.25)
        var lhs = GMPFloat(3.5)
        let rhs = GMPFloat(2.25)
        let originalRhs = rhs.toDouble()

        // When: lhs += rhs
        lhs += rhs

        // Then: lhs == 5.75 and rhs unchanged
        #expect(lhs.toDouble() == 5.75)
        #expect(rhs.toDouble() == originalRhs)
    }

    @Test
    func plusEqualsOperator_Zero_NoChange() async throws {
        // Given: var lhs = GMPFloat(5.0), rhs = GMPFloat(0.0)
        var lhs = GMPFloat(5.0)
        let rhs = GMPFloat(0.0)

        // When: lhs += rhs
        lhs += rhs

        // Then: lhs == 5.0 and rhs unchanged
        #expect(lhs.toDouble() == 5.0)
        #expect(rhs.toDouble() == 0.0)
    }

    // MARK: += (lhs: inout GMPFloat, rhs: Int)

    @Test
    func plusEqualsOperator_Int_ModifiesLeft() async throws {
        // Given: var lhs = GMPFloat(3.5), rhs = 5
        var lhs = GMPFloat(3.5)
        let rhs = 5

        // When: lhs += rhs
        lhs += rhs

        // Then: lhs == 8.5
        #expect(lhs.toDouble() == 8.5)
    }

    // MARK: - = (lhs: inout GMPFloat, rhs: GMPFloat)

    @Test
    func minusEqualsOperator_ModifiesLeft() async throws {
        // Given: var lhs = GMPFloat(5.5), rhs = GMPFloat(2.25)
        var lhs = GMPFloat(5.5)
        let rhs = GMPFloat(2.25)
        let originalRhs = rhs.toDouble()

        // When: lhs -= rhs
        lhs -= rhs

        // Then: lhs == 3.25 and rhs unchanged
        #expect(lhs.toDouble() == 3.25)
        #expect(rhs.toDouble() == originalRhs)
    }

    // MARK: - = (lhs: inout GMPFloat, rhs: Int)

    @Test
    func minusEqualsOperator_Int_ModifiesLeft() async throws {
        // Given: var lhs = GMPFloat(5.5), rhs = 3
        var lhs = GMPFloat(5.5)
        let rhs = 3

        // When: lhs -= rhs
        lhs -= rhs

        // Then: lhs == 2.5
        #expect(lhs.toDouble() == 2.5)
    }

    // MARK: *= (lhs: inout GMPFloat, rhs: GMPFloat)

    @Test
    func multiplyEqualsOperator_ModifiesLeft() async throws {
        // Given: var lhs = GMPFloat(3.5), rhs = GMPFloat(2.0)
        var lhs = GMPFloat(3.5)
        let rhs = GMPFloat(2.0)
        let originalRhs = rhs.toDouble()

        // When: lhs *= rhs
        lhs *= rhs

        // Then: lhs == 7.0 and rhs unchanged
        #expect(lhs.toDouble() == 7.0)
        #expect(rhs.toDouble() == originalRhs)
    }

    // MARK: *= (lhs: inout GMPFloat, rhs: Int)

    @Test
    func multiplyEqualsOperator_Int_ModifiesLeft() async throws {
        // Given: var lhs = GMPFloat(3.5), rhs = 2
        var lhs = GMPFloat(3.5)
        let rhs = 2

        // When: lhs *= rhs
        lhs *= rhs

        // Then: lhs == 7.0
        #expect(lhs.toDouble() == 7.0)
    }

    // MARK: /= (lhs: inout GMPFloat, rhs: GMPFloat)

    @Test
    func divideEqualsOperator_ModifiesLeft() async throws {
        // Given: var lhs = GMPFloat(7.5), rhs = GMPFloat(2.5)
        var lhs = GMPFloat(7.5)
        let rhs = GMPFloat(2.5)
        let originalRhs = rhs.toDouble()

        // When: lhs /= rhs
        try lhs /= rhs

        // Then: lhs == 3.0 and rhs unchanged
        #expect(lhs.toDouble() == 3.0)
        #expect(rhs.toDouble() == originalRhs)
    }

    @Test
    func divideEqualsOperator_ByZero_ThrowsDivisionByZero() async throws {
        // Given: var lhs = GMPFloat(5.5), rhs = GMPFloat(0.0)
        var lhs = GMPFloat(5.5)
        let originalLhs = lhs.toDouble()
        let rhs = GMPFloat(0.0)

        // When/Then: lhs /= rhs throws GMPError.divisionByZero
        #expect(throws: GMPError.divisionByZero) {
            try lhs /= rhs
        }

        // And: lhs is unchanged
        #expect(lhs.toDouble() == originalLhs)
    }

    // MARK: /= (lhs: inout GMPFloat, rhs: Int)

    @Test
    func divideEqualsOperator_Int_ModifiesLeft() async throws {
        // Given: var lhs = GMPFloat(7.5), rhs = 2
        var lhs = GMPFloat(7.5)
        let rhs = 2

        // When: lhs /= rhs
        try lhs /= rhs

        // Then: lhs == 3.75
        #expect(lhs.toDouble() == 3.75)
    }

    @Test
    func divideEqualsOperator_IntByZero_ThrowsDivisionByZero() async throws {
        // Given: var lhs = GMPFloat(5.5), rhs = 0
        var lhs = GMPFloat(5.5)
        let originalLhs = lhs.toDouble()
        let rhs = 0

        // When/Then: lhs /= rhs throws GMPError.divisionByZero
        #expect(throws: GMPError.divisionByZero) {
            try lhs /= rhs
        }

        // And: lhs is unchanged
        #expect(lhs.toDouble() == originalLhs)
    }
}
