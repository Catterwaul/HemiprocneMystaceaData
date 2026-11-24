import SwiftData

// These are `@_alwaysEmitIntoClient`, so that a target which doesn't link HMData itself can still call them.
// `@inlinable` isn't enough: without optimization, as in a Debug build, the caller still links to HMData's own copy,
// so a test target that links only a package that depends on HMData fails to link.
public extension ModelContext {
  /// A [`fetch(_:)`](https://developer.apple.com/documentation/swiftdata/modelcontext/fetch(_:)) overload
  /// that takes the type of model, or infers it, so a descriptor is only needed to filter, sort or limit the result.
  ///
  /// - Parameters:
  ///   - type: The type of model to fetch. Without it, the type comes from how the result is used.
  ///   - descriptor: Which models to fetch, and how to sort and limit them.
  ///     The default fetches every model of the type, in no particular order.
  ///
  /// - Remark: This provides an explicit overload that should have been handled via default arguments.
  @_alwaysEmitIntoClient func fetch<Model: PersistentModel>(
    _ type: Model.Type = Model.self,
    descriptor: FetchDescriptor<Model> = .init()
  ) throws -> [Model] {
    try fetch(descriptor)
  }

  /// [`fetchCount(_:)`](https://developer.apple.com/documentation/swiftdata/modelcontext/fetchcount(_:)) that takes the type of model,
  /// so a descriptor is only needed to filter what's counted.
  ///
  /// - Parameters:
  ///   - type: The type of model to count. It's required, because the result is an `Int`,
  ///     so there is nothing to infer the type from.
  ///   - descriptor: Which models to count. The default counts every model of the type.
  ///
  /// - Remark: This provides an explicit overload that should have been handled via default arguments.
  @_alwaysEmitIntoClient func fetchCount<Model: PersistentModel>(
    _ type: Model.Type,
    descriptor: FetchDescriptor<Model> = .init()
  ) throws -> Int {
    try fetchCount(descriptor)
  }
}
