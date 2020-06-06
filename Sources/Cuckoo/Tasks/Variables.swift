@dynamicMemberLookup
public struct Variables {
  
  private var dict: Dictionary<String, Any> = [:]
  
  public init() {}
  
  public subscript<T>(dynamicMember member: String) -> T! {
    get { dict[member] as? T }
    set { dict[member] = newValue }
  }
  
  public subscript(dynamicMember member: String) -> String {
    get { dict[member].map { "\($0)" } ?? "" }
    set { dict[member] = newValue }
  }
}

extension Variables: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral elements: (String, Any)...) {
    dict = Dictionary(uniqueKeysWithValues: elements)
  }
}
