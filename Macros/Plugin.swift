import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main struct Plugin: CompilerPlugin {
  var providingMacros: [any Macro.Type] { [RuntimeSortedMacro.self] }
}
