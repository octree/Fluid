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
    var minWidth: FlexibleDimension?
    var maxWidth: FlexibleDimension?
    var minHeight: FlexibleDimension?
    var maxHeight: FlexibleDimension?
    var content: Content

    var children: [MeasurableNode] { [content] }

    func layout(using layoutContext: LayoutContext) -> MeasuredNode {
        let proposedSize = layoutContext.proposedSize
        let minWidth = self.minWidth?.dimension(in: proposedSize.width)
        let maxWidth = self.maxWidth?.dimension(in: proposedSize.width)
        let minHeight = self.minHeight?.dimension(in: proposedSize.height)
        let maxHeight = self.maxHeight?.dimension(in: proposedSize.height)
        let minW = minWidth ?? 0
        let maxW = max(minW, min(proposedSize.width, maxWidth ?? .infinity))
        let minH = minHeight ?? 0
        let maxH = max(minH, min(proposedSize.height, maxHeight ?? .infinity))
        let measured = content.layout(using: .init(.init(width: maxW, height: maxH)))
        var size = measured.size
        size.width = max(minW, size.width)
        size.height = max(minH, size.height)
        if let width = maxWidth {
            if width == .infinity, proposedSize.width != .infinity {
                size.width = maxW
            } else {
                size.width = min(maxW, size.width)
            }
        }

        if let height = maxHeight {
            if height == .infinity, proposedSize.height != .infinity {
                size.height = maxH
            } else {
                size.height = min(maxH, size.height)
            }
        }

        if maxWidth == .infinity, proposedSize.width != .infinity { size.width = maxW }
        if maxHeight == .infinity, proposedSize.height != .infinity { size.height = maxH }
        var frame = CGRect(origin: .zero, size: measured.size)
        frame.formAlign(to: .init(origin: .zero, size: size), alignment: alignment)
        return Measured(size: size, frame: frame, content: measured)
    }
}

extension BoundedSize: ShrinkContainer, ShrinkableNode where Content: ShrinkableNode {
    func unshrinkableSize(in context: LayoutContext) -> CGSize {
        let minWidth = self.minWidth?.dimension(in: context.proposedSize.width) ?? 0
        let minHeight = self.minHeight?.dimension(in: context.proposedSize.height) ?? 0
        var size = CGSize(width: minWidth, height: minHeight)
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
    func frame(minWidth: FlexibleDimension? = nil, maxWidth: FlexibleDimension? = nil, minHeight: FlexibleDimension? = nil, maxHeight: FlexibleDimension? = nil, alignment: Alignment = .center) -> MeasurableNode {
        return BoundedSize(alignment: alignment, minWidth: minWidth, maxWidth: maxWidth, minHeight: minHeight, maxHeight: maxHeight, content: self)
    }
}
