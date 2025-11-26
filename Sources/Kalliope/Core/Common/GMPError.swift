/// Errors that can be thrown by GMP operations.
///
/// This enum represents various error conditions that may occur when using
/// GMP functions. All cases are recoverable - the operation fails gracefully
/// and the error can be handled by the caller.
public enum GMPError: Error, Equatable {
    /// Division by zero error.
    ///
    /// Thrown when attempting to divide by zero or compute a modular inverse
    /// when the inverse doesn't exist.
    case divisionByZero

    /// Invalid string format error.
    ///
    /// Thrown when attempting to parse a string that is not a valid number
    /// in the specified base.
    case invalidStringFormat

    /// Overflow error.
    ///
    /// Thrown when an operation would produce a result that exceeds the
    /// representable range (though GMP supports arbitrary precision, this
    /// may occur in conversions to native types).
    case overflow

    /// Underflow error.
    ///
    /// Thrown when an operation would produce a result that is too small to
    /// represent (typically in floating-point operations).
    case underflow

    /// Invalid precision error.
    ///
    /// Thrown when attempting to set a precision that is invalid (e.g.,
    /// negative
    /// or zero for floating-point numbers).
    case invalidPrecision

    /// Invalid radix (base) error.
    ///
    /// Thrown when attempting to use a radix that is outside the valid range
    /// (typically 2-62, or 0 for auto-detection).
    ///
    /// - Parameter value: The invalid radix value that was provided.
    case invalidRadix(Int)

    /// Invalid exponent error.
    ///
    /// Thrown when an exponent is invalid (e.g., negative when a non-negative
    /// exponent is required).
    ///
    /// - Parameter value: The invalid exponent value that was provided.
    case invalidExponent(Int)

    /// Negative square root error.
    ///
    /// Thrown when attempting to compute the square root of a negative value.
    case negativeSquareRoot

    /// Invalid random state error.
    ///
    /// Thrown when attempting to initialize a random state with invalid
    /// parameters
    /// (e.g., invalid size for linear congruential generator).
    case invalidRandomState
}
