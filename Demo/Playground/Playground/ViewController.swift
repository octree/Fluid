//
//  ViewController.swift
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
import Fluid

class View: UIView, ShrinkableNode, Measurable {
    var max: CGFloat = 1000
    func layout(using layoutContext: LayoutContext) -> CGSize {
        guard layoutContext.proposedSize.width <= max else {
            return .init(width: max, height: 40)
        }
        return .init(width: layoutContext.proposedSize.width,
                     height: 40 + max - layoutContext.proposedSize.width)
    }
}

class ViewController: UIViewController {
    var view1 = View(frame: CGRect(origin: .zero, size: .init(width: 800, height: 40)))
    var view2 = View(frame: CGRect(origin: .zero, size: .init(width: 200, height: 40)))
    var node: MeasurableNode {
        HStack(alignment: .top) {
            self.view1
            self.view2
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view1.max = 1000
        view2.max = 200
        view1.backgroundColor = .systemPink
        view2.backgroundColor = .systemCyan
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let measured = node.layout(using: .init(width: view.frame.size.width, height: view.frame.size.height))
        measured.render(in: view, origin: .init(x: 0, y: 100))
    }
}
