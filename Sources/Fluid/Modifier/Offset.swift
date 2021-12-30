//
//  Offset.swift
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

struct OffsetModifier<Content: MeasurableNode>: MeasurableNode {
    var offset: CGPoint
    let content: Content

    var children: [MeasurableNode] { [content] }

    func layout(using layoutContext: LayoutContext) -> MeasuredNode {
        let node = content.layout(using: layoutContext)
        let rect = CGRect(origin: offset, size: node.size)
        return Measured(size: node.size, frame: rect, content: node)
    }
}

extension OffsetModifier: ShrinkContainer, ShrinkableNode where Content: ShrinkableNode {
    var unshrinkableSize: CGSize {
        (content as? ShrinkContainer)?.unshrinkableSize ?? .zero
    }
}

public extension MeasurableNode {
    func offset(x: CGFloat = 0, y: CGFloat = 0) -> MeasurableNode {
        OffsetModifier(offset: .init(x: x, y: y), content: self)
    }
}

public extension Measurable where Self: UIView {
    func offset(x: CGFloat = 0, y: CGFloat = 0) -> MeasurableNode {
        Measure(self) { _, _ in self }.offset(x: x, y: y)
    }
}
