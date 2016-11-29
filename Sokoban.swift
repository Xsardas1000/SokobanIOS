//
//  Sokoban.swift
//  Sokoban
//
//  Created by Максим on 09.10.16.
//  Copyright © 2016 Максим. All rights reserved.
//

import Foundation
import UIKit

struct Coord : Equatable {
    var i : Int
    var j : Int

    
    static func == (lhs: Coord, rhs: Coord) -> Bool {
        return (lhs.i == rhs.i) && (lhs.j == rhs.j) ? true : false
    }
    
    init() {
        i = 0
        j = 0
    }
    
    init(_ i: Int, _ j : Int) {
        self.i = i
        self.j = j
    }
}

class Cell: NSObject, NSCopying {
    
    static let size : Int = Field.elementSize
    var type : CellType = CellType()
    
    func copy(with zone: NSZone? = nil) ->  Any {
        let copy  = Cell(type: type)
        return copy
    }
    static func makeView(type: CellType, coord: Coord) -> UIImageView {
        let view = UIImageView(frame: CGRect(x: coord.j * size, y: coord.i * size, width: size, height: size))
        view.image = type.cellImage
        return view

    }
    
    init(type: CellType = CellType()) {
        self.type = type
    }
    
}

enum CellType : String {
    
    case Ground = "Ground"
    case Box = "Box"
    case Player = "Player"
    case Target = "Target"
    case Wall = "Wall"
    case Undefined = "Undefined"

    init() {
        self = .Undefined
    }
    
    var cellImage : UIImage {
        switch self {
        case .Ground:
            return UIImage(named: "ground.png")!
        case .Wall:
            return UIImage(named: "wall.png")!
        case .Target:
            return UIImage(named: "target.png")!
        case .Box:
            return UIImage(named: "box.png")!
        case .Player:
            return UIImage(named: "player.png")!
        default:
            return UIImage()
        }
    }
}

enum Direction : String {
    case Left = "Left"
    case Right = "Right"
    case Up = "Up"
    case Down = "Down"
}


func printCharacters(str: String) {
    for index in str.characters.indices {
        print("\(str[index]) ", terminator: "")
    }
}

func containsArray<T: Equatable>(array: [T], element: T)  -> Bool {
    for item in array {
        if item == element {
            return true
        }
    }
    return false
}

func intersectArrays<T: Equatable>(array1: [T], array2: [T]) -> [T] {
    var array : [T] = []
    for elem in array1 {
        if containsArray(array: array2, element: elem) {
            array.append(elem);
        }
    }
    return array
}



class Field : NSObject, NSCopying{
    
    var player: Coord = Coord()
    var targets = [Coord]()
    var numberOfActiveTargets : Int = 0
    var numberOfboxes : Int = 0
    var cells = Array<Array<Cell>>()
    var width : Int = 0
    var height : Int = 0
    var steps: Int = 0

    
    static let maxSize = 17
    static let elementSize = 20
    
    
    
    func checkInit() -> Bool {
        return self.targets.count == self.numberOfboxes
    }
    
    func checkWin() -> Bool {
        return self.numberOfActiveTargets == 0
    }
    
    
    func copy(with zone: NSZone? = nil) ->  Any {
        var cellsCopies = Array<Array<Cell>>()
        for _ in 0 ..< height {
            cellsCopies.append(Array(repeating:Cell(), count:width))
        }
        for i in 0 ..< height {
            for j in 0 ..< width {
                cellsCopies[i][j] = cells[i][j].copy() as! Cell
            }
        }
        let copy = Field(player: player,
                         targets: targets,
                         numberOfActiveTargets: numberOfActiveTargets,
                         numberOfboxes: numberOfboxes,
                         cells: cellsCopies,
                         width: width,
                         height: height,
                         steps: steps)
        return copy
    }
    
    
    init(player: Coord, targets: [Coord], numberOfActiveTargets: Int, numberOfboxes: Int,
         cells: Array<Array<Cell>>, width: Int, height: Int, steps: Int) {
        
        self.player = player
        self.targets = targets
        self.numberOfActiveTargets = numberOfActiveTargets
        self.numberOfboxes = numberOfboxes
        self.cells = cells
        self.width = width
        self.height = height
        self.steps = steps
        
    }
    
    init(data: [String: [(Int, Int)]]) {
        
        var h : Int = 0
        var w : Int = 0
        
        if let playerCoord = data["size"]?[0] {
            self.width = playerCoord.1
            self.height = playerCoord.0
            
            w = playerCoord.1
            h = playerCoord.0
        }
        
        for _ in 0 ..< h {
            cells.append(Array(repeating:Cell(), count:w))
        }
        
        
        for i in 0 ..< h {
            for j in 0 ..< w {
                var type = CellType.Ground
                if i * j == 0 || i == h - 1 || j == w - 1 {
                    type = .Wall
                }
                cells[i][j] =
                    Cell(type: type)
            }
        }
        
        if let playerCoord = data["player"]?[0] {
            self.player = Coord(playerCoord.0, playerCoord.1)
        }
        
        if let wallCoords = data["walls"] {
            for (i, j) in wallCoords {
                cells[i][j] =  Cell(type: CellType.Wall)
            }
        }
        
        if let boxCoords = data["boxes"] {
            for (i, j) in boxCoords {
                cells[i][j] =  Cell(type: CellType.Box)
            }
            self.numberOfboxes = boxCoords.count
        }
        
        if let targetCoords = data["targets"] {
            for (i, j) in targetCoords {
                self.targets.append(Coord(i,j))
            }
            
            var targets : [Coord] = []
            for elem in targetCoords {
                targets.append(Coord(elem.0, elem.1))
            }
            
            var boxes : [Coord] = []
            let boxCoords = data["boxes"]!
            for elem in boxCoords {
                boxes.append(Coord(elem.0, elem.1))
            }
            
            let amount = intersectArrays(array1: boxes, array2: targets).count
            self.numberOfActiveTargets = targets.count - amount
        }
        
    }
    
    func getCellViews() -> [UIImageView] {
        var cellViews : [UIImageView] = []

        for i in 0..<height {
            for j in 0..<width {
                if (self.player == Coord(i,j)) {
                    cellViews.append(Cell.makeView(type: .Player, coord: Coord(i,j)))
                    
                } else if (containsArray(array: self.targets, element: Coord(i,j)) &&
                    (self.cells[i][j].type == .Ground)) {
                    cellViews.append(Cell.makeView(type: .Target, coord: Coord(i,j)))
                    
                } else {
                    cellViews.append(Cell.makeView(type: cells[i][j].type, coord: Coord(i,j)))
                }
            }
        }
        return cellViews
    }
    
    
        
    func checkMove(oldCoord: Coord, newCoord: Coord, followCoord: Coord)// -> [(Int, UIImageView)]? {
    {
        
        switch cells[newCoord.i][newCoord.j].type {
        case .Ground:
            self.player = newCoord
            cells[oldCoord.i][oldCoord.j].type = CellType.Ground
            //cells[newCoord.i][newCoord.j].type = CellType.Player
            
        case .Box:
            if cells[followCoord.i][followCoord.j].type == .Ground {
                
                self.player = newCoord
                cells[oldCoord.i][oldCoord.j].type = CellType.Ground
                cells[followCoord.i][followCoord.j].type = CellType.Box

                
                
                if containsArray(array: self.targets, element: followCoord) {
                    self.numberOfActiveTargets -= 1
                }
                if containsArray(array: self.targets, element: newCoord) {
                    self.numberOfActiveTargets += 1
                }
            }
            
            
        default:
            break
        }
        if self.player != oldCoord {
            self.steps += 1
        }
        
    }
    
    func movePlayerWithDirection(direction : Direction) //-> [(Int, UIImageView)]? {
    {
        let i = self.player.i
        let j = self.player.j
        
        switch direction {
        case .Left:
            checkMove(oldCoord: Coord(i,j), newCoord: Coord(i,j-1), followCoord: Coord(i,j-2))
        case .Right:
            checkMove(oldCoord: Coord(i,j), newCoord: Coord(i,j+1), followCoord: Coord(i,j+2))
        case .Up:
            checkMove(oldCoord: Coord(i,j), newCoord: Coord(i-1,j), followCoord: Coord(i-2,j))
        case .Down:
            checkMove(oldCoord: Coord(i,j), newCoord: Coord(i+1,j), followCoord: Coord(i+2,j))
        }
        
    }
}


class Storage {
    var initialField: Field
    
    var savedSteps : [Field] = []
   
    var stackSize = 40 //possible number of saved steps
    var undos = 10
    
    func pushField(field: Field) {
        if !isChanged(field: field) {
            return
        }
        if savedSteps.count >= stackSize {
            savedSteps.removeFirst()
        }
        savedSteps.append(field.copy() as! Field)
    }
    
    func popField() -> Field? {
        if undos > 0 && savedSteps.count > 0 {
            self.undos -= 1
            let field = savedSteps.last
            savedSteps.removeLast()
            return field
        }
        return nil
    }
    
    func isChanged(field: Field) -> Bool {
        if self.savedSteps.count == 0 {
            return true
        } else {
            return self.savedSteps.last?.player != field.player
        }
    }
    
    func deleteStates() {
        savedSteps.removeAll()
        pushField(field: initialField.copy() as! Field)
        self.stackSize = initialField.targets.count * 2
        self.undos = initialField.targets.count * 2

    }

    
    init(field: Field) {
        self.initialField = field.copy() as! Field
        self.stackSize = field.targets.count * 2
        self.undos = field.targets.count * 2
        pushField(field: field)
        print("storage initializes")
        print(initialField.numberOfActiveTargets)
    }
}

