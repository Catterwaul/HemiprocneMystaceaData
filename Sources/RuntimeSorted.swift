import typealias HMCollections.SortedArray
import Not
import SwiftData

/// Adds a computed property for a stored relationship `persisted<Name>: [<Model>]?`, named `<name>`.
///
/// SwiftData doesn't keep a relationship in order, so the property sorts on every read.
/// It can't be generated along with the relationship, because `@Model` only persists the properties that are written out.
///
/// The files that use this macro need `import HMData` and `import typealias HMCollections.SortedArray`.
@attached(peer, names: arbitrary)
public macro RuntimeSorted() = #externalMacro(module: "HMDataMacros", type: "RuntimeSortedMacro")

// MARK: - internal
public extension PersistentModel {
  /// Always sorted. SwiftData doesn't keep a relationship in order,
  /// so the sorting happens here, on every read.
  ///
  /// Assigning replaces the models, and deletes the ones that are no longer included,
  /// because a model that belongs to no owner would otherwise stay in the store and sync.
  subscript<Element: Sortable>(
    sorted persisted: ReferenceWritableKeyPath<Self, [Element]?>
  ) -> SortedArray<Element.Comparator> {
    get { .init(wrappedValue: self[keyPath: persisted] ?? []) }
    set {
      if let modelContext {
        self[keyPath: persisted]?
          .filter(!newValue.wrappedValue.contains)
          .forEach(modelContext.delete)
      }
      self[keyPath: persisted] = newValue.wrappedValue
    }
  }
}
