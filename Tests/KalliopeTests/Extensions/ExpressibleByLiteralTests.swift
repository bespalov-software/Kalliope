@testable import Kalliope
import Testing

// MARK: - ExpressibleByIntegerLiteral Tests

// MARK: GMPInteger

@Test
func gMPIntegerIntegerLiteral_PositiveValue_CreatesCorrectInteger() {
    let value: GMPInteger = 42
    #expect(value == GMPInteger(42))
}

@Test
func gMPIntegerIntegerLiteral_Zero_CreatesZeroInteger() {
    let value: GMPInteger = 0
    #expect(value.isZero)
}

@Test
func gMPIntegerIntegerLiteral_NegativeValue_CreatesNegativeInteger() {
    let value: GMPInteger = -42
    #expect(value == GMPInteger(-42))
    #expect(value.isNegative)
}

@Test
func gMPIntegerIntegerLiteral_EdgeValueOne_CreatesOne() {
    let value: GMPInteger = 1
    #expect(value == GMPInteger(1))
}

@Test
func gMPIntegerIntegerLiteral_EdgeValueMinusOne_CreatesMinusOne() {
    let value: GMPInteger = -1
    #expect(value == GMPInteger(-1))
}

@Test
func gMPIntegerIntegerLiteral_MaxIntValue_CreatesCorrectInteger() {
    // Use explicit init since Int.max might not work with literal syntax
    let value = GMPInteger(integerLiteral: Int.max)
    #expect(value == GMPInteger(Int.max))
}

@Test
func gMPIntegerIntegerLiteral_MinIntValue_CreatesCorrectInteger() {
    // Use explicit init since Int.min might not work with literal syntax
    let value = GMPInteger(integerLiteral: Int.min)
    #expect(value == GMPInteger(Int.min))
}

@Test
func gMPIntegerIntegerLiteral_EquivalentToGMPIntegerInit() {
    let literal: GMPInteger = 42
    let initValue = GMPInteger(42)
    #expect(literal == initValue)
}

@Test
func gMPIntegerIntegerLiteral_LiteralSyntax_CreatesCorrectValue() {
    let x: GMPInteger = 42
    #expect(x == GMPInteger(42))
}

// MARK: GMPRational

@Test
func gMPRationalIntegerLiteral_PositiveValue_CreatesRationalValueSlashOne(
) throws {
    let value: GMPRational = 42
    let expected = try GMPRational(numerator: 42, denominator: 1)
    #expect(value == expected)
}

@Test
func gMPRationalIntegerLiteral_Zero_CreatesZeroRational() {
    let value: GMPRational = 0
    #expect(value.isZero)
}

@Test
func gMPRationalIntegerLiteral_NegativeValue_CreatesNegativeRational() throws {
    let value: GMPRational = -42
    let expected = try GMPRational(numerator: -42, denominator: 1)
    #expect(value == expected)
    #expect(value.isNegative)
}

@Test
func gMPRationalIntegerLiteral_EdgeValueOne_CreatesOneSlashOne() throws {
    let value: GMPRational = 1
    let expected = try GMPRational(numerator: 1, denominator: 1)
    #expect(value == expected)
}

@Test
func gMPRationalIntegerLiteral_EdgeValueMinusOne_CreatesMinusOneSlashOne(
) throws {
    let value: GMPRational = -1
    let expected = try GMPRational(numerator: -1, denominator: 1)
    #expect(value == expected)
}

@Test
func gMPRationalIntegerLiteral_MaxIntValue_CreatesCorrectRational() throws {
    // Use explicit init since Int.max might not work with literal syntax
    let value = GMPRational(integerLiteral: Int.max)
    let expected = try GMPRational(numerator: Int.max, denominator: 1)
    #expect(value == expected)
}

@Test
func gMPRationalIntegerLiteral_MinIntValue_CreatesCorrectRational() throws {
    // Use explicit init since Int.min might not work with literal syntax
    let value = GMPRational(integerLiteral: Int.min)
    let expected = try GMPRational(numerator: Int.min, denominator: 1)
    #expect(value == expected)
}

@Test
func gMPRationalIntegerLiteral_EquivalentToGMPRationalInit() throws {
    let literal: GMPRational = 42
    let initValue = GMPRational(GMPInteger(42))
    #expect(literal == initValue)
}

@Test
func gMPRationalIntegerLiteral_LiteralSyntax_CreatesCorrectValue() throws {
    let x: GMPRational = 42
    let expected = try GMPRational(numerator: 42, denominator: 1)
    #expect(x == expected)
}

@Test
func gMPRationalIntegerLiteral_DenominatorIsOne() throws {
    let value: GMPRational = 42
    let den = value.denominator
    #expect(den == GMPInteger(1))
}

// MARK: GMPFloat

@Test
func gMPFloatIntegerLiteral_PositiveValue_CreatesCorrectFloat() {
    let value: GMPFloat = 42
    #expect(value == GMPFloat(42))
}

@Test
func gMPFloatIntegerLiteral_Zero_CreatesZeroFloat() {
    let value: GMPFloat = 0
    #expect(value.isZero)
}

@Test
func gMPFloatIntegerLiteral_NegativeValue_CreatesNegativeFloat() {
    let value: GMPFloat = -42
    #expect(value == GMPFloat(-42))
    #expect(value.isNegative)
}

@Test
func gMPFloatIntegerLiteral_EdgeValueOne_CreatesOne() {
    let value: GMPFloat = 1
    #expect(value == GMPFloat(1))
}

@Test
func gMPFloatIntegerLiteral_EdgeValueMinusOne_CreatesMinusOne() {
    let value: GMPFloat = -1
    #expect(value == GMPFloat(-1))
}

@Test
func gMPFloatIntegerLiteral_MaxIntValue_CreatesCorrectFloat() {
    // Use explicit init since Int.max might not work with literal syntax
    let value = GMPFloat(integerLiteral: Int.max)
    #expect(value == GMPFloat(Int.max))
}

@Test
func gMPFloatIntegerLiteral_MinIntValue_CreatesCorrectFloat() {
    // Use explicit init since Int.min might not work with literal syntax
    let value = GMPFloat(integerLiteral: Int.min)
    #expect(value == GMPFloat(Int.min))
}

@Test
func gMPFloatIntegerLiteral_EquivalentToGMPFloatInit() {
    let literal: GMPFloat = 42
    let initValue = GMPFloat(42)
    #expect(literal == initValue)
}

@Test
func gMPFloatIntegerLiteral_LiteralSyntax_CreatesCorrectValue() {
    let x: GMPFloat = 42
    #expect(x == GMPFloat(42))
}

// MARK: - ExpressibleByFloatLiteral Tests

// MARK: GMPRational

@Test
func gMPRationalFloatLiteral_PositiveFloat_CreatesApproximateRational() {
    let value: GMPRational = 3.14
    // Verify it's approximately 3.14 by checking it's close to the expected
    // value
    let expected = GMPRational(3.14)
    // Since conversion may be approximate, we check they're close
    let diff = value.subtracting(expected).absoluteValue()
    let threshold = try! GMPRational(numerator: 1, denominator: 100) // 0.01
    #expect(diff < threshold)
}

@Test
func gMPRationalFloatLiteral_NegativeFloat_CreatesApproximateRational() {
    let value: GMPRational = -3.14
    let expected = GMPRational(-3.14)
    let diff = value.subtracting(expected).absoluteValue()
    let threshold = try! GMPRational(numerator: 1, denominator: 100) // 0.01
    #expect(diff < threshold)
    #expect(value.isNegative)
}

@Test
func gMPRationalFloatLiteral_Zero_CreatesZeroRational() {
    let value: GMPRational = 0.0
    #expect(value.isZero)
}

@Test
func gMPRationalFloatLiteral_IntegerFloat_CreatesRational() {
    let value: GMPRational = 42.0
    let expected = try! GMPRational(numerator: 42, denominator: 1)
    // Should be very close since 42.0 is exactly representable
    let diff = value.subtracting(expected).absoluteValue()
    let threshold = try! GMPRational(numerator: 1, denominator: 10000) // 0.0001
    #expect(diff < threshold)
}

@Test
func gMPRationalFloatLiteral_VerySmallValue_CreatesRational() {
    let value: GMPRational = 1e-10
    let expected = GMPRational(1e-10)
    // Very small values may have some approximation error
    let diff = value.subtracting(expected).absoluteValue()
    let threshold = GMPRational(1e-8)
    #expect(diff < threshold)
}

@Test
func gMPRationalFloatLiteral_VeryLargeValue_CreatesRational() {
    let value: GMPRational = 1e10
    let expected = GMPRational(1e10)
    let diff = value.subtracting(expected).absoluteValue()
    let threshold = try! GMPRational(numerator: 1, denominator: 1) // 1
    #expect(diff < threshold)
}

@Test
func gMPRationalFloatLiteral_EquivalentToGMPRationalInit() {
    let literal: GMPRational = 3.14
    let initValue = GMPRational(3.14)
    // They should be approximately equal
    let diff = literal.subtracting(initValue).absoluteValue()
    let threshold = try! GMPRational(numerator: 1, denominator: 10000) // 0.0001
    #expect(diff < threshold)
}

@Test
func gMPRationalFloatLiteral_LiteralSyntax_CreatesCorrectValue() {
    let x: GMPRational = 3.14
    let expected = GMPRational(3.14)
    let diff = x.subtracting(expected).absoluteValue()
    let threshold = try! GMPRational(numerator: 1, denominator: 10000) // 0.0001
    #expect(diff < threshold)
}

// MARK: GMPFloat

@Test
func gMPFloatFloatLiteral_PositiveFloat_CreatesCorrectFloat() {
    let value: GMPFloat = 3.14
    #expect(value == GMPFloat(3.14))
}

@Test
func gMPFloatFloatLiteral_NegativeFloat_CreatesCorrectFloat() {
    let value: GMPFloat = -3.14
    #expect(value == GMPFloat(-3.14))
    #expect(value.isNegative)
}

@Test
func gMPFloatFloatLiteral_Zero_CreatesZeroFloat() {
    let value: GMPFloat = 0.0
    #expect(value.isZero)
}

@Test
func gMPFloatFloatLiteral_IntegerFloat_CreatesFloat() {
    let value: GMPFloat = 42.0
    #expect(value == GMPFloat(42.0))
}

@Test
func gMPFloatFloatLiteral_VerySmallValue_CreatesFloat() {
    let value: GMPFloat = 1e-10
    #expect(value == GMPFloat(1e-10))
}

@Test
func gMPFloatFloatLiteral_VeryLargeValue_CreatesFloat() {
    let value: GMPFloat = 1e10
    #expect(value == GMPFloat(1e10))
}

@Test
func gMPFloatFloatLiteral_EquivalentToGMPFloatInit() {
    let literal: GMPFloat = 3.14
    let initValue = GMPFloat(3.14)
    #expect(literal == initValue)
}

@Test
func gMPFloatFloatLiteral_LiteralSyntax_CreatesCorrectValue() {
    let x: GMPFloat = 3.14
    #expect(x == GMPFloat(3.14))
}

@Test
func gMPFloatFloatLiteral_PrecisionIsDefault() {
    let value: GMPFloat = 3.14
    // Create a default-initialized float to get default precision
    let defaultFloat = GMPFloat()
    #expect(value.precision == defaultFloat.precision)
}
