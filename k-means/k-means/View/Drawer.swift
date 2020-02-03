//
//  Drawer.swift
//  k-means
//
//  Created by Yahor Bychkouski on 2/3/20.
//  Copyright © 2020 yenz0redd. All rights reserved.
//

import Foundation
import UIKit

class Drawer {
    static let shared = Drawer()

    private init() { }

    func drawCommonResult(with pointsProvider: IResolver, for size: CGSize, completion: ((UIImage) -> Void)?) {
        DispatchQueue.global(qos: .userInteractive).async {
            pointsProvider.search()
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: size.width + 20, height: size.height + 20))
            let img = renderer.image { ctx in
                ctx.cgContext.setLineWidth(1)

                for cluster in pointsProvider.clusters {
                    var resultColors = [UIColor]()
                    let randColor = UIColor(
                        red: CGFloat(Int.random(in: 0..<256)) / 255.0,
                        green: CGFloat(Int.random(in: 0..<256)) / 255.0,
                        blue: CGFloat(Int.random(in: 0..<256)) / 255.0,
                        alpha: 1
                    )
                    ctx.cgContext.setStrokeColor(UIColor.white.cgColor)
                    ctx.cgContext.setFillColor(randColor.cgColor)

                    for point in cluster.points {
                        let rectangle = CGRect(x: point.x, y: point.y, width: 10, height: 10)
                        ctx.cgContext.addEllipse(in: rectangle)
                        resultColors.append(randColor)
                    }
                    ctx.cgContext.drawPath(using: .fillStroke)
                    cluster.colors = resultColors
                    let centerRect = CGRect(
                        x: cluster.cetroid.x,
                        y: cluster.cetroid.y,
                        width: 20,
                        height: 20
                    )
                    ctx.cgContext.addRect(centerRect)
                    ctx.cgContext.setFillColor(UIColor.red.cgColor)
                    ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
                    ctx.cgContext.drawPath(using: .fillStroke)
                }
            }
            completion?(img)
        }
    }

    func drawDetailResult(with pointsProvider: IResolver, for indexPath: IndexPath, for size: CGSize, completion: ((UIImage) -> Void)?) {
        DispatchQueue.global(qos: .userInteractive).async {
            var centoids = [CGPoint]()

            let renderer = UIGraphicsImageRenderer(size: CGSize(width: size.width + 20, height: size.height + 20))
            let img = renderer.image { ctx in
                ctx.cgContext.setLineWidth(1)

                let detailPoint = pointsProvider.clusters[indexPath.section].points[indexPath.row]

                for cluster in pointsProvider.clusters {
                    ctx.cgContext.setStrokeColor(UIColor.white.cgColor)

                    for (index, point) in cluster.points.enumerated() where index != indexPath.row {
                        let rectangle = CGRect(x: point.x, y: point.y, width: 10, height: 10)
                        ctx.cgContext.addEllipse(in: rectangle)
                        ctx.cgContext.setFillColor(cluster.colors[index].cgColor)
                    }
                    ctx.cgContext.drawPath(using: .fillStroke)
                    let centerRect = CGRect(
                        x: cluster.cetroid.x,
                        y: cluster.cetroid.y,
                        width: 10,
                        height: 10
                    )
                    centoids.append(cluster.cetroid)

                    ctx.cgContext.addRect(centerRect)
                    ctx.cgContext.setFillColor(UIColor.red.cgColor)
                    ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
                    ctx.cgContext.drawPath(using: .fillStroke)
                }

                for point in centoids {
                    ctx.cgContext.move(to: CGPoint(x: detailPoint.x + 10, y: detailPoint.y + 10))
                    ctx.cgContext.addLine(to: CGPoint(x: point.x + 5, y: point.y + 5))
                    ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
                    ctx.cgContext.drawPath(using: .stroke)

                    let distance = pointsProvider.getDistance(point: detailPoint, centroid: point)
                    let attributedText = NSAttributedString(
                        string: "\(Int(distance.rounded()))",
                        attributes: [
                            .font: UIFont(name: "Avenir-Black", size: 15)!,
                            .foregroundColor: UIColor.black
                        ]
                    )
                    attributedText.draw(at: CGPoint(x: point.x - 15, y: point.y - 15))
                }

                ctx.cgContext.drawPath(using: .fillStroke)
                let centerRect = CGRect(
                    x: detailPoint.x,
                    y: detailPoint.y,
                    width: 20,
                    height: 20
                )

                ctx.cgContext.setLineWidth(3)
                ctx.cgContext.addRect(centerRect)
                ctx.cgContext.setFillColor(UIColor.orange.cgColor)
                ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
                ctx.cgContext.drawPath(using: .fillStroke)
            }
            completion?(img)
        }
    }
}
