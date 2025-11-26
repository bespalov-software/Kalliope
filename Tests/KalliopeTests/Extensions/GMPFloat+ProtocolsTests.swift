@testable import Kalliope
import Testing

// MARK: - Hashable Tests

@Test
func gMPFloatHash_SameValue_SameHash() {
    let a = GMPFloat(3.14159)
    let b = GMPFloat(3.14159)

    var hasherA = Hasher()
    var hasherB = Hasher()
    a.hash(into: &hasherA)
    b.hash(into: &hasherB)

    #expect(hasherA.finalize() == hasherB.finalize())
}

@Test
func gMPFloatHash_SameValueDifferentPrecision_SameHash() {
    var a = try! GMPFloat(precision: 64)
    a.set(3.14159)

    var b = try! GMPFloat(precision: 128)
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
func gMPFloatHash_DifferentValues_DifferentHash() {
    let a = GMPFloat(3.14)
    let b = GMPFloat(3.15)

    var hasherA = Hasher()
    var hasherB = Hasher()
    a.hash(into: &hasherA)
    b.hash(into: &hasherB)

    #expect(hasherA.finalize() != hasherB.finalize())
}

@Test
func gMPFloatHash_Zero_ConsistentHash() {
    let a = GMPFloat(0.0)
    let b = GMPFloat(0.0)

    var hasherA = Hasher()
    var hasherB = Hasher()
    a.hash(into: &hasherA)
    b.hash(into: &hasherB)

    #expect(hasherA.finalize() == hasherB.finalize())
}

@Test
func gMPFloatHash_EqualityImpliesSameHash() {
    let a = GMPFloat(3.14159)
    let b = GMPFloat(3.14159)

    #expect(a == b)
    #expect(a.hashValue == b.hashValue)
}

@Test
func gMPFloatHash_VerySmallValue_ComputesHash() {
    let small = GMPFloat(1e-100)

    var hasher = Hasher()
    small.hash(into: &hasher)
    let hash = hasher.finalize()

    // Just verify it computes without error
    #expect(hash != 0 || small.isZero)
}

@Test
func gMPFloatHash_VeryLargeValue_ComputesHash() {
    let large = GMPFloat(1e100)

    var hasher = Hasher()
    large.hash(into: &hasher)
    let hash = hasher.finalize()

    // Just verify it computes without error
    #expect(hash != 0 || large.isZero)
}

@Test
func gMPFloatHash_EqualityConsistency_EqualValuesHaveSameHash() {
    // Test that if a == b, then hash(a) == hash(b)
    // This is a fundamental requirement of Hashable
    let a = GMPFloat(3.14159)
    let b = GMPFloat(3.14159)

    // Same value, same precision - must be equal and have same hash
    #expect(a == b)
    #expect(a.hashValue == b.hashValue)

    // Test with different precisions - check if GMP considers them equal
    var c = try! GMPFloat(precision: 64)
    c.set(3.14159)
    var d = try! GMPFloat(precision: 128)
    d.set(3.14159)

    let areEqualDifferentPrec = c == d

    // CRITICAL: If they're equal, hashes MUST be equal (Hashable requirement)
    // If they're not equal, hashes can be different
    if areEqualDifferentPrec {
        #expect(
            c.hashValue == d.hashValue,
            "Hashable violation: equal values must have same hash"
        )
    }
}

// MARK: - CustomStringConvertible Tests

@Test
func gMPFloatDescription_PositiveValue_ReturnsDecimalString() {
    let value = GMPFloat(3.14159)
    let description = value.description
    #expect(description.contains("3"))
    #expect(description == value.toString())
}

@Test
func gMPFloatDescription_Zero_ReturnsZero() {
    let value = GMPFloat(0.0)
    #expect(value.description == "0")
    #expect(value.description == value.toString())
}

@Test
func gMPFloatDescription_NegativeValue_ReturnsDecimalStringWithMinus() {
    let value = GMPFloat(-3.14159)
    let description = value.description
    #expect(description.contains("-"))
    #expect(description == value.toString())
}

@Test
func gMPFloatDescription_LargeValue_ReturnsDecimalString() {
    let value = GMPFloat(1e100)
    let description = value.description
    #expect(!description.isEmpty)
    #expect(description == value.toString())
}

@Test
func gMPFloatDescription_MatchesToString() {
    let value = GMPFloat(2.71828)
    #expect(value.description == value.toString())
}
