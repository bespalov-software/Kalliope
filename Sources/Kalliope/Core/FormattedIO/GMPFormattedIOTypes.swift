/// Supporting types for GMP Formatted I/O operations.
///
/// This file contains types used by the formatted I/O interface, particularly
/// for string interpolation support.

/// Padding style for formatted output.
///
/// Used in string interpolation to specify how values should be padded when
/// a minimum width is specified.
///
/// Example:
/// ```swift
/// let z = GMPInteger(255)
/// print("\(z, width: 10, pad: .space)")   // "       255"
/// print("\(z, width: 10, pad: .zero)")    // "0000000255"
/// ```
public enum Padding {
    /// Pad with spaces (default).
    case space

    /// Pad with zeros.
    case zero
}

/// Formatting style for floating-point numbers.
///
/// Used in string interpolation to specify how floating-point values should
/// be formatted.
///
/// Example:
/// ```swift
/// let f = GMPFloat(3.14159)
/// print("\(f, style: .fixed)")        // "3.14159"
/// print("\(f, style: .scientific)")   // "3.14159e+00"
/// print("\(f, style: .auto)")         // Automatically selects best format
/// ```
public enum FloatFormatStyle {
    /// Fixed-point notation (e.g., "3.14").
    case fixed

    /// Scientific notation (e.g., "3.14e+00").
    case scientific

    /// Automatic selection between fixed and scientific notation.
    case auto
}
