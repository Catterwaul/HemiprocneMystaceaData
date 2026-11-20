import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

struct RuntimeSortedMacro {}

// MARK: - PeerMacro
extension RuntimeSortedMacro: PeerMacro {
  static func expansion(
    of node: AttributeSyntax,
    providingPeersOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws(MacroExpansionErrorMessage) -> [DeclSyntax] {
    guard
      let binding = declaration.as(VariableDeclSyntax.self)?.bindings.first,
      let persisted = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
      persisted.hasPrefix("persisted"),
      let element = binding.typeAnnotation?.type
        .as(OptionalTypeSyntax.self)?.wrappedType
        .as(ArrayTypeSyntax.self)?.element
    else {
      throw .init("@RuntimeSorted goes on `persisted<Name>: [<Model>]?`")
    }

    let name = persisted.dropFirst("persisted".count)
    let property = name.prefix(1).lowercased() + name.dropFirst()
    return [
      """
      /// Always sorted. Assigning replaces the \(raw: property), and deletes the ones that are no longer included,
      /// because a model that belongs to no owner would otherwise stay in the store and sync.
      var \(raw: property): SortedArray<\(element.trimmed).Comparator> {
        get { self[sorted: \\.\(raw: persisted)] }
        set { self[sorted: \\.\(raw: persisted)] = newValue }
      }
      """
    ]
  }
}
