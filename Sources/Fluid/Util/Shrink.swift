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
    func shrinkTo(width: CGFloat) -> [CGFloat] {
        let indices = self.indices.sorted { self[$0] < self[$1] }
        var width = width
        var avg: CGFloat = 0
        var count = indices.count
        var result = [CGFloat](repeating: 0, count: count)

        for index in indices {
            defer { count -= 1 }
            let emptyLen = self[index] - avg
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
