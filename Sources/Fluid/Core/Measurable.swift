//
//  Measurable.swift
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
import CoreGraphics

public protocol Measurable {
    associatedtype Layout
    func layout(using layoutContext: LayoutContext) -> Layout
    static func size(for layout: Layout) -> CGSize
}

public protocol SelfMeasured {
    var size: CGSize { get }
}

public extension Measurable where Layout == CGSize {
    @inlinable static func size(for layout: Layout) -> CGSize {
        layout
    }
}

public extension Measurable where Layout: SelfMeasured {
    @inlinable static func size(for layout: Layout) -> CGSize {
        layout.size
    }
}

struct MeasuredView<Body: UIView>: MeasuredNode {
    let size: CGSize
    let body: Body

    func render(in view: UIView, origin: CGPoint) {
        if body.superview !== view { view.addSubview(body) }
        body.frame = .init(origin: origin, size: size)
    }

    var positionedChildren: [(CGRect, MeasuredNode)] { [] }

    var uiViews: [UIView] {
        [body]
    }
}

struct Measured: MeasuredNode {
    var size: CGSize
    var frame: CGRect
    var content: MeasuredNode

    var positionedChildren: [(CGRect, MeasuredNode)] {
        [(frame, content)]
    }

    func render(in view: UIView, origin: CGPoint) {
        let new = origin.moved(frame.origin)
        content.render(in: view, origin: new)
    }

    var uiViews: [UIView] {
        content.uiViews
    }
}
