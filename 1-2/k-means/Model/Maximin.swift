//
//  Maximin.swift
//  k-means
//
//  Created by yenz0redd on 02.02.2020.
//  Copyright © 2020 yenz0redd. All rights reserved.
//

import Foundation
import CoreGraphics

class Maximin: IResolver {

    private let numberOfPoints: Int
    private var points: [CGPoint] = []
    var clusters: [Cluster] = []

    private let maxSize: CGSize

    var size: CGSize {
        return self.maxSize
    }

    private var maxDistance: CGFloat = 0
    private var newCentroid: CGPoint = CGPoint.zero

    init(numberOfPoints: Int, size: CGSize) {
        self.numberOfPoints = numberOfPoints
        self.maxSize = size

        self.points = self.configureRandomPoints()
    }

    func search() {
        self.createFirstCluster()
        self.createSecondCluster()

        while true {
            clearClusters()
            assignCluster()
            if !isSetNewCentroid() { break }
        }
    }

    private func assignCluster() {
        var clusterIndex = 0
        var distance = CGFloat.zero

        for point in self.points {
            var min: CGFloat = 1000000
            for index in 0..<self.clusters.count {
                let cluster = self.clusters[index]
                distance = self.getDistance(point: point, centroid: cluster.cetroid)
                if distance < min {
                    min = distance
                    clusterIndex = index
                }
            }
            self.clusters[clusterIndex].addPoint(point)
        }
    }

    private func calculateMaxDistance() {
        var max: CGFloat = -1000000
        var pointToCentroid: CGPoint?
        var distance = CGFloat.zero

        for cluster in self.clusters {
            for point in cluster.points {
                distance = getDistance(point: point, centroid: cluster.cetroid)
                if distance > max {
                    max = distance
                    pointToCentroid = point
                }
            }
        }

        if let point = pointToCentroid {
            self.maxDistance = distance
            self.newCentroid = point
        }
    }

    private func createFirstCluster() {
        let cluster = Cluster()
        if let centroid = self.points.popLast() {
            cluster.cetroid = centroid
            self.clusters.append(cluster)
        }
    }

    private func isSetNewCentroid() -> Bool {
        var totalDistance = CGFloat.zero

        var distances = [CGFloat]()
        calculateMaxDistance()

        for i in 0..<self.clusters.count - 1 {
            for j in 1..<self.clusters.count {
                let currentDistance = self.getDistance(
                    point: self.clusters[i].cetroid,
                    centroid: self.clusters[j].cetroid
                )
                distances.append(currentDistance)
                totalDistance += currentDistance
            }
        }

        if maxDistance > totalDistance / CGFloat(distances.count) / 2 {
            let cluster = Cluster()
            cluster.cetroid = self.newCentroid
            self.points.remove(at: self.points.lastIndex(of: self.newCentroid)!)
            self.clusters.append(cluster)
            return true
        }

        return false
    }

    private func createSecondCluster() {
        var max: CGFloat = -1000000
        var pointToCentroid: CGPoint?
        var distance = CGFloat.zero

        let cluster = self.clusters[0]
        for point in self.points {
            distance = getDistance(point: point, centroid: cluster.cetroid)
            if distance > max {
                max = distance
                pointToCentroid = point
            }
        }

        if let point = pointToCentroid {
            let cluster = Cluster()
            cluster.cetroid = point
            self.clusters.append(cluster)
            self.points.remove(at: self.points.lastIndex(of: point)!)
        }
    }

    func getDistance(point: CGPoint, centroid: CGPoint) -> CGFloat {
        let x = centroid.x - point.x
        let y = centroid.y - point.y
        return sqrt(pow(x, 2) + pow(y, 2))
    }

    private func clearClusters() {
        self.clusters.forEach { $0.clear() }
    }

    private func configureRandomPoints() -> [CGPoint] {
        var result = [CGPoint]()
        (0..<self.numberOfPoints).forEach { _ in
            result.append(CGPoint(
                x: Int.random(in: 0..<Int(maxSize.width)),
                y: Int.random(in: 0..<Int(maxSize.height)))
            )
        }
        return result
    }
    
}
