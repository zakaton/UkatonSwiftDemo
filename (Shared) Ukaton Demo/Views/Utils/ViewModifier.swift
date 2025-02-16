import SwiftUI

// https://stackoverflow.com/questions/68892142/swiftui-using-view-modifiers-between-different-ios-versions-without-available

public extension View {
    func modify<Content>(@ViewBuilder _ transform: (Self) -> Content) -> Content {
        transform(self)
    }

    @ViewBuilder
    func modify(@ViewBuilder _ transform: (Self) -> (some View)?) -> some View {
        if let view = transform(self), !(view is EmptyView) {
            view
        } else {
            self
        }
    }
}

#if !os(visionOS) && !os(tvOS)
public extension WidgetConfiguration {
    func modify<Content>(_ transform: (Self) -> Content) -> Content {
        transform(self)
    }
}
#endif
