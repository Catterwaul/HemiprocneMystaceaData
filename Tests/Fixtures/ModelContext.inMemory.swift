import SwiftData

extension ModelContext {
  static var inMemory: ModelContext {
    get throws {
      ModelContext(
        try .init(for: Cat.self, configurations: .init(isStoredInMemoryOnly: true))
      )
    }
  }
}
