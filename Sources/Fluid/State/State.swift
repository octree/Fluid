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

final class AnyLocation<Value> {
    private var get: (() -> Value)!
    private var set: ((Value) -> Void)!

    var value: Value {
        get { get() }
        set { set(newValue) }
    }

    init() {}

    func bind<T: AnyObject>(to instance: T, keyPath: ReferenceWritableKeyPath<T, Value>) {
        get = { [unowned instance] in
            instance[keyPath: keyPath]
        }
        set = { [unowned instance] in
            instance[keyPath: keyPath] = $0
        }
    }
}

@propertyWrapper
public struct State<Value> {
    @available(*, unavailable,
               message: "This property wrapper can only be applied to ``LegoContainer``")
    public var wrappedValue: Value {
        get { fatalError() }
        // swiftlint: disable unused_setter_value
        set { fatalError() }
    }

    private var location: AnyLocation<Value> = .init()
    private var storage: Value
    public var projectedValue: Binding<Value> {
        .init {
            location.value
        } set: {
            location.value = $0
        }
    }

    /// Create a property wrapper with initial value.
    /// - Parameter wrappedValue: The initial value.
    public init(wrappedValue: Value) {
        storage = wrappedValue
    }

    public static subscript<T: AnyObject & FluidContainer>(
        _enclosingInstance instance: T,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<T, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<T, State>
    ) -> Value {
        get {
            let state = instance[keyPath: storageKeyPath]
            instance[keyPath: storageKeyPath].location.bind(to: instance, keyPath: wrappedKeyPath)
            return state.storage
        }
        set {
            instance[keyPath: storageKeyPath].storage = newValue
            if let container = instance as? FluidView {
                container.markFluidDirty()
            }
        }
    }
}
