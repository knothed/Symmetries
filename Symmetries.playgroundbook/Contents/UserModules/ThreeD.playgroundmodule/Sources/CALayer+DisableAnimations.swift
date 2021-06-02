import QuartzCore

internal extension CALayer {
    func disableAnimations() {
        allowsEdgeAntialiasing = true
        actions = [
            "onOrderIn": NSNull(),
            "onOrderOut": NSNull(),
            "sublayers": NSNull(),
            "contents": NSNull(),
            "bounds": NSNull(),
            "position": NSNull(),
            "transform": NSNull(),
            "opacity": NSNull(),
            "isHidden": NSNull(),
            "cornerRadius": NSNull(),
            "backgroundColor": NSNull()
        ]
    }
}
