//
//  VStack.swift
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

private struct VStackLayout {
    let alignment: HorizontalAlignment
    let spacing: CGFloat
    let context: LayoutContext
    struct Result {
        var size: CGSize
        var children: [(CGRect, MeasuredNode)]

        mutating func normalize(minX: CGFloat) {
            children.indices.forEach {
                children[$0].0.origin.x -= minX
            }
        }
    }

    private func deal(with nodes: [MeasuredNode], spacerIndices: [Int]) -> Result {
        var nodes = nodes
        let totalSpacing = spacing * CGFloat(max(0, nodes.count - 1 - spacerIndices.count))

        var result = Result(size: .zero, children: [])
        result.size.height = totalSpacing + nodes.reduce(0) { $0 + $1.size.height }
        let proposedHeight = context.proposedSize.height
        let left = proposedHeight - result.size.height
        if spacerIndices.count > 0, proposedHeight != .infinity, left > 0 {
            let per = left / CGFloat(spacerIndices.count)
            spacerIndices.forEach {
                nodes[$0] = MeasuredSpacer(size: .init(width: 0, height: per))
            }
            result.size.height = proposedHeight
        }
        var minX: CGFloat = 0
        let firstRect = CGRect(origin: .zero, size: nodes.first!.size)
        var maxX: CGFloat = firstRect.maxX
        var y = firstRect.height + (nodes.first is MeasuredSpacer ? 0 : spacing)
        result.children = [(firstRect, nodes.first!)]

        for node in nodes.dropFirst() {
            var rect = CGRect(origin: .init(x: 0, y: y), size: node.size)
            rect.formAlign(to: firstRect, alignment: alignment)
            result.children.append((rect, node))
            minX = min(minX, rect.minX)
            maxX = max(maxX, rect.maxX)
            y += rect.height + (node is MeasuredSpacer ? 0 : spacing)
        }
        result.size.width = maxX - minX
        result.normalize(minX: minX)
        return result
    }

    func layout(node: MeasurableNode, context: LayoutContext) -> MeasuredNode {
        let node = node is Spacer ? node.layout(using: .init(.zero)) : node.layout(using: context)
        precondition(node.size.height != .infinity)
        return node
    }

    func layout(_ children: [MeasurableNode]) -> Result {
        guard children.count > 0 else { return .init(size: .zero, children: []) }
        let proposedSize = context.proposedSize
        let spacerIndices = children.indices.filter { children[$0] is Spacer }
        let nonSpacerCount = children.count - spacerIndices.count
        var collection = children.map { layout(node: $0, context: context) }
        let totalSpacing = spacing * CGFloat(max(0, nonSpacerCount))
        let resumed = collection.reduce(0) { $0 + $1.size.height } + totalSpacing
        if proposedSize.height >= resumed {
            return deal(with: collection, spacerIndices: spacerIndices)
        }
        let shrinkIndices = collection.indices.filter { children[$0] is ShrinkableNode }
        guard shrinkIndices.count > 0 else {
            return deal(with: collection, spacerIndices: spacerIndices)
        }
        let beforeHeight = shrinkIndices.reduce(0) { $0 + collection[$1].size.height }
        let left = max(proposedSize.height - resumed + beforeHeight, 0)
        let unshrinkable = shrinkIndices.map {
            (collection[$0] as? ShrinkContainer)?.unshrinkableSize.height ?? 0
        }
        let shrinked = shrinkIndices.map { collection[$0].size.height }.shrinkTo(width: left, unshrinkable: unshrinkable)
        zip(shrinkIndices, shrinked).forEach {
            let context = LayoutContext(width: context.proposedSize.width, height: $1)
            collection[$0] = layout(node: children[$0], context: context)
        }
        return deal(with: collection, spacerIndices: spacerIndices)
    }
}

public struct VStack: MeasurableNode {
    public let alignment: HorizontalAlignment
    public let spacing: CGFloat
    public let content: MeasurableCollection

    init(alignment: HorizontalAlignment, spacing: CGFloat, content: Group) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content
    }

    public var children: [MeasurableNode] {
        content.children
    }

    public func layout(using layoutContext: LayoutContext) -> MeasuredNode {
        let result = VStackLayout(alignment: alignment, spacing: spacing, context: layoutContext)
            .layout(children)
        let content = self.content.measuredCollection(result.children)
        return MeasuredVStack(size: result.size, alignment: alignment, spacing: spacing, content: content)
    }
}

private struct MeasuredVStack: MeasuredNode {
    let size: CGSize
    let alignment: HorizontalAlignment
    let spacing: CGFloat
    let content: MeasuredCollection

    var positionedChildren: [(CGRect, MeasuredNode)] {
        content.children
    }

    func render(in view: UIView, origin: CGPoint) {
        content.render(in: view, origin: origin)
    }
}

extension VStack: ShrinkContainer, ShrinkableNode {
    public var unshrinkableSize: CGSize {
        content.unshrinkableSizeList.reduce(.zero) {
            CGSize(width: max($0.width, $1.width), height: $0.height + $1.height)
        }
    }
}
