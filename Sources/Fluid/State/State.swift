//
//  State.swift
//  Fluid
//
//  Created by octree on 2022/2/28.
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

@propertyWrapper
public struct State<Value> {
    public static subscript<V: UIView>(
        _enclosingInstance instance: V,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<V, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<V, Self>
    ) -> Value {
        get {
            instance[keyPath: storageKeyPath].storage
        }
        set {
            instance[keyPath: storageKeyPath].storage = newValue
            instance.setNeedsLayout()
        }
    }

    @available(*, unavailable, message: "@State can only be applied to UIView or UIViewController")
    public var wrappedValue: Value {
        get { fatalError() }
        set { fatalError() }
    }

    private var storage: Value

    public init(wrappedValue: Value) {
        storage = wrappedValue
    }
}

public protocol FluidRenderer {
    func renderFluid()
}

public protocol FluidContainer: FluidRenderer {
    var constraint: CGSize { get }
    var body: MeasurableNode { get }
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
            objc_getAssociatedObject(self, "fluid_views") as? Set<UIView>
        }
        set {
            objc_setAssociatedObject(self, "fluid_views", newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
