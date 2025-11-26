import Foundation

/// String interpolation support for GMP types.
///
/// This extension provides Swift string interpolation support for GMPInteger,
/// GMPRational, and GMPFloat, allowing natural syntax like `"Value: \(z)"`
/// instead of requiring explicit formatting calls.
extension String.StringInterpolation {
    // MARK: - GMPInteger Interpolation

    /// Append a GMPInteger with default formatting (decimal).
    ///
    /// Example:
    /// ```swift
    /// let z = GMPInteger(1234)
    /// let str = "Value: \(z)"  // "Value: 1234"
    /// ```
    mutating func appendInterpolation(_ value: GMPInteger) {
        appendLiteral(value.toString())
    }

    /// Append a GMPInteger with a custom format string.
    ///
    /// - Parameters:
    ///   - value: The integer to format
    ///   - format: A GMP format string (e.g., "%Zd", "%#Zx", "%10Zd")
    ///
    /// Example:
    /// ```swift
    /// let z = GMPInteger(255)
    /// print("Hex: \(z, format: "%#Zx")")  // "Hex: 0xff"
    /// ```
    mutating func appendInterpolation(_ value: GMPInteger, format: String) {
        if let formatted = GMPFormattedIO.string(format: format, value) {
            appendLiteral(formatted)
        } else {
            appendLiteral(value.toString()) // Fallback to default
        }
    }

    /// Append a GMPInteger with convenience formatting options.
    ///
    /// - Parameters:
    ///   - value: The integer to format
    ///   - base: The numeric base (2-62). Defaults to 10.
    ///   - width: Minimum field width. If nil, no padding.
    ///   - pad: Padding character (.space or .zero). Defaults to .space.
    ///   - prefix: Whether to include base prefix (0x, 0o, etc.). Defaults to
    /// false.
    ///
    /// Example:
    /// ```swift
    /// let z = GMPInteger(255)
    /// print("\(z, base: 16, prefix: true)")  // "0xff"
    /// print("\(z, width: 10, pad: .zero)")   // "0000000255"
    /// ```
    mutating func appendInterpolation(
        _ value: GMPInteger,
        base: Int = 10,
        width: Int? = nil,
        pad: Padding = .space,
        prefix: Bool = false
    ) {
        // Validate base range
        guard (base >= 2 && base <= 62) || (base >= -36 && base <= -2) else {
            // Invalid base - fall back to default toString
            appendLiteral(value.toString())
            return
        }

        var format = "%"
        if pad == .zero { format += "0" }
        if prefix, base == 16 || base == 8 { format += "#" }
        if let width { format += "\(width)" }

        // Determine conversion character
        let conv: String
        switch base {
        case 16: conv = "Zx"
        case 8: conv = "Zo"
        case 10: conv = "Zd"
        default:
            // For other bases, GMP format strings don't support base parameter
            // directly
            // So we'll fall back to toString with the base
            appendLiteral(value.toString(base: base))
            return
        }
        format += conv

        if let formatted = GMPFormattedIO.string(format: format, value) {
            appendLiteral(formatted)
        } else {
            appendLiteral(value.toString(base: base))
        }
    }

    // MARK: - GMPRational Interpolation

    /// Append a GMPRational with default formatting (decimal).
    ///
    /// Example:
    /// ```swift
    /// let q = try GMPRational(numerator: 1, denominator: 2)
    /// let str = "Value: \(q)"  // "Value: 1/2"
    /// ```
    mutating func appendInterpolation(_ value: GMPRational) {
        appendLiteral(value.toString())
    }

    /// Append a GMPRational with a custom format string.
    ///
    /// - Parameters:
    ///   - value: The rational to format
    ///   - format: A GMP format string (e.g., "%Qd")
    ///
    /// Example:
    /// ```swift
    /// let q = try GMPRational(numerator: 1, denominator: 2)
    /// print("Value: \(q, format: "%Qd")")  // "Value: 1/2"
    /// ```
    mutating func appendInterpolation(_ value: GMPRational, format: String) {
        if let formatted = GMPFormattedIO.string(format: format, value) {
            appendLiteral(formatted)
        } else {
            appendLiteral(value.toString())
        }
    }

    /// Append a GMPRational with convenience formatting options.
    ///
    /// - Parameters:
    ///   - value: The rational to format
    ///   - base: The numeric base (2-62). Defaults to 10.
    ///
    /// Example:
    /// ```swift
    /// let q = try GMPRational(numerator: 1, denominator: 2)
    /// print("Value: \(q, base: 16)")  // "Value: 1/2"
    /// ```
    mutating func appendInterpolation(
        _ value: GMPRational,
        base: Int = 10
    ) {
        let format = "%Qd"
        if let formatted = GMPFormattedIO.string(format: format, value) {
            appendLiteral(formatted)
        } else {
            appendLiteral(value.toString(base: base))
        }
    }

    // MARK: - GMPFloat Interpolation

    /// Append a GMPFloat with default formatting.
    ///
    /// Example:
    /// ```swift
    /// let f = GMPFloat(3.14159)
    /// let str = "Value: \(f)"  // "Value: 3.14159"
    /// ```
    mutating func appendInterpolation(_ value: GMPFloat) {
        appendLiteral(value.toString())
    }

    /// Append a GMPFloat with a custom format string.
    ///
    /// - Parameters:
    ///   - value: The float to format
    ///   - format: A GMP format string (e.g., "%Ff", "%.2Ff", "%Fe")
    ///
    /// Example:
    /// ```swift
    /// let f = GMPFloat(3.14159)
    /// print("Value: \(f, format: "%.2Ff")")  // "Value: 3.14"
    /// print("Value: \(f, format: "%Fe")")    // "Value: 3.14159e+00"
    /// ```
    mutating func appendInterpolation(_ value: GMPFloat, format: String) {
        if let formatted = GMPFormattedIO.string(format: format, value) {
            appendLiteral(formatted)
        } else {
            appendLiteral(value.toString())
        }
    }

    /// Append a GMPFloat with convenience formatting options.
    ///
    /// - Parameters:
    ///   - value: The float to format
    ///   - style: Formatting style (.fixed, .scientific, .auto)
    ///   - precision: Number of decimal places (for fixed) or significant
    /// digits
    ///   - width: Minimum field width
    ///
    /// Example:
    /// ```swift
    /// let f = GMPFloat(3.14159)
    /// print("\(f, style: .fixed, precision: 2)")      // "3.14"
    /// print("\(f, style: .scientific)")               // "3.14159e+00"
    /// ```
    mutating func appendInterpolation(
        _ value: GMPFloat,
        style: FloatFormatStyle = .auto,
        precision: Int? = nil,
        width: Int? = nil
    ) {
        var format = "%"
        if let width { format += "\(width)" }
        if let precision { format += ".\(precision)" }

        switch style {
        case .fixed: format += "Ff"
        case .scientific: format += "Fe"
        case .auto: format += "Fg"
        }

        if let formatted = GMPFormattedIO.string(format: format, value) {
            appendLiteral(formatted)
        } else {
            // Fallback to toString with precision
            appendLiteral(value.toString(digits: precision ?? 0))
        }
    }
}
