//
//  ZStack.swift
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

private struct ZStackLayout {
    let alignment: Alignment
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

    private func deal(with nodes: [MeasuredNode]) -> Result {
        var result = Result(size: .zero, children: [])
        var minX: CGFloat = 0
        var minY: CGFloat = 0
        let firstRect = CGRect(origin: .zero, size: nodes.first!.size)
        var maxX: CGFloat = firstRect.maxX
        var maxY: CGFloat = firstRect.maxY
        result.children = [(firstRect, nodes.first!)]

        for node in nodes.dropFirst() {
            var rect = CGRect(origin: .zero, size: node.size)
            rect.formAlign(to: firstRect, alignment: alignment)
            result.children.append((rect, node))
            minX = min(minX, rect.minX)
            maxX = max(maxX, rect.maxX)
            minY = min(minY, rect.minY)
            maxY = max(maxY, rect.maxY)
        }
        result.size.width = maxX - minX
        result.size.height = maxY - minY
        result.normalize(minX: minX)
        return result
    }

    func layout(node: MeasurableNode, context: LayoutContext) -> MeasuredNode {
        let node = node.layout(using: context)
        precondition(node.size.height != .infinity)
        precondition(node.size.width != .infinity)
        return node
    }

    func layout(_ children: [MeasurableNode]) -> Result {
        guard children.count > 0 else { return .init(size: .zero, children: []) }
        let collection = children.map { layout(node: $0, context: context) }
        return deal(with: collection)
    }
}

public struct ZStack: MeasurableNode {
    public let alignment: Alignment
    public let content: MeasurableCollection

    init(alignment: Alignment, content: Group) {
        self.alignment = alignment
        self.content = content
    }

    public var children: [MeasurableNode] {
        content.children
    }

    public func layout(using layoutContext: LayoutContext) -> MeasuredNode {
        let result = ZStackLayout(alignment: alignment, context: layoutContext)
            .layout(children)
        let content = self.content.measuredCollection(result.children)
        return MeasuredZStack(size: result.size, alignment: alignment, content: content)
    }
}

private struct MeasuredZStack: MeasuredNode {
    let size: CGSize
    let alignment: Alignment
    let content: MeasuredCollection

    var positionedChildren: [(CGRect, MeasuredNode)] {
        content.children
    }

    func render(in view: UIView, origin: CGPoint) {
        content.render(in: view, origin: origin)
    }
}
