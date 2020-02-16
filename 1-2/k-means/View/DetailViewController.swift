//
//  DetailViewController.swift
//  k-means
//
//  Created by Yahor Bychkouski on 2/3/20.
//  Copyright © 2020 yenz0redd. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    private let pointsProvider: IResolver
    private let detailIndexPath: IndexPath

    private var imageView: UIImageView!
    private var loader: UIActivityIndicatorView!
    private var titleLabel: UILabel!
    private var closeButton: UIButton!

    var onCloseButtonTap: (() -> Void)?

    init(provider: IResolver, indexPath: IndexPath) {
        self.pointsProvider = provider
        self.detailIndexPath = indexPath

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = UIView()

        self.imageView = UIImageView()
        self.view.addSubview(self.imageView)
        self.imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(self.pointsProvider.size)
        }

        self.titleLabel = UILabel()
        self.view.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(20)
        }

        self.closeButton = UIButton(type: .system)
        self.view.addSubview(self.closeButton)
        self.closeButton.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(50)
        }

        self.loader = UIActivityIndicatorView(style: .large)
        self.view.addSubview(self.loader)
        self.loader.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white

        self.imageView.contentMode = .scaleAspectFill

        self.titleLabel.font = UIFont(name: "Avenir-Roman", size: 25)
        self.titleLabel.textAlignment = .center
        self.titleLabel.textColor = .black
        let point = self.pointsProvider.clusters[detailIndexPath.section].points[detailIndexPath.row]
        self.titleLabel.text = "Info for point:\nx = \(point.x) ~ y = \(point.y)"
        self.titleLabel.numberOfLines = 2

        self.closeButton.backgroundColor = UIColor.orange.withAlphaComponent(0.7)
        self.closeButton.layer.cornerRadius = 10
        self.closeButton.clipsToBounds = true
        let attributedCloseTitle = NSAttributedString(
            string: "Close",
            attributes: [
                .font: UIFont(name: "Avenir-Roman", size: 20)!,
                .foregroundColor: UIColor.white
            ]
        )
        self.closeButton.setAttributedTitle(attributedCloseTitle, for: .normal)
        self.closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)

        self.loader.color = .orange
        self.loader.startAnimating()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        Drawer.shared.drawDetailResult(with: self.pointsProvider, for: self.detailIndexPath, for: self.imageView.frame.size) { image in
            DispatchQueue.main.async {
                self.imageView.image = image
                self.loader.stopAnimating()
            }
        }
    }

    @objc private func closeButtonTapped() {
        self.onCloseButtonTap?()
    }
}
