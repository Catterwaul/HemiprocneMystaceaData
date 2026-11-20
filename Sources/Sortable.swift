import protocol Foundation.SortComparator
import protocol Initializable.InitializableWithoutArguments
import protocol SwiftData.PersistentModel

/// A model that knows how to order itself, for use in a relationship that SwiftData stores unsorted.
public protocol Sortable: PersistentModel {
  associatedtype Comparator: SortComparator<Self> & InitializableWithoutArguments
}
