//
//  Persiptron.swift
//  test-1
//
//  Created by yenz0redd on 15.02.2020.
//  Copyright © 2020 yenz0redd. All rights reserved.
//

import Foundation

protocol IPersiptron {
    func getSeparateFunctions(vectors: inout [[Vector]]) -> [Function]
    func maxVectorClass(result: inout [Function], currentVector: Vector) -> Int?
}

class Persiptron: IPersiptron {
    private let classCount: Int
    private let vectorsSize: Int

    var warning: Bool = false

    init(classCount: Int, vectorsSize: Int) {
        self.classCount = classCount
        self.vectorsSize = vectorsSize
    }

    func getSeparateFunctions(vectors: inout [[Vector]]) -> [Function] {
        var result = self.configureEmptyFunctions()
        self.warning = false
        var nextIteration = true
        var iterationNumber = 0

        while iterationNumber < 1000 && nextIteration {
            iterationNumber += 1
            nextIteration = makeIteration(vectors: vectors, result: &result)
        }

        self.warning = iterationNumber == 1000

        return result
    }

    func maxVectorClass(result: inout [Function], currentVector: Vector) -> Int? {
        guard var max = result.first?.getValue(vector: currentVector) else {
            return nil
        }
        var maxClass = 0
        var maxCount = 1

        (1..<classCount).forEach {
            guard let currentValue = result[$0].getValue(vector: currentVector) else {
                return
            }

            if currentValue > max {
                maxCount = 0
                max = currentValue
                maxClass = $0
            }

            if currentValue == max {
                maxCount += 1
            }
        }

        return maxCount == 1 ? maxClass : -1
    }

    private func makeIteration(vectors: [[Vector]], result: inout [Function]) -> Bool {
        var nextIteration = false

        guard vectors.count == self.classCount else { return false }

        for classNumber in (0..<classCount) {
            for i in vectors.indices {

                nextIteration = self.workWithVector(
                    currentVector: vectors[classNumber][i],
                    result: &result,
                    vectorsClass: classNumber
                )

            }
        }

        return nextIteration
    }

    private func workWithVector(currentVector: Vector, result: inout [Function], vectorsClass: Int) -> Bool {
        let maxClass = self.maxVectorClass(result: &result, currentVector: currentVector)

        guard maxClass != vectorsClass else { return false }

        self.panish(currentVector: currentVector, result: &result, vectorClass: vectorsClass)
        return true
    }

    private func panish(currentVector: Vector, result: inout [Function], vectorClass: Int) {
        (0..<self.classCount).forEach {
            if let function = Function.update(
                    function: result[$0],
                    vector: $0 == vectorClass ? currentVector : Vector.multiply(on: -1, from: currentVector)
                ) {
                result[$0] = function
            }
        }
    }

    private func configureEmptyFunctions() -> [Function] {
        return Array(repeating: Function(with: self.vectorsSize), count: self.classCount)
    }
}
