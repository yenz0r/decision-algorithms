//
//  Protocols.swift
//  k-means
//
//  Created by yenz0redd on 02.02.2020.
//  Copyright © 2020 yenz0redd. All rights reserved.
//

import Foundation

protocol IResolver {
    func search()
    var clusters: [Cluster] { get }
}
