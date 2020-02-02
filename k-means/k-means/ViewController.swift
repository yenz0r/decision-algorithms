//
//  ViewController.swift
//  k-means
//
//  Created by yenz0redd on 02.02.2020.
//  Copyright © 2020 yenz0redd. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    enum ResolverType {
        case kmeans
        case maximin

        static func resolverAt(_ index: Int) -> ResolverType {
            return index == 0 ? .kmeans : .maximin
        }
    }

    private var resolveProvider: IResolver!
    private var resultColors = [UIColor]()

    private var clustersCountTextField: UITextField!
    private var pointsCountTextField: UITextField!
    private var startButton: UIButton!
    private var showResultsButton: UIButton!
    private var stackView: UIStackView!

    private var segmentControl: UISegmentedControl!

    private var loader: UIActivityIndicatorView!

    private var imageView: UIImageView!

    private var currentResolverType = ResolverType.kmeans {
        didSet {
            if self.currentResolverType == .maximin {
                self.clustersCountTextField.text = ""
                self.clustersCountTextField.placeholder = "Disabled"
                self.clustersCountTextField.isEnabled = false
            } else {
                self.clustersCountTextField.placeholder = "Clusters count"
                self.clustersCountTextField.isEnabled = true
            }
        }
    }

    override func loadView() {
        self.view = UIView()

        self.stackView = UIStackView()
        self.view.addSubview(self.stackView)
        self.stackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            make.height.equalToSuperview().dividedBy(3)
        }

        self.clustersCountTextField = UITextField()
        self.pointsCountTextField = UITextField()
        self.startButton = UIButton(type: .system)
        self.showResultsButton = UIButton(type: .system)

        self.segmentControl = UISegmentedControl(items: ["KMeans", "Maximin"])

        [self.segmentControl,
         self.clustersCountTextField,
         self.pointsCountTextField,
         self.startButton,
         self.showResultsButton].forEach { self.stackView.addArrangedSubview($0) }

        self.imageView = UIImageView()
        self.view.addSubview(self.imageView)
        self.imageView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(30)
            make.height.equalTo(self.imageView.snp.width)
            make.top.equalTo(self.stackView.snp.bottom).offset(10)
        }

        self.loader = UIActivityIndicatorView(style: .large)
        self.view.addSubview(self.loader)
        self.loader.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white

        self.stackView.axis = .vertical
        self.stackView.distribution = .fillEqually
        self.stackView.spacing = 10

        [self.pointsCountTextField,
         self.clustersCountTextField].forEach { $0?.textAlignment = .center }

        self.pointsCountTextField.placeholder = "Points count"
        self.clustersCountTextField.placeholder = "Clusters count"

        self.segmentControl.selectedSegmentIndex = 0
        self.segmentControl.addTarget(self, action: #selector(segmentControlChanged), for: .valueChanged)

        self.loader.tintColor = .black

        self.imageView.contentMode = .scaleAspectFit
        self.imageView.layer.cornerRadius = 10.0
        self.imageView.clipsToBounds = true

        self.showResultsButton.backgroundColor = .purple
        self.showResultsButton.layer.cornerRadius = 10
        self.showResultsButton.clipsToBounds =  true
        let attriburedResultsTitle = NSAttributedString(
            string: "Show results",
            attributes: [
                .font: UIFont(name: "Avenir-Roman", size: 30)!,
                .foregroundColor: UIColor.white
            ]
        )
        self.showResultsButton.setAttributedTitle(attriburedResultsTitle, for: .normal)
        self.showResultsButton.addTarget(self, action: #selector(showButtonTapped), for: .touchUpInside)

        self.startButton.backgroundColor = .orange
        self.startButton.layer.cornerRadius = 10
        self.startButton.clipsToBounds = true
        let attriburedStartTitle = NSAttributedString(
            string: "Press to resolve",
            attributes: [
                .font: UIFont(name: "Avenir-Roman", size: 30)!,
                .foregroundColor: UIColor.white
            ]
        )
        self.startButton.setAttributedTitle(attriburedStartTitle, for: .normal)
        self.startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
    }

    @objc private func segmentControlChanged(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        self.currentResolverType = ResolverType.resolverAt(selectedIndex)
    }

    @objc private func showButtonTapped() {
        let resultViewController = ResultViewController(
            provider: self.resolveProvider,
            colors: self.resultColors
        )
        self.present(resultViewController, animated: true, completion: nil)
    }

    @objc private func startButtonTapped() {
        var clustersCount = 0
        if !(self.currentResolverType == .maximin) {
            guard let count = Int(self.clustersCountTextField.text ?? "-") else { return }
            clustersCount = count
        }

        guard let pointsCount = Int(self.pointsCountTextField.text ?? "-") else { return }

        var pointsProvider: IResolver

        switch self.currentResolverType {
        case .kmeans:
            pointsProvider = KMeans(
                numberOfPoints: pointsCount,
                numberOfClusters: clustersCount,
                windowSize: self.imageView.frame.size // CGSize(width: 512, height: 512)
            )
        case .maximin:
            pointsProvider = Maximin(
                numberOfPoints: pointsCount,
                size: self.imageView.frame.size
            )
        }

        self.resolveProvider = pointsProvider
        self.loader.startAnimating()

        self.drawImage(with: pointsProvider, for: self.imageView.frame.size) { [weak self] image in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self?.loader.stopAnimating()
                self?.imageView.image = image
            }
        }
    }

    private func drawImage(with pointsProvider: IResolver, for size: CGSize, completion: ((UIImage) -> Void)?) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.resultColors = []
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: size.width + 20, height: size.height + 20))
            let img = renderer.image { ctx in
                ctx.cgContext.setLineWidth(1)

                for cluster in pointsProvider.clusters {
                    let randColor = UIColor(
                        red: CGFloat(Int.random(in: 0..<256)) / 255.0,
                        green: CGFloat(Int.random(in: 0..<256)) / 255.0,
                        blue: CGFloat(Int.random(in: 0..<256)) / 255.0,
                        alpha: 1
                    )
                    self?.resultColors.append(randColor)
                    ctx.cgContext.setStrokeColor(UIColor.white.cgColor)
                    ctx.cgContext.setFillColor(randColor.cgColor)

                    for point in cluster.points {
                        let rectangle = CGRect(x: point.x, y: point.y, width: 20, height: 20)
                        ctx.cgContext.addEllipse(in: rectangle)
                    }
                    ctx.cgContext.drawPath(using: .fillStroke)

                    let centerRect = CGRect(
                        x: cluster.cetroid.x,
                        y: cluster.cetroid.y,
                        width: 30,
                        height: 30
                    )
                    ctx.cgContext.addRect(centerRect)
                    ctx.cgContext.setFillColor(UIColor.red.cgColor)
                    ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
                    ctx.cgContext.drawPath(using: .fillStroke)
                }
            }
            completion?(img)
        }
    }
}

