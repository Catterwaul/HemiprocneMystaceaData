import Foundation
import HMData
import protocol Initializable.InitializableWithoutArguments
import SwiftData

@Model final class Toy: Sortable {
  /// Orders toys by name.
  struct Comparator: SortComparator, InitializableWithoutArguments {
    var order = SortOrder.forward

    func compare(_ toy0: Toy, _ toy1: Toy) -> ComparisonResult {
      KeyPathComparator(\Toy.name, order: order).compare(toy0, toy1)
    }
  }

  var name = ""
  var cat: Cat?

  init(_ name: String) {
    self.name = name
  }
}
