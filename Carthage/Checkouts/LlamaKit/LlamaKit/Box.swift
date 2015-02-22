///
/// Box
///

/// Due to current swift limitations, we have to include this Box in Result.
/// Swift cannot handle an enum with multiple associated data (A, NSError) where one is of unknown size (A)
final public class Box<T> {
  public let unbox: T
  public init(_ value: T) { self.unbox = value }
}
