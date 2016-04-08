//
//  Stroke.swift
//  japanize
//
//  Created by Xinxin Xie on 4/3/16.
//  Copyright © 2016 Codepath. All rights reserved.
//

import UIKit

class Stroke {
    
    let pathString: String
    let points: [CGPoint]
    
    // Internal path
    private let _path = UIBezierPath()
    
    var path: UIBezierPath {
        get {
            // Defensive copy
            return _path.copy() as! UIBezierPath
        }
    }
    
    init(pathString: String) {
        self.pathString = pathString
        
        var tokens = [String]()
        var token = ""
        let letters = NSCharacterSet.letterCharacterSet()
        let digits = NSCharacterSet.decimalDigitCharacterSet()
        var points = [CGPoint]()
        
        for uni in pathString.unicodeScalars {
            if letters.longCharacterIsMember(uni.value) {
                if !token.isEmpty {
                    tokens.append(token)
                    token = ""
                }
                tokens.append(String(uni))
            } else if digits.longCharacterIsMember(uni.value) || String(uni) == "." {
                token.append(uni)
            } else if String(uni) == "," {
                if !token.isEmpty {
                    tokens.append(token)
                    token = ""
                }
            } else if String(uni) == "-" {
                if !token.isEmpty {
                    tokens.append(token)
                    token = "-"
                }
            }
        }
        if !token.isEmpty {
            tokens.append(token)
        }
        
        tokens = tokens.reverse()
        
        while !tokens.isEmpty {
            let last = tokens.removeLast()
            if last == "M" {
                let x = tokens.removeLast()
                let y = tokens.removeLast()
                let point = CGPoint(x: Double(x)!, y: Double(y)!)
                points.append(point)
                _path.moveToPoint(point)
            } else if last == "c" || last == "C" {
                let c1x = tokens.removeLast()
                let c1y = tokens.removeLast()
                let c2x = tokens.removeLast()
                let c2y = tokens.removeLast()
                let ex = tokens.removeLast()
                let ey = tokens.removeLast()
                
                let c1Point = CGPoint(x: Double(c1x)!, y: Double(c1y)!)
                let c2Point = CGPoint(x: Double(c2x)!, y: Double(c2y)!)
                let endPoint = CGPoint(x: Double(ex)!, y: Double(ey)!)
                if last == "c" {
                    points.append(CGPoint(x: _path.currentPoint.x + endPoint.x, y: _path.currentPoint.y + endPoint.y))
                    _path.addCurveToRelativePoint(endPoint, controlPoint1: c1Point, controlPoint2: c2Point)
                } else {
                    points.append(endPoint)
                    _path.addCurveToPoint(endPoint, controlPoint1: c1Point, controlPoint2: c2Point)
                }
            }
        }
        
        self.points = points
    }
    
}