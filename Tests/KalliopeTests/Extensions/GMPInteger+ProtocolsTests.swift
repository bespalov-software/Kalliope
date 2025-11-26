@testable import Kalliope
import Testing

// MARK: - Hashable Tests

@Test
func gMPIntegerHash_SameValue_SameHash() {
    let a = GMPInteger(42)
    let b = GMPInteger(42)

    var hasherA = Hasher()
    var hasherB = Hasher()
    a.hash(into: &hasherA)
    b.hash(into: &hasherB)

    #expect(hasherA.finalize() == hasherB.finalize())
}

@Test
func gMPIntegerHash_DifferentValues_DifferentHash() {
    let a = GMPInteger(42)
    let b = GMPInteger(43)

    var hasherA = Hasher()
    var hasherB = Hasher()
    a.hash(into: &hasherA)
    b.hash(into: &hasherB)

    #expect(hasherA.finalize() != hasherB.finalize())
}

@Test
func gMPIntegerHash_Zero_ConsistentHash() {
    let a = GMPInteger(0)
    let b = GMPInteger(0)

    var hasherA = Hasher()
    var hasherB = Hasher()
    a.hash(into: &hasherA)
    b.hash(into: &hasherB)

    #expect(hasherA.finalize() == hasherB.finalize())
}

@Test
func gMPIntegerHash_NegativeValue_DifferentFromPositive() {
    let a = GMPInteger(42)
    let b = GMPInteger(-42)

    var hasherA = Hasher()
    var hasherB = Hasher()
    a.hash(into: &hasherA)
    b.hash(into: &hasherB)

    #expect(hasherA.finalize() != hasherB.finalize())
}

@Test
func gMPIntegerHash_VeryLargeValue_ComputesHash() {
    let largeValue = GMPInteger(
        "1234567890123456789012345678901234567890",
        base: 10
    )!

    var hasher = Hasher()
    largeValue.hash(into: &hasher)
    let hash = hasher.finalize()

    // Just verify it computes without error
    #expect(hash != 0 || largeValue.isZero)
}

@Test
func gMPIntegerHash_EqualityImpliesSameHash() {
    let a = GMPInteger(42)
    let b = GMPInteger(42)

    #expect(a == b)
    #expect(a.hashValue == b.hashValue)
}

@Test
func gMPIntegerHash_DifferentRepresentationsSameValue_SameHash() {
    let a = GMPInteger(42)
    let b = GMPInteger("42", base: 10)!

    var hasherA = Hasher()
    var hasherB = Hasher()
    a.hash(into: &hasherA)
    b.hash(into: &hasherB)

    #expect(hasherA.finalize() == hasherB.finalize())
}

// MARK: - CustomStringConvertible Tests

@Test
func gMPIntegerDescription_PositiveValue_ReturnsDecimalString() {
    let value = GMPInteger(42)
    #expect(value.description == "42")
    #expect(value.description == value.toString())
}

@Test
func gMPIntegerDescription_Zero_ReturnsZero() {
    let value = GMPInteger(0)
    #expect(value.description == "0")
    #expect(value.description == value.toString())
}

@Test
func gMPIntegerDescription_NegativeValue_ReturnsDecimalStringWithMinus() {
    let value = GMPInteger(-42)
    #expect(value.description == "-42")
    #expect(value.description == value.toString())
}

@Test
func gMPIntegerDescription_LargeValue_ReturnsDecimalString() {
    let value = GMPInteger("12345678901234567890", base: 10)!
    #expect(value.description == "12345678901234567890")
    #expect(value.description == value.toString())
}

@Test
func gMPIntegerDescription_MatchesToString() {
    let value = GMPInteger(255)
    #expect(value.description == value.toString())
}
