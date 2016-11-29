//
//  Data.swift
//  Sokoban
//
//  Created by Максим on 02.11.16.
//  Copyright © 2016 Максим. All rights reserved.
//

import Foundation
import UIKit

class SokobanData : NSObject, NSCoding {

    
    var name : String!
    var levelView : UIView!
    
    var walls : [Int]!
    var boxes : [Int]!
    var targets : [Int]!
    var player : [Int]!
    var size : [Int]!
    
    required convenience init?(coder aDecoder: NSCoder) {
        let levelView = aDecoder.decodeObject(forKey: PropertyKeys.levelViewKey)
            as? UIView
        let name = aDecoder.decodeObject(forKey: PropertyKeys.nameKey)
            as? String
        let walls = aDecoder.decodeObject(forKey: PropertyKeys.wallsKey)
            as? [Int]
        let boxes = aDecoder.decodeObject(forKey: PropertyKeys.boxesKey)
            as? [Int]
        let targets = aDecoder.decodeObject(forKey: PropertyKeys.targetsKey)
            as? [Int]
        let player = aDecoder.decodeObject(forKey: PropertyKeys.playerKey)
            as? [Int]
        let size = aDecoder.decodeObject(forKey: PropertyKeys.sizeKey)
            as? [Int]
        
        self.init(levelView: levelView!, name: name!, walls: walls!, boxes: boxes!, targets: targets!, player: player!, size: size!)
    }
    
    
    init?(levelView: UIView, name: String, walls: [Int], boxes: [Int], targets: [Int], player: [Int], size: [Int]) {
        // Initialize stored properties.
        self.levelView = levelView
        self.name = name
        self.walls = walls
        self.boxes = boxes
        self.targets = targets
        self.player = player
        self.size = size
        
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        print("encode with aCoder...")
        if (levelView != nil) {
            aCoder.encode(levelView, forKey: PropertyKeys.levelViewKey)
        }
        if (name != nil) {
            aCoder.encode(name, forKey: PropertyKeys.nameKey)
        }
        if (walls != nil) {
            aCoder.encode(walls, forKey: PropertyKeys.wallsKey)
        }
        if (boxes != nil) {
            aCoder.encode(boxes, forKey: PropertyKeys.boxesKey)
        }
        if (targets != nil) {
            aCoder.encode(targets, forKey: PropertyKeys.targetsKey)
        }
        if (player != nil) {
            aCoder.encode(player, forKey: PropertyKeys.playerKey)
        }
        if (size != nil) {
            aCoder.encode(size, forKey: PropertyKeys.sizeKey)
        }

    }
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    
    
    static func getLevelPath(name: String) -> String {
        return DocumentsDirectory.appendingPathComponent(name).path
    }
    

    static func tuplesToArray(coords: [(Int, Int)]) -> [Int] {
        var arr : [Int] = []
        for coord in coords {
            arr.append(coord.0)
            arr.append(coord.1)
        }
        return arr
    }
    
    static func arrayToTuples(arr: [Int]) -> [(Int, Int)] {
        var coords : [(Int, Int)] = []
        for i in 0..<arr.count {
            if (i % 2 == 0) {
                coords.append((arr[i], arr[i + 1]))
            }
        }
        return coords
    }
    
    func makeDictionary() -> [String: [(Int, Int)]] {
        return ["walls": SokobanData.arrayToTuples(arr: self.walls),
                "boxes": SokobanData.arrayToTuples(arr: self.boxes),
                "targets": SokobanData.arrayToTuples(arr: self.targets),
                "player": SokobanData.arrayToTuples(arr: self.player),
                "size": SokobanData.arrayToTuples(arr: self.size)]
    }
    
    static func makeSokobanData(fromField field: Field, withName name: String, andView view: UIView) -> SokobanData {
        var walls: [Int] = []
        var boxes: [Int] = []
        var targets: [Int] = []
        let player: [Int] = [field.player.i, field.player.j]
        let size: [Int] = [field.height, field.width]
        
        for i in 0..<field.height {
            for j in 0..<field.width {
                switch field.cells[i][j].type {
                case .Wall:
                    walls.append(i)
                    walls.append(j)
                case .Box:
                    boxes.append(i)
                    boxes.append(j)
                default: break
                   
                }
            }
        }
        for coord in field.targets {
            targets.append(coord.i)
            targets.append(coord.j)
        }
        
        let sokobanData = SokobanData(levelView: view, name: name, walls: walls, boxes: boxes, targets: targets, player: player, size: size)
        
        return sokobanData!
    }
    
}

struct PropertyKeys {
    static let levelViewKey = "levelView"
    static let nameKey = "name"
    static let wallsKey = "walls"
    static let boxesKey = "boxes"
    static let targetsKey = "targets"
    static let playerKey = "player"
    static let sizeKey = "size"
}

