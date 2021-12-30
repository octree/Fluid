//
//  Group.swift
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

public struct Group: MeasurableCollection {
    public enum Child {
        case node(MeasurableNode)
        case collection(MeasurableCollection)
    }

    let content: [Child]
    public var children: [MeasurableNode] {
        var list: [MeasurableNode] = []
        for child in content {
            switch child {
            case .node(let x):
                list.append(x)
            case .collection(let xs):
                list.append(contentsOf: xs.children)
            }
        }
        return list
    }

    init(_ content: [Child]) {
        precondition(content.count <= 10)
        self.content = content
    }

    public func measuredCollection(_ content: [(CGRect, MeasuredNode)]) -> MeasuredCollection {
        MeasuredGroup(content)
    }
}

private struct MeasuredGroup: MeasuredCollection {
    var children: [(CGRect, MeasuredNode)]

    init(_ children: [(CGRect, MeasuredNode)]) {
        self.children = children
    }

    func render(in view: UIView, origin: CGPoint) {
        children.forEach {
            let new = origin.moved($0.0.origin)
            $0.1.render(in: view, origin: new)
        }
    }
}
