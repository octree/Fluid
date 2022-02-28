//
//  AspectRatio.swift
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

struct AspectRatioModifier<Content: MeasurableNode>: MeasurableNode {
    var children: [MeasurableNode] { [content] }

    var content: Content
    /// Aspect ratio is width / height.
    var aspectRatio: CGFloat

    public func layout(using layoutContext: LayoutContext) -> MeasuredNode {
        var size = layoutContext.proposedSize
        if size.height == .infinity {
            if size.width == .infinity {
                assertionFailure("A measurable view must have at least one side constrained.")
                size = .init(width: 100, height: 100)
            }
            size.height = size.width / aspectRatio
        } else if size.width == .infinity {
            size.width = size.height * aspectRatio
        } else {
            let derivedH = size.width / aspectRatio
            let derivedW = size.height * aspectRatio
            size.height = min(derivedH, size.height)
            size.width = min(derivedW, size.width)
        }

        let measured = content.layout(using: LayoutContext(size))
        var frame = CGRect(origin: .zero, size: size)
        frame.formAlign(to: CGRect(origin: .zero, size: measured.size), alignment: Alignment.center)
        return Measured(size: size, frame: frame, content: measured)
    }
}

public extension MeasurableNode {
    /// Create a measurable node with aspectRatio
    /// - Parameter ratio: A floating point represents the ratio between width and height
    /// - Returns: A measurable node
    func aspectRatio(_ ratio: CGFloat) -> MeasurableNode {
        AspectRatioModifier(content: self, aspectRatio: ratio)
    }
}
