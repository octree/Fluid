//
//  Collection.swift
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

public protocol MeasurableCollection {
    var children: [MeasurableNode] { get }
}

public protocol MeasuredCollection {
    func render(in view: UIView, origin: CGPoint)
    var children: [(CGRect, MeasuredNode)] { get }
}

public extension MeasurableCollection {
    func unshrinkableSize(in context: LayoutContext) -> CGSize {
        unshrinkableSizeList(in: context).reduce(.zero) {
            CGSize(width: max($0.width, $1.width),
                   height: max($0.height, $1.height))
        }
    }

    func unshrinkableSizeList(in context: LayoutContext) -> [CGSize] {
        children.compactMap { ($0 as? ShrinkContainer)?.unshrinkableSize(in: context) }
    }
}
