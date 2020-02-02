//
//  ResultsViewController.swift
//  k-means
//
//  Created by yenz0redd on 02.02.2020.
//  Copyright © 2020 yenz0redd. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {
    private var tableView: UITableView!

    private let pointsProvider: IResolver

    init(provider: IResolver) {
        self.pointsProvider = provider

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = UIView()

        self.tableView = UITableView()
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "resultPointCell")
    }
}

extension ResultViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.pointsProvider.clusters.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pointsProvider.clusters[section].points.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultPointCell", for: indexPath)
        let point = self.pointsProvider.clusters[indexPath.section].points[indexPath.row]
        cell.textLabel?.text = "x = \(point.x) ~ y = \(point.y)"
        cell.backgroundColor = self.pointsProvider.clusters[indexPath.section].colors[indexPath.row]
        return cell
    }
}
