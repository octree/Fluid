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

class ViewController: UIViewController {
    private let imageView: UIImageView = {
        let im = UIImageView(image: UIImage(named: "Blue.jpg"))
        im.layer.masksToBounds = true
        im.layer.cornerRadius = 40
        im.layer.cornerCurve = .continuous
        return im
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.numberOfLines = 1
        label.textColor = .label
        label.text = "Blue"
        return label
    }()

    private let detailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.numberOfLines = 2
        label.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var editButton: UIButton = {
        let view = UIButton(type: .custom)
        let image = UIImage(systemName: "pencil.circle.fill",
                            withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 30)))
        view.setImage(image, for: .normal)
        view.imageView?.contentMode = .scaleAspectFill
        view.tintColor = .systemRed
        return view
    }()

    private var chevronImageView: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "chevron.right"))
        view.contentMode = .scaleAspectFit
        view.tintColor = .systemRed
        return view
    }()

    var node: MeasurableNode {
        HStack(spacing: 16) {
            self.imageView
                .aspectRatio(1)
                .frame(width: 80)
                .overlay {
                    self.editButton
                        .flexible(width: 25%, height: 25%)
                        .offset(x: -3, y: -3)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                }
            VStack(alignment: .leading) {
                nameLabel
                detailLabel
            }
            Spacer()
            chevronImageView
                .flexible(width: 20, height: 20)
        }
        .padding()
        .background(backgroundView)
    }

    let backgroundView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.backgroundColor = UIColor(white: 0.95, alpha: 1)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var size = view.frame.size
        size.width -= 40
        size.height -= 60
        let measured = node.layout(using: .init(size))
        measured.render(in: view, origin: .init(x: 20, y: 40))
    }
}
