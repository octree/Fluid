//
//  Resizable.swift
//  Fluid
//
//  Created by octree on 2022/1/2.
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

struct ResizableModifier<Content: UIView>: MeasurableNode {
    var content: Content
    var children: [MeasurableNode] { [] }

    func layout(using layoutContext: LayoutContext) -> MeasuredNode {
        let proposedSize = layoutContext.proposedSize
        assert(proposedSize.width != .infinity, "Resizable width can not be infinity")
        assert(proposedSize.height != .infinity, "Resizable height can not be infinity")
        let size = content.layout(using: layoutContext)
        var frame = CGRect(origin: .zero, size: size)
        frame.formAlign(to: .init(origin: .zero, size: proposedSize), alignment: Alignment.center)
        return Measure.Measured(content: content, layout: size, body: { _, _ in
            content
        }, tag: nil)
    }
}

extension ResizableModifier: ShrinkContainer, ShrinkableNode where Content: ShrinkableNode {
    func unshrinkableSize(in context: LayoutContext) -> CGSize {
        (content as? ShrinkContainer)?.unshrinkableSize(in: context) ?? .zero
    }
}

public extension UIView {
    func resizable() -> MeasurableNode {
        return ResizableModifier(content: self)
    }
}
