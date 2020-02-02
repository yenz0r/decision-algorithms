//
//  Cluster.swift
//  k-means
//
//  Created by yenz0redd on 02.02.2020.
//  Copyright © 2020 yenz0redd. All rights reserved.
//

import UIKit
import CoreGraphics

protocol ICluster {
    var points: [CGPoint] { get }
    var cetroid: CGPoint { get set }
    var colors: [UIColor] { get set }
    func addPoint(_ point: CGPoint)
    func clear()
}

class Cluster {
    private var insidePoints: [CGPoint]
    private var insideCetroid: CGPoint?

    var colors: [UIColor] = []

    init() {
        self.insidePoints = []
    }
}

extension Cluster: ICluster {
    var points: [CGPoint] {
        return self.insidePoints
    }

    var cetroid: CGPoint {
        get {
            return self.insideCetroid ?? CGPoint(x: 0, y: 0)
        }
        set {
            self.insideCetroid = newValue
        }
    }

    func addPoint(_ point: CGPoint) {
        self.insidePoints.append(point)
    }

    func clear() {
        self.insidePoints.removeAll()
    }


}
