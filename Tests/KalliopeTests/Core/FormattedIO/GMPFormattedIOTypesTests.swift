import Foundation
@testable import Kalliope
import Testing

/// Tests for GMP Formatted I/O supporting types.
struct GMPFormattedIOTypesTests {
    // MARK: - Padding Enum Tests

    @Test
    func padding_Space_CaseExists() async throws {
        // Given: Padding enum
        // When: Access .space case
        let padding: Padding = .space

        // Then: Case exists and can be used
        #expect(padding == .space)
    }

    @Test
    func padding_Zero_CaseExists() async throws {
        // Given: Padding enum
        // When: Access .zero case
        let padding: Padding = .zero

        // Then: Case exists and can be used
        #expect(padding == .zero)
    }

    @Test
    func padding_Equatable() async throws {
        // Given: Two Padding values
        let space1: Padding = .space
        let space2: Padding = .space
        let zero: Padding = .zero

        // When: Comparing values
        // Then: Equality works correctly
        #expect(space1 == space2)
        #expect(space1 != zero)
        #expect(zero == .zero)
    }

    // MARK: - FloatFormatStyle Enum Tests

    @Test
    func floatFormatStyle_Fixed_CaseExists() async throws {
        // Given: FloatFormatStyle enum
        // When: Access .fixed case
        let style: FloatFormatStyle = .fixed

        // Then: Case exists and can be used
        #expect(style == .fixed)
    }

    @Test
    func floatFormatStyle_Scientific_CaseExists() async throws {
        // Given: FloatFormatStyle enum
        // When: Access .scientific case
        let style: FloatFormatStyle = .scientific

        // Then: Case exists and can be used
        #expect(style == .scientific)
    }

    @Test
    func floatFormatStyle_Auto_CaseExists() async throws {
        // Given: FloatFormatStyle enum
        // When: Access .auto case
        let style: FloatFormatStyle = .auto

        // Then: Case exists and can be used
        #expect(style == .auto)
    }

    @Test
    func floatFormatStyle_Equatable() async throws {
        // Given: FloatFormatStyle values
        let fixed1: FloatFormatStyle = .fixed
        let fixed2: FloatFormatStyle = .fixed
        let scientific: FloatFormatStyle = .scientific
        let auto: FloatFormatStyle = .auto

        // When: Comparing values
        // Then: Equality works correctly
        #expect(fixed1 == fixed2)
        #expect(fixed1 != scientific)
        #expect(fixed1 != auto)
        #expect(scientific != auto)
    }

    @Test
    func floatFormatStyle_AllCases() async throws {
        // Given: FloatFormatStyle enum
        // When: Accessing all cases
        let fixed: FloatFormatStyle = .fixed
        let scientific: FloatFormatStyle = .scientific
        let auto: FloatFormatStyle = .auto

        // Then: All cases are distinct
        #expect(fixed != scientific)
        #expect(fixed != auto)
        #expect(scientific != auto)
    }
}
