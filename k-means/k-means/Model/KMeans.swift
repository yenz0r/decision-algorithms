//
//  KMeans.swift
//  k-means
//
//  Created by yenz0redd on 02.02.2020.
//  Copyright © 2020 yenz0redd. All rights reserved.
//

import Foundation
import CoreGraphics

class KMeans {
    var points: [CGPoint] = []
    var clusters: [Cluster] = []

    private let numberOfPoints: Int
    private let numberOfClusters: Int

    private let windowSize: CGSize

    init(numberOfPoints: Int,
         numberOfClusters: Int,
         windowSize: CGSize) {
        self.numberOfPoints = numberOfPoints
        self.numberOfClusters = numberOfClusters
        self.windowSize = windowSize

        self.points = self.configureRandomPoints()
        self.clusters = self.configureRandomClusters()
        self.search()
    }

    private func configureRandomPoints() -> [CGPoint] {
        var result = [CGPoint]()

        (0..<self.numberOfPoints).forEach { _ in
            result.append(CGPoint(
                x: Int.random(in: 0...Int(windowSize.width)),
                y: Int.random(in: 0...Int(windowSize.height)))
            )
        }

        return result
    }

    private func configureRandomClusters() -> [Cluster] {
        var result = [Cluster]()

        (0..<self.numberOfClusters).forEach { _ in
            let cluster = Cluster()
            if let centroid = self.points.popLast() {
                cluster.cetroid = centroid
                result.append(cluster)
            } else {
                return
            }
        }

        return result
    }

    private func calculateCetroids() {
        for cluster in self.clusters {
            var sumX: CGFloat = 0
            var sumY: CGFloat = 0

            let numberOfPoints = cluster.points.count

            for point in cluster.points {
                sumX += point.x
                sumY += point.y
            }

            if numberOfPoints > 0 {
                let newX = sumX / CGFloat(numberOfPoints)
                let newY = sumY / CGFloat(numberOfPoints)

                cluster.cetroid.x = newX
                cluster.cetroid.y = newY
            }
        }
    }

    private func getDistance(point: CGPoint, cetroid: CGPoint) -> CGFloat {
        let x = cetroid.x - point.x
        let y = cetroid.y - point.y

        return sqrt(pow(x, 2) + pow(y, 2))
    }

    private func clearClusters() {
        clusters.forEach { $0.clear() }
    }

    private func getCentroids() -> [CGPoint] {
        var centroids = [CGPoint]()
        self.clusters.forEach {
            centroids.append($0.cetroid)
        }
        return centroids
    }

    private func assignCluster() {
        var clusterIndex = 0
        var distance = CGFloat.zero

        for point in self.points {
            var min: CGFloat = 100000
            for index in 0..<self.numberOfClusters {
                let cluster = self.clusters[index]
                distance = self.getDistance(point: point, cetroid: cluster.cetroid)
                if distance < min {
                    min = distance
                    clusterIndex = index
                }
            }
            self.clusters[clusterIndex].addPoint(point)
        }
    }

    func search() {
        var finish = false

        repeat {

            self.clearClusters()
            let lastCentroids = self.getCentroids()
            self.assignCluster()
            self.calculateCetroids()
            let currentCentroids = self.getCentroids()
            var distance: CGFloat = 0
            for index in 0..<lastCentroids.count {
                distance += self.getDistance(point: lastCentroids[index], cetroid: currentCentroids[index])
            }
            if (distance == 0) {
                finish = true;
            }

        } while (!finish);
    }
}
