import Foundation
import typealias HMCollections.SortedArray
import HMData
import protocol Initializable.InitializableWithoutArguments
import SwiftData
import Testing

enum PersistentModel_Tests {
  @Test static func `A relationship's models are sorted when its owner is loaded`() throws {
    let context = try ModelContext.inMemory
    let cat = Cat()
    context.insert(cat)
    cat.toys = .init(wrappedValue: ["🧶", "🐟", "🐭"].map(Toy.init))
    try context.save()

    let loaded: Cat = try #require(ModelContext(context.container).fetch(.init()).first)
    #expect(loaded.toys.wrappedValue.map(\.name) == ["🐟", "🐭", "🧶"])
  }

  @Test static func `A relationship that was never assigned is empty`() {
    #expect(Cat().toys.wrappedValue.isEmpty)
  }

  @Test static func `A relationship can be assigned before its owner is inserted`() throws {
    let cat = Cat()
    cat.toys = .init(wrappedValue: ["🧶", "🐟"].map(Toy.init))
    let context = try ModelContext.inMemory
    context.insert(cat)
    try context.save()

    #expect(try (context.fetch(.init()) as [Toy]).map(\.name).sorted() == ["🐟", "🧶"])
  }

  @Test static func `Assigning a relationship deletes the models it replaces`() throws {
    let context = try ModelContext.inMemory
    let cat = Cat()
    context.insert(cat)
    cat.toys = .init(wrappedValue: ["🐟", "🐭"].map(Toy.init))
    try context.save()

    cat.toys = .init(wrappedValue: ["🧶"].map(Toy.init))
    try context.save()

    #expect(try (context.fetch(.init()) as [Toy]).map(\.name) == ["🧶"])
  }

  @Test static func `Assigning a relationship keeps the models that are still included`() throws {
    let context = try ModelContext.inMemory
    let cat = Cat()
    context.insert(cat)
    cat.toys = .init(wrappedValue: ["🐟", "🐭", "🧶"].map(Toy.init))
    try context.save()

    let kept = cat.toys.wrappedValue.filter { $0.name != "🐭" }
    cat.toys = .init(wrappedValue: kept)
    try context.save()

    #expect(try (context.fetch(.init()) as [Toy]).map(\.name).sorted() == ["🐟", "🧶"])
    #expect(cat.toys.wrappedValue.allSatisfy { toy in kept.contains { $0 === toy } })
  }
}

@Model final class Cat {
  @Relationship(deleteRule: .cascade) @RuntimeSorted private var persistedToys: [Toy]?

  init() { }
}

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

private extension ModelContext {
  static var inMemory: ModelContext {
    get throws {
      ModelContext(
        try .init(for: Cat.self, configurations: .init(isStoredInMemoryOnly: true))
      )
    }
  }
}
