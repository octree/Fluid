//
//  Padding.swift
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

struct Padding<Content: MeasurableNode>: MeasurableNode {
    let edges: Edge.Set
    let length: CGFloat
    let content: Content

    var children: [MeasurableNode] { [content] }

    func layout(using layoutContext: LayoutContext) -> MeasuredNode {
        var proposedSize = layoutContext.proposedSize
        let insets = edges.insets(length: length)
        if proposedSize.width != .infinity {
            proposedSize.width -= insets.horizontal
        }
        if proposedSize.height != .infinity {
            proposedSize.height -= insets.vertical
        }
        let node = content.layout(using: .init(width: proposedSize.width, height: proposedSize.height))
        let size = CGSize(width: node.size.width + insets.horizontal,
                          height: node.size.height + insets.vertical)
        let rect = CGRect(origin: .init(x: insets.left, y: insets.top), size: node.size)
        return Measured(size: size, frame: rect, content: node)
    }
}

extension Padding: ShrinkContainer, ShrinkableNode where Content: ShrinkableNode {
    func unshrinkableSize(in context: LayoutContext) -> CGSize {
        let insets = edges.insets(length: length)
        var size = CGSize(width: insets.horizontal, height: insets.vertical)
        guard let content = content as? ShrinkContainer else {
            return size
        }
        let child = content.unshrinkableSize(in: context)
        size.width += child.width
        size.height += child.height
        return size
    }
}

public extension MeasurableNode {
    func padding(_ edges: Edge.Set = .all, _ length: CGFloat = 16) -> MeasurableNode {
        Padding(edges: edges, length: length, content: self)
    }
}

public extension Measurable where Self: UIView {
    func padding(_ edges: Edge.Set = .all, _ length: CGFloat = 16) -> MeasurableNode {
        Measure(self) { _, _ in self }.padding(edges, length)
    }
}
