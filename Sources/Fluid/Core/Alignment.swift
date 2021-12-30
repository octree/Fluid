//
//  Alignment.swift
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

public protocol AlignmentID {
    static func defaultValue(in dimensions: ViewDimensions) -> CGFloat
}

/// An alignment position along the horizontal axis.
public struct HorizontalAlignment: Equatable, Hashable {
    private enum LeadingID: AlignmentID {
        static func defaultValue(in dimensions: ViewDimensions) -> CGFloat { 0 }
    }

    private enum CenterID: AlignmentID {
        static func defaultValue(in dimensions: ViewDimensions) -> CGFloat {
            dimensions.width / 2
        }
    }

    private enum TrailingID: AlignmentID {
        static func defaultValue(in dimensions: ViewDimensions) -> CGFloat { dimensions.width }
    }

    public static func == (lhs: HorizontalAlignment, rhs: HorizontalAlignment) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(id))
    }

    let id: AlignmentID.Type

    /// Creates an instance with the given identifier.
    /// - Parameter id: An identifier that uniquely identifies the horizontal alignment.
    public init(_ id: AlignmentID.Type) {
        self.id = id
    }

    public static let leading: Self = .init(LeadingID.self)
    public static let center: Self = .init(CenterID.self)
    public static let traling: Self = .init(TrailingID.self)
}

/// An alignment position along the vertical axis.
public struct VerticalAlignment: Equatable, Hashable {
    private enum TopID: AlignmentID {
        static func defaultValue(in dimensions: ViewDimensions) -> CGFloat { 0 }
    }

    private enum CenterID: AlignmentID {
        static func defaultValue(in dimensions: ViewDimensions) -> CGFloat {
            dimensions.height / 2
        }
    }

    private enum BottomID: AlignmentID {
        static func defaultValue(in dimensions: ViewDimensions) -> CGFloat { dimensions.height }
    }

    public static func == (lhs: VerticalAlignment, rhs: VerticalAlignment) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(id))
    }

    let id: AlignmentID.Type

    /// Creates an instance with the given identifier.
    /// - Parameter id: An identifier that uniquely identifies the vertical alignment.
    public init(_ id: AlignmentID.Type) {
        self.id = id
    }

    public static let top: Self = .init(TopID.self)
    public static let center: Self = .init(CenterID.self)
    public static let bottom: Self = .init(BottomID.self)
}

/// An alignment in both axes.
public struct Alignment: Equatable, Hashable {
    public let horizontal: HorizontalAlignment
    public let vertical: VerticalAlignment

    /// Creates an instance with the given horizontal and vertical alignments.
    /// - Parameters:
    ///   - horizontal: The alignment on the horizontal axis.
    ///   - vertical: The alignment on the vertical axis.
    public init(horizontal: HorizontalAlignment, vertical: VerticalAlignment) {
        self.horizontal = horizontal
        self.vertical = vertical
    }

    /// A guide marking the bottom edge of the view.
    public static let bottom: Alignment = .init(horizontal: .center, vertical: .bottom)
    /// A guide marking the bottom and leading edges of the view.
    public static let bottomLeading: Alignment = .init(horizontal: .leading, vertical: .bottom)
    /// A guide marking the bottom and trailing edges of the view.
    public static let bottomTrailing: Alignment = .init(horizontal: .traling, vertical: .bottom)
    /// A guide marking the center of the view.
    public static let center: Alignment = .init(horizontal: .center, vertical: .center)
    /// A guide marking the leading edge of the view.
    public static let leading: Alignment = .init(horizontal: .leading, vertical: .center)
    /// A guide marking the top edge of the view.
    public static let top: Alignment = .init(horizontal: .center, vertical: .top)
    /// A guide marking the top and leading edges of the view.
    public static let topLeading: Alignment = .init(horizontal: .leading, vertical: .top)
    /// A guide marking the top and trailing edges of the view.
    public static let topTrailing: Alignment = .init(horizontal: .traling, vertical: .top)
    /// A guide marking the trailing edge of the view.
    public static let trailing: Alignment = .init(horizontal: .traling, vertical: .center)
}

extension HorizontalAlignment {
    func anchorX(in dimensions: ViewDimensions) -> CGFloat {
        id.defaultValue(in: dimensions)
    }

    func anchorX(in rect: CGRect) -> CGFloat {
        anchorX(in: ViewDimensions(width: rect.width, height: rect.height))
    }
}

extension VerticalAlignment {
    func anchorY(in dimensions: ViewDimensions) -> CGFloat {
        id.defaultValue(in: dimensions)
    }

    func anchorY(in rect: CGRect) -> CGFloat {
        anchorY(in: ViewDimensions(width: rect.width, height: rect.height))
    }
}

extension Alignment {
    func anchorPoint(in dimensions: ViewDimensions) -> CGPoint {
        .init(x: horizontal.anchorX(in: dimensions),
              y: vertical.anchorY(in: dimensions))
    }

    func anchorPoint(in rect: CGRect) -> CGPoint {
        .init(x: horizontal.anchorX(in: rect),
              y: vertical.anchorY(in: rect))
    }
}
