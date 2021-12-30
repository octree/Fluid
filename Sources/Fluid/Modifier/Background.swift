//
//  Background.swift
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

struct BackgroundModifier<Content: MeasurableNode>: MeasurableNode {
    let content: Content
    let background: MeasurableNode

    var children: [MeasurableNode] { [content] }

    func layout(using layoutContext: LayoutContext) -> MeasuredNode {
        let node = content.layout(using: layoutContext)
        let background = self.background.layout(using: .init(node.size))
        return MeasuredBackground(size: node.size,
                                  content: node,
                                  background: background)
    }
}

private struct MeasuredBackground: MeasuredNode {
    var size: CGSize
    var content: MeasuredNode
    var background: MeasuredNode
    var positionedChildren: [(CGRect, MeasuredNode)] {
        [(CGRect(origin: .zero, size: content.size), content)]
    }

    func render(in view: UIView, origin: CGPoint) {
        background.render(in: view, origin: origin)
        content.render(in: view, origin: origin)
    }
}

extension BackgroundModifier: ShrinkContainer, ShrinkableNode where Content: ShrinkableNode {
    var unshrinkableSize: CGSize {
        (content as? ShrinkContainer)?.unshrinkableSize ?? .zero
    }
}

public extension MeasurableNode {
    func background(_ node: () -> MeasurableNode) -> MeasurableNode {
        BackgroundModifier(content: self, background: node())
    }

    func background(_ view: UIView) -> MeasurableNode {
        background {
            Measure(FlexibleSize(width: .flexible(1), height: .flexible(1))) { _, _ in view }
        }
    }
}

public extension Measurable where Self: UIView {
    func background(_ node: () -> MeasurableNode) -> MeasurableNode {
        Measure(self) { _, _ in self }.background(node)
    }

    func background(_ view: UIView) -> MeasurableNode {
        Measure(self) { _, _ in self }.background(view)
    }
}
