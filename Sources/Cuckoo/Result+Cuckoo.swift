public extension Result where Success == Void {
  static var success: Self { .success(()) }
}
