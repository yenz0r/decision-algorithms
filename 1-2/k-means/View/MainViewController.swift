//
//  ViewController.swift
//  k-means
//
//  Created by yenz0redd on 02.02.2020.
//  Copyright © 2020 yenz0redd. All rights reserved.
//

import UIKit
import SnapKit

class MainViewController: UIViewController {
    enum ResolverType {
        case kmeans
        case maximin

        static func resolverAt(_ index: Int) -> ResolverType {
            return index == 0 ? .kmeans : .maximin
        }
    }

    private var resolveProvider: IResolver!

    private var clustersCountTextField: UITextField!
    private var pointsCountTextField: UITextField!
    private var startButton: UIButton!
    private var showResultsButton: UIButton!
    private var stackView: UIStackView!

    private var segmentControl: UISegmentedControl!
    private var progressView: UIProgressView!

    private var loader: UIActivityIndicatorView!

    private var imageView: UIImageView!

    private var currentResolverType = ResolverType.kmeans {
        didSet {
            if self.currentResolverType == .maximin {
                self.clustersCountTextField.text = ""
                self.clustersCountTextField.attributedPlaceholder = NSAttributedString(
                    string: "Disabled",
                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.red.withAlphaComponent(0.3)]
                )
                self.clustersCountTextField.isEnabled = false
            } else {
                self.clustersCountTextField.attributedPlaceholder = NSAttributedString(
                    string: "Cluster count",
                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.purple.withAlphaComponent(0.3)]
                )
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

        self.progressView = UIProgressView(progressViewStyle: .default)
        self.view.addSubview(self.progressView)
        self.progressView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(10)
            make.height.equalTo(3)
        }

        self.imageView = UIImageView()
        self.view.addSubview(self.imageView)
        self.imageView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(30)
            make.bottom.equalTo(self.progressView.snp.top).offset(-10)
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
         self.clustersCountTextField].forEach {
            $0?.textAlignment = .center
            $0?.layer.borderColor = UIColor.purple.withAlphaComponent(0.2).cgColor
            $0?.layer.borderWidth = 1
            $0?.layer.cornerRadius = 10
            $0?.clipsToBounds = true
        }

        self.pointsCountTextField.placeholder = "Points count"
        self.pointsCountTextField.textColor = .black
        self.pointsCountTextField.keyboardType = .numberPad
        self.pointsCountTextField.attributedPlaceholder = NSAttributedString(
            string: "Points count",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.purple.withAlphaComponent(0.3)]
        )

        self.clustersCountTextField.textColor = .black
        self.clustersCountTextField.keyboardType = .numberPad
        self.clustersCountTextField.attributedPlaceholder = NSAttributedString(
            string: "Clusters count",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.purple.withAlphaComponent(0.3)]
        )

        self.segmentControl.selectedSegmentIndex = 0
        self.segmentControl.selectedSegmentTintColor = UIColor.blue.withAlphaComponent(0.5)
        self.segmentControl.addTarget(self, action: #selector(segmentControlChanged), for: .valueChanged)

        self.loader.color = .red

        self.progressView.progressTintColor = UIColor.purple.withAlphaComponent(0.8)
        self.progressView.trackTintColor = .lightGray

        self.imageView.contentMode = .scaleAspectFit
        self.imageView.layer.cornerRadius = 10.0
        self.imageView.clipsToBounds = true

        self.showResultsButton.backgroundColor = .gray
        self.showResultsButton.isEnabled = false
        self.showResultsButton.layer.cornerRadius = 10
        self.showResultsButton.clipsToBounds =  true
        let attriburedResultsTitle = NSAttributedString(
            string: "Show results",
            attributes: [
                .font: UIFont(name: "Avenir-Roman", size: 20)!,
                .foregroundColor: UIColor.white
            ]
        )
        self.showResultsButton.setAttributedTitle(attriburedResultsTitle, for: .normal)
        self.showResultsButton.addTarget(self, action: #selector(showButtonTapped), for: .touchUpInside)

        self.startButton.backgroundColor = UIColor.orange.withAlphaComponent(0.6)
        self.startButton.layer.cornerRadius = 10
        self.startButton.clipsToBounds = true
        let attriburedStartTitle = NSAttributedString(
            string: "Press to resolve",
            attributes: [
                .font: UIFont(name: "Avenir-Roman", size: 20)!,
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
            provider: self.resolveProvider
        )
        self.present(resultViewController, animated: true, completion: nil)
    }

    @objc private func startButtonTapped() {
        self.view.endEditing(true)
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

        UIView.animate(withDuration: 0.8, animations: {
            self.imageView.alpha = 0
        }, completion: { _ in
            self.imageView.image = nil
            self.progressView.setProgress(0.7, animated: true)
        })
        self.progressView.setProgress(0, animated: false)

        self.showResultsButton.backgroundColor = UIColor.purple.withAlphaComponent(0.6)
        self.showResultsButton.isEnabled = true

        Drawer.shared.drawCommonResult(with: pointsProvider, for: self.imageView.frame.size) { [weak self] image in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self?.loader.stopAnimating()
                self?.imageView.image = image
                UIView.animate(withDuration: 0.8, animations: {
                    self?.imageView.alpha = 1
                })
                self?.progressView.setProgress(1, animated: true)
            }
        }
    }
}

