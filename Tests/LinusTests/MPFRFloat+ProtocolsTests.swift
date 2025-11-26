import CKalliope // Import CKalliope first so gmp.h is available
import CLinus
import CLinusBridge
import Kalliope
@testable import Linus
import Testing

// MARK: - Hashable Tests

@Test
func mPFRFloatHash_SameValue_SameHash() {
    let a = MPFRFloat(3.14159)
    let b = MPFRFloat(3.14159)

    var hasherA = Hasher()
    var hasherB = Hasher()
    a.hash(into: &hasherA)
    b.hash(into: &hasherB)

    #expect(hasherA.finalize() == hasherB.finalize())
}

@Test
func mPFRFloatHash_SameValueDifferentPrecision_SameHash() {
    var a = MPFRFloat(precision: 64)
    a.set(3.14159)

    var b = MPFRFloat(precision: 128)
    b.set(3.14159)

    // The hash implementation uses normalized representation (sign, exponent,
    // mantissa)
    // via toDouble2Exp(), so same values with different precisions will hash to
    // the same value. This satisfies Hashable: if a == b, then hash(a) ==
    // hash(b).
    var hasherA = Hasher()
    var hasherB = Hasher()
    a.hash(into: &hasherA)
    b.hash(into: &hasherB)

    // Since we hash the normalized value (ignoring precision), same values with
    // different precisions should hash to the same value
    #expect(hasherA.finalize() == hasherB.finalize())
}

@Test
func mPFRFloatHash_DifferentValues_DifferentHash() {
    let a = MPFRFloat(3.14)
    let b = MPFRFloat(3.15)

    var hasherA = Hasher()
    var hasherB = Hasher()
    a.hash(into: &hasherA)
    b.hash(into: &hasherB)

    #expect(hasherA.finalize() != hasherB.finalize())
}

@Test
func mPFRFloatHash_Zero_ConsistentHash() {
    let a = MPFRFloat(0.0)
    let b = MPFRFloat(0.0)

    var hasherA = Hasher()
    var hasherB = Hasher()
    a.hash(into: &hasherA)
    b.hash(into: &hasherB)

    #expect(hasherA.finalize() == hasherB.finalize())
}

@Test
func mPFRFloatHash_NegativeValue_DifferentFromPositive() {
    let a = MPFRFloat(42.0)
    let b = MPFRFloat(-42.0)

    var hasherA = Hasher()
    var hasherB = Hasher()
    a.hash(into: &hasherA)
    b.hash(into: &hasherB)

    #expect(hasherA.finalize() != hasherB.finalize())
}

@Test
func mPFRFloatHash_NaN_ConsistentHash() {
    let a = MPFRFloat()
    let b = MPFRFloat()

    // Both should be NaN
    #expect(a.isNaN)
    #expect(b.isNaN)

    var hasherA = Hasher()
    var hasherB = Hasher()
    a.hash(into: &hasherA)
    b.hash(into: &hasherB)

    // All NaNs should hash to the same value
    #expect(hasherA.finalize() == hasherB.finalize())
}

@Test
func mPFRFloatHash_VerySmallValue_ComputesHash() {
    let small = MPFRFloat(1e-100)

    var hasher = Hasher()
    small.hash(into: &hasher)
    let hash = hasher.finalize()

    // Just verify it computes without error
    #expect(hash != 0 || small.isZero)
}

@Test
func mPFRFloatHash_VeryLargeValue_ComputesHash() {
    let large = MPFRFloat(1e100)

    var hasher = Hasher()
    large.hash(into: &hasher)
    let hash = hasher.finalize()

    // Just verify it computes without error
    #expect(hash != 0 || large.isZero)
}

@Test
func mPFRFloatHash_EqualityImpliesSameHash() {
    let a = MPFRFloat(3.14159)
    let b = MPFRFloat(3.14159)

    // Same value, same precision - must be equal and have same hash
    #expect(a == b)

    var hasherA = Hasher()
    var hasherB = Hasher()
    a.hash(into: &hasherA)
    b.hash(into: &hasherB)

    #expect(hasherA.finalize() == hasherB.finalize())
}

@Test
func mPFRFloatHash_EqualityConsistency_EqualValuesHaveSameHash() {
    // Test that if a == b, then hash(a) == hash(b)
    // This is a fundamental requirement of Hashable
    let a = MPFRFloat(3.14159)
    let b = MPFRFloat(3.14159)

    // Same value, same precision - must be equal and have same hash
    #expect(a == b)

    var hasherA = Hasher()
    var hasherB = Hasher()
    a.hash(into: &hasherA)
    b.hash(into: &hasherB)
    #expect(hasherA.finalize() == hasherB.finalize())

    // Test with different precisions - check if MPFR considers them equal
    var c = MPFRFloat(precision: 64)
    c.set(3.14159)
    var d = MPFRFloat(precision: 128)
    d.set(3.14159)

    let areEqualDifferentPrec = c == d

    // CRITICAL: If they're equal, hashes MUST be equal (Hashable requirement)
    // If they're not equal, hashes can be different
    if areEqualDifferentPrec {
        var hasherC = Hasher()
        var hasherD = Hasher()
        c.hash(into: &hasherC)
        d.hash(into: &hasherD)
        #expect(
            hasherC.finalize() == hasherD.finalize(),
            "Hashable violation: equal values must have same hash"
        )
    }
}

// MARK: - CustomStringConvertible Tests

@Test
func mPFRFloatDescription_PositiveValue_ReturnsDecimalString() {
    let value = MPFRFloat(3.14159)
    let description = value.description
    #expect(description.contains("3"))
    #expect(description == value.toString())
}

@Test
func mPFRFloatDescription_Zero_ReturnsZero() {
    let value = MPFRFloat(0.0)
    // MPFR's toString() returns a detailed representation, so description may
    // be "0.00000000000000000" instead of "0"
    #expect(value.description.contains("0"))
    #expect(value.description == value.toString())
}

@Test
func mPFRFloatDescription_NegativeValue_ReturnsDecimalStringWithMinus() {
    let value = MPFRFloat(-3.14159)
    let description = value.description
    #expect(description.contains("-"))
    #expect(description == value.toString())
}

@Test
func mPFRFloatDescription_LargeValue_ReturnsDecimalString() {
    let value = MPFRFloat(1e100)
    let description = value.description
    #expect(!description.isEmpty)
    #expect(description == value.toString())
}

@Test
func mPFRFloatDescription_MatchesToString() {
    let value = MPFRFloat(2.71828)
    #expect(value.description == value.toString())
}

// MARK: - ExpressibleByIntegerLiteral Tests

@Test
func mPFRFloatIntegerLiteral_SimpleValue_CreatesCorrectValue() {
    let value: MPFRFloat = 42
    #expect(value.toInt() == 42)
}

@Test
func mPFRFloatIntegerLiteral_Zero_CreatesZero() {
    let value: MPFRFloat = 0
    #expect(value.isZero)
}

@Test
func mPFRFloatIntegerLiteral_NegativeValue_CreatesNegativeValue() {
    let value: MPFRFloat = -42
    #expect(value.toInt() == -42)
}

@Test
func mPFRFloatIntegerLiteral_LargeValue_CreatesValue() {
    let value: MPFRFloat = 1_234_567_890
    #expect(value.toInt() == 1_234_567_890)
}

@Test
func mPFRFloatIntegerLiteral_UsesDefaultPrecision() {
    let originalDefault = MPFRFloat.defaultPrecision
    defer { MPFRFloat.setDefaultPrecision(originalDefault) }

    MPFRFloat.setDefaultPrecision(128)
    let value: MPFRFloat = 42
    #expect(value.precision == 128)
}

// MARK: - ExpressibleByFloatLiteral Tests

@Test
func mPFRFloatFloatLiteral_SimpleValue_CreatesCorrectValue() {
    let value: MPFRFloat = 3.14159
    #expect(abs(value.toDouble() - 3.14159) < 0.0001)
}

@Test
func mPFRFloatFloatLiteral_Zero_CreatesZero() {
    let value: MPFRFloat = 0.0
    #expect(value.isZero)
}

@Test
func mPFRFloatFloatLiteral_NegativeValue_CreatesNegativeValue() {
    let value: MPFRFloat = -3.14159
    #expect(abs(value.toDouble() - -3.14159) < 0.0001)
}

@Test
func mPFRFloatFloatLiteral_LargeValue_CreatesValue() {
    let value: MPFRFloat = 1e100
    #expect(value.toDouble() > 1e99)
}

@Test
func mPFRFloatFloatLiteral_SmallValue_CreatesValue() {
    let value: MPFRFloat = 1e-100
    #expect(value.toDouble() < 1e-99)
}

@Test
func mPFRFloatFloatLiteral_UsesDefaultPrecision() {
    let originalDefault = MPFRFloat.defaultPrecision
    defer { MPFRFloat.setDefaultPrecision(originalDefault) }

    MPFRFloat.setDefaultPrecision(256)
    let value: MPFRFloat = 3.14159
    #expect(value.precision == 256)
}
