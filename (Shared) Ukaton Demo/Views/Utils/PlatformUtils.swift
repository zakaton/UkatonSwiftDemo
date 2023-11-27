var isWatch: Bool {
    #if os(watchOS)
    true
    #else
    false
    #endif
}

var isTv: Bool {
    #if os(tvOS)
    true
    #else
    false
    #endif
}
