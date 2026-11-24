import HMData
import typealias HMCollections.SortedArray
import SwiftData

@Model final class Cat {
  @Relationship(deleteRule: .cascade) @RuntimeSorted private var persistedToys: [Toy]?

  init() { }
}
