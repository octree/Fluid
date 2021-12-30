//
//  Shrink.swift
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

extension Array where Element == CGFloat {
    func shrinkTo(width: CGFloat, unshrinkable: [CGFloat]) -> [CGFloat] {
        assert(count == unshrinkable.count)
        var width = width
        var shrinkable = [CGFloat](repeating: 0, count: count)
        for (idx, val) in unshrinkable.enumerated() {
            shrinkable[idx] = self[idx] - val
            width -= val
        }
        width = Swift.max(0, width)
        let indices = self.indices.sorted { shrinkable[$0] < shrinkable[$1] }
        var avg: CGFloat = 0
        var count = indices.count
        var result = unshrinkable

        for index in indices {
            defer { count -= 1 }
            let emptyLen = shrinkable[index] - avg
            guard emptyLen > 0 else {
                result[index] = avg
                continue
            }
            let per = Swift.min(width / CGFloat(count), emptyLen)
            width -= per * CGFloat(count)
            avg += per
            result[index] = avg
        }
        return result
    }
}
