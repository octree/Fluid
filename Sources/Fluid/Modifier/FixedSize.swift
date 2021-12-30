//
//  FixedSize.swift
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

struct FixedSize<Content: MeasurableNode>: MeasurableNode {
    var alignment: Alignment = .center
    var width: CGFloat?
    var height: CGFloat?
    var content: Content

    var children: [MeasurableNode] { [content] }

    func layout(using layoutContext: LayoutContext) -> MeasuredNode {
        var proposedSize = layoutContext.proposedSize
        if let width = width { proposedSize.width = width }
        if let height = height { proposedSize.height = height }
        let measured = content.layout(using: .init(proposedSize))
        let size = CGSize(width: width ?? measured.size.width,
                          height: height ?? measured.size.height)
        var frame = CGRect(origin: .zero, size: measured.size)
        frame.formAlign(to: .init(origin: .zero, size: size), alignment: alignment)
        return Measured(size: size, frame: frame, content: measured)
    }
}

extension FixedSize: ShrinkContainer, ShrinkableNode where Content: ShrinkableNode {
    var unshrinkableSize: CGSize {
        var size = CGSize(width: width ?? 0, height: height ?? 0)
        guard let content = content as? ShrinkContainer else {
            return size
        }
        let child = content.unshrinkableSize
        size.width += child.width
        size.height += child.height
        return size
    }
}

public extension MeasurableNode {
    func frame(width: CGFloat? = nil, height: CGFloat? = nil, alignment: Alignment = .center) -> MeasurableNode {
        assert(width != .infinity && height != .infinity)
        return FixedSize(alignment: alignment, width: width, height: height, content: self)
    }
}

public extension Measurable where Self: UIView {
    func frame(width: CGFloat? = nil, height: CGFloat? = nil, alignment: Alignment = .center) -> MeasurableNode {
        Measure(self) { _, _ in self }.frame(width: width, height: height, alignment: alignment)
    }
}
