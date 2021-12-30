//
//  CGRect+Extensions.swift
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

import Foundation
import CoreGraphics

public extension CGRect {
    /// Create a CGRect with specified center and size
    /// - Parameters:
    ///   - center: The center of the rect
    ///   - size: The size of the rect
    init(center: CGPoint, size: CGSize) {
        self.init(origin: CGPoint(x: center.x - size.width / 2,
                                  y: center.y - size.height / 2),
                  size: size)
    }

    /// Create a rect with two points
    /// - Parameters:
    ///   - point1: A point
    ///   - point2: Another point
    init(point1: CGPoint, point2: CGPoint) {
        let (minX, maxX) = point1.x < point2.x ? (point1.x, point2.x) : (point2.x, point1.x)
        let (minY, maxY) = point1.y < point2.y ? (point1.y, point2.y) : (point2.y, point1.y)
        self.init(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    /// Return the center of this CGRect
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }

    func aligned(to rect: CGRect, anchor: CGPoint, selfAnchor: CGPoint) -> CGRect {
        let x = rect.origin.x - selfAnchor.x + anchor.x
        let y = rect.origin.y - selfAnchor.y + anchor.y
        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }

    mutating func formAlign(to rect: CGRect, anchor: CGPoint, selfAnchor: CGPoint) {
        formAlign(to: rect, anchorX: anchor.x, selfAnchorX: selfAnchor.x)
        formAlign(to: rect, anchorY: anchor.y, selfAnchorY: selfAnchor.y)
    }

    mutating func formAlign(to rect: CGRect, anchorX: CGFloat, selfAnchorX: CGFloat) {
        origin.x = rect.origin.x - selfAnchorX + anchorX
    }

    mutating func formAlign(to rect: CGRect, anchorY: CGFloat, selfAnchorY: CGFloat) {
        origin.y = rect.origin.y - selfAnchorY + anchorY
    }

    mutating func formAlign(to rect: CGRect, alignment: HorizontalAlignment) {
        formAlign(to: rect,
                  anchorX: alignment.anchorX(in: rect),
                  selfAnchorX: alignment.anchorX(in: self))
    }

    mutating func formAlign(to rect: CGRect, alignment: VerticalAlignment) {
        formAlign(to: rect,
                  anchorY: alignment.anchorY(in: rect),
                  selfAnchorY: alignment.anchorY(in: self))
    }

    mutating func formAlign(to rect: CGRect, alignment: Alignment) {
        formAlign(to: rect,
                  anchor: alignment.anchorPoint(in: rect),
                  selfAnchor: alignment.anchorPoint(in: self))
    }
}
