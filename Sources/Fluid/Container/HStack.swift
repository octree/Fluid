//
//  HStack.swift
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

private struct HStackLayout {
    let alignment: VerticalAlignment
    let spacing: CGFloat
    let context: LayoutContext
    struct Result {
        var size: CGSize
        var children: [(CGRect, MeasuredNode)]

        mutating func normalize(minY: CGFloat) {
            children.indices.forEach {
                children[$0].0.origin.y -= minY
            }
        }
    }

    private func deal(with nodes: [MeasuredNode], spacerIndices: [Int]) -> Result {
        var nodes = nodes
        let totalSpacing = spacing * CGFloat(max(0, nodes.count - 1 - spacerIndices.count))
        var result = Result(size: .zero, children: [])
        result.size.width = totalSpacing + nodes.reduce(0) { $0 + $1.size.width }
        let proposedWidth = context.proposedSize.width
        let left = proposedWidth - result.size.width
        if spacerIndices.count > 0, proposedWidth != .infinity, left > 0 {
            let per = left / CGFloat(spacerIndices.count)
            spacerIndices.forEach {
                nodes[$0] = MeasuredSpacer(size: .init(width: per, height: 0))
            }
            result.size.width = proposedWidth
        }
        var minY: CGFloat = 0
        let firstRect = CGRect(origin: .zero, size: nodes.first!.size)
        var maxY: CGFloat = firstRect.maxY
        var x = firstRect.width + (nodes.first is MeasuredSpacer ? 0 : spacing)
        result.children = [(firstRect, nodes.first!)]

        for node in nodes.dropFirst() {
            var rect = CGRect(origin: .init(x: x, y: 0), size: node.size)
            rect.formAlign(to: firstRect, alignment: alignment)
            result.children.append((rect, node))
            minY = min(minY, rect.minY)
            maxY = max(maxY, rect.maxY)
            x += rect.width + (node is MeasuredSpacer ? 0 : spacing)
        }
        result.size.height = maxY - minY
        result.normalize(minY: minY)
        return result
    }

    func layout(node: MeasurableNode, context: LayoutContext) -> MeasuredNode {
        let node = node is Spacer ? node.layout(using: .init(.zero)) : node.layout(using: context)
        precondition(node.size.width != .infinity)
        return node
    }

    func layout(_ children: [MeasurableNode]) -> Result {
        guard children.count > 0 else { return .init(size: .zero, children: []) }
        let spacerIndices = children.indices.filter { children[$0] is Spacer }
        let nonSpacerCount = children.count - spacerIndices.count
        let proposedSize = context.proposedSize
        var collection = children.map { layout(node: $0, context: context) }
        let totalSpacing = spacing * CGFloat(max(0, nonSpacerCount))
        let resumed = collection.reduce(0) { $0 + $1.size.width } + totalSpacing
        if proposedSize.width >= resumed {
            return deal(with: collection, spacerIndices: spacerIndices)
        }
        let shrinkIndices = collection.indices.filter { children[$0] is ShrinkableNode }
        guard shrinkIndices.count > 0 else {
            return deal(with: collection, spacerIndices: spacerIndices)
        }
        let beforeWidth = shrinkIndices.reduce(0) { $0 + collection[$1].size.width }
        let left = max(proposedSize.width - resumed + beforeWidth, 0)
        let unshrinkable = shrinkIndices.map {
            (collection[$0] as? ShrinkContainer)?.unshrinkableSize(in: context).width ?? 0
        }
        let shrinked = shrinkIndices.map { collection[$0].size.width }.shrinkTo(width: left, unshrinkable: unshrinkable)
        zip(shrinkIndices, shrinked).forEach {
            let context = LayoutContext(width: $1, height: context.proposedSize.height)
            collection[$0] = layout(node: children[$0], context: context)
        }
        return deal(with: collection, spacerIndices: spacerIndices)
    }
}

public struct HStack: MeasurableNode {
    public let alignment: VerticalAlignment
    public let spacing: CGFloat
    public let content: MeasurableCollection

    init(alignment: VerticalAlignment, spacing: CGFloat, content: Group) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content
    }

    public var children: [MeasurableNode] {
        content.children
    }

    public func layout(using layoutContext: LayoutContext) -> MeasuredNode {
        let result = HStackLayout(alignment: alignment, spacing: spacing, context: layoutContext)
            .layout(children)
        return MeasuredGroup(size: result.size, positionedChildren: result.children)
    }
}

extension HStack: ShrinkContainer, ShrinkableNode {
    public func unshrinkableSize(in context: LayoutContext) -> CGSize {
        content.unshrinkableSizeList(in: context).reduce(.zero) {
            CGSize(width: $0.width + $1.width, height: max($0.height, $1.height))
        }
    }
}
