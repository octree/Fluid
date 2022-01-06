//
//  FlexibleView.swift
//  Fluid
//
//  Created by octree on 2022/1/4.
//
//  Copyright (c) 2022 Octree <octree@octree.me>
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

public struct FlexibleView: MeasurableNode {
    public let horizentalAlignment: HorizontalAlignment
    public let rowAlignment: VerticalAlignment
    public var horizontalSpacing: CGFloat
    public var verticalSpacing: CGFloat
    public let content: MeasurableCollection

    public var children: [MeasurableNode] {
        content.children
    }

    public func layout(using layoutContext: LayoutContext) -> MeasuredNode {
        let size = layoutContext.proposedSize
        var origin = CGPoint()
        func createLayoutContext() -> HorizontalLayoutContext {
            HorizontalLayoutContext(origin: origin,
                                    availableSize: size,
                                    spacing: horizontalSpacing,
                                    horizontalAlignment: horizentalAlignment,
                                    rowAlignment: rowAlignment)
        }

        var layout = createLayoutContext()
        var width: CGFloat = 0
        var rowLayouts: [HorizontalLayoutContext] = []
        for elt in content.children {
            if layout.attemptToLayoutItem(elt) {
                continue
            } else {
                layout.alignVertical()
                width = max(width, layout.usedWidth)
                origin.y += layout.height + verticalSpacing
                rowLayouts.append(layout)
                layout = createLayoutContext()
                layout.attemptToLayoutItem(elt)
            }
        }
        layout.alignVertical()
        width = max(width, layout.usedWidth)
        width = min(width, size.width)
        rowLayouts.append(layout)
        rowLayouts.indices.forEach {
            rowLayouts[$0].alignHorizontal(width: width)
        }
        let height = origin.y + layout.height
        return MeasuredGroup(size: CGSize(width: width, height: height),
                             positionedChildren: rowLayouts.flatMap { $0.alignedItems })
    }
}

struct HorizontalLayoutContext {
    var origin: CGPoint
    var availableSize: CGSize
    var spacing: CGFloat
    var horizontalAlignment: HorizontalAlignment
    var rowAlignment: VerticalAlignment
    private(set) var usedWidth: CGFloat = 0
    private(set) var alignedItems = [(CGRect, MeasuredNode)]()
    private(set) var height: CGFloat = 0

    init(origin: CGPoint,
         availableSize: CGSize,
         spacing: CGFloat,
         horizontalAlignment: HorizontalAlignment,
         rowAlignment: VerticalAlignment)
    {
        self.origin = origin
        self.availableSize = availableSize
        self.spacing = spacing
        self.horizontalAlignment = horizontalAlignment
        self.rowAlignment = rowAlignment
    }

    @discardableResult
    mutating func attemptToLayoutItem(_ node: MeasurableNode) -> Bool {
        let node = node.layout(using: .init(availableSize))
        guard alignedItems.isEmpty || availableSize.width - usedWidth >= node.size.width else {
            return false
        }
        let rect = CGRect(origin: .init(x: usedWidth, y: origin.y), size: node.size)
        alignedItems.append((rect, node))
        usedWidth += node.size.width + spacing
        return true
    }

    mutating func alignVertical() {
        guard alignedItems.count > 0 else { return }
        usedWidth -= spacing
        guard let firstRect = alignedItems.first?.0 else { return }
        var minY: CGFloat = firstRect.minY
        var maxY: CGFloat = firstRect.maxY
        for index in alignedItems.dropFirst().indices {
            var rect = alignedItems[index].0
            rect.formAlign(to: firstRect, alignment: rowAlignment)
            alignedItems[index].0 = rect
            minY = min(minY, rect.minY)
            maxY = max(maxY, rect.maxY)
        }
        height = maxY - minY
        let offset = minY - origin.y
        for index in alignedItems.indices {
            alignedItems[index].0.origin.y -= offset
        }
    }

    mutating func alignHorizontal(width: CGFloat) {
        var fullRect = CGRect(origin: .zero, size: CGSize(width: usedWidth, height: height))
        fullRect.formAlign(to: .init(origin: origin, size: CGSize(width: width, height: height)), alignment: horizontalAlignment)
        let minX = fullRect.minX
        for index in alignedItems.indices {
            alignedItems[index].0.origin.x += minX
        }
    }
}

public extension FlexibleView {
    init(horizentalAlignment: HorizontalAlignment = .center,
         rowAlignment: VerticalAlignment = .center,
         horizontalSpacing: CGFloat = 8,
         verticalSpacing: CGFloat = 8,
         @MeasurableViewBuilder content: () -> Group)
    {
        self = .init(horizentalAlignment: horizentalAlignment,
                     rowAlignment: rowAlignment,
                     horizontalSpacing: horizontalSpacing,
                     verticalSpacing: verticalSpacing,
                     content: content())
    }
}
