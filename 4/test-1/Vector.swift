//
//  Vector.swift
//  test-1
//
//  Created by yenz0redd on 15.02.2020.
//  Copyright © 2020 yenz0redd. All rights reserved.
//

import Foundation

class Vector {
    var elements: [Int]

    init(with size: Int) {
        self.elements = Array(repeating: 0, count: size)
    }

    static func multiply(on koef: Int, from vector: Vector) -> Vector {
        let result = Vector(with: vector.elements.count)

        vector.elements.indices.forEach {
            result.elements[$0] = vector.elements[$0] * koef
        }

        return result
    }
}
