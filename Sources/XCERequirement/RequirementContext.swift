// SPDX-License-Identifier: MIT
// Copyright (c) 2016 Maxim Khatskevich

/// The source location from which a requirement was evaluated.
///
/// Validation APIs populate this value from `#fileID`, `#line`, and `#function`
/// by default. Pass explicit values when validation is forwarded through a
/// wrapper and the wrapper's caller should be reported instead.
public struct RequirementContext: Codable, Equatable, Hashable, Sendable {
    /// The module-qualified source file in which validation was requested.
    public let file: String
    /// The source line on which validation was requested.
    public let line: Int
    /// The function from which validation was requested.
    public let function: String

    /// Creates source context for a requirement evaluation.
    ///
    /// - Parameters:
    ///   - file: The module-qualified source file in which validation was requested.
    ///   - line: The source line on which validation was requested.
    ///   - function: The function from which validation was requested.
    public init(file: String, line: Int, function: String) {
        self.file = file
        self.line = line
        self.function = function
    }
}
