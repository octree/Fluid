//
//  Overlay.swift
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

struct OverlayModifier<Content: MeasurableNode>: MeasurableNode {
    let content: Content
    let overlay: MeasurableNode

    var children: [MeasurableNode] { [content] }

    func layout(using layoutContext: LayoutContext) -> MeasuredNode {
        let node = content.layout(using: layoutContext)
        let overlay = self.overlay.layout(using: .init(node.size))
        var frame = CGRect(origin: .zero, size: overlay.size)
        frame.formAlign(to: .init(origin: .zero, size: node.size), alignment: Alignment.center)
        return MeasuredOverlay(size: node.size,
                               content: node,
                               overlayOrigin: frame.origin,
                               overlay: overlay)
    }
}

private struct MeasuredOverlay: MeasuredNode {
    var size: CGSize
    var content: MeasuredNode
    var overlayOrigin: CGPoint
    var overlay: MeasuredNode
    var positionedChildren: [(CGRect, MeasuredNode)] {
        [(CGRect(origin: .zero, size: content.size), content)]
    }

    func render(in view: UIView, origin: CGPoint) {
        content.render(in: view, origin: origin)
        overlay.render(in: view, origin: origin.moved(overlayOrigin))
    }

    var uiViews: [UIView] {
        content.uiViews + overlay.uiViews
    }
}

extension OverlayModifier: ShrinkContainer, ShrinkableNode where Content: ShrinkableNode {
    func unshrinkableSize(in context: LayoutContext) -> CGSize {
        (content as? ShrinkContainer)?.unshrinkableSize(in: context) ?? .zero
    }
}

public extension MeasurableNode {
    func overlay(_ node: () -> MeasurableNode) -> MeasurableNode {
        OverlayModifier(content: self, overlay: node())
    }

    func overlay(_ view: UIView) -> MeasurableNode {
        overlay {
            view.resizable()
                .frame(width: .flexible(1), height: .flexible(1))
        }
    }
}
