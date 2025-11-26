// Import CKalliope first so gmp.h is available when CLinus imports mpfr.h
import CKalliope
import CLinus
import CLinusBridge
import Kalliope

// MARK: - Hashable Conformance

/// Hashable conformance for `MPFRFloat`.
///
/// **Note**: The hash is based on the float's mathematical value, not its
/// precision.
/// Two floats with the same value but different precisions will have the same
/// hash value.
/// This ensures Hashable compliance: if `a == b`, then `hash(a) == hash(b)`.
extension MPFRFloat: Hashable {
    /// Hash the float into the provided hasher.
    ///
    /// - Parameter hasher: The hasher to use for combining hash values.
    ///
    /// - Requires: This float must be properly initialized.
    /// - Guarantees: The hash value is based on the float's mathematical value.
    ///   Two floats with the same value will produce the same hash value,
    /// regardless
    ///   of precision. This satisfies the Hashable requirement: if `a == b`,
    /// then
    ///   `hash(a) == hash(b)`. NaN values all hash to the same special value.
    ///
    /// - Note: The hash uses a normalized representation by converting to a
    ///   `GMPRational` via `mpfr_get_q()`, which gives an exact rational
    ///   representation. Rationals are canonicalized (reduced to lowest terms),
    ///   ensuring that same values hash the same regardless of precision.
    ///   This preserves full precision and ensures Hashable compliance: equal
    ///   values always hash the same, regardless of their internal precision.
    ///   This approach is similar to CPython's rational-based hashing strategy.
    public func hash(into hasher: inout Hasher) {
        // Handle NaN specially - all NaNs should hash to the same value
        if isNaN {
            // Use a special marker for NaN
            hasher.combine(UInt8.max) // Special marker for NaN
            return
        }

        // Convert MPFRFloat to GMPRational using mpfr_get_q
        // This gives an exact rational representation that is canonicalized
        // (reduced to lowest terms), ensuring same values hash the same
        // regardless of precision. This is similar to CPython's approach of
        // using rational number reduction for hashing.
        var rationalQ = mpq_t()
        __gmpq_init(&rationalQ)
        defer {
            __gmpq_clear(&rationalQ)
        }

        mpfr_get_q(&rationalQ, &_storage.value)

        // Create a GMPRational from the mpq_t and use its hash method
        // GMPRational's hash uses numerator and denominator, which are
        // canonicalized, ensuring same values hash the same
        var rational = GMPRational()
        rational.withMutableCPointer { dstPtr in
            __gmpq_set(dstPtr, &rationalQ)
        }

        // Use GMPRational's hash method - it handles canonicalized num/den
        rational.hash(into: &hasher)

        // Note: This approach converts to rational and uses its canonicalized
        // form, so floats with the same mathematical value but different
        // precisions
        // will hash to the same value, which satisfies the Hashable
        // requirement:
        // if `a == b`, then `hash(a) == hash(b)`. This preserves full precision
        // (no loss to Double) and is similar to CPython's rational-based
        // hashing.
    }
}

// MARK: - CustomStringConvertible Conformance

extension MPFRFloat: CustomStringConvertible {
    /// A textual representation of this float.
    ///
    /// Returns the decimal string representation of the float.
    public var description: String {
        toString()
    }
}
