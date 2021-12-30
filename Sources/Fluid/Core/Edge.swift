//
//  Edge.swift
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

/// An enumeration to indicate one edge of a rectangle.
@frozen public enum Edge: Int8, CaseIterable, RawRepresentable, Hashable, Equatable {
    case top
    case leading
    case bottom
    case trailing
    /// An efficient set of `Edge`s.
    @frozen public struct Set: OptionSet {
        /// The element type of the option set.
        ///
        /// To inherit all the default implementations from the `OptionSet` protocol,
        /// the `Element` type must be `Self`, the default.
        public typealias Element = Edge.Set

        /// The corresponding value of the raw type.
        public let rawValue: Int8

        /// Creates a new option set from the given raw value.
        public init(rawValue: Int8) {
            self.rawValue = rawValue
        }

        public static let top: Edge.Set = .init(.top)

        public static let leading: Edge.Set = .init(.leading)

        public static let bottom: Edge.Set = .init(.bottom)

        public static let trailing: Edge.Set = .init(.trailing)

        public static let all: Edge.Set = [horizontal, vertical]

        public static let horizontal: Edge.Set = [leading, trailing]

        public static let vertical: Edge.Set = [top, bottom]

        public init(_ e: Edge) {
            rawValue = 1 << e.rawValue
        }
        /// The raw type that can be used to represent all values of the conforming
        /// type.
        public typealias RawValue = Int8
    }
}
