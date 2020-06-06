import class Foundation.NSLock.NSRecursiveLock
import struct Foundation.NSData.Data

@dynamicMemberLookup
public final class Variables {
  
  private let lock: NSRecursiveLock = NSRecursiveLock()
  private var dict: Dictionary<String, Any> = [:] {
    willSet { lock.lock() }
    didSet { lock.unlock() }
  }
  
  public init() {}
  
  public subscript<T>(dynamicMember member: String) -> T! {
    get { dict[member] as? T }
    set { dict[member] = newValue }
  }
  
  public subscript(dynamicMember member: String) -> String {
    get { dict[member].map { "\($0)" } ?? "" }
    set { dict[member] = newValue }
  }
  
  public subscript(dynamicMember member: String) -> (Data) -> Void {
    { [weak self] data in
      if var stored = self?.dict[member] as? Data {
        stored.append(data)
        self?.dict[member] = stored
      } else {
        self?.dict[member] = data
      }
    }
  }
  
  public subscript(dynamicMember member: String) -> ((Data) -> Void)? {
    { [weak self] data in
      if var stored = self?.dict[member] as? Data {
        stored.append(data)
        self?.dict[member] = stored
      } else {
        self?.dict[member] = data
      }
    }
  }
}

extension Variables: ExpressibleByDictionaryLiteral {
  public convenience init(dictionaryLiteral elements: (String, Any)...) {
    self.init()
    dict = Dictionary(uniqueKeysWithValues: elements)
  }
}
