//
//  FluidContainer.swift
//  Fluid
//
//  Created by octree on 2022/6/1.
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

public protocol FluidRenderer {
    func renderFluid()
}

public protocol FluidContainer: FluidRenderer {
    var constraint: CGSize { get }
    var body: MeasurableNode { get }
}

private enum FluidAssociatedKey {
    static var views: String = "fluid_views"
}

public extension FluidContainer where Self: UIView {
    var constraint: CGSize { .init(width: frame.width, height: .infinity) }

    func renderFluid() {
        let old = views ?? []
        let measured = body.layout(using: .init(constraint))
        let viewSet = Set(measured.uiViews)
        defer { views = viewSet }
        old.patches(to: viewSet).forEach {
            guard case let .deletion(v) = $0 else { return }
            v.removeFromSuperview()
        }
        measured.render(in: self, origin: .zero)
    }

    private var views: Set<UIView>? {
        get {
            objc_getAssociatedObject(self, &FluidAssociatedKey.views) as? Set<UIView>
        }
        set {
            objc_setAssociatedObject(self, &FluidAssociatedKey.views, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

open class FluidView: UIView, FluidContainer {
    open var body: MeasurableNode { .empty }
    private var isDirty: Bool = false
    /// state 改变
    /// frame 改变
    /// frame 和当前 需求 frame 不一致

    func markFluidDirty() {
        isDirty = true
    }
}
