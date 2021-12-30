//
//  FlexibleSize.swift
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

public struct FlexibleSize: Measurable {
    public enum Dimension {
        case absolute(CGFloat)
        case flexible(CGFloat)
        internal func dimension(in containerDimension: CGFloat) -> CGFloat {
            switch self {
            case let .absolute(x):
                return x
            case let .flexible(x):
                return x * containerDimension
            }
        }
    }

    public var width: Dimension
    public var height: Dimension

    public init(width: Dimension, height: Dimension) {
        self.width = width
        self.height = height
    }

    public func layout(using layoutContext: LayoutContext) -> CGSize {
        return CGSize(width: width.dimension(in: layoutContext.proposedSize.width),
                      height: height.dimension(in: layoutContext.proposedSize.height))
    }
}
