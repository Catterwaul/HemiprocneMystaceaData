import Foundation
import SwiftData
import Testing

extension ModelContext {
  @Test static func fetch() throws {
    let context = try ModelContext.withSavedToys
    let toys: [Toy] = try context.fetch()
    #expect(toys.map(\.name).sorted() == ["🐟", "🧶"])
    #expect(try Set(context.fetch(Toy.self)) == Set(toys))
    #expect(try context.fetch(Toy.self, descriptor: .fish).map(\.name) == ["🐟"])
  }

  @Test static func fetchCount() throws {
    let context = try ModelContext.withSavedToys
    #expect(try context.fetchCount(Toy.self) == 2)
    #expect(try context.fetchCount(Toy.self, descriptor: .fish) == 1)
  }
}

private extension ModelContext {
  /// An in-memory context that has saved a fish toy and a yarn toy.
  static var withSavedToys: ModelContext {
    get throws {
      let context = try inMemory
      ["🐟", "🧶"].map(Toy.init).forEach(context.insert)
      try context.save()
      return context
    }
  }
}

private extension FetchDescriptor<Toy> {
  static var fish: Self {
    .init(predicate: #Predicate { $0.name == "🐟" })
  }
}
