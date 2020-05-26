//
//  FluidTimingCurve.swift
//  EmojiPickerUI
//
//  Created by Guilherme Rambo on 05/08/19.
//  Copyright © 2019 Peixe Urbano. All rights reserved.
//

import UIKit

public final class FluidTimingCurve: NSObject, UITimingCurveProvider {

    public let initialVelocity: CGVector
    let mass: CGFloat
    let stiffness: CGFloat
    let damping: CGFloat

    public init(velocity: CGVector, stiffness: CGFloat = 400, damping: CGFloat = 30, mass: CGFloat = 1.0) {
        self.initialVelocity = velocity
        self.stiffness = stiffness
        self.damping = damping
        self.mass = mass

        super.init()
    }

    public func encode(with aCoder: NSCoder) {
        fatalError("Not supported")
    }

    public init?(coder aDecoder: NSCoder) {
        fatalError("Not supported")
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        return FluidTimingCurve(velocity: initialVelocity)
    }

    public var timingCurveType: UITimingCurveType {
        return .composed
    }

    public var cubicTimingParameters: UICubicTimingParameters? {
        return .init(animationCurve: .easeIn)
    }

    public var springTimingParameters: UISpringTimingParameters? {
        return UISpringTimingParameters(mass: mass, stiffness: stiffness, damping: damping, initialVelocity: initialVelocity)
    }

}
