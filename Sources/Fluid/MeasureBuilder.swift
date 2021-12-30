//
//  MeasureBuilder.swift
//  Fluid
//
//  Created by octree on 2021/12/30.
//
//  Copyright (c) 2021 Octree <octree@octree.me>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

public extension Group {
    init(@MeasurableViewBuilder content: () -> Group) {
        self = content()
    }
}

public extension HStack {
    init(alignment: VerticalAlignment = .center, spacing: CGFloat = 8, @MeasurableViewBuilder content: () -> Group) {
        self = .init(alignment: alignment, spacing: spacing, content: content())
    }
}

@resultBuilder
public enum MeasurableViewBuilder {
    public typealias Component = [Group.Child]

    public static func buildExpression(_ expression: MeasurableNode) -> Component {
        [.node(expression)]
    }

    public static func buildExpression<T: UIView & Measurable>(_ expression: T) -> Component {
        [.node(Measure(expression, body: { _, _ in expression }))]
    }

    public static func buildExpression(_ expression: MeasurableCollection) -> Component {
        [.collection(expression)]
    }

    public static func buildOptional(_ component: Component?) -> Component {
        component ?? []
    }

    public static func buildEither(first component: Component) -> Component {
        component
    }

    public static func buildEither(second component: Component) -> Component {
        component
    }

    public static func buildFinalResult(_ component: Component) -> Group {
        .init(component)
    }

    public static func buildBlock() -> Component {
        []
    }

    public static func buildBlock(_ items: Component...) -> Component {
        return items.flatMap { $0 }
    }

    public static func buildLimitedAvailability(_ component: Component) -> Component {
        return component
    }
}
