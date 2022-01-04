//
//  Tag.swift
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
import SwiftUI

public protocol ValueTag: Hashable {
    associatedtype Value
}

@usableFromInline
struct TaggedMeasurableNode<Content: MeasurableNode>: MeasurableNode {
    @usableFromInline
    let content: Content
    @usableFromInline
    let tag: AnyHashable
    @usableFromInline
    let value: Any?

    @usableFromInline
    func layout(using layoutContext: LayoutContext) -> MeasuredNode {
        TaggedMeasuredNode(
            content: content.layout(using: layoutContext),
            tag: tag,
            value: value)
    }

    @usableFromInline
    var children: [MeasurableNode] {
        [content]
    }
}

@usableFromInline
struct TaggedMeasuredNode: MeasuredNode, TaggedNode {
    @usableFromInline
    let content: MeasuredNode
    @usableFromInline
    let tag: AnyHashable?
    @usableFromInline
    let value: Any?

    @usableFromInline
    var size: CGSize {
        content.size
    }

    @usableFromInline
    func render(in view: UIView, origin: CGPoint) {
        content.render(in: view, origin: origin)
    }

    @usableFromInline
    var positionedChildren: [(CGRect, MeasuredNode)] {
        let frame = CGRect(origin: .zero, size: content.size)
        return [(frame, content)]
    }

    @usableFromInline
    var uiViews: [UIView] {
        content.uiViews
    }
}

public extension MeasurableNode {
    func tag<Tag: Hashable>(_ tag: Tag) -> MeasurableNode {
        TaggedMeasurableNode(content: self, tag: AnyHashable(tag), value: nil)
    }

    func tag<Tag: ValueTag>(_ tag: Tag, _ value: Tag.Value) -> MeasurableNode {
        TaggedMeasurableNode(content: self, tag: AnyHashable(tag), value: value)
    }
}

@usableFromInline
protocol TaggedNode {
    var tag: AnyHashable? { get }
    var value: Any? { get }
}

public struct MeasuredNodeTaggedInfo {
    public fileprivate(set) var frames: [AnyHashable: CGRect]
    public fileprivate(set) var values: [AnyHashable: Any]

    @inlinable
    public func taggedFrame<Tag: Hashable>(for tag: Tag) -> CGRect? {
        frames[AnyHashable(tag)]
    }

    @inlinable
    public func taggedValue<Tag: ValueTag>(for tag: Tag) -> Tag.Value? {
        guard let value = values[AnyHashable(tag)] else { return nil }
        let casted = value as! Tag.Value
        return casted
    }
}

public extension MeasuredNode {
    var taggedInfo: MeasuredNodeTaggedInfo {
        var info = MeasuredNodeTaggedInfo(frames: [:], values: [:])

        for (frame, child) in positionedChildren {
            let subInfo = child.taggedInfo

            for (tag, subframe) in subInfo.frames {
                var subframe = subframe
                subframe.origin.x += frame.origin.x
                subframe.origin.y += frame.origin.y
                info.frames[tag] = subframe
            }

            for (tag, value) in subInfo.values {
                info.values[tag] = value
            }
        }

        // Higher level things have higher priorities.
        if let self = self as? TaggedNode, let tag = self.tag {
            info.frames[tag] = CGRect(origin: .zero, size: size)
            if let value = self.value {
                info.values[tag] = value
            }
        }

        return info
    }

    @inlinable
    func frame<Tag: Hashable>(withTag tag: Tag) -> CGRect? {
        if let self = self as? TaggedMeasuredNode,
           self.tag == AnyHashable(tag)
        {
            return CGRect(origin: .zero, size: size)
        }
        for (frame, child) in positionedChildren {
            if var subframe = child.frame(withTag: tag) {
                subframe.origin.x += frame.origin.x
                subframe.origin.y += frame.origin.y
                return subframe
            }
        }
        return nil
    }

    @inlinable
    func associatedValue<Tag: ValueTag>(for tag: Tag) -> Tag.Value? {
        if let self = self as? TaggedNode,
           self.tag == AnyHashable(tag),
           let value = self.value
        {
            let casted = value as! Tag.Value
            return casted
        }
        for (_, child) in positionedChildren {
            if let value = child.associatedValue(for: tag) {
                return value
            }
        }
        return nil
    }
}

extension TaggedMeasurableNode: ShrinkableNode where Content: ShrinkableNode {}
extension TaggedMeasurableNode: ShrinkContainer where Content: ShrinkContainer {
    @usableFromInline
    func unshrinkableSize(in context: LayoutContext) -> CGSize {
        content.unshrinkableSize(in: context)
    }
}
