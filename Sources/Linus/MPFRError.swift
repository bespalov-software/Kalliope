// Import CKalliope first so gmp.h is available when CLinus imports mpfr.h
import CKalliope
import CLinus

/// Errors that can be thrown by MPFR operations.
///
/// This OptionSet represents exception conditions that may occur when using
/// MPFR functions. These correspond to MPFR's exception flags (see MPFR
/// documentation Section 4.6 Exceptions). All cases are recoverable - the
/// operation completes but the result may be exceptional (NaN, Infinity, etc.).
///
/// **Multiple flags can be set simultaneously**: Since this is an OptionSet,
/// multiple exceptions can be represented at once. For example, an operation
/// might set both `.underflow` and `.overflow` simultaneously.
public struct MPFRError: Error, OptionSet, Equatable {
    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    /// Underflow exception.
    ///
    /// Set when the exact result of a function is a non-zero real number
    /// and the result obtained after rounding has an exponent smaller than
    /// the minimum value of the current exponent range.
    public static let underflow =
        MPFRError(rawValue: UInt32(MPFR_FLAGS_UNDERFLOW))

    /// Overflow exception.
    ///
    /// Set when the exact result of a function is a non-zero real number
    /// and the result obtained after rounding has an exponent larger than
    /// the maximum value of the current exponent range.
    public static let overflow =
        MPFRError(rawValue: UInt32(MPFR_FLAGS_OVERFLOW))

    /// NaN (Not-a-Number) exception.
    ///
    /// Set when the result of a function is NaN. This occurs for invalid
    /// operations such as:
    /// - Square root of a negative number
    /// - Logarithm of zero or negative number
    /// - Division 0/0 or ∞/∞
    public static let nan = MPFRError(rawValue: UInt32(MPFR_FLAGS_NAN))

    /// Range error exception.
    ///
    /// Set when a function that does not return an MPFR number (such as
    /// comparisons and conversions to an integer) has an invalid result
    /// (e.g., an argument is NaN in mpfr_cmp, or a conversion to an integer
    /// cannot be represented in the target type).
    public static let rangeError =
        MPFRError(rawValue: UInt32(MPFR_FLAGS_ERANGE))

    /// Divide-by-zero exception.
    ///
    /// Set when an exact infinite result is obtained from finite inputs
    /// (e.g., 1/0, log(0)).
    public static let divideByZero =
        MPFRError(rawValue: UInt32(MPFR_FLAGS_DIVBY0))

    // MARK: - Convenience Accessors

    /// Returns `true` if the NaN flag is set.
    public var isNaN: Bool {
        contains(.nan)
    }

    /// Returns `true` if the divide-by-zero flag is set.
    public var isDivideByZero: Bool {
        contains(.divideByZero)
    }

    /// Returns `true` if the overflow flag is set.
    public var isOverflow: Bool {
        contains(.overflow)
    }

    /// Returns `true` if the underflow flag is set.
    public var isUnderflow: Bool {
        contains(.underflow)
    }

    /// Returns `true` if the range error flag is set.
    public var isRangeError: Bool {
        contains(.rangeError)
    }
}
