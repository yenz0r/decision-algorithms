//
//  Function.swift
//  test-1
//
//  Created by yenz0redd on 15.02.2020.
//  Copyright © 2020 yenz0redd. All rights reserved.
//

import Foundation

protocol IFunction {
    var elements: [Int] { get set }
    func getValue(vector: Vector) -> Int?
}

class Function: IFunction {
    var elements: [Int]

    init(with count: Int) {
        self.elements = Array(repeating: 0, count: count)
    }

    func getValue(vector: Vector) -> Int? {
        guard self.elements.count == vector.elements.count else {
            return nil
        }

        var result = 0

        vector.elements.indices.forEach {
            result += vector.elements[$0] * self.elements[$0]
        }

        return result
    }

    static func update(function: Function, vector: Vector) -> Function? {
        guard function.elements.count == vector.elements.count else {
            return nil
        }

        let result = Function(with: function.elements.count)

        vector.elements.indices.forEach {
            result.elements[$0] = function.elements[$0] + vector.elements[$0]
        }

        return result
    }
}
