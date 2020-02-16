//
//  Protocols.swift
//  k-means
//
//  Created by yenz0redd on 02.02.2020.
//  Copyright © 2020 yenz0redd. All rights reserved.
//

import UIKit

protocol IResolver {
    func search()
    func getDistance(point: CGPoint, centroid: CGPoint) -> CGFloat
    var clusters: [Cluster] { get }
    var size: CGSize { get }
}
