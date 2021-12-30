//
//  BoundedSize.swift
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

struct BoundedSize<Content: MeasurableNode>: MeasurableNode {
    var alignment: Alignment = .center
    var minWidth: CGFloat?
    var maxWidth: CGFloat?
    var minHeight: CGFloat?
    var maxHeight: CGFloat?
    var content: Content

    var children: [MeasurableNode] { [content] }

    func layout(using layoutContext: LayoutContext) -> MeasuredNode {
        let proposedSize = layoutContext.proposedSize
        let minWidth = minWidth ?? 0
        let maxWidth = max(minWidth, min(proposedSize.width, maxWidth ?? .infinity))
        let minHeight = minHeight ?? 0
        let maxHeight = max(minHeight, min(proposedSize.height, maxHeight ?? .infinity))
        let measured = content.layout(using: .init(.init(width: maxWidth, height: maxHeight)))
        var size = measured.size
        size.width = max(minWidth, size.width)
        size.height = max(minHeight, size.height)
        if let width = self.maxWidth {
            if width == .infinity, proposedSize.width != .infinity {
                size.width = maxWidth
            } else {
                size.width = min(maxWidth, size.width)
            }
        }

        if let height = self.maxHeight {
            if height == .infinity, proposedSize.height != .infinity {
                size.height = maxHeight
            } else {
                size.height = min(maxHeight, size.height)
            }
        }

        if self.maxWidth == .infinity, proposedSize.width != .infinity { size.width = maxWidth }
        if self.maxHeight == .infinity, proposedSize.height != .infinity { size.height = maxHeight }
        var frame = CGRect(origin: .zero, size: measured.size)
        frame.formAlign(to: .init(origin: .zero, size: size), alignment: alignment)
        return Measured(size: size, frame: frame, content: measured)
    }
}

extension BoundedSize: ShrinkContainer, ShrinkableNode where Content: ShrinkableNode {
    var unshrinkableSize: CGSize {
        var size = CGSize(width: minWidth ?? 0, height: minHeight ?? 0)
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
    func frame(minWidth: CGFloat? = nil, maxWidth: CGFloat? = nil, minHeight: CGFloat? = nil, maxHeight: CGFloat? = nil, alignment: Alignment = .center) -> MeasurableNode {
        return BoundedSize(alignment: alignment, minWidth: minWidth, maxWidth: maxWidth, minHeight: minHeight, maxHeight: maxHeight, content: self)
    }
}

public extension Measurable where Self: UIView {
    func frame(minWidth: CGFloat? = nil, maxWidth: CGFloat? = nil, minHeight: CGFloat? = nil, maxHeight: CGFloat? = nil, alignment: Alignment = .center) -> MeasurableNode {
        Measure(self) { _, _ in self }.frame(minWidth: minWidth, maxWidth: maxWidth, minHeight: minHeight, maxHeight: maxHeight, alignment: alignment)
    }
}
