import CKalliope // Import CKalliope first so gmp.h is available
import CLinus
import CLinusBridge
import Kalliope
@testable import Linus
import Testing

/// Tests for MPFRFloat Basic Arithmetic operations
struct MPFRFloatArithmeticTests {
    // MARK: - Section 1: Immutable Operations

    // MARK: - adding(_ other: MPFRFloat, rounding: MPFRRoundingMode) -> (result: MPFRFloat, ternary: Int)

    @Test
    func adding_BasicValues_ReturnsSum() async throws {
        // Test Case 1: Table Test
        let testCases: [(
            a: Double,
            b: Double,
            expectedResult: Double,
            expectedTernary: Int?,
            notes: String
        )] = [
            (3.14, 2.71, 5.85, nil, "Positive numbers"),
            (-3.14, -2.71, -5.85, nil, "Negative numbers"),
            (3.14, -2.71, 0.43, nil, "Mixed signs"),
            (3.14, 0.0, 3.14, 0, "Adding zero"),
        ]

        for testCase in testCases {
            // Given: let a = MPFRFloat(a, precision: 64) and let b = MPFRFloat(b, precision: 64)
            let a = MPFRFloat(testCase.a, precision: 64)
            let b = MPFRFloat(testCase.b, precision: 64)
            let originalA = a.toDouble()

            // When: Calling let (result, ternary) = a.adding(b, rounding: .nearest)
            let (result, ternary) = a.adding(b, rounding: .nearest)

            // Then: Result matches expected result, a is unchanged, ternary matches expected
            #expect(
                abs(result.toDouble() - testCase.expectedResult) < 0.01,
                "Result should be approximately \(testCase.expectedResult) for \(testCase.notes)"
            )
            #expect(
                a.toDouble() == originalA,
                "Original value should be unchanged for \(testCase.notes)"
            )
            if let expectedTernary = testCase.expectedTernary {
                #expect(
                    ternary == expectedTernary,
                    "Ternary should be \(expectedTernary) for \(testCase.notes)"
                )
            } else {
                // Ternary indicates rounding (may be non-zero)
                #expect(
                    ternary == -1 || ternary == 0 || ternary == 1,
                    "Ternary should be -1, 0, or 1 for \(testCase.notes)"
                )
            }
        }
    }

    @Test
    func adding_Infinity_Works() async throws {
        // Test Case 2: Table Test
        let testCases: [(
            a: Double,
            b: Double,
            expectedIsInfinity: Bool,
            expectedIsNaN: Bool,
            expectedSign: Int?,
            notes: String
        )] = [
            (3.14, Double.infinity, true, false, 1, "Adding positive infinity"),
            (
                3.14,
                -Double.infinity,
                true,
                false,
                -1,
                "Adding negative infinity"
            ),
            (
                Double.infinity,
                Double.infinity,
                true,
                false,
                1,
                "Infinity plus infinity"
            ),
            (
                Double.infinity,
                -Double.infinity,
                false,
                true,
                nil,
                "Infinity minus infinity"
            ),
        ]

        for testCase in testCases {
            // Given: let a = MPFRFloat(a, precision: 64) and let b = MPFRFloat(b, precision: 64)
            let a = MPFRFloat(testCase.a, precision: 64)
            let b = MPFRFloat(testCase.b, precision: 64)

            // When: Calling let (result, ternary) = a.adding(b, rounding: .nearest)
            let (result, _) = a.adding(b, rounding: .nearest)

            // Then: Result matches expected result from table
            if testCase.expectedIsNaN {
                #expect(
                    result.isNaN,
                    "Result should be NaN for \(testCase.notes)"
                )
            } else if testCase.expectedIsInfinity {
                #expect(
                    result.isInfinity,
                    "Result should be infinity for \(testCase.notes)"
                )
                if let expectedSign = testCase.expectedSign {
                    #expect(
                        result.sign == expectedSign,
                        "Result sign should be \(expectedSign) for \(testCase.notes)"
                    )
                }
            }
        }
    }

    @Test
    func adding_NaN_ReturnsNaN() async throws {
        // Test Case 3
        // Given: let a = MPFRFloat(3.14, precision: 64) and let b = MPFRFloat() (NaN)
        let a = MPFRFloat(3.14, precision: 64)
        let b = MPFRFloat() // NaN

        // When: Calling let (result, ternary) = a.adding(b, rounding: .nearest)
        let (result, _) = a.adding(b, rounding: .nearest)

        // Then: Returns NaN
        #expect(result.isNaN, "Adding NaN should return NaN")
    }

    @Test
    func adding_DifferentPrecisions_Works() async throws {
        // Test Case 4: Table Test
        let testCases: [(
            aValue: Double,
            aPrecision: Int,
            bValue: Double,
            bPrecision: Int,
            resultPrecision: Int
        )] = [
            (3.14, 32, 2.71, 64, 32),
            (3.14, 64, 2.71, 32, 64),
            (3.14, 128, 2.71, 256, 128),
        ]

        for testCase in testCases {
            // Given: let a = MPFRFloat(aValue, precision: aPrecision) and
            // let b = MPFRFloat(bValue, precision: bPrecision)
            let a = MPFRFloat(testCase.aValue, precision: testCase.aPrecision)
            let b = MPFRFloat(testCase.bValue, precision: testCase.bPrecision)

            // When: Calling let (result, ternary) = a.adding(b, rounding: .nearest)
            let (result, _) = a.adding(b, rounding: .nearest)

            // Then: Operation succeeds, result has precision matching result
            // precision from table, and result value is approximately aValue +
            // bValue
            #expect(
                result.precision == testCase.resultPrecision,
                "Result precision should be \(testCase.resultPrecision), got \(result.precision)"
            )
            let expectedValue = testCase.aValue + testCase.bValue
            #expect(
                abs(result.toDouble() - expectedValue) < 0.01,
                "Result value should be approximately \(expectedValue)"
            )
        }
    }

    @Test
    func adding_AllRoundingModes_Works() async throws {
        // Test Case 5: Table Test
        // Note: With precision 2, 1.5 + 1.5 = 3.0 exactly, so rounding behavior
        // may vary
        // We test that all rounding modes work without crashing and produce
        // valid results
        let testCases: [(mode: MPFRRoundingMode, a: Double, b: Double)] = [
            (.nearest, 1.5, 1.5),
            (.towardZero, 1.5, 1.5),
            (.towardPositiveInfinity, 1.5, 1.5),
            (.towardNegativeInfinity, 1.5, 1.5),
        ]

        for testCase in testCases {
            // Given: let a = MPFRFloat(a, precision: 2) and
            // let b = MPFRFloat(b, precision: 2) with rounding mode from table
            let a = MPFRFloat(testCase.a, precision: 2)
            let b = MPFRFloat(testCase.b, precision: 2)

            // When: Calling let (result, _) = a.adding(b, rounding: mode)
            let (result, ternary) = a.adding(b, rounding: testCase.mode)

            // Then: Result matches expected rounding behavior
            // With precision 2, 1.5 + 1.5 = 3.0, which may round to 2.0 or 3.0
            // depending on mode
            let resultValue = result.toDouble()
            #expect(
                resultValue == 2.0 || resultValue == 3.0 || resultValue == 4.0,
                "Result \(resultValue) should be a valid rounded value for mode \(testCase.mode)"
            )
            #expect(
                ternary == -1 || ternary == 0 || ternary == 1,
                "Ternary should be -1, 0, or 1 for mode \(testCase.mode)"
            )
        }
    }

    @Test
    func adding_ReturnsTernary() async throws {
        // Test Case 6
        // Given: let a = MPFRFloat(1.5, precision: 2) and let b = MPFRFloat(1.5, precision: 2)
        let a = MPFRFloat(1.5, precision: 2)
        let b = MPFRFloat(1.5, precision: 2)

        // When: Calling let (result, ternary) = a.adding(b, rounding: .nearest)
        let (_, ternary) = a.adding(b, rounding: .nearest)

        // Then: Returns ternary
        #expect(
            ternary == -1 || ternary == 0 || ternary == 1,
            "Ternary should be -1, 0, or 1, got \(ternary)"
        )
    }

    @Test
    func adding_DoesNotModifyOriginal() async throws {
        // Test Case 7
        // Given: let a = MPFRFloat(3.14, precision: 64) and let b = MPFRFloat(2.71, precision: 64)
        let a = MPFRFloat(3.14, precision: 64)
        let b = MPFRFloat(2.71, precision: 64)
        let originalA = a.toDouble()
        let originalB = b.toDouble()

        // When: Calling let (result, _) = a.adding(b, rounding: .nearest)
        _ = a.adding(b, rounding: .nearest)

        // Then: Original value is unchanged
        #expect(
            a.toDouble() == originalA,
            "Original value a should be unchanged"
        )
        #expect(
            b.toDouble() == originalB,
            "Original value b should be unchanged"
        )
    }

    // MARK: - subtracting(_ other: MPFRFloat, rounding: MPFRRoundingMode) -> (result: MPFRFloat, ternary: Int)

    @Test
    func subtracting_PositiveNumbers_ReturnsDifference() async throws {
        // Test Case 8
        // Given: let a = MPFRFloat(3.0, precision: 64) and let b = MPFRFloat(2.0, precision: 64)
        let a = MPFRFloat(3.0, precision: 64)
        let b = MPFRFloat(2.0, precision: 64)

        // When: Calling let (result, ternary) = a.subtracting(b, rounding: .nearest)
        let (result, ternary) = a.subtracting(b, rounding: .nearest)

        // Then: Returns difference value
        #expect(result.toDouble() == 1.0, "Result should be 1.0")
        #expect(
            ternary == -1 || ternary == 0 || ternary == 1,
            "Ternary should be -1, 0, or 1"
        )
    }

    @Test
    func subtracting_NegativeNumbers_ReturnsDifference() async throws {
        // Test Case 9
        // Given: let a = MPFRFloat(-3.0, precision: 64) and let b = MPFRFloat(-2.0, precision: 64)
        let a = MPFRFloat(-3.0, precision: 64)
        let b = MPFRFloat(-2.0, precision: 64)

        // When: Calling let (result, ternary) = a.subtracting(b, rounding: .nearest)
        let (result, ternary) = a.subtracting(b, rounding: .nearest)

        // Then: Returns difference value
        #expect(result.toDouble() == -1.0, "Result should be -1.0")
        #expect(
            ternary == -1 || ternary == 0 || ternary == 1,
            "Ternary should be -1, 0, or 1"
        )
    }

    @Test
    func subtracting_MixedSigns_ReturnsDifference() async throws {
        // Test Case 10
        // Given: let a = MPFRFloat(3.0, precision: 64) and let b = MPFRFloat(-2.0, precision: 64)
        let a = MPFRFloat(3.0, precision: 64)
        let b = MPFRFloat(-2.0, precision: 64)

        // When: Calling let (result, ternary) = a.subtracting(b, rounding: .nearest)
        let (result, ternary) = a.subtracting(b, rounding: .nearest)

        // Then: Returns difference value
        #expect(result.toDouble() == 5.0, "Result should be 5.0")
        #expect(
            ternary == -1 || ternary == 0 || ternary == 1,
            "Ternary should be -1, 0, or 1"
        )
    }

    @Test
    func subtracting_Zero_ReturnsOriginal() async throws {
        // Test Case 11
        // Given: let a = MPFRFloat(3.14, precision: 64) and let b = MPFRFloat(0.0, precision: 64)
        let a = MPFRFloat(3.14, precision: 64)
        let b = MPFRFloat(0.0, precision: 64)
        let originalA = a.toDouble()

        // When: Calling let (result, ternary) = a.subtracting(b, rounding: .nearest)
        let (result, ternary) = a.subtracting(b, rounding: .nearest)

        // Then: Returns original value (unchanged)
        #expect(
            result.toDouble() == originalA,
            "Result should equal original value"
        )
        #expect(
            ternary == 0,
            "Ternary should be 0 (exact) when subtracting zero"
        )
    }

    @Test
    func subtracting_Self_ReturnsZero() async throws {
        // Test Case 12
        // Given: let a = MPFRFloat(3.14, precision: 64)
        let a = MPFRFloat(3.14, precision: 64)

        // When: Calling let (result, ternary) = a.subtracting(a, rounding: .nearest)
        let (result, ternary) = a.subtracting(a, rounding: .nearest)

        // Then: Result equals zero (0.0), ternary is 0 (exact)
        #expect(result.isZero, "Result should be zero")
        #expect(
            ternary == 0,
            "Ternary should be 0 (exact) when subtracting self"
        )
    }

    @Test
    func subtracting_Infinity_Works() async throws {
        // Test Case 13: Table Test
        let testCases: [(
            a: Double,
            b: Double,
            expectedIsInfinity: Bool,
            expectedIsNaN: Bool,
            expectedSign: Int?,
            notes: String
        )] = [
            (
                3.14,
                Double.infinity,
                true,
                false,
                -1,
                "Subtracting positive infinity"
            ),
            (
                3.14,
                -Double.infinity,
                true,
                false,
                1,
                "Subtracting negative infinity"
            ),
            (Double.infinity, 3.14, true, false, 1, "Infinity minus finite"),
            (
                Double.infinity,
                Double.infinity,
                false,
                true,
                nil,
                "Infinity minus infinity"
            ),
        ]

        for testCase in testCases {
            // Given: let a = MPFRFloat(a, precision: 64) and let b = MPFRFloat(b, precision: 64) from table
            let a = MPFRFloat(testCase.a, precision: 64)
            let b = MPFRFloat(testCase.b, precision: 64)

            // When: Calling let (result, ternary) = a.subtracting(b, rounding: .nearest)
            let (result, _) = a.subtracting(b, rounding: .nearest)

            // Then: Result matches expected result from table
            if testCase.expectedIsNaN {
                #expect(
                    result.isNaN,
                    "Result should be NaN for \(testCase.notes)"
                )
            } else if testCase.expectedIsInfinity {
                #expect(
                    result.isInfinity,
                    "Result should be infinity for \(testCase.notes)"
                )
                if let expectedSign = testCase.expectedSign {
                    #expect(
                        result.sign == expectedSign,
                        "Result sign should be \(expectedSign) for \(testCase.notes)"
                    )
                }
            }
        }
    }

    @Test
    func subtracting_NaN_ReturnsNaN() async throws {
        // Test Case 14: Table Test
        let testCases: [(a: Double?, b: Double?, notes: String)] = [
            (3.14, nil, "Finite minus NaN"),
            (nil, 3.14, "NaN minus finite"),
            (nil, nil, "NaN minus NaN"),
        ]

        for testCase in testCases {
            // Given: let a = MPFRFloat(a, precision: 64) and
            // let b = MPFRFloat(b, precision: 64) from table
            // (where NaN is created with MPFRFloat())
            let a = testCase.a
                .map { MPFRFloat($0, precision: 64) } ?? MPFRFloat()
            let b = testCase.b
                .map { MPFRFloat($0, precision: 64) } ?? MPFRFloat()

            // When: Calling let (result, ternary) = a.subtracting(b, rounding: .nearest)
            let (result, _) = a.subtracting(b, rounding: .nearest)

            // Then: Result is NaN
            #expect(
                result.isNaN,
                "Result should be NaN for \(testCase.notes)"
            )
        }
    }

    @Test
    func subtracting_DifferentPrecisions_Works() async throws {
        // Test Case 15
        // Given: let a = MPFRFloat(5.0, precision: 32) and let b = MPFRFloat(2.0, precision: 64)
        let a = MPFRFloat(5.0, precision: 32)
        let b = MPFRFloat(2.0, precision: 64)

        // When: Calling let (result, ternary) = a.subtracting(b, rounding: .nearest)
        let (result, _) = a.subtracting(b, rounding: .nearest)

        // Then: Operation succeeds and produces correct result
        #expect(
            result.precision == 32,
            "Result precision should be 32 (uses a's precision)"
        )
        #expect(
            abs(result.toDouble() - 3.0) < 0.01,
            "Result should be approximately 3.0"
        )
    }

    @Test
    func subtracting_AllRoundingModes_Works() async throws {
        // Test Case 16: Table Test
        // Note: With precision 2, 1.5 - 0.5 = 1.0, which should be exact
        let testCases: [(mode: MPFRRoundingMode, a: Double, b: Double)] = [
            (.nearest, 1.5, 0.5),
            (.towardZero, 1.5, 0.5),
            (.towardPositiveInfinity, 1.5, 0.5),
            (.towardNegativeInfinity, 1.5, 0.5),
        ]

        for testCase in testCases {
            // Given: let a = MPFRFloat(a, precision: 2) and
            // let b = MPFRFloat(b, precision: 2) with rounding mode from table
            let a = MPFRFloat(testCase.a, precision: 2)
            let b = MPFRFloat(testCase.b, precision: 2)

            // When: Calling let (result, _) = a.subtracting(b, rounding: mode)
            let (result, ternary) = a.subtracting(b, rounding: testCase.mode)

            // Then: Result matches expected rounding behavior
            let resultValue = result.toDouble()
            #expect(
                resultValue == 1.0 || resultValue == 2.0 || resultValue == 0.0,
                "Result \(resultValue) should be a valid rounded value for mode \(testCase.mode)"
            )
            #expect(
                ternary == -1 || ternary == 0 || ternary == 1,
                "Ternary should be -1, 0, or 1 for mode \(testCase.mode)"
            )
        }
    }

    @Test
    func subtracting_ReturnsTernary() async throws {
        // Test Case 17
        // Given: let a = MPFRFloat(1.5, precision: 2) and let b = MPFRFloat(0.5, precision: 2)
        let a = MPFRFloat(1.5, precision: 2)
        let b = MPFRFloat(0.5, precision: 2)

        // When: Calling let (result, ternary) = a.subtracting(b, rounding: .nearest)
        let (_, ternary) = a.subtracting(b, rounding: .nearest)

        // Then: Returns ternary
        #expect(
            ternary == -1 || ternary == 0 || ternary == 1,
            "Ternary should be -1, 0, or 1, got \(ternary)"
        )
    }

    @Test
    func subtracting_DoesNotModifyOriginal() async throws {
        // Test Case 18
        // Given: let a = MPFRFloat(5.0, precision: 64) and let b = MPFRFloat(2.0, precision: 64)
        let a = MPFRFloat(5.0, precision: 64)
        let b = MPFRFloat(2.0, precision: 64)
        let originalA = a.toDouble()
        let originalB = b.toDouble()

        // When: Calling let (result, _) = a.subtracting(b, rounding: .nearest)
        _ = a.subtracting(b, rounding: .nearest)

        // Then: Original value is unchanged
        #expect(
            a.toDouble() == originalA,
            "Original value a should be unchanged"
        )
        #expect(
            b.toDouble() == originalB,
            "Original value b should be unchanged"
        )
    }

    // MARK: - multiplied(by other: MPFRFloat, rounding: MPFRRoundingMode) -> (result: MPFRFloat, ternary: Int)

    @Test
    func multiplied_PositiveNumbers_ReturnsProduct() async throws {
        // Test Case 19
        // Given: let a = MPFRFloat(3.0, precision: 64) and let b = MPFRFloat(2.0, precision: 64)
        let a = MPFRFloat(3.0, precision: 64)
        let b = MPFRFloat(2.0, precision: 64)
        let originalA = a.toDouble()

        // When: Calling let (result, ternary) = a.multiplied(by: b, rounding: .nearest)
        let (result, ternary) = a.multiplied(by: b, rounding: .nearest)

        // Then: Result equals ~6.0, ternary is 0 (exact), a is unchanged
        #expect(
            abs(result.toDouble() - 6.0) < 0.01,
            "Result should be approximately 6.0"
        )
        #expect(ternary == 0, "Ternary should be 0 (exact)")
        #expect(
            a.toDouble() == originalA,
            "Original value a should be unchanged"
        )
    }

    @Test
    func multiplied_NegativeNumbers_ReturnsProduct() async throws {
        // Test Case 20
        // Given: let a = MPFRFloat(-3.0, precision: 64) and let b = MPFRFloat(-2.0, precision: 64)
        let a = MPFRFloat(-3.0, precision: 64)
        let b = MPFRFloat(-2.0, precision: 64)
        let originalA = a.toDouble()

        // When: Calling let (result, ternary) = a.multiplied(by: b, rounding: .nearest)
        let (result, ternary) = a.multiplied(by: b, rounding: .nearest)

        // Then: Result equals ~6.0, ternary is 0 (exact), a is unchanged
        #expect(
            abs(result.toDouble() - 6.0) < 0.01,
            "Result should be approximately 6.0"
        )
        #expect(ternary == 0, "Ternary should be 0 (exact)")
        #expect(
            a.toDouble() == originalA,
            "Original value a should be unchanged"
        )
    }

    @Test
    func multiplied_MixedSigns_ReturnsProduct() async throws {
        // Test Case 21
        // Given: let a = MPFRFloat(3.0, precision: 64) and let b = MPFRFloat(-2.0, precision: 64)
        let a = MPFRFloat(3.0, precision: 64)
        let b = MPFRFloat(-2.0, precision: 64)
        let originalA = a.toDouble()

        // When: Calling let (result, ternary) = a.multiplied(by: b, rounding: .nearest)
        let (result, ternary) = a.multiplied(by: b, rounding: .nearest)

        // Then: Result equals ~-6.0, ternary is 0 (exact), a is unchanged
        #expect(
            abs(result.toDouble() - -6.0) < 0.01,
            "Result should be approximately -6.0"
        )
        #expect(ternary == 0, "Ternary should be 0 (exact)")
        #expect(
            a.toDouble() == originalA,
            "Original value a should be unchanged"
        )
    }

    @Test
    func multiplied_Zero_ReturnsZero() async throws {
        // Test Case 22
        // Given: let a = MPFRFloat(3.14, precision: 64) and let b = MPFRFloat(0.0, precision: 64)
        let a = MPFRFloat(3.14, precision: 64)
        let b = MPFRFloat(0.0, precision: 64)
        let originalA = a.toDouble()

        // When: Calling let (result, ternary) = a.multiplied(by: b, rounding: .nearest)
        let (result, ternary) = a.multiplied(by: b, rounding: .nearest)

        // Then: Result equals 0.0, ternary is 0 (exact), a is unchanged
        #expect(result.isZero, "Result should be zero")
        #expect(ternary == 0, "Ternary should be 0 (exact)")
        #expect(
            a.toDouble() == originalA,
            "Original value a should be unchanged"
        )
    }

    @Test
    func multiplied_One_ReturnsOriginal() async throws {
        // Test Case 23
        // Given: let a = MPFRFloat(3.14, precision: 64) and let b = MPFRFloat(1.0, precision: 64)
        let a = MPFRFloat(3.14, precision: 64)
        let b = MPFRFloat(1.0, precision: 64)
        let originalA = a.toDouble()

        // When: Calling let (result, ternary) = a.multiplied(by: b, rounding: .nearest)
        let (result, ternary) = a.multiplied(by: b, rounding: .nearest)

        // Then: Result equals ~3.14, ternary is 0 (exact), a is unchanged
        #expect(
            abs(result.toDouble() - 3.14) < 0.01,
            "Result should be approximately 3.14"
        )
        #expect(ternary == 0, "Ternary should be 0 (exact)")
        #expect(
            a.toDouble() == originalA,
            "Original value a should be unchanged"
        )
    }

    @Test
    func multiplied_Infinity_Works() async throws {
        // Test Case 24: Table Test
        let testCases: [(
            a: Double,
            b: Double,
            expectedIsInfinity: Bool,
            expectedIsNaN: Bool,
            expectedSign: Int?,
            notes: String
        )] = [
            (3.14, Double.infinity, true, false, 1, "Positive times infinity"),
            (
                -3.14,
                Double.infinity,
                true,
                false,
                -1,
                "Negative times infinity"
            ),
            (0.0, Double.infinity, false, true, nil, "Zero times infinity"),
            (
                Double.infinity,
                Double.infinity,
                true,
                false,
                1,
                "Infinity times infinity"
            ),
        ]

        for testCase in testCases {
            // Given: let a = MPFRFloat(a, precision: 64) and let b = MPFRFloat(b, precision: 64) from table
            let a = MPFRFloat(testCase.a, precision: 64)
            let b = MPFRFloat(testCase.b, precision: 64)

            // When: Calling let (result, ternary) = a.multiplied(by: b, rounding: .nearest)
            let (result, _) = a.multiplied(by: b, rounding: .nearest)

            // Then: Result matches expected result from table
            if testCase.expectedIsNaN {
                #expect(
                    result.isNaN,
                    "Result should be NaN for \(testCase.notes)"
                )
            } else if testCase.expectedIsInfinity {
                #expect(
                    result.isInfinity,
                    "Result should be infinity for \(testCase.notes)"
                )
                if let expectedSign = testCase.expectedSign {
                    #expect(
                        result.sign == expectedSign,
                        "Result sign should be \(expectedSign) for \(testCase.notes)"
                    )
                }
            }
        }
    }

    @Test
    func multiplied_NaN_ReturnsNaN() async throws {
        // Test Case 25: Table Test
        let testCases: [(a: Double?, b: Double?, notes: String)] = [
            (3.14, nil, "Finite times NaN"),
            (nil, 3.14, "NaN times finite"),
            (nil, nil, "NaN times NaN"),
        ]

        for testCase in testCases {
            // Given: let a = MPFRFloat(a, precision: 64) and
            // let b = MPFRFloat(b, precision: 64) from table
            // (where NaN is created with MPFRFloat())
            let a = testCase.a
                .map { MPFRFloat($0, precision: 64) } ?? MPFRFloat()
            let b = testCase.b
                .map { MPFRFloat($0, precision: 64) } ?? MPFRFloat()

            // When: Calling let (result, ternary) = a.multiplied(by: b, rounding: .nearest)
            let (result, _) = a.multiplied(by: b, rounding: .nearest)

            // Then: Result is NaN
            #expect(
                result.isNaN,
                "Result should be NaN for \(testCase.notes)"
            )
        }
    }

    @Test
    func multiplied_DifferentPrecisions_Works() async throws {
        // Test Case 26: Table Test
        let testCases: [(
            aValue: Double,
            aPrecision: Int,
            bValue: Double,
            bPrecision: Int,
            resultPrecision: Int
        )] = [
            (3.0, 32, 2.0, 64, 32),
            (3.0, 64, 2.0, 32, 64),
            (3.0, 128, 2.0, 256, 128),
        ]

        for testCase in testCases {
            // Given: let a = MPFRFloat(aValue, precision: aPrecision) and
            // let b = MPFRFloat(bValue, precision: bPrecision) from table
            let a = MPFRFloat(testCase.aValue, precision: testCase.aPrecision)
            let b = MPFRFloat(testCase.bValue, precision: testCase.bPrecision)

            // When: Calling let (result, ternary) = a.multiplied(by: b, rounding: .nearest)
            let (result, _) = a.multiplied(by: b, rounding: .nearest)

            // Then: Operation succeeds, result has precision matching result
            // precision from table, and result value is approximately aValue *
            // bValue
            #expect(
                result.precision == testCase.resultPrecision,
                "Result precision should be \(testCase.resultPrecision), got \(result.precision)"
            )
            let expectedValue = testCase.aValue * testCase.bValue
            #expect(
                abs(result.toDouble() - expectedValue) < 0.01,
                "Result value should be approximately \(expectedValue)"
            )
        }
    }

    @Test
    func multiplied_AllRoundingModes_Works() async throws {
        // Test Case 27: Table Test
        // Note: With precision 2, 1.5 * 1.5 = 2.25, which may round to 2.0 or
        // 3.0 depending on mode
        let testCases: [(mode: MPFRRoundingMode, a: Double, b: Double)] = [
            (.nearest, 1.5, 1.5),
            (.towardZero, 1.5, 1.5),
            (.towardPositiveInfinity, 1.5, 1.5),
            (.towardNegativeInfinity, 1.5, 1.5),
        ]

        for testCase in testCases {
            // Given: let a = MPFRFloat(a, precision: 2) and
            // let b = MPFRFloat(b, precision: 2) with rounding mode from table
            let a = MPFRFloat(testCase.a, precision: 2)
            let b = MPFRFloat(testCase.b, precision: 2)

            // When: Calling let (result, _) = a.multiplied(by: b, rounding: mode)
            let (result, ternary) = a.multiplied(by: b, rounding: testCase.mode)

            // Then: Result matches expected rounding behavior
            let resultValue = result.toDouble()
            #expect(
                resultValue == 2.0 || resultValue == 3.0 || resultValue == 4.0,
                "Result \(resultValue) should be a valid rounded value for mode \(testCase.mode)"
            )
            #expect(
                ternary == -1 || ternary == 0 || ternary == 1,
                "Ternary should be -1, 0, or 1 for mode \(testCase.mode)"
            )
        }
    }

    @Test
    func multiplied_ReturnsTernary() async throws {
        // Test Case 28
        // Given: let a = MPFRFloat(1.5, precision: 2) and let b = MPFRFloat(1.5, precision: 2)
        let a = MPFRFloat(1.5, precision: 2)
        let b = MPFRFloat(1.5, precision: 2)

        // When: Calling let (result, ternary) = a.multiplied(by: b, rounding: .nearest)
        let (_, ternary) = a.multiplied(by: b, rounding: .nearest)

        // Then: Returns ternary value (may be non-zero due to rounding)
        #expect(
            ternary == -1 || ternary == 0 || ternary == 1,
            "Ternary should be -1, 0, or 1, got \(ternary)"
        )
    }

    @Test
    func multiplied_DoesNotModifyOriginal() async throws {
        // Test Case 29
        // Given: let a = MPFRFloat(3.0, precision: 64) and let b = MPFRFloat(2.0, precision: 64)
        let a = MPFRFloat(3.0, precision: 64)
        let b = MPFRFloat(2.0, precision: 64)
        let originalA = a.toDouble()
        let originalB = b.toDouble()

        // When: Calling let (result, _) = a.multiplied(by: b, rounding: .nearest)
        _ = a.multiplied(by: b, rounding: .nearest)

        // Then: a remains unchanged (equals 3.0)
        #expect(
            a.toDouble() == originalA,
            "Original value a should be unchanged"
        )
        #expect(
            b.toDouble() == originalB,
            "Original value b should be unchanged"
        )
    }

    // MARK: - divided(by other: MPFRFloat, rounding: MPFRRoundingMode) -> (result: MPFRFloat, ternary: Int)

    @Test
    func divided_BasicValues_ReturnsQuotient() async throws {
        // Test Case 30: Table Test
        let testCases: [(
            a: Double,
            b: Double,
            expectedResult: Double,
            expectedTernary: Int,
            notes: String
        )] = [
            (6.0, 2.0, 3.0, 0, "Positive numbers"),
            (-6.0, -2.0, 3.0, 0, "Negative numbers"),
            (6.0, -2.0, -3.0, 0, "Mixed signs"),
            (3.14, 1.0, 3.14, 0, "Dividing by one"),
            (3.14, 3.14, 1.0, 0, "Dividing by self"),
        ]

        for testCase in testCases {
            // Given: let a = MPFRFloat(a, precision: 64) and let b = MPFRFloat(b, precision: 64) from table
            let a = MPFRFloat(testCase.a, precision: 64)
            let b = MPFRFloat(testCase.b, precision: 64)
            let originalA = a.toDouble()

            // When: Calling let (result, ternary) = a.divided(by: b, rounding: .nearest)
            let (result, ternary) = a.divided(by: b, rounding: .nearest)

            // Then: Result matches expected result, a is unchanged, ternary matches expected
            #expect(
                abs(result.toDouble() - testCase.expectedResult) < 0.01,
                "Result should be approximately \(testCase.expectedResult) for \(testCase.notes)"
            )
            #expect(
                a.toDouble() == originalA,
                "Original value a should be unchanged for \(testCase.notes)"
            )
            #expect(
                ternary == testCase.expectedTernary,
                "Ternary should be \(testCase.expectedTernary) for \(testCase.notes)"
            )
        }
    }

    @Test
    func divided_Zero_ReturnsNaN() async throws {
        // Test Case 31
        // Given: let a = MPFRFloat(3.14, precision: 64) and let b = MPFRFloat(0.0, precision: 64)
        let a = MPFRFloat(3.14, precision: 64)
        let b = MPFRFloat(0.0, precision: 64)

        // When: Calling let (result, ternary) = a.divided(by: b, rounding: .nearest)
        let (result, _) = a.divided(by: b, rounding: .nearest)

        // Then: Result is NaN or Infinity (MPFR behavior may vary, but should be invalid)
        // MPFR typically sets NaN for division by zero, but may set infinity in
        // some cases
        #expect(
            result.isNaN || result.isInfinity,
            "Dividing by zero should return NaN or Infinity"
        )
    }

    @Test
    func divided_Infinity_Works() async throws {
        // Test Case 32: Table Test
        let testCases: [(
            a: Double,
            b: Double,
            expectedIsInfinity: Bool,
            expectedIsNaN: Bool,
            expectedIsZero: Bool,
            expectedSign: Int?,
            notes: String
        )] = [
            (
                3.14,
                Double.infinity,
                false,
                false,
                true,
                nil,
                "Finite divided by infinity"
            ),
            (
                Double.infinity,
                3.14,
                true,
                false,
                false,
                1,
                "Infinity divided by finite"
            ),
            (
                Double.infinity,
                Double.infinity,
                false,
                true,
                false,
                nil,
                "Infinity divided by infinity"
            ),
            (
                0.0,
                Double.infinity,
                false,
                false,
                true,
                nil,
                "Zero divided by infinity"
            ),
        ]

        for testCase in testCases {
            // Given: let a = MPFRFloat(a, precision: 64) and let b = MPFRFloat(b, precision: 64) from table
            let a = MPFRFloat(testCase.a, precision: 64)
            let b = MPFRFloat(testCase.b, precision: 64)

            // When: Calling let (result, ternary) = a.divided(by: b, rounding: .nearest)
            let (result, _) = a.divided(by: b, rounding: .nearest)

            // Then: Result matches expected result from table
            if testCase.expectedIsNaN {
                #expect(
                    result.isNaN,
                    "Result should be NaN for \(testCase.notes)"
                )
            } else if testCase.expectedIsInfinity {
                #expect(
                    result.isInfinity,
                    "Result should be infinity for \(testCase.notes)"
                )
                if let expectedSign = testCase.expectedSign {
                    #expect(
                        result.sign == expectedSign,
                        "Result sign should be \(expectedSign) for \(testCase.notes)"
                    )
                }
            } else if testCase.expectedIsZero {
                #expect(
                    result.isZero,
                    "Result should be zero for \(testCase.notes)"
                )
            }
        }
    }

    @Test
    func divided_NaN_ReturnsNaN() async throws {
        // Test Case 33: Table Test
        let testCases: [(a: Double?, b: Double?, notes: String)] = [
            (3.14, nil, "Finite divided by NaN"),
            (nil, 3.14, "NaN divided by finite"),
            (nil, nil, "NaN divided by NaN"),
        ]

        for testCase in testCases {
            // Given: let a = MPFRFloat(a, precision: 64) and
            // let b = MPFRFloat(b, precision: 64) from table
            // (where NaN is created with MPFRFloat())
            let a = testCase.a
                .map { MPFRFloat($0, precision: 64) } ?? MPFRFloat()
            let b = testCase.b
                .map { MPFRFloat($0, precision: 64) } ?? MPFRFloat()

            // When: Calling let (result, ternary) = a.divided(by: b, rounding: .nearest)
            let (result, _) = a.divided(by: b, rounding: .nearest)

            // Then: Result is NaN
            #expect(result.isNaN, "Result should be NaN for \(testCase.notes)")
        }
    }

    @Test
    func divided_DifferentPrecisions_Works() async throws {
        // Test Case 34
        // Given: let a = MPFRFloat(6.0, precision: 32) and let b = MPFRFloat(2.0, precision: 64)
        let a = MPFRFloat(6.0, precision: 32)
        let b = MPFRFloat(2.0, precision: 64)

        // When: Calling let (result, ternary) = a.divided(by: b, rounding: .nearest)
        let (result, _) = a.divided(by: b, rounding: .nearest)

        // Then: Operation succeeds and produces correct result
        #expect(
            result.precision == 32,
            "Result precision should be 32 (uses a's precision)"
        )
        #expect(
            abs(result.toDouble() - 3.0) < 0.01,
            "Result should be approximately 3.0"
        )
    }

    @Test
    func divided_AllRoundingModes_Works() async throws {
        // Test Case 35: Table Test
        // Note: With precision 2, 1.0 / 3.0 = 0.333..., which may round to 0.25
        // or 0.375 depending on mode
        let testCases: [(mode: MPFRRoundingMode, a: Double, b: Double)] = [
            (.nearest, 1.0, 3.0),
            (.towardZero, 1.0, 3.0),
            (.towardPositiveInfinity, 1.0, 3.0),
            (.towardNegativeInfinity, 1.0, 3.0),
        ]

        for testCase in testCases {
            // Given: let a = MPFRFloat(a, precision: 2) and
            // let b = MPFRFloat(b, precision: 2) with rounding mode from table
            let a = MPFRFloat(testCase.a, precision: 2)
            let b = MPFRFloat(testCase.b, precision: 2)

            // When: Calling let (result, _) = a.divided(by: b, rounding: mode)
            let (result, ternary) = a.divided(by: b, rounding: testCase.mode)

            // Then: Result matches expected rounding behavior
            // With precision 2, 1.0 / 3.0 may round to 0.25, 0.375, 0.5, etc.
            let resultValue = result.toDouble()
            #expect(
                resultValue >= 0.0 && resultValue <= 1.0,
                "Result \(resultValue) should be a valid rounded value for mode \(testCase.mode)"
            )
            #expect(
                ternary == -1 || ternary == 0 || ternary == 1,
                "Ternary should be -1, 0, or 1 for mode \(testCase.mode)"
            )
        }
    }

    @Test
    func divided_ReturnsTernary() async throws {
        // Test Case 36
        // Given: let a = MPFRFloat(1.0, precision: 2) and let b = MPFRFloat(3.0, precision: 2)
        let a = MPFRFloat(1.0, precision: 2)
        let b = MPFRFloat(3.0, precision: 2)

        // When: Calling let (result, ternary) = a.divided(by: b, rounding: .nearest)
        let (_, ternary) = a.divided(by: b, rounding: .nearest)

        // Then: Returns ternary
        #expect(
            ternary == -1 || ternary == 0 || ternary == 1,
            "Ternary should be -1, 0, or 1, got \(ternary)"
        )
    }

    @Test
    func divided_DoesNotModifyOriginal() async throws {
        // Test Case 37
        // Given: let a = MPFRFloat(6.0, precision: 64) and let b = MPFRFloat(2.0, precision: 64)
        let a = MPFRFloat(6.0, precision: 64)
        let b = MPFRFloat(2.0, precision: 64)
        let originalA = a.toDouble()
        let originalB = b.toDouble()

        // When: Calling let (result, _) = a.divided(by: b, rounding: .nearest)
        _ = a.divided(by: b, rounding: .nearest)

        // Then: Original value is unchanged
        #expect(
            a.toDouble() == originalA,
            "Original value a should be unchanged"
        )
        #expect(
            b.toDouble() == originalB,
            "Original value b should be unchanged"
        )
    }

    // MARK: - negated(rounding: MPFRRoundingMode) -> (result: MPFRFloat, ternary: Int)

    @Test
    func negated_BasicValues_ReturnsNegated() async throws {
        // Test Case 38: Table Test
        let testCases: [(
            value: Double,
            expectedResult: Double,
            expectedTernary: Int,
            notes: String
        )] = [
            (3.14, -3.14, 0, "Positive"),
            (-3.14, 3.14, 0, "Negative"),
            (0.0, 0.0, 0, "Zero"),
        ]

        for testCase in testCases {
            // Given: let a = MPFRFloat(value, precision: 64) from table
            let a = MPFRFloat(testCase.value, precision: 64)
            let originalA = a.toDouble()

            // When: Calling let (result, ternary) = a.negated(rounding: .nearest)
            let (result, ternary) = a.negated(rounding: .nearest)

            // Then: Result matches expected result, a is unchanged, ternary is 0 (negation is exact)
            #expect(
                abs(result.toDouble() - testCase.expectedResult) < 0.01,
                "Result should be approximately \(testCase.expectedResult) for \(testCase.notes)"
            )
            #expect(
                a.toDouble() == originalA,
                "Original value a should be unchanged for \(testCase.notes)"
            )
            #expect(
                ternary == testCase.expectedTernary,
                "Ternary should be 0 (exact) for \(testCase.notes)"
            )
        }
    }

    @Test
    func negated_Infinity_Works() async throws {
        // Test Case 38 continued: Infinity and NaN cases
        let posInf = MPFRFloat(Double.infinity, precision: 64)
        let (resultPosInf, ternaryPosInf) = posInf.negated(rounding: .nearest)
        #expect(
            resultPosInf.isInfinity && resultPosInf.sign == -1,
            "Negating positive infinity should give negative infinity"
        )
        #expect(ternaryPosInf == 0, "Ternary should be 0 (exact)")

        let negInf = MPFRFloat(-Double.infinity, precision: 64)
        let (resultNegInf, ternaryNegInf) = negInf.negated(rounding: .nearest)
        #expect(
            resultNegInf.isInfinity && resultNegInf.sign == 1,
            "Negating negative infinity should give positive infinity"
        )
        #expect(ternaryNegInf == 0, "Ternary should be 0 (exact)")

        let nan = MPFRFloat()
        let (resultNaN, ternaryNaN) = nan.negated(rounding: .nearest)
        #expect(resultNaN.isNaN, "Negating NaN should return NaN")
        #expect(ternaryNaN == 0, "Ternary should be 0 (exact)")
    }

    @Test
    func negated_AllRoundingModes_Works() async throws {
        // Test Case 39
        // Given: let a = MPFRFloat(3.14, precision: 64) and all rounding modes
        let a = MPFRFloat(3.14, precision: 64)
        let modes: [MPFRRoundingMode] = [
            .nearest,
            .towardZero,
            .towardPositiveInfinity,
            .towardNegativeInfinity,
            .awayFromZero,
            .faithful,
        ]

        for mode in modes {
            // When: Calling let (result, ternary) = a.negated(rounding: mode) for each rounding mode
            let (result, ternary) = a.negated(rounding: mode)

            // Then: Result equals ~-3.14 for all modes, ternary is 0 (negation is exact)
            #expect(
                abs(result.toDouble() - -3.14) < 0.01,
                "Result should be approximately -3.14 for mode \(mode)"
            )
            #expect(
                ternary == 0,
                "Ternary should be 0 (exact) for mode \(mode)"
            )
        }
    }

    @Test
    func negated_ReturnsZeroTernary() async throws {
        // Test Case 40
        // Given: let a = MPFRFloat(0.0, precision: 64)
        let a = MPFRFloat(0.0, precision: 64)

        // When: Calling let (result, ternary) = a.negated(rounding: .nearest)
        let (result, ternary) = a.negated(rounding: .nearest)

        // Then: Result equals 0.0, ternary is 0 (exact)
        #expect(result.isZero, "Result should be zero")
        #expect(ternary == 0, "Ternary should be 0 (exact)")
    }

    @Test
    func negated_DoesNotModifyOriginal() async throws {
        // Test Case 41
        // Given: let a = MPFRFloat(3.14, precision: 64)
        let a = MPFRFloat(3.14, precision: 64)
        let originalA = a.toDouble()

        // When: Calling let (result, _) = a.negated(rounding: .nearest)
        _ = a.negated(rounding: .nearest)

        // Then: Original value is unchanged
        #expect(
            a.toDouble() == originalA,
            "Original value a should be unchanged"
        )
    }

    // MARK: - absoluteValue(rounding: MPFRRoundingMode) -> (result: MPFRFloat, ternary: Int)

    @Test
    func absoluteValue_Positive_ReturnsSame() async throws {
        // Test Case 42
        // Given: let a = MPFRFloat(3.14, precision: 64)
        let a = MPFRFloat(3.14, precision: 64)
        let originalA = a.toDouble()

        // When: Calling let (result, ternary) = a.absoluteValue(rounding: .nearest)
        let (result, ternary) = a.absoluteValue(rounding: .nearest)

        // Then: Result equals ~3.14, ternary is 0 (exact), a is unchanged
        #expect(
            abs(result.toDouble() - 3.14) < 0.01,
            "Result should be approximately 3.14"
        )
        #expect(ternary == 0, "Ternary should be 0 (exact)")
        #expect(
            a.toDouble() == originalA,
            "Original value a should be unchanged"
        )
    }

    @Test
    func absoluteValue_Negative_ReturnsPositive() async throws {
        // Test Case 43
        // Given: let a = MPFRFloat(-3.14, precision: 64)
        let a = MPFRFloat(-3.14, precision: 64)
        let originalA = a.toDouble()

        // When: Calling let (result, ternary) = a.absoluteValue(rounding: .nearest)
        let (result, ternary) = a.absoluteValue(rounding: .nearest)

        // Then: Result equals ~3.14, ternary is 0 (exact), a is unchanged
        #expect(
            abs(result.toDouble() - 3.14) < 0.01,
            "Result should be approximately 3.14"
        )
        #expect(ternary == 0, "Ternary should be 0 (exact)")
        #expect(
            a.toDouble() == originalA,
            "Original value a should be unchanged"
        )
    }

    @Test
    func absoluteValue_Zero_ReturnsZero() async throws {
        // Test Case 44
        // Given: let a = MPFRFloat(0.0, precision: 64)
        let a = MPFRFloat(0.0, precision: 64)

        // When: Calling let (result, ternary) = a.absoluteValue(rounding: .nearest)
        let (result, ternary) = a.absoluteValue(rounding: .nearest)

        // Then: Result equals 0.0, ternary is 0 (exact)
        #expect(result.isZero, "Result should be zero")
        #expect(ternary == 0, "Ternary should be 0 (exact)")
    }

    @Test
    func absoluteValue_Infinity_Works() async throws {
        // Test Case 45: Table Test
        let testCases: [(
            inputValue: Double,
            expectedIsPositiveInfinity: Bool,
            notes: String
        )] = [
            (Double.infinity, true, "Positive infinity"),
            (-Double.infinity, true, "Negative infinity"),
        ]

        for testCase in testCases {
            // Given: let a = MPFRFloat(inputValue, precision: 64) from table
            let a = MPFRFloat(testCase.inputValue, precision: 64)

            // When: Calling let (result, ternary) = a.absoluteValue(rounding: .nearest)
            let (result, ternary) = a.absoluteValue(rounding: .nearest)

            // Then: Result matches expected result from table, ternary is 0 (exact)
            #expect(
                result.isInfinity && result.sign == 1,
                "Result should be positive infinity for \(testCase.notes)"
            )
            #expect(
                ternary == 0,
                "Ternary should be 0 (exact) for \(testCase.notes)"
            )
        }
    }

    @Test
    func absoluteValue_NaN_ReturnsNaN() async throws {
        // Test Case 46
        // Given: let a = MPFRFloat() (NaN value)
        let a = MPFRFloat()

        // When: Calling let (result, ternary) = a.absoluteValue(rounding: .nearest)
        let (result, _) = a.absoluteValue(rounding: .nearest)

        // Then: Result is NaN
        #expect(result.isNaN, "Absolute value of NaN should return NaN")
    }

    @Test
    func absoluteValue_AllRoundingModes_Works() async throws {
        // Test Case 47
        // Given: let a = MPFRFloat(-3.14, precision: 64) and all rounding modes
        let a = MPFRFloat(-3.14, precision: 64)
        let modes: [MPFRRoundingMode] = [
            .nearest,
            .towardZero,
            .towardPositiveInfinity,
            .towardNegativeInfinity,
            .awayFromZero,
            .faithful,
        ]

        for mode in modes {
            // When: Calling let (result, ternary) = a.absoluteValue(rounding: mode) for each rounding mode
            let (result, ternary) = a.absoluteValue(rounding: mode)

            // Then: Result equals ~3.14 for all modes, ternary is 0 (absolute value is exact)
            #expect(
                abs(result.toDouble() - 3.14) < 0.01,
                "Result should be approximately 3.14 for mode \(mode)"
            )
            #expect(
                ternary == 0,
                "Ternary should be 0 (exact) for mode \(mode)"
            )
        }
    }

    @Test
    func absoluteValue_ReturnsZeroTernary() async throws {
        // Test Case 48
        // Given: let a = MPFRFloat(0.0, precision: 64)
        let a = MPFRFloat(0.0, precision: 64)

        // When: Calling let (result, ternary) = a.absoluteValue(rounding: .nearest)
        let (result, ternary) = a.absoluteValue(rounding: .nearest)

        // Then: Result equals 0.0, ternary is 0 (exact)
        #expect(result.isZero, "Result should be zero")
        #expect(ternary == 0, "Ternary should be 0 (exact)")
    }

    @Test
    func absoluteValue_DoesNotModifyOriginal() async throws {
        // Test Case 49
        // Given: let a = MPFRFloat(-3.14, precision: 64)
        let a = MPFRFloat(-3.14, precision: 64)
        let originalA = a.toDouble()

        // When: Calling let (result, _) = a.absoluteValue(rounding: .nearest)
        _ = a.absoluteValue(rounding: .nearest)

        // Then: Original value is unchanged
        #expect(
            a.toDouble() == originalA,
            "Original value a should be unchanged"
        )
    }

    // MARK: - Section 2: Mutable Operations

    // MARK: - add(_ other: MPFRFloat, rounding: MPFRRoundingMode) -> Int

    @Test
    func add_MPFRFloat_PositiveNumbers_ModifiesSelf() async throws {
        // Test Case 50
        // Given: var a = MPFRFloat(3.0, precision: 64) and let b = MPFRFloat(2.0, precision: 64)
        var a = MPFRFloat(3.0, precision: 64)
        let b = MPFRFloat(2.0, precision: 64)

        // When: Calling let ternary = a.add(b, rounding: .nearest)
        let ternary = a.add(b, rounding: .nearest)

        // Then: a equals ~5.0, ternary is 0 (exact)
        #expect(abs(a.toDouble() - 5.0) < 0.01, "a should be approximately 5.0")
        #expect(ternary == 0, "Ternary should be 0 (exact)")
    }

    @Test
    func add_MPFRFloat_NegativeNumbers_ModifiesSelf() async throws {
        // Test Case 51
        var a = MPFRFloat(-3.0, precision: 64)
        let b = MPFRFloat(-2.0, precision: 64)
        let ternary = a.add(b, rounding: .nearest)
        #expect(
            abs(a.toDouble() - -5.0) < 0.01,
            "a should be approximately -5.0"
        )
        #expect(ternary == 0, "Ternary should be 0 (exact)")
    }

    @Test
    func add_MPFRFloat_MixedSigns_ModifiesSelf() async throws {
        // Test Case 52
        var a = MPFRFloat(3.0, precision: 64)
        let b = MPFRFloat(-2.0, precision: 64)
        let ternary = a.add(b, rounding: .nearest)
        #expect(abs(a.toDouble() - 1.0) < 0.01, "a should be approximately 1.0")
        #expect(ternary == 0, "Ternary should be 0 (exact)")
    }

    @Test
    func add_MPFRFloat_Zero_NoChange() async throws {
        // Test Case 53
        var a = MPFRFloat(3.14, precision: 64)
        let b = MPFRFloat(0.0, precision: 64)
        let ternary = a.add(b, rounding: .nearest)
        #expect(
            abs(a.toDouble() - 3.14) < 0.01,
            "a should be approximately 3.14 (unchanged)"
        )
        #expect(ternary == 0, "Ternary should be 0 (exact)")
    }

    @Test
    func add_MPFRFloat_Infinity_Works() async throws {
        // Test Case 54: Table Test
        let testCases: [(
            a: Double,
            b: Double,
            expectedIsInfinity: Bool,
            expectedSign: Int?,
            notes: String
        )] = [
            (3.14, Double.infinity, true, 1, "Adding positive infinity"),
            (3.14, -Double.infinity, true, -1, "Adding negative infinity"),
        ]

        for testCase in testCases {
            var a = MPFRFloat(testCase.a, precision: 64)
            let b = MPFRFloat(testCase.b, precision: 64)
            _ = a.add(b, rounding: .nearest)
            #expect(a.isInfinity, "a should be infinity for \(testCase.notes)")
            if let expectedSign = testCase.expectedSign {
                #expect(
                    a.sign == expectedSign,
                    "a sign should be \(expectedSign) for \(testCase.notes)"
                )
            }
        }
    }

    @Test
    func add_MPFRFloat_NaN_SetsNaN() async throws {
        // Test Case 55
        var a = MPFRFloat(3.14, precision: 64)
        let b = MPFRFloat() // NaN
        _ = a.add(b, rounding: .nearest)
        #expect(a.isNaN, "a should be NaN")
    }

    @Test
    func add_MPFRFloat_AllRoundingModes_Works() async throws {
        // Test Case 56
        let modes: [MPFRRoundingMode] = [
            .nearest,
            .towardZero,
            .towardPositiveInfinity,
            .towardNegativeInfinity,
            .awayFromZero,
            .faithful,
        ]
        for mode in modes {
            var a = MPFRFloat(1.5, precision: 2)
            let b = MPFRFloat(1.5, precision: 2)
            let ternary = a.add(b, rounding: mode)
            #expect(
                ternary == -1 || ternary == 0 || ternary == 1,
                "Ternary should be valid for mode \(mode)"
            )
        }
    }

    @Test
    func add_MPFRFloat_ReturnsTernary() async throws {
        // Test Case 57
        var a = MPFRFloat(1.5, precision: 2)
        let b = MPFRFloat(1.5, precision: 2)
        let ternary = a.add(b, rounding: .nearest)
        #expect(
            ternary == -1 || ternary == 0 || ternary == 1,
            "Ternary should be -1, 0, or 1"
        )
    }

    // MARK: - add(_ value: Int, rounding: MPFRRoundingMode) -> Int

    @Test
    func add_Int_BasicValues_ModifiesSelf() async throws {
        // Test Case 58: Table Test
        let testCases: [(
            a: Double,
            intValue: Int,
            expectedResult: Double,
            expectedTernary: Int?,
            notes: String
        )] = [
            (3.14, 5, 8.14, 0, "Positive integer"),
            (3.14, -5, -1.86, 0, "Negative integer"),
            (3.14, 0, 3.14, 0, "Zero"),
            (
                3.14,
                1_000_000,
                1_000_003.14,
                nil,
                "Large integer"
            ), // May have rounding
        ]

        for testCase in testCases {
            var a = MPFRFloat(testCase.a, precision: 64)
            let ternary = a.add(testCase.intValue, rounding: .nearest)
            #expect(
                abs(a.toDouble() - testCase.expectedResult) < 0.01,
                "a should match expected result for \(testCase.notes)"
            )
            if let expectedTernary = testCase.expectedTernary {
                #expect(
                    ternary == expectedTernary,
                    "Ternary should be \(expectedTernary) for \(testCase.notes)"
                )
            } else {
                #expect(
                    ternary == -1 || ternary == 0 || ternary == 1,
                    "Ternary should be valid for \(testCase.notes)"
                )
            }
        }
    }

    @Test
    func add_Int_AllRoundingModes_Works() async throws {
        // Test Case 59
        let modes: [MPFRRoundingMode] = [
            .nearest,
            .towardZero,
            .towardPositiveInfinity,
            .towardNegativeInfinity,
            .awayFromZero,
            .faithful,
        ]
        for mode in modes {
            var a = MPFRFloat(1.5, precision: 2)
            let ternary = a.add(1, rounding: mode)
            #expect(
                ternary == -1 || ternary == 0 || ternary == 1,
                "Ternary should be valid for mode \(mode)"
            )
        }
    }

    @Test
    func add_Int_ReturnsTernary() async throws {
        // Test Case 60
        var a = MPFRFloat(1.5, precision: 2)
        let ternary = a.add(1, rounding: .nearest)
        #expect(
            ternary == -1 || ternary == 0 || ternary == 1,
            "Ternary should be -1, 0, or 1"
        )
    }

    // MARK: - subtract(_ other: MPFRFloat, rounding: MPFRRoundingMode) -> Int

    @Test
    func subtract_MPFRFloat_BasicValues_ModifiesSelf() async throws {
        // Test Case 61: Table Test
        let testCases: [(
            a: Double,
            b: Double,
            expectedResult: Double,
            expectedTernary: Int,
            notes: String
        )] = [
            (5.0, 2.0, 3.0, 0, "Positive numbers"),
            (-5.0, -2.0, -3.0, 0, "Negative numbers"),
            (5.0, -2.0, 7.0, 0, "Mixed signs"),
            (3.14, 0.0, 3.14, 0, "Subtracting zero"),
            (3.14, 3.14, 0.0, 0, "Subtracting self"),
        ]

        for testCase in testCases {
            var a = MPFRFloat(testCase.a, precision: 64)
            let b = MPFRFloat(testCase.b, precision: 64)
            let ternary = a.subtract(b, rounding: .nearest)
            #expect(
                abs(a.toDouble() - testCase.expectedResult) < 0.01,
                "a should match expected result for \(testCase.notes)"
            )
            #expect(
                ternary == testCase.expectedTernary,
                "Ternary should be \(testCase.expectedTernary) for \(testCase.notes)"
            )
        }
    }

    @Test
    func subtract_MPFRFloat_Infinity_Works() async throws {
        // Test Case 62: Table Test
        let testCases: [(
            a: Double,
            b: Double,
            expectedIsInfinity: Bool,
            expectedSign: Int?,
            notes: String
        )] = [
            (3.14, Double.infinity, true, -1, "Subtracting positive infinity"),
            (3.14, -Double.infinity, true, 1, "Subtracting negative infinity"),
        ]

        for testCase in testCases {
            var a = MPFRFloat(testCase.a, precision: 64)
            let b = MPFRFloat(testCase.b, precision: 64)
            _ = a.subtract(b, rounding: .nearest)
            #expect(a.isInfinity, "a should be infinity for \(testCase.notes)")
            if let expectedSign = testCase.expectedSign {
                #expect(
                    a.sign == expectedSign,
                    "a sign should be \(expectedSign) for \(testCase.notes)"
                )
            }
        }
    }

    @Test
    func subtract_MPFRFloat_NaN_SetsNaN() async throws {
        // Test Case 63
        var a = MPFRFloat(3.14, precision: 64)
        let b = MPFRFloat() // NaN
        _ = a.subtract(b, rounding: .nearest)
        #expect(a.isNaN, "a should be NaN")
    }

    @Test
    func subtract_MPFRFloat_AllRoundingModes_Works() async throws {
        // Test Case 64
        let modes: [MPFRRoundingMode] = [
            .nearest,
            .towardZero,
            .towardPositiveInfinity,
            .towardNegativeInfinity,
            .awayFromZero,
            .faithful,
        ]
        for mode in modes {
            var a = MPFRFloat(1.5, precision: 2)
            let b = MPFRFloat(0.5, precision: 2)
            let ternary = a.subtract(b, rounding: mode)
            #expect(
                ternary == -1 || ternary == 0 || ternary == 1,
                "Ternary should be valid for mode \(mode)"
            )
        }
    }

    @Test
    func subtract_MPFRFloat_ReturnsTernary() async throws {
        // Test Case 65
        var a = MPFRFloat(1.5, precision: 2)
        let b = MPFRFloat(0.5, precision: 2)
        let ternary = a.subtract(b, rounding: .nearest)
        #expect(
            ternary == -1 || ternary == 0 || ternary == 1,
            "Ternary should be -1, 0, or 1"
        )
    }

    // MARK: - subtract(_ value: Int, rounding: MPFRRoundingMode) -> Int

    @Test
    func subtract_Int_BasicValues_ModifiesSelf() async throws {
        // Test Case 66: Table Test
        let testCases: [(
            a: Double,
            intValue: Int,
            expectedResult: Double,
            expectedTernary: Int,
            notes: String
        )] = [
            (5.0, 2, 3.0, 0, "Positive integer"),
            (5.0, -2, 7.0, 0, "Negative integer"),
            (3.14, 0, 3.14, 0, "Zero"),
            (1_000_003.14, 1_000_000, 3.14, 0, "Large integer"),
        ]

        for testCase in testCases {
            var a = MPFRFloat(testCase.a, precision: 64)
            let ternary = a.subtract(testCase.intValue, rounding: .nearest)
            #expect(
                abs(a.toDouble() - testCase.expectedResult) < 0.01,
                "a should match expected result for \(testCase.notes)"
            )
            #expect(
                ternary == testCase.expectedTernary,
                "Ternary should be \(testCase.expectedTernary) for \(testCase.notes)"
            )
        }
    }

    @Test
    func subtract_Int_AllRoundingModes_Works() async throws {
        // Test Case 67
        let modes: [MPFRRoundingMode] = [
            .nearest,
            .towardZero,
            .towardPositiveInfinity,
            .towardNegativeInfinity,
            .awayFromZero,
            .faithful,
        ]
        for mode in modes {
            var a = MPFRFloat(1.5, precision: 2)
            let ternary = a.subtract(1, rounding: mode)
            #expect(
                ternary == -1 || ternary == 0 || ternary == 1,
                "Ternary should be valid for mode \(mode)"
            )
        }
    }

    @Test
    func subtract_Int_ReturnsTernary() async throws {
        // Test Case 68
        var a = MPFRFloat(1.5, precision: 2)
        let ternary = a.subtract(1, rounding: .nearest)
        #expect(
            ternary == -1 || ternary == 0 || ternary == 1,
            "Ternary should be -1, 0, or 1"
        )
    }

    // MARK: - multiply(by other: MPFRFloat, rounding: MPFRRoundingMode) -> Int

    @Test
    func multiply_MPFRFloat_BasicValues_ModifiesSelf() async throws {
        // Test Case 69: Table Test
        let testCases: [(
            a: Double,
            b: Double,
            expectedResult: Double,
            expectedTernary: Int,
            notes: String
        )] = [
            (3.0, 2.0, 6.0, 0, "Positive numbers"),
            (-3.0, -2.0, 6.0, 0, "Negative numbers"),
            (3.0, -2.0, -6.0, 0, "Mixed signs"),
            (3.14, 0.0, 0.0, 0, "Multiplying by zero"),
            (3.14, 1.0, 3.14, 0, "Multiplying by one"),
        ]

        for testCase in testCases {
            var a = MPFRFloat(testCase.a, precision: 64)
            let b = MPFRFloat(testCase.b, precision: 64)
            let ternary = a.multiply(by: b, rounding: .nearest)
            #expect(
                abs(a.toDouble() - testCase.expectedResult) < 0.01 ||
                    (testCase.expectedResult == 0.0 && a.isZero),
                "a should match expected result for \(testCase.notes)"
            )
            #expect(
                ternary == testCase.expectedTernary,
                "Ternary should be \(testCase.expectedTernary) for \(testCase.notes)"
            )
        }
    }

    @Test
    func multiply_MPFRFloat_Infinity_Works() async throws {
        // Test Case 70: Table Test
        let testCases: [(
            a: Double,
            b: Double,
            expectedIsInfinity: Bool,
            expectedSign: Int?,
            notes: String
        )] = [
            (
                3.14,
                Double.infinity,
                true,
                1,
                "Multiplying by positive infinity"
            ),
            (
                -3.14,
                Double.infinity,
                true,
                -1,
                "Multiplying by negative infinity"
            ),
        ]

        for testCase in testCases {
            var a = MPFRFloat(testCase.a, precision: 64)
            let b = MPFRFloat(testCase.b, precision: 64)
            _ = a.multiply(by: b, rounding: .nearest)
            #expect(a.isInfinity, "a should be infinity for \(testCase.notes)")
            if let expectedSign = testCase.expectedSign {
                #expect(
                    a.sign == expectedSign,
                    "a sign should be \(expectedSign) for \(testCase.notes)"
                )
            }
        }
    }

    @Test
    func multiply_MPFRFloat_NaN_SetsNaN() async throws {
        // Test Case 71
        var a = MPFRFloat(3.14, precision: 64)
        let b = MPFRFloat() // NaN
        _ = a.multiply(by: b, rounding: .nearest)
        #expect(a.isNaN, "a should be NaN")
    }

    @Test
    func multiply_MPFRFloat_AllRoundingModes_Works() async throws {
        // Test Case 72
        let modes: [MPFRRoundingMode] = [
            .nearest,
            .towardZero,
            .towardPositiveInfinity,
            .towardNegativeInfinity,
            .awayFromZero,
            .faithful,
        ]
        for mode in modes {
            var a = MPFRFloat(1.5, precision: 2)
            let b = MPFRFloat(1.5, precision: 2)
            let ternary = a.multiply(by: b, rounding: mode)
            #expect(
                ternary == -1 || ternary == 0 || ternary == 1,
                "Ternary should be valid for mode \(mode)"
            )
        }
    }

    @Test
    func multiply_MPFRFloat_ReturnsTernary() async throws {
        // Test Case 73
        var a = MPFRFloat(1.5, precision: 2)
        let b = MPFRFloat(1.5, precision: 2)
        let ternary = a.multiply(by: b, rounding: .nearest)
        #expect(
            ternary == -1 || ternary == 0 || ternary == 1,
            "Ternary should be -1, 0, or 1"
        )
    }

    // MARK: - multiply(by value: Int, rounding: MPFRRoundingMode) -> Int

    @Test
    func multiply_Int_BasicValues_ModifiesSelf() async throws {
        // Test Case 74: Table Test
        let testCases: [(
            a: Double,
            intValue: Int,
            expectedResult: Double,
            expectedTernary: Int,
            notes: String
        )] = [
            (3.0, 2, 6.0, 0, "Positive integer"),
            (3.0, -2, -6.0, 0, "Negative integer"),
            (3.14, 0, 0.0, 0, "Zero"),
            (3.14, 1, 3.14, 0, "One"),
        ]

        for testCase in testCases {
            var a = MPFRFloat(testCase.a, precision: 64)
            let ternary = a.multiply(by: testCase.intValue, rounding: .nearest)
            #expect(
                abs(a.toDouble() - testCase.expectedResult) < 0.01 ||
                    (testCase.expectedResult == 0.0 && a.isZero),
                "a should match expected result for \(testCase.notes)"
            )
            #expect(
                ternary == testCase.expectedTernary,
                "Ternary should be \(testCase.expectedTernary) for \(testCase.notes)"
            )
        }
    }

    @Test
    func multiply_Int_AllRoundingModes_Works() async throws {
        // Test Case 75
        let modes: [MPFRRoundingMode] = [
            .nearest,
            .towardZero,
            .towardPositiveInfinity,
            .towardNegativeInfinity,
            .awayFromZero,
            .faithful,
        ]
        for mode in modes {
            var a = MPFRFloat(1.5, precision: 2)
            let ternary = a.multiply(by: 2, rounding: mode)
            #expect(
                ternary == -1 || ternary == 0 || ternary == 1,
                "Ternary should be valid for mode \(mode)"
            )
        }
    }

    @Test
    func multiply_Int_ReturnsTernary() async throws {
        // Test Case 76
        var a = MPFRFloat(1.5, precision: 2)
        let ternary = a.multiply(by: 2, rounding: .nearest)
        #expect(
            ternary == -1 || ternary == 0 || ternary == 1,
            "Ternary should be -1, 0, or 1"
        )
    }

    // MARK: - divide(by other: MPFRFloat, rounding: MPFRRoundingMode) -> Int

    @Test
    func divide_MPFRFloat_BasicValues_ModifiesSelf() async throws {
        // Test Case 77: Table Test
        let testCases: [(
            a: Double,
            b: Double,
            expectedResult: Double,
            expectedTernary: Int,
            notes: String
        )] = [
            (6.0, 2.0, 3.0, 0, "Positive numbers"),
            (-6.0, -2.0, 3.0, 0, "Negative numbers"),
            (6.0, -2.0, -3.0, 0, "Mixed signs"),
            (3.14, 1.0, 3.14, 0, "Dividing by one"),
            (3.14, 3.14, 1.0, 0, "Dividing by self"),
        ]

        for testCase in testCases {
            var a = MPFRFloat(testCase.a, precision: 64)
            let b = MPFRFloat(testCase.b, precision: 64)
            let ternary = a.divide(by: b, rounding: .nearest)
            #expect(
                abs(a.toDouble() - testCase.expectedResult) < 0.01,
                "a should match expected result for \(testCase.notes)"
            )
            #expect(
                ternary == testCase.expectedTernary,
                "Ternary should be \(testCase.expectedTernary) for \(testCase.notes)"
            )
        }
    }

    @Test
    func divide_MPFRFloat_Zero_ReturnsNaN() async throws {
        // Test Case 78
        var a = MPFRFloat(3.14, precision: 64)
        let b = MPFRFloat(0.0, precision: 64)
        _ = a.divide(by: b, rounding: .nearest)
        // MPFR may set NaN or Infinity for division by zero
        #expect(
            a.isNaN || a.isInfinity,
            "Dividing by zero should set a to NaN or Infinity"
        )
    }

    @Test
    func divide_MPFRFloat_Infinity_Works() async throws {
        // Test Case 79: Table Test
        let testCases: [(
            a: Double,
            b: Double,
            expectedIsInfinity: Bool,
            expectedIsZero: Bool,
            expectedSign: Int?,
            notes: String
        )] = [
            (
                3.14,
                Double.infinity,
                false,
                true,
                nil,
                "Finite divided by infinity"
            ),
            (
                Double.infinity,
                3.14,
                true,
                false,
                1,
                "Infinity divided by finite"
            ),
        ]

        for testCase in testCases {
            var a = MPFRFloat(testCase.a, precision: 64)
            let b = MPFRFloat(testCase.b, precision: 64)
            _ = a.divide(by: b, rounding: .nearest)
            if testCase.expectedIsInfinity {
                #expect(
                    a.isInfinity,
                    "a should be infinity for \(testCase.notes)"
                )
                if let expectedSign = testCase.expectedSign {
                    #expect(
                        a.sign == expectedSign,
                        "a sign should be \(expectedSign) for \(testCase.notes)"
                    )
                }
            } else if testCase.expectedIsZero {
                #expect(a.isZero, "a should be zero for \(testCase.notes)")
            }
        }
    }

    @Test
    func divide_MPFRFloat_NaN_SetsNaN() async throws {
        // Test Case 80
        var a = MPFRFloat(3.14, precision: 64)
        let b = MPFRFloat() // NaN
        _ = a.divide(by: b, rounding: .nearest)
        #expect(a.isNaN, "a should be NaN")
    }

    @Test
    func divide_MPFRFloat_AllRoundingModes_Works() async throws {
        // Test Case 81
        let modes: [MPFRRoundingMode] = [
            .nearest,
            .towardZero,
            .towardPositiveInfinity,
            .towardNegativeInfinity,
            .awayFromZero,
            .faithful,
        ]
        for mode in modes {
            var a = MPFRFloat(1.0, precision: 2)
            let b = MPFRFloat(3.0, precision: 2)
            let ternary = a.divide(by: b, rounding: mode)
            #expect(
                ternary == -1 || ternary == 0 || ternary == 1,
                "Ternary should be valid for mode \(mode)"
            )
        }
    }

    @Test
    func divide_MPFRFloat_ReturnsTernary() async throws {
        // Test Case 82
        var a = MPFRFloat(1.0, precision: 2)
        let b = MPFRFloat(3.0, precision: 2)
        let ternary = a.divide(by: b, rounding: .nearest)
        #expect(
            ternary == -1 || ternary == 0 || ternary == 1,
            "Ternary should be -1, 0, or 1"
        )
    }

    // MARK: - divide(by value: Int, rounding: MPFRRoundingMode) -> Int

    @Test
    func divide_Int_BasicValues_ModifiesSelf() async throws {
        // Test Case 83: Table Test
        let testCases: [(
            a: Double,
            intValue: Int,
            expectedResult: Double,
            expectedTernary: Int?,
            notes: String
        )] = [
            (6.0, 2, 3.0, 0, "Positive integer"),
            (6.0, -2, -3.0, 0, "Negative integer"),
            (3.14, 1, 3.14, 0, "One"),
            (3140.0, 1000, 3.14, nil, "Large integer"), // May have rounding
        ]

        for testCase in testCases {
            var a = MPFRFloat(testCase.a, precision: 64)
            let ternary = a.divide(by: testCase.intValue, rounding: .nearest)
            #expect(
                abs(a.toDouble() - testCase.expectedResult) < 0.01,
                "a should match expected result for \(testCase.notes)"
            )
            if let expectedTernary = testCase.expectedTernary {
                #expect(
                    ternary == expectedTernary,
                    "Ternary should be \(expectedTernary) for \(testCase.notes)"
                )
            } else {
                #expect(
                    ternary == -1 || ternary == 0 || ternary == 1,
                    "Ternary should be valid for \(testCase.notes)"
                )
            }
        }
    }

    @Test
    func divide_Int_AllRoundingModes_Works() async throws {
        // Test Case 84
        let modes: [MPFRRoundingMode] = [
            .nearest,
            .towardZero,
            .towardPositiveInfinity,
            .towardNegativeInfinity,
            .awayFromZero,
            .faithful,
        ]
        for mode in modes {
            var a = MPFRFloat(1.0, precision: 2)
            let ternary = a.divide(by: 3, rounding: mode)
            #expect(
                ternary == -1 || ternary == 0 || ternary == 1,
                "Ternary should be valid for mode \(mode)"
            )
        }
    }

    @Test
    func divide_Int_ReturnsTernary() async throws {
        // Test Case 85
        var a = MPFRFloat(1.0, precision: 2)
        let ternary = a.divide(by: 3, rounding: .nearest)
        #expect(
            ternary == -1 || ternary == 0 || ternary == 1,
            "Ternary should be -1, 0, or 1"
        )
    }

    @Test
    func divide_Int_Zero_SetsToNaN() async throws {
        // Test division by zero - should set to NaN and return 0
        var a = MPFRFloat(3.14, precision: 64)
        let ternary = a.divide(by: 0, rounding: .nearest)

        // Then: Result should be NaN, ternary should be 0
        #expect(a.isNaN == true, "Dividing by zero should set result to NaN")
        #expect(ternary == 0, "NaN operations return 0 as ternary")
    }

    // MARK: - negate(rounding: MPFRRoundingMode) -> Int

    @Test
    func negate_BasicValues_ModifiesSelf() async throws {
        // Test Case 86: Table Test
        let testCases: [(
            value: Double,
            expectedResult: Double,
            expectedTernary: Int,
            notes: String
        )] = [
            (3.14, -3.14, 0, "Positive"),
            (-3.14, 3.14, 0, "Negative"),
            (0.0, 0.0, 0, "Zero"),
        ]

        for testCase in testCases {
            var a = MPFRFloat(testCase.value, precision: 64)
            let ternary = a.negate(rounding: .nearest)
            #expect(
                abs(a.toDouble() - testCase.expectedResult) < 0.01,
                "a should match expected result for \(testCase.notes)"
            )
            #expect(
                ternary == testCase.expectedTernary,
                "Ternary should be 0 (exact) for \(testCase.notes)"
            )
        }
    }

    @Test
    func negate_Infinity_Works() async throws {
        // Test Case 86 continued: Infinity and NaN cases
        var posInf = MPFRFloat(Double.infinity, precision: 64)
        let ternaryPosInf = posInf.negate(rounding: .nearest)
        #expect(
            posInf.isInfinity && posInf.sign == -1,
            "Negating positive infinity should give negative infinity"
        )
        #expect(ternaryPosInf == 0, "Ternary should be 0 (exact)")

        var negInf = MPFRFloat(-Double.infinity, precision: 64)
        let ternaryNegInf = negInf.negate(rounding: .nearest)
        #expect(
            negInf.isInfinity && negInf.sign == 1,
            "Negating negative infinity should give positive infinity"
        )
        #expect(ternaryNegInf == 0, "Ternary should be 0 (exact)")

        var nan = MPFRFloat()
        let ternaryNaN = nan.negate(rounding: .nearest)
        #expect(nan.isNaN, "Negating NaN should return NaN")
        #expect(ternaryNaN == 0, "Ternary should be 0 (exact)")
    }

    @Test
    func negate_AllRoundingModes_Works() async throws {
        // Test Case 87
        let modes: [MPFRRoundingMode] = [
            .nearest,
            .towardZero,
            .towardPositiveInfinity,
            .towardNegativeInfinity,
            .awayFromZero,
            .faithful,
        ]
        for mode in modes {
            var a = MPFRFloat(3.14, precision: 64)
            let ternary = a.negate(rounding: mode)
            #expect(
                abs(a.toDouble() - -3.14) < 0.01,
                "a should be approximately -3.14 for mode \(mode)"
            )
            #expect(
                ternary == 0,
                "Ternary should be 0 (exact) for mode \(mode)"
            )
        }
    }

    @Test
    func negate_ReturnsZeroTernary() async throws {
        // Test Case 88
        var a = MPFRFloat(0.0, precision: 64)
        let ternary = a.negate(rounding: .nearest)
        #expect(a.isZero, "a should be zero")
        #expect(ternary == 0, "Ternary should be 0 (exact)")
    }

    // MARK: - makeAbsolute(rounding: MPFRRoundingMode) -> Int

    @Test
    func makeAbsolute_Positive_NoChange() async throws {
        // Test Case 89
        var a = MPFRFloat(3.14, precision: 64)
        let ternary = a.makeAbsolute(rounding: .nearest)
        #expect(
            abs(a.toDouble() - 3.14) < 0.01,
            "a should be approximately 3.14 (unchanged)"
        )
        #expect(ternary == 0, "Ternary should be 0 (exact)")
    }

    @Test
    func makeAbsolute_Negative_ModifiesSelf() async throws {
        // Test Case 90
        var a = MPFRFloat(-3.14, precision: 64)
        let ternary = a.makeAbsolute(rounding: .nearest)
        #expect(
            abs(a.toDouble() - 3.14) < 0.01,
            "a should be approximately 3.14"
        )
        #expect(ternary == 0, "Ternary should be 0 (exact)")
    }

    @Test
    func makeAbsolute_Zero_NoChange() async throws {
        // Test Case 91
        var a = MPFRFloat(0.0, precision: 64)
        let ternary = a.makeAbsolute(rounding: .nearest)
        #expect(a.isZero, "a should be zero (unchanged)")
        #expect(ternary == 0, "Ternary should be 0 (exact)")
    }

    @Test
    func makeAbsolute_Infinity_Works() async throws {
        // Test Case 92: Table Test
        let testCases: [(
            inputValue: Double,
            expectedIsPositiveInfinity: Bool,
            notes: String
        )] = [
            (Double.infinity, true, "Positive infinity"),
            (-Double.infinity, true, "Negative infinity"),
        ]

        for testCase in testCases {
            var a = MPFRFloat(testCase.inputValue, precision: 64)
            let ternary = a.makeAbsolute(rounding: .nearest)
            #expect(
                a.isInfinity && a.sign == 1,
                "a should be positive infinity for \(testCase.notes)"
            )
            #expect(
                ternary == 0,
                "Ternary should be 0 (exact) for \(testCase.notes)"
            )
        }
    }

    @Test
    func makeAbsolute_NaN_SetsNaN() async throws {
        // Test Case 93
        var a = MPFRFloat() // NaN value
        _ = a.makeAbsolute(rounding: .nearest)
        #expect(a.isNaN, "a should be NaN")
    }

    @Test
    func makeAbsolute_AllRoundingModes_Works() async throws {
        // Test Case 94
        let modes: [MPFRRoundingMode] = [
            .nearest,
            .towardZero,
            .towardPositiveInfinity,
            .towardNegativeInfinity,
            .awayFromZero,
            .faithful,
        ]
        for mode in modes {
            var a = MPFRFloat(-3.14, precision: 64)
            let ternary = a.makeAbsolute(rounding: mode)
            #expect(
                abs(a.toDouble() - 3.14) < 0.01,
                "a should be approximately 3.14 for mode \(mode)"
            )
            #expect(
                ternary == 0,
                "Ternary should be 0 (exact) for mode \(mode)"
            )
        }
    }

    @Test
    func makeAbsolute_ReturnsZeroTernary() async throws {
        // Test Case 95
        var a = MPFRFloat(0.0, precision: 64)
        let ternary = a.makeAbsolute(rounding: .nearest)
        #expect(a.isZero, "a should be zero")
        #expect(ternary == 0, "Ternary should be 0 (exact)")
    }
}

/// Tests for MPFRFloat Advanced Arithmetic operations
/// (Reverse Operations, Power of 2 Operations, Operator Overloads)
struct MPFRFloatArithmeticAdvancedTests {
    // MARK: - Section 3: Reverse Operations

    // MARK: - subtracting(_ value: Int, _ other: MPFRFloat, rounding: MPFRRoundingMode)

    // -> (result: MPFRFloat, ternary: Int)

    @Test
    func subtracting_Int_MPFRFloat_Positive_ReturnsDifference() async throws {
        // Test Case 96
        let b = MPFRFloat(3.14, precision: 64)
        let (result, ternary) = MPFRFloat.subtracting(5, b, rounding: .nearest)
        #expect(
            abs(result.toDouble() - 1.86) < 0.01,
            "Result should be approximately 1.86 (5 - 3.14)"
        )
        #expect(ternary == 0, "Ternary should be 0 (exact)")
    }

    @Test
    func subtracting_Int_MPFRFloat_Negative_ReturnsDifference() async throws {
        // Test Case 97
        let b = MPFRFloat(3.14, precision: 64)
        let (result, ternary) = MPFRFloat.subtracting(-5, b, rounding: .nearest)
        #expect(
            abs(result.toDouble() - -8.14) < 0.01,
            "Result should be approximately -8.14 (-5 - 3.14)"
        )
        #expect(ternary == 0, "Ternary should be 0 (exact)")
    }

    @Test
    func subtracting_Int_MPFRFloat_MixedSigns_ReturnsDifference() async throws {
        // Test Case 98
        let b = MPFRFloat(-2.0, precision: 64)
        let (result, ternary) = MPFRFloat.subtracting(5, b, rounding: .nearest)
        #expect(
            abs(result.toDouble() - 7.0) < 0.01,
            "Result should be approximately 7.0 (5 - (-2.0))"
        )
        #expect(ternary == 0, "Ternary should be 0 (exact)")
    }

    @Test
    func subtracting_Int_MPFRFloat_Zero_ReturnsInt() async throws {
        // Test Case 99
        let b = MPFRFloat(0.0, precision: 64)
        let (result, ternary) = MPFRFloat.subtracting(5, b, rounding: .nearest)
        #expect(
            abs(result.toDouble() - 5.0) < 0.01,
            "Result should be approximately 5.0"
        )
        #expect(ternary == 0, "Ternary should be 0 (exact)")
    }

    @Test
    func subtracting_Int_MPFRFloat_AllRoundingModes_Works() async throws {
        // Test Case 100: Table Test
        let testCases: [(
            mode: MPFRRoundingMode,
            intValue: Int,
            floatValue: Double
        )] = [
            (.nearest, 5, 1.5),
            (.towardZero, 5, 1.5),
            (.towardPositiveInfinity, 5, 1.5),
            (.towardNegativeInfinity, 5, 1.5),
        ]

        for testCase in testCases {
            let b = MPFRFloat(testCase.floatValue, precision: 2)
            let (result, ternary) = MPFRFloat.subtracting(
                testCase.intValue,
                b,
                rounding: testCase.mode
            )
            let resultValue = result.toDouble()
            #expect(
                resultValue >= 2.0 && resultValue <= 4.0,
                "Result \(resultValue) should be a valid rounded value for mode \(testCase.mode)"
            )
            #expect(
                ternary == -1 || ternary == 0 || ternary == 1,
                "Ternary should be valid for mode \(testCase.mode)"
            )
        }
    }

    @Test
    func subtracting_Int_MPFRFloat_ReturnsTernary() async throws {
        // Test Case 101
        let b = MPFRFloat(1.5, precision: 2)
        let (_, ternary) = MPFRFloat.subtracting(5, b, rounding: .nearest)
        #expect(
            ternary == -1 || ternary == 0 || ternary == 1,
            "Ternary should be -1, 0, or 1"
        )
    }

    // MARK: - dividing(_ value: Int, _ other: MPFRFloat, rounding: MPFRRoundingMode)

    // -> (result: MPFRFloat, ternary: Int)

    @Test
    func dividing_Int_MPFRFloat_Positive_ReturnsQuotient() async throws {
        // Test Case 102
        let b = MPFRFloat(2.0, precision: 64)
        let (result, ternary) = MPFRFloat.dividing(6, b, rounding: .nearest)
        #expect(
            abs(result.toDouble() - 3.0) < 0.01,
            "Result should be approximately 3.0 (6 / 2.0)"
        )
        #expect(ternary == 0, "Ternary should be 0 (exact)")
    }

    @Test
    func dividing_Int_MPFRFloat_Negative_ReturnsQuotient() async throws {
        // Test Case 103
        let b = MPFRFloat(2.0, precision: 64)
        let (result, ternary) = MPFRFloat.dividing(-6, b, rounding: .nearest)
        #expect(
            abs(result.toDouble() - -3.0) < 0.01,
            "Result should be approximately -3.0 (-6 / 2.0)"
        )
        #expect(ternary == 0, "Ternary should be 0 (exact)")
    }

    @Test
    func dividing_Int_MPFRFloat_MixedSigns_ReturnsQuotient() async throws {
        // Test Case 104
        let b = MPFRFloat(-2.0, precision: 64)
        let (result, ternary) = MPFRFloat.dividing(6, b, rounding: .nearest)
        #expect(
            abs(result.toDouble() - -3.0) < 0.01,
            "Result should be approximately -3.0 (6 / (-2.0))"
        )
        #expect(ternary == 0, "Ternary should be 0 (exact)")
    }

    @Test
    func dividing_Int_MPFRFloat_Zero_ReturnsNaN() async throws {
        // Test Case 105
        let b = MPFRFloat(0.0, precision: 64)
        let (result, _) = MPFRFloat.dividing(6, b, rounding: .nearest)
        // MPFR may set NaN or Infinity for division by zero
        #expect(
            result.isNaN || result.isInfinity,
            "Dividing by zero should return NaN or Infinity"
        )
    }

    @Test
    func dividing_Int_MPFRFloat_AllRoundingModes_Works() async throws {
        // Test Case 106: Table Test
        let testCases: [(
            mode: MPFRRoundingMode,
            intValue: Int,
            floatValue: Double
        )] = [
            (.nearest, 1, 3.0),
            (.towardZero, 1, 3.0),
            (.towardPositiveInfinity, 1, 3.0),
            (.towardNegativeInfinity, 1, 3.0),
        ]

        for testCase in testCases {
            let b = MPFRFloat(testCase.floatValue, precision: 2)
            let (result, ternary) = MPFRFloat.dividing(
                testCase.intValue,
                b,
                rounding: testCase.mode
            )
            let resultValue = result.toDouble()
            #expect(
                resultValue >= 0.0 && resultValue <= 1.0,
                "Result \(resultValue) should be a valid rounded value for mode \(testCase.mode)"
            )
            #expect(
                ternary == -1 || ternary == 0 || ternary == 1,
                "Ternary should be valid for mode \(testCase.mode)"
            )
        }
    }

    @Test
    func dividing_Int_MPFRFloat_ReturnsTernary() async throws {
        // Test Case 107
        let b = MPFRFloat(3.0, precision: 2)
        let (_, ternary) = MPFRFloat.dividing(1, b, rounding: .nearest)
        #expect(
            ternary == -1 || ternary == 0 || ternary == 1,
            "Ternary should be -1, 0, or 1"
        )
    }

    // MARK: - formSubtracting(_ value: Int, _ other: MPFRFloat, rounding: MPFRRoundingMode) -> Int

    @Test
    func formSubtracting_Int_MPFRFloat_BasicValues_ModifiesSelf() async throws {
        // Test Case 108: Table Test
        let testCases: [(
            intValue: Int,
            floatValue: Double,
            expectedResult: Double,
            notes: String
        )] = [
            (5, 2.0, 3.0, "Positive values"),
            (-5, -2.0, -3.0, "Negative values"),
            (5, -2.0, 7.0, "Mixed signs"),
            (5, 0.0, 5.0, "Zero float"),
        ]

        for testCase in testCases {
            var a = MPFRFloat(
                0.0,
                precision: 64
            ) // Will be set to intValue - floatValue
            let b = MPFRFloat(testCase.floatValue, precision: 64)
            _ = a.formSubtracting(testCase.intValue, b, rounding: .nearest)
            #expect(
                abs(a.toDouble() - testCase.expectedResult) < 0.01,
                "a should match expected result for \(testCase.notes)"
            )
        }
    }

    @Test
    func formSubtracting_Int_MPFRFloat_AllRoundingModes_Works() async throws {
        // Test Case 109: Table Test
        let modes: [MPFRRoundingMode] = [
            .nearest,
            .towardZero,
            .towardPositiveInfinity,
            .towardNegativeInfinity,
            .awayFromZero,
            .faithful,
        ]
        for mode in modes {
            var a = MPFRFloat(5.0, precision: 2)
            let b = MPFRFloat(1.5, precision: 2)
            let ternary = a.formSubtracting(5, b, rounding: mode)
            #expect(
                ternary == -1 || ternary == 0 || ternary == 1,
                "Ternary should be valid for mode \(mode)"
            )
        }
    }

    @Test
    func formSubtracting_Int_MPFRFloat_ReturnsTernary() async throws {
        // Test Case 110
        var a = MPFRFloat(5.0, precision: 64)
        let b = MPFRFloat(2.0, precision: 64)
        let ternary = a.formSubtracting(5, b, rounding: .nearest)
        #expect(
            ternary == -1 || ternary == 0 || ternary == 1,
            "Ternary should be -1, 0, or 1"
        )
        #expect(
            abs(a.toDouble() - 3.0) < 0.01,
            "a should be approximately 3.0 (5 - 5 - 2.0 is wrong, should be 5 - 2.0 = 3.0)"
        )
    }

    // MARK: - formDividing(_ value: Int, _ other: MPFRFloat, rounding: MPFRRoundingMode) -> Int

    @Test
    func formDividing_Int_MPFRFloat_BasicValues_ModifiesSelf() async throws {
        // Test Case 111: Table Test
        let testCases: [(
            intValue: Int,
            floatValue: Double,
            expectedResult: Double,
            notes: String
        )] = [
            (6, 2.0, 3.0, "Positive values"),
            (-6, -2.0, 3.0, "Negative values"),
            (6, -2.0, -3.0, "Mixed signs"),
        ]

        for testCase in testCases {
            var a = MPFRFloat(
                0.0,
                precision: 64
            ) // Will be set to intValue / floatValue
            let b = MPFRFloat(testCase.floatValue, precision: 64)
            _ = a.formDividing(testCase.intValue, b, rounding: .nearest)
            #expect(
                abs(a.toDouble() - testCase.expectedResult) < 0.01,
                "a should match expected result for \(testCase.notes)"
            )
        }
    }

    @Test
    func formDividing_Int_MPFRFloat_AllRoundingModes_Works() async throws {
        // Test Case 112: Table Test
        let modes: [MPFRRoundingMode] = [
            .nearest,
            .towardZero,
            .towardPositiveInfinity,
            .towardNegativeInfinity,
            .awayFromZero,
            .faithful,
        ]
        for mode in modes {
            var a = MPFRFloat(1.0, precision: 2)
            let b = MPFRFloat(3.0, precision: 2)
            let ternary = a.formDividing(1, b, rounding: mode)
            #expect(
                ternary == -1 || ternary == 0 || ternary == 1,
                "Ternary should be valid for mode \(mode)"
            )
        }
    }

    @Test
    func formDividing_Int_MPFRFloat_ReturnsTernary() async throws {
        // Test Case 113
        var a = MPFRFloat(6.0, precision: 64)
        let b = MPFRFloat(2.0, precision: 64)
        let ternary = a.formDividing(6, b, rounding: .nearest)
        #expect(
            ternary == -1 || ternary == 0 || ternary == 1,
            "Ternary should be -1, 0, or 1"
        )
        #expect(
            abs(a.toDouble() - 3.0) < 0.01,
            "a should be approximately 3.0 (6 / 2.0)"
        )
    }

    // MARK: - Section 4: Power of 2 Operations

    // MARK: - multipliedByPowerOf2(_ exponent: Int, rounding: MPFRRoundingMode) -> (result: MPFRFloat, ternary: Int)

    @Test
    func multipliedByPowerOf2_PositiveExponent_Multiplies() async throws {
        // Test Case 114
        let a = MPFRFloat(3.0, precision: 64)
        let originalA = a.toDouble()
        let (result, ternary) = a.multipliedByPowerOf2(2, rounding: .nearest)
        #expect(
            abs(result.toDouble() - 12.0) < 0.01,
            "Result should be approximately 12.0 (3.0 * 2^2)"
        )
        #expect(ternary == 0, "Ternary should be 0 (exact)")
        #expect(
            a.toDouble() == originalA,
            "Original value a should be unchanged"
        )
    }

    @Test
    func multipliedByPowerOf2_NegativeExponent_Divides() async throws {
        // Test Case 115
        let a = MPFRFloat(12.0, precision: 64)
        let originalA = a.toDouble()
        let (result, ternary) = a.multipliedByPowerOf2(-2, rounding: .nearest)
        #expect(
            abs(result.toDouble() - 3.0) < 0.01,
            "Result should be approximately 3.0 (12.0 * 2^(-2) = 12.0 / 4)"
        )
        #expect(ternary == 0, "Ternary should be 0 (exact)")
        #expect(
            a.toDouble() == originalA,
            "Original value a should be unchanged"
        )
    }

    @Test
    func multipliedByPowerOf2_Zero_NoChange() async throws {
        // Test Case 116
        let a = MPFRFloat(0.0, precision: 64)
        let (result, ternary) = a.multipliedByPowerOf2(5, rounding: .nearest)
        #expect(result.isZero, "Result should be zero (unchanged)")
        #expect(ternary == 0, "Ternary should be 0 (exact)")
    }

    @Test
    func multipliedByPowerOf2_LargeExponent_Works() async throws {
        // Test Case 117
        let a = MPFRFloat(1.0, precision: 64)
        let (result, ternary) = a.multipliedByPowerOf2(100, rounding: .nearest)
        // 2^100 is a very large number, just verify it's not zero and operation
        // succeeds
        #expect(!result.isZero, "Result should not be zero")
        #expect(ternary == 0, "Ternary should be 0 (exact)")
    }

    @Test
    func multipliedByPowerOf2_AllRoundingModes_Works() async throws {
        // Test Case 118
        let modes: [MPFRRoundingMode] = [
            .nearest,
            .towardZero,
            .towardPositiveInfinity,
            .towardNegativeInfinity,
            .awayFromZero,
            .faithful,
        ]
        for mode in modes {
            let a = MPFRFloat(1.5, precision: 2)
            let (result, ternary) = a.multipliedByPowerOf2(1, rounding: mode)
            let resultValue = result.toDouble()
            #expect(
                resultValue >= 2.0 && resultValue <= 4.0,
                "Result \(resultValue) should be a valid rounded value for mode \(mode)"
            )
            #expect(
                ternary == -1 || ternary == 0 || ternary == 1,
                "Ternary should be valid for mode \(mode)"
            )
        }
    }

    @Test
    func multipliedByPowerOf2_ReturnsTernary() async throws {
        // Test Case 119
        let a = MPFRFloat(1.5, precision: 2)
        let (_, ternary) = a.multipliedByPowerOf2(1, rounding: .nearest)
        #expect(
            ternary == -1 || ternary == 0 || ternary == 1,
            "Ternary should be -1, 0, or 1"
        )
    }

    @Test
    func multipliedByPowerOf2_DoesNotModifyOriginal() async throws {
        // Test Case 120
        let a = MPFRFloat(3.0, precision: 64)
        let originalA = a.toDouble()
        _ = a.multipliedByPowerOf2(2, rounding: .nearest)
        #expect(
            a.toDouble() == originalA,
            "a should remain unchanged (equals 3.0)"
        )
    }

    // MARK: - dividedByPowerOf2(_ exponent: Int, rounding: MPFRRoundingMode) -> (result: MPFRFloat, ternary: Int)

    @Test
    func dividedByPowerOf2_PositiveExponent_Divides() async throws {
        // Test Case 121
        let a = MPFRFloat(12.0, precision: 64)
        let originalA = a.toDouble()
        let (result, ternary) = a.dividedByPowerOf2(2, rounding: .nearest)
        #expect(
            abs(result.toDouble() - 3.0) < 0.01,
            "Result should be approximately 3.0 (12.0 / 2^2 = 12.0 / 4)"
        )
        #expect(ternary == 0, "Ternary should be 0 (exact)")
        #expect(
            a.toDouble() == originalA,
            "Original value a should be unchanged"
        )
    }

    @Test
    func dividedByPowerOf2_Zero_NoChange() async throws {
        // Test Case 122
        let a = MPFRFloat(0.0, precision: 64)
        let (result, ternary) = a.dividedByPowerOf2(5, rounding: .nearest)
        #expect(result.isZero, "Result should be zero (unchanged)")
        #expect(ternary == 0, "Ternary should be 0 (exact)")
    }

    @Test
    func dividedByPowerOf2_LargeExponent_Works() async throws {
        // Test Case 123
        let a = MPFRFloat(1.0, precision: 64)
        let (result, ternary) = a.dividedByPowerOf2(100, rounding: .nearest)
        // 2^(-100) is a very small number, just verify it's not infinity and
        // operation succeeds
        #expect(!result.isInfinity, "Result should not be infinity")
        #expect(ternary == 0, "Ternary should be 0 (exact)")
    }

    @Test
    func dividedByPowerOf2_AllRoundingModes_Works() async throws {
        // Test Case 124
        let modes: [MPFRRoundingMode] = [
            .nearest,
            .towardZero,
            .towardPositiveInfinity,
            .towardNegativeInfinity,
            .awayFromZero,
            .faithful,
        ]
        for mode in modes {
            let a = MPFRFloat(1.5, precision: 2)
            let (result, ternary) = a.dividedByPowerOf2(1, rounding: mode)
            let resultValue = result.toDouble()
            #expect(
                resultValue >= 0.0 && resultValue <= 1.0,
                "Result \(resultValue) should be a valid rounded value for mode \(mode)"
            )
            #expect(
                ternary == -1 || ternary == 0 || ternary == 1,
                "Ternary should be valid for mode \(mode)"
            )
        }
    }

    @Test
    func dividedByPowerOf2_ReturnsTernary() async throws {
        // Test Case 125
        let a = MPFRFloat(1.5, precision: 2)
        let (_, ternary) = a.dividedByPowerOf2(1, rounding: .nearest)
        #expect(
            ternary == -1 || ternary == 0 || ternary == 1,
            "Ternary should be -1, 0, or 1"
        )
    }

    @Test
    func dividedByPowerOf2_DoesNotModifyOriginal() async throws {
        // Test Case 126
        let a = MPFRFloat(12.0, precision: 64)
        let originalA = a.toDouble()
        _ = a.dividedByPowerOf2(2, rounding: .nearest)
        #expect(
            a.toDouble() == originalA,
            "a should remain unchanged (equals 12.0)"
        )
    }

    // MARK: - multiplyByPowerOf2(_ exponent: Int, rounding: MPFRRoundingMode) -> Int

    @Test
    func multiplyByPowerOf2_PositiveExponent_ModifiesSelf() async throws {
        // Test Case 127
        var a = MPFRFloat(3.0, precision: 64)
        let ternary = a.multiplyByPowerOf2(2, rounding: .nearest)
        #expect(
            abs(a.toDouble() - 12.0) < 0.01,
            "a should be approximately 12.0 (3.0 * 2^2)"
        )
        #expect(ternary == 0, "Ternary should be 0 (exact)")
    }

    @Test
    func multiplyByPowerOf2_NegativeExponent_ModifiesSelf() async throws {
        // Test Case 128
        var a = MPFRFloat(12.0, precision: 64)
        let ternary = a.multiplyByPowerOf2(-2, rounding: .nearest)
        #expect(
            abs(a.toDouble() - 3.0) < 0.01,
            "a should be approximately 3.0 (12.0 * 2^(-2) = 12.0 / 4)"
        )
        #expect(ternary == 0, "Ternary should be 0 (exact)")
    }

    @Test
    func multiplyByPowerOf2_Zero_NoChange() async throws {
        // Test Case 129
        var a = MPFRFloat(0.0, precision: 64)
        let ternary = a.multiplyByPowerOf2(5, rounding: .nearest)
        #expect(a.isZero, "a should be zero (unchanged)")
        #expect(ternary == 0, "Ternary should be 0 (exact)")
    }

    @Test
    func multiplyByPowerOf2_LargeExponent_Works() async throws {
        // Test Case 130
        var a = MPFRFloat(1.0, precision: 64)
        let ternary = a.multiplyByPowerOf2(100, rounding: .nearest)
        // 2^100 is a very large number, just verify it's not zero and operation
        // succeeds
        #expect(!a.isZero, "a should not be zero")
        #expect(ternary == 0, "Ternary should be 0 (exact)")
    }

    @Test
    func multiplyByPowerOf2_AllRoundingModes_Works() async throws {
        // Test Case 131
        let modes: [MPFRRoundingMode] = [
            .nearest,
            .towardZero,
            .towardPositiveInfinity,
            .towardNegativeInfinity,
            .awayFromZero,
            .faithful,
        ]
        for mode in modes {
            var a = MPFRFloat(1.5, precision: 2)
            let ternary = a.multiplyByPowerOf2(1, rounding: mode)
            #expect(
                ternary == -1 || ternary == 0 || ternary == 1,
                "Ternary should be valid for mode \(mode)"
            )
        }
    }

    @Test
    func multiplyByPowerOf2_ReturnsTernary() async throws {
        // Test Case 132
        var a = MPFRFloat(1.5, precision: 2)
        let ternary = a.multiplyByPowerOf2(1, rounding: .nearest)
        #expect(
            ternary == -1 || ternary == 0 || ternary == 1,
            "Ternary should be -1, 0, or 1"
        )
    }

    // MARK: - divideByPowerOf2(_ exponent: Int, rounding: MPFRRoundingMode) -> Int

    @Test
    func divideByPowerOf2_PositiveExponent_ModifiesSelf() async throws {
        // Test Case 133
        var a = MPFRFloat(12.0, precision: 64)
        let ternary = a.divideByPowerOf2(2, rounding: .nearest)
        #expect(
            abs(a.toDouble() - 3.0) < 0.01,
            "a should be approximately 3.0 (12.0 / 2^2 = 12.0 / 4)"
        )
        #expect(ternary == 0, "Ternary should be 0 (exact)")
    }

    @Test
    func divideByPowerOf2_Zero_NoChange() async throws {
        // Test Case 134
        var a = MPFRFloat(0.0, precision: 64)
        let ternary = a.divideByPowerOf2(5, rounding: .nearest)
        #expect(a.isZero, "a should be zero (unchanged)")
        #expect(ternary == 0, "Ternary should be 0 (exact)")
    }

    @Test
    func divideByPowerOf2_LargeExponent_Works() async throws {
        // Test Case 135
        var a = MPFRFloat(1.0, precision: 64)
        let ternary = a.divideByPowerOf2(100, rounding: .nearest)
        // 2^(-100) is a very small number, just verify it's not infinity and
        // operation succeeds
        #expect(!a.isInfinity, "a should not be infinity")
        #expect(ternary == 0, "Ternary should be 0 (exact)")
    }

    @Test
    func divideByPowerOf2_AllRoundingModes_Works() async throws {
        // Test Case 136
        let modes: [MPFRRoundingMode] = [
            .nearest,
            .towardZero,
            .towardPositiveInfinity,
            .towardNegativeInfinity,
            .awayFromZero,
            .faithful,
        ]
        for mode in modes {
            var a = MPFRFloat(1.5, precision: 2)
            let ternary = a.divideByPowerOf2(1, rounding: mode)
            #expect(
                ternary == -1 || ternary == 0 || ternary == 1,
                "Ternary should be valid for mode \(mode)"
            )
        }
    }

    @Test
    func divideByPowerOf2_ReturnsTernary() async throws {
        // Test Case 137
        var a = MPFRFloat(1.5, precision: 2)
        let ternary = a.divideByPowerOf2(1, rounding: .nearest)
        #expect(
            ternary == -1 || ternary == 0 || ternary == 1,
            "Ternary should be -1, 0, or 1"
        )
    }

    // MARK: - Section 5: Operator Overloads

    // MARK: - operator + (MPFRFloat, MPFRFloat)

    @Test
    func operator_Plus_MPFRFloat_ReturnsSum() async throws {
        // Test Case 138
        let a = MPFRFloat(3.14, precision: 64)
        let b = MPFRFloat(2.71, precision: 64)
        let originalA = a.toDouble()
        let originalB = b.toDouble()
        let result = a + b
        #expect(
            abs(result.toDouble() - 5.85) < 0.01,
            "Result should be approximately 5.85"
        )
        #expect(a.toDouble() == originalA, "a should be unchanged")
        #expect(b.toDouble() == originalB, "b should be unchanged")
    }

    @Test
    func operator_Plus_MPFRFloat_SpecialValues_Works() async throws {
        // Test Case 139: Table Test
        let testCases: [(
            a: Double,
            b: Double,
            expectedResult: Double?,
            expectedIsInfinity: Bool,
            expectedIsNaN: Bool,
            notes: String
        )] = [
            (3.14, 0.0, 3.14, false, false, "Adding zero"),
            (3.14, Double.infinity, nil, true, false, "Adding infinity"),
            (3.14, Double.nan, nil, false, true, "Adding NaN"),
        ]

        for testCase in testCases {
            let a = MPFRFloat(testCase.a, precision: 64)
            let b = MPFRFloat(testCase.b, precision: 64)
            let result = a + b
            if let expectedResult = testCase.expectedResult {
                #expect(
                    abs(result.toDouble() - expectedResult) < 0.01,
                    "Result should match expected for \(testCase.notes)"
                )
            } else if testCase.expectedIsInfinity {
                #expect(
                    result.isInfinity,
                    "Result should be infinity for \(testCase.notes)"
                )
            } else if testCase.expectedIsNaN {
                #expect(
                    result.isNaN,
                    "Result should be NaN for \(testCase.notes)"
                )
            }
        }
    }

    // MARK: - operator + (MPFRFloat, Int)

    @Test
    func operator_Plus_Int_ReturnsSum() async throws {
        // Test Case 140
        let a = MPFRFloat(3.14, precision: 64)
        let originalA = a.toDouble()
        let result = a + 5
        #expect(
            abs(result.toDouble() - 8.14) < 0.01,
            "Result should be approximately 8.14"
        )
        #expect(a.toDouble() == originalA, "a should be unchanged")
    }

    @Test
    func operator_Plus_Int_SpecialValues_Works() async throws {
        // Test Case 141: Table Test
        let testCases: [(
            a: Double,
            intValue: Int,
            expectedResult: Double,
            notes: String
        )] = [
            (3.14, 0, 3.14, "Adding zero"),
            (3.14, 1_000_000, 1_000_003.14, "Large integer"),
        ]

        for testCase in testCases {
            let a = MPFRFloat(testCase.a, precision: 64)
            let result = a + testCase.intValue
            #expect(
                abs(result.toDouble() - testCase.expectedResult) < 0.01,
                "Result should match expected for \(testCase.notes)"
            )
        }
    }

    // MARK: - operator - (MPFRFloat, MPFRFloat)

    @Test
    func operator_Minus_MPFRFloat_ReturnsDifference() async throws {
        // Test Case 142
        let a = MPFRFloat(3.14, precision: 64)
        let b = MPFRFloat(2.71, precision: 64)
        let originalA = a.toDouble()
        let originalB = b.toDouble()
        let result = a - b
        #expect(
            abs(result.toDouble() - 0.43) < 0.01,
            "Result should be approximately 0.43"
        )
        #expect(a.toDouble() == originalA, "a should be unchanged")
        #expect(b.toDouble() == originalB, "b should be unchanged")
    }

    @Test
    func operator_Minus_MPFRFloat_Self_ReturnsZero() async throws {
        // Test Case 143
        let a = MPFRFloat(3.14, precision: 64)
        let originalA = a.toDouble()
        let result = a - a
        #expect(result.isZero, "Result should be zero")
        #expect(a.toDouble() == originalA, "a should be unchanged")
    }

    @Test
    func operator_Minus_MPFRFloat_Infinity_Works() async throws {
        // Test Case 144: Table Test
        let testCases: [(
            a: Double,
            b: Double,
            expectedIsInfinity: Bool,
            expectedSign: Int?,
            notes: String
        )] = [
            (3.14, Double.infinity, true, -1, "Subtracting positive infinity"),
            (Double.infinity, 3.14, true, 1, "Infinity minus finite"),
        ]

        for testCase in testCases {
            let a = MPFRFloat(testCase.a, precision: 64)
            let b = MPFRFloat(testCase.b, precision: 64)
            let result = a - b
            #expect(
                result.isInfinity,
                "Result should be infinity for \(testCase.notes)"
            )
            if let expectedSign = testCase.expectedSign {
                #expect(
                    result.sign == expectedSign,
                    "Result sign should be \(expectedSign) for \(testCase.notes)"
                )
            }
        }
    }

    @Test
    func operator_Minus_MPFRFloat_NaN_ReturnsNaN() async throws {
        // Test Case 145
        let a = MPFRFloat(3.14, precision: 64)
        let b = MPFRFloat() // NaN
        let result = a - b
        #expect(result.isNaN, "Result should be NaN")
    }

    // MARK: - operator - (MPFRFloat, Int)

    @Test
    func operator_Minus_Int_ReturnsDifference() async throws {
        // Test Case 146
        let a = MPFRFloat(5.0, precision: 64)
        let originalA = a.toDouble()
        let result = a - 2
        #expect(
            abs(result.toDouble() - 3.0) < 0.01,
            "Result should be approximately 3.0"
        )
        #expect(a.toDouble() == originalA, "a should be unchanged")
    }

    @Test
    func operator_Minus_Int_Zero_ReturnsOriginal() async throws {
        // Test Case 147
        let a = MPFRFloat(3.14, precision: 64)
        let originalA = a.toDouble()
        let result = a - 0
        #expect(
            abs(result.toDouble() - 3.14) < 0.01,
            "Result should be approximately 3.14 (unchanged)"
        )
        #expect(a.toDouble() == originalA, "a should be unchanged")
    }

    @Test
    func operator_Minus_Int_Large_ReturnsDifference() async throws {
        // Test Case 148
        let a = MPFRFloat(1_000_003.14, precision: 64)
        let originalA = a.toDouble()
        let result = a - 1_000_000
        #expect(
            abs(result.toDouble() - 3.14) < 0.01,
            "Result should be approximately 3.14"
        )
        #expect(a.toDouble() == originalA, "a should be unchanged")
    }

    // MARK: - operator * (MPFRFloat, MPFRFloat)

    @Test
    func operator_Multiply_MPFRFloat_ReturnsProduct() async throws {
        // Test Case 149
        let a = MPFRFloat(3.0, precision: 64)
        let b = MPFRFloat(2.0, precision: 64)
        let originalA = a.toDouble()
        let originalB = b.toDouble()
        let result = a * b
        #expect(
            abs(result.toDouble() - 6.0) < 0.01,
            "Result should be approximately 6.0"
        )
        #expect(a.toDouble() == originalA, "a should be unchanged")
        #expect(b.toDouble() == originalB, "b should be unchanged")
    }

    @Test
    func operator_Multiply_MPFRFloat_SpecialValues_Works() async throws {
        // Test Case 150: Table Test
        let testCases: [(
            a: Double,
            b: Double,
            expectedResult: Double?,
            expectedIsInfinity: Bool,
            expectedIsNaN: Bool,
            expectedIsZero: Bool,
            notes: String
        )] = [
            (3.14, 0.0, 0.0, false, false, true, "Multiplying by zero"),
            (3.14, 1.0, 3.14, false, false, false, "Multiplying by one"),
            (
                3.14,
                Double.infinity,
                nil,
                true,
                false,
                false,
                "Multiplying by infinity"
            ),
            (3.14, Double.nan, nil, false, true, false, "Multiplying by NaN"),
        ]

        for testCase in testCases {
            let a = MPFRFloat(testCase.a, precision: 64)
            let b = MPFRFloat(testCase.b, precision: 64)
            let result = a * b
            if let expectedResult = testCase.expectedResult {
                #expect(
                    abs(result.toDouble() - expectedResult) < 0.01 ||
                        (testCase.expectedIsZero && result.isZero),
                    "Result should match expected for \(testCase.notes)"
                )
            } else if testCase.expectedIsInfinity {
                #expect(
                    result.isInfinity,
                    "Result should be infinity for \(testCase.notes)"
                )
            } else if testCase.expectedIsNaN {
                #expect(
                    result.isNaN,
                    "Result should be NaN for \(testCase.notes)"
                )
            }
        }
    }

    // MARK: - operator * (MPFRFloat, Int)

    @Test
    func operator_Multiply_Int_ReturnsProduct() async throws {
        // Test Case 151
        let a = MPFRFloat(3.0, precision: 64)
        let originalA = a.toDouble()
        let result = a * 2
        #expect(
            abs(result.toDouble() - 6.0) < 0.01,
            "Result should be approximately 6.0"
        )
        #expect(a.toDouble() == originalA, "a should be unchanged")
    }

    @Test
    func operator_Multiply_Int_SpecialValues_Works() async throws {
        // Test Case 152: Table Test
        let testCases: [(
            a: Double,
            intValue: Int,
            expectedResult: Double?,
            expectedIsZero: Bool,
            notes: String
        )] = [
            (3.14, 0, 0.0, true, "Multiplying by zero"),
            (3.14, 1, 3.14, false, "Multiplying by one"),
            (3.14, 1_000_000, 3_140_000.0, false, "Large integer"),
        ]

        for testCase in testCases {
            let a = MPFRFloat(testCase.a, precision: 64)
            let result = a * testCase.intValue
            if let expectedResult = testCase.expectedResult {
                #expect(
                    abs(result.toDouble() - expectedResult) < 0.01 ||
                        (testCase.expectedIsZero && result.isZero),
                    "Result should match expected for \(testCase.notes)"
                )
            }
        }
    }

    // MARK: - operator / (MPFRFloat, MPFRFloat)

    @Test
    func operator_Divide_MPFRFloat_ReturnsQuotient() async throws {
        // Test Case 153
        let a = MPFRFloat(6.0, precision: 64)
        let b = MPFRFloat(2.0, precision: 64)
        let originalA = a.toDouble()
        let originalB = b.toDouble()
        let result = a / b
        #expect(
            abs(result.toDouble() - 3.0) < 0.01,
            "Result should be approximately 3.0"
        )
        #expect(a.toDouble() == originalA, "a should be unchanged")
        #expect(b.toDouble() == originalB, "b should be unchanged")
    }

    @Test
    func operator_Divide_MPFRFloat_One_ReturnsOriginal() async throws {
        // Test Case 154
        let a = MPFRFloat(3.14, precision: 64)
        let b = MPFRFloat(1.0, precision: 64)
        let originalA = a.toDouble()
        let result = a / b
        #expect(
            abs(result.toDouble() - 3.14) < 0.01,
            "Result should be approximately 3.14 (unchanged)"
        )
        #expect(a.toDouble() == originalA, "a should be unchanged")
    }

    @Test
    func operator_Divide_MPFRFloat_Self_ReturnsOne() async throws {
        // Test Case 155
        let a = MPFRFloat(3.14, precision: 64)
        let originalA = a.toDouble()
        let result = a / a
        #expect(
            abs(result.toDouble() - 1.0) < 0.01,
            "Result should be approximately 1.0"
        )
        #expect(a.toDouble() == originalA, "a should be unchanged")
    }

    @Test
    func operator_Divide_MPFRFloat_Zero_ReturnsNaN() async throws {
        // Test Case 156
        let a = MPFRFloat(3.14, precision: 64)
        let b = MPFRFloat(0.0, precision: 64)
        let result = a / b
        // MPFR may set NaN or Infinity for division by zero
        #expect(
            result.isNaN || result.isInfinity,
            "Dividing by zero should return NaN or Infinity"
        )
    }

    @Test
    func operator_Divide_MPFRFloat_Infinity_Works() async throws {
        // Test Case 157: Table Test
        let testCases: [(
            a: Double,
            b: Double,
            expectedIsInfinity: Bool,
            expectedIsZero: Bool,
            expectedSign: Int?,
            notes: String
        )] = [
            (
                3.14,
                Double.infinity,
                false,
                true,
                nil,
                "Finite divided by infinity"
            ),
            (
                Double.infinity,
                3.14,
                true,
                false,
                1,
                "Infinity divided by finite"
            ),
        ]

        for testCase in testCases {
            let a = MPFRFloat(testCase.a, precision: 64)
            let b = MPFRFloat(testCase.b, precision: 64)
            let result = a / b
            if testCase.expectedIsInfinity {
                #expect(
                    result.isInfinity,
                    "Result should be infinity for \(testCase.notes)"
                )
                if let expectedSign = testCase.expectedSign {
                    #expect(
                        result.sign == expectedSign,
                        "Result sign should be \(expectedSign) for \(testCase.notes)"
                    )
                }
            } else if testCase.expectedIsZero {
                #expect(
                    result.isZero,
                    "Result should be zero for \(testCase.notes)"
                )
            }
        }
    }

    @Test
    func operator_Divide_MPFRFloat_NaN_ReturnsNaN() async throws {
        // Test Case 158
        let a = MPFRFloat(3.14, precision: 64)
        let b = MPFRFloat() // NaN
        let result = a / b
        #expect(result.isNaN, "Result should be NaN")
    }

    // MARK: - operator / (MPFRFloat, Int)

    @Test
    func operator_Divide_Int_ReturnsQuotient() async throws {
        // Test Case 159
        let a = MPFRFloat(6.0, precision: 64)
        let originalA = a.toDouble()
        let result = a / 2
        #expect(
            abs(result.toDouble() - 3.0) < 0.01,
            "Result should be approximately 3.0"
        )
        #expect(a.toDouble() == originalA, "a should be unchanged")
    }

    @Test
    func operator_Divide_Int_One_ReturnsOriginal() async throws {
        // Test Case 160
        let a = MPFRFloat(3.14, precision: 64)
        let originalA = a.toDouble()
        let result = a / 1
        #expect(
            abs(result.toDouble() - 3.14) < 0.01,
            "Result should be approximately 3.14 (unchanged)"
        )
        #expect(a.toDouble() == originalA, "a should be unchanged")
    }

    @Test
    func operator_Divide_Int_Zero_ReturnsNaN() async throws {
        // Test Case 161
        let a = MPFRFloat(3.14, precision: 64)
        let result = a / 0
        // MPFR may set NaN or Infinity for division by zero
        #expect(
            result.isNaN || result.isInfinity,
            "Dividing by zero should return NaN or Infinity"
        )
    }

    @Test
    func operator_Divide_Int_Large_ReturnsQuotient() async throws {
        // Test Case 162
        let a = MPFRFloat(3140.0, precision: 64)
        let originalA = a.toDouble()
        let result = a / 1000
        #expect(
            abs(result.toDouble() - 3.14) < 0.01,
            "Result should be approximately 3.14"
        )
        #expect(a.toDouble() == originalA, "a should be unchanged")
    }

    // MARK: - prefix operator - (MPFRFloat)

    @Test
    func operator_PrefixMinus_Positive_ReturnsNegative() async throws {
        // Test Case 163
        let a = MPFRFloat(3.14, precision: 64)
        let originalA = a.toDouble()
        let result = -a
        #expect(
            abs(result.toDouble() - -3.14) < 0.01,
            "Result should be approximately -3.14"
        )
        #expect(a.toDouble() == originalA, "a should be unchanged")
    }

    @Test
    func operator_PrefixMinus_Negative_ReturnsPositive() async throws {
        // Test Case 164
        let a = MPFRFloat(-3.14, precision: 64)
        let originalA = a.toDouble()
        let result = -a
        #expect(
            abs(result.toDouble() - 3.14) < 0.01,
            "Result should be approximately 3.14"
        )
        #expect(a.toDouble() == originalA, "a should be unchanged")
    }

    @Test
    func operator_PrefixMinus_Zero_ReturnsZero() async throws {
        // Test Case 165
        let a = MPFRFloat(0.0, precision: 64)
        let result = -a
        #expect(result.isZero, "Result should be zero")
    }

    @Test
    func operator_PrefixMinus_Infinity_Works() async throws {
        // Test Case 166: Table Test
        let testCases: [(
            inputValue: Double,
            expectedIsInfinity: Bool,
            expectedSign: Int?,
            notes: String
        )] = [
            (Double.infinity, true, -1, "Positive infinity"),
            (-Double.infinity, true, 1, "Negative infinity"),
        ]

        for testCase in testCases {
            let a = MPFRFloat(testCase.inputValue, precision: 64)
            let result = -a
            #expect(
                result.isInfinity,
                "Result should be infinity for \(testCase.notes)"
            )
            if let expectedSign = testCase.expectedSign {
                #expect(
                    result.sign == expectedSign,
                    "Result sign should be \(expectedSign) for \(testCase.notes)"
                )
            }
        }
    }

    @Test
    func operator_PrefixMinus_NaN_ReturnsNaN() async throws {
        // Test Case 167
        let a = MPFRFloat() // NaN value
        let result = -a
        #expect(result.isNaN, "Result should be NaN")
    }

    // MARK: - operator += (MPFRFloat, MPFRFloat)

    @Test
    func operator_PlusEquals_MPFRFloat_ModifiesSelf() async throws {
        // Test Case 168
        var a = MPFRFloat(3.0, precision: 64)
        let b = MPFRFloat(2.0, precision: 64)
        let originalB = b.toDouble()
        a += b
        #expect(abs(a.toDouble() - 5.0) < 0.01, "a should be approximately 5.0")
        #expect(b.toDouble() == originalB, "b should be unchanged")
    }

    @Test
    func operator_PlusEquals_MPFRFloat_Zero_NoChange() async throws {
        // Test Case 169
        var a = MPFRFloat(3.14, precision: 64)
        let b = MPFRFloat(0.0, precision: 64)
        let originalB = b.toDouble()
        a += b
        #expect(
            abs(a.toDouble() - 3.14) < 0.01,
            "a should be approximately 3.14 (unchanged)"
        )
        #expect(b.toDouble() == originalB, "b should be unchanged")
    }

    @Test
    func operator_PlusEquals_MPFRFloat_Infinity_Works() async throws {
        // Test Case 170
        var a = MPFRFloat(3.14, precision: 64)
        let b = MPFRFloat(Double.infinity, precision: 64)
        a += b
        #expect(a.isInfinity && a.sign == 1, "a should be positive infinity")
    }

    @Test
    func operator_PlusEquals_MPFRFloat_NaN_SetsNaN() async throws {
        // Test Case 171
        var a = MPFRFloat(3.14, precision: 64)
        let b = MPFRFloat() // NaN
        a += b
        #expect(a.isNaN, "a should be NaN")
    }

    // MARK: - operator += (MPFRFloat, Int)

    @Test
    func operator_PlusEquals_Int_ModifiesSelf() async throws {
        // Test Case 172
        var a = MPFRFloat(3.0, precision: 64)
        a += 2
        #expect(abs(a.toDouble() - 5.0) < 0.01, "a should be approximately 5.0")
    }

    @Test
    func operator_PlusEquals_Int_SpecialValues_Works() async throws {
        // Test Case 173: Table Test
        let testCases: [(
            a: Double,
            intValue: Int,
            expectedResult: Double,
            notes: String
        )] = [
            (3.14, 0, 3.14, "Adding zero"),
            (3.14, 1_000_000, 1_000_003.14, "Large integer"),
        ]

        for testCase in testCases {
            var a = MPFRFloat(testCase.a, precision: 64)
            a += testCase.intValue
            #expect(
                abs(a.toDouble() - testCase.expectedResult) < 0.01,
                "a should match expected result for \(testCase.notes)"
            )
        }
    }

    // MARK: - operator -= (MPFRFloat, MPFRFloat)

    @Test
    func operator_MinusEquals_MPFRFloat_ModifiesSelf() async throws {
        // Test Case 174
        var a = MPFRFloat(5.0, precision: 64)
        let b = MPFRFloat(2.0, precision: 64)
        let originalB = b.toDouble()
        a -= b
        #expect(abs(a.toDouble() - 3.0) < 0.01, "a should be approximately 3.0")
        #expect(b.toDouble() == originalB, "b should be unchanged")
    }

    @Test
    func operator_MinusEquals_MPFRFloat_SpecialValues_Works() async throws {
        // Test Case 175: Table Test
        let testCases: [(
            a: Double,
            b: Double,
            expectedResult: Double?,
            expectedIsInfinity: Bool,
            expectedIsNaN: Bool,
            expectedIsZero: Bool,
            notes: String
        )] = [
            (3.14, 0.0, 3.14, false, false, false, "Subtracting zero"),
            (3.14, 3.14, 0.0, false, false, true, "Subtracting self"),
            (
                3.14,
                Double.infinity,
                nil,
                true,
                false,
                false,
                "Subtracting infinity"
            ),
            (3.14, Double.nan, nil, false, true, false, "Subtracting NaN"),
        ]

        for testCase in testCases {
            var a = MPFRFloat(testCase.a, precision: 64)
            let b = MPFRFloat(testCase.b, precision: 64)
            a -= b
            if let expectedResult = testCase.expectedResult {
                #expect(
                    abs(a.toDouble() - expectedResult) < 0.01 ||
                        (testCase.expectedIsZero && a.isZero),
                    "a should match expected result for \(testCase.notes)"
                )
            } else if testCase.expectedIsInfinity {
                #expect(
                    a.isInfinity && a.sign == -1,
                    "a should be negative infinity for \(testCase.notes)"
                )
            } else if testCase.expectedIsNaN {
                #expect(a.isNaN, "a should be NaN for \(testCase.notes)")
            }
        }
    }

    // MARK: - operator -= (MPFRFloat, Int)

    @Test
    func operator_MinusEquals_Int_ModifiesSelf() async throws {
        // Test Case 176
        var a = MPFRFloat(5.0, precision: 64)
        a -= 2
        #expect(abs(a.toDouble() - 3.0) < 0.01, "a should be approximately 3.0")
    }

    @Test
    func operator_MinusEquals_Int_SpecialValues_Works() async throws {
        // Test Case 177: Table Test
        let testCases: [(
            a: Double,
            intValue: Int,
            expectedResult: Double,
            notes: String
        )] = [
            (3.14, 0, 3.14, "Subtracting zero"),
            (1_000_003.14, 1_000_000, 3.14, "Large integer"),
        ]

        for testCase in testCases {
            var a = MPFRFloat(testCase.a, precision: 64)
            a -= testCase.intValue
            #expect(
                abs(a.toDouble() - testCase.expectedResult) < 0.01,
                "a should match expected result for \(testCase.notes)"
            )
        }
    }

    // MARK: - operator *= (MPFRFloat, MPFRFloat)

    @Test
    func operator_MultiplyEquals_MPFRFloat_ModifiesSelf() async throws {
        // Test Case 178
        var a = MPFRFloat(3.0, precision: 64)
        let b = MPFRFloat(2.0, precision: 64)
        let originalB = b.toDouble()
        a *= b
        #expect(abs(a.toDouble() - 6.0) < 0.01, "a should be approximately 6.0")
        #expect(b.toDouble() == originalB, "b should be unchanged")
    }

    @Test
    func operator_MultiplyEquals_MPFRFloat_SpecialValues_Works() async throws {
        // Test Case 179: Table Test
        let testCases: [(
            a: Double,
            b: Double,
            expectedResult: Double?,
            expectedIsInfinity: Bool,
            expectedIsNaN: Bool,
            expectedIsZero: Bool,
            notes: String
        )] = [
            (3.14, 0.0, 0.0, false, false, true, "Multiplying by zero"),
            (3.14, 1.0, 3.14, false, false, false, "Multiplying by one"),
            (
                3.14,
                Double.infinity,
                nil,
                true,
                false,
                false,
                "Multiplying by infinity"
            ),
            (3.14, Double.nan, nil, false, true, false, "Multiplying by NaN"),
        ]

        for testCase in testCases {
            var a = MPFRFloat(testCase.a, precision: 64)
            let b = MPFRFloat(testCase.b, precision: 64)
            a *= b
            if let expectedResult = testCase.expectedResult {
                #expect(
                    abs(a.toDouble() - expectedResult) < 0.01 ||
                        (testCase.expectedIsZero && a.isZero),
                    "a should match expected result for \(testCase.notes)"
                )
            } else if testCase.expectedIsInfinity {
                #expect(
                    a.isInfinity && a.sign == 1,
                    "a should be positive infinity for \(testCase.notes)"
                )
            } else if testCase.expectedIsNaN {
                #expect(a.isNaN, "a should be NaN for \(testCase.notes)")
            }
        }
    }

    // MARK: - operator *= (MPFRFloat, Int)

    @Test
    func operator_MultiplyEquals_Int_ModifiesSelf() async throws {
        // Test Case 180
        var a = MPFRFloat(3.0, precision: 64)
        a *= 2
        #expect(abs(a.toDouble() - 6.0) < 0.01, "a should be approximately 6.0")
    }

    @Test
    func operator_MultiplyEquals_Int_SpecialValues_Works() async throws {
        // Test Case 181: Table Test
        let testCases: [(
            a: Double,
            intValue: Int,
            expectedResult: Double?,
            expectedIsZero: Bool,
            notes: String
        )] = [
            (3.14, 0, 0.0, true, "Multiplying by zero"),
            (3.14, 1, 3.14, false, "Multiplying by one"),
            (3.14, 1_000_000, 3_140_000.0, false, "Large integer"),
        ]

        for testCase in testCases {
            var a = MPFRFloat(testCase.a, precision: 64)
            a *= testCase.intValue
            if let expectedResult = testCase.expectedResult {
                #expect(
                    abs(a.toDouble() - expectedResult) < 0.01 ||
                        (testCase.expectedIsZero && a.isZero),
                    "a should match expected result for \(testCase.notes)"
                )
            }
        }
    }

    // MARK: - operator /= (MPFRFloat, MPFRFloat)

    @Test
    func operator_DivideEquals_MPFRFloat_ModifiesSelf() async throws {
        // Test Case 182
        var a = MPFRFloat(6.0, precision: 64)
        let b = MPFRFloat(2.0, precision: 64)
        let originalB = b.toDouble()
        a /= b
        #expect(abs(a.toDouble() - 3.0) < 0.01, "a should be approximately 3.0")
        #expect(b.toDouble() == originalB, "b should be unchanged")
    }

    @Test
    func operator_DivideEquals_MPFRFloat_One_NoChange() async throws {
        // Test Case 183
        var a = MPFRFloat(3.14, precision: 64)
        let b = MPFRFloat(1.0, precision: 64)
        let originalB = b.toDouble()
        a /= b
        #expect(
            abs(a.toDouble() - 3.14) < 0.01,
            "a should be approximately 3.14 (unchanged)"
        )
        #expect(b.toDouble() == originalB, "b should be unchanged")
    }

    @Test
    func operator_DivideEquals_MPFRFloat_Self_SetsOne() async throws {
        // Test Case 184
        var a = MPFRFloat(3.14, precision: 64)
        a /= a
        #expect(abs(a.toDouble() - 1.0) < 0.01, "a should be approximately 1.0")
    }

    @Test
    func operator_DivideEquals_MPFRFloat_Zero_ReturnsNaN() async throws {
        // Test Case 185
        var a = MPFRFloat(3.14, precision: 64)
        let b = MPFRFloat(0.0, precision: 64)
        a /= b
        // MPFR may set NaN or Infinity for division by zero
        #expect(
            a.isNaN || a.isInfinity,
            "Dividing by zero should set a to NaN or Infinity"
        )
    }

    @Test
    func operator_DivideEquals_MPFRFloat_Infinity_Works() async throws {
        // Test Case 186
        var a = MPFRFloat(3.14, precision: 64)
        let b = MPFRFloat(Double.infinity, precision: 64)
        a /= b
        #expect(a.isZero, "a should be zero")
    }

    @Test
    func operator_DivideEquals_MPFRFloat_NaN_SetsNaN() async throws {
        // Test Case 187
        var a = MPFRFloat(3.14, precision: 64)
        let b = MPFRFloat() // NaN
        a /= b
        #expect(a.isNaN, "a should be NaN")
    }

    // MARK: - operator /= (MPFRFloat, Int)

    @Test
    func operator_DivideEquals_Int_ModifiesSelf() async throws {
        // Test Case 188
        var a = MPFRFloat(6.0, precision: 64)
        a /= 2
        #expect(abs(a.toDouble() - 3.0) < 0.01, "a should be approximately 3.0")
    }

    @Test
    func operator_DivideEquals_Int_SpecialValues_Works() async throws {
        // Test Case 189: Table Test
        let testCases: [(
            a: Double,
            intValue: Int,
            expectedResult: Double,
            notes: String
        )] = [
            (3.14, 1, 3.14, "Dividing by one"),
            (3140.0, 1000, 3.14, "Large integer"),
        ]

        for testCase in testCases {
            var a = MPFRFloat(testCase.a, precision: 64)
            a /= testCase.intValue
            #expect(
                abs(a.toDouble() - testCase.expectedResult) < 0.01,
                "a should match expected result for \(testCase.notes)"
            )
        }
    }
}
