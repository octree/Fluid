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

    private func deal(with nodes: [MeasuredNode]) -> Result {
        let spacing = self.spacing * CGFloat(nodes.count - 1)
        var result = Result(size: .zero, children: [])
        result.size.width = spacing
        var minY: CGFloat = 0
        let firstRect = CGRect(origin: .zero, size: nodes.first!.size)
        var maxY: CGFloat = firstRect.maxY
        var x = firstRect.width + spacing
        result.children = [(firstRect, nodes.first!)]
        result.size.width += nodes.first!.size.width

        for node in nodes.dropFirst() {
            var rect = CGRect(origin: .init(x: x, y: 0), size: node.size)
            rect.formAlign(to: firstRect, alignment: alignment)
            result.children.append((rect, node))
            minY = min(minY, rect.minY)
            maxY = max(maxY, rect.maxY)
            x += rect.width + spacing
            result.size.width += rect.width
        }
        result.size.height = maxY - minY
        result.normalize(minY: minY)
        return result
    }

    func layout(node: MeasurableNode, context: LayoutContext) -> MeasuredNode {
        let node = node.layout(using: context)
        precondition(node.size.width != .infinity)
        return node
    }

    func layout(_ children: [MeasurableNode]) -> Result {
        guard children.count > 0 else { return .init(size: .zero, children: []) }
        let proposedSize = context.proposedSize
        var collection = children.map { layout(node: $0, context: context) }
        let spacing = self.spacing * CGFloat(children.count - 1)
        let resumed = collection.reduce(0) { $0 + $1.size.width } + spacing
        if proposedSize.width >= resumed {
            return deal(with: collection)
        }
        let shrinkIndices = collection.indices.filter { children[$0] is ShrinkableNode }
        guard shrinkIndices.count > 0 else {
            return deal(with: collection)
        }
        let beforeWidth = shrinkIndices.reduce(0) { $0 + collection[$1].size.width }
        let left = max(proposedSize.width - resumed + beforeWidth, 0)
        let unshrinkable = shrinkIndices.map {
            (collection[$0] as? ShrinkContainer)?.unshrinkableSize.width ?? 0
        }
        let shrinked = shrinkIndices.map { collection[$0].size.width }.shrinkTo(width: left, unshrinkable: unshrinkable)
        zip(shrinkIndices, shrinked).forEach {
            let context = LayoutContext(width: $1, height: context.proposedSize.height)
            collection[$0] = layout(node: children[$0], context: context)
        }
        return deal(with: collection)
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
        let content = self.content.measuredCollection(result.children)
        return MeasuredHStack(size: result.size, alignment: alignment, spacing: spacing, content: content)
    }
}

private struct MeasuredHStack: MeasuredNode {
    let size: CGSize
    let alignment: VerticalAlignment
    let spacing: CGFloat
    let content: MeasuredCollection

    var positionedChildren: [(CGRect, MeasuredNode)] {
        content.children
    }

    func render(in view: UIView, origin: CGPoint) {
        content.render(in: view, origin: origin)
    }
}
