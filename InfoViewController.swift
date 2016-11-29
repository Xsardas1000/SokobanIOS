//
//  InfoViewController.swift
//  Sokoban
//
//  Created by Максим on 26.10.16.
//  Copyright © 2016 Максим. All rights reserved.
//

import UIKit
import Foundation

class InfoViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var levels: [SokobanData]! = []
    var currentIndex: Int! = 0
    
    func getFieldView(sokobanGame: Field) -> UIView {
        let cellViews = sokobanGame.getCellViews()
        
        
        let fieldRect = CGRect(x: 0,
                               y: 0,
                               width: CGFloat(sokobanGame.width * Field.elementSize),
                               height: CGFloat(sokobanGame.height * Field.elementSize))
        
        let view = UIView(frame: fieldRect)
        
        for cellView in cellViews {
            view.addSubview(cellView)
        }
        view.backgroundColor = UIColor(red: 252.0/255.0, green: 233.0/255, blue: 169.0/255, alpha: 1)
        
        return view
        
    }
    
    func loadLevelNames() -> [String]? {
        let levels = NSKeyedUnarchiver.unarchiveObject(withFile: SokobanData.getLevelPath(name: "levels")) as? [String]
        if levels != nil{
            print("Levels:",levels!)
            return levels!
            
        } else {
            let isInitializedLevels =
                NSKeyedArchiver.archiveRootObject([], toFile: SokobanData.getLevelPath(name: "levels"))
            if isInitializedLevels == true {
                print("levels initialized")
            }
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var levelViews : [UIView] = []

        var levelNames = loadLevelNames()
        if levelNames == nil {
            print("no levels")
            saveNewLevel(data: level1, withName: "level_1")
            saveNewLevel(data: level2, withName: "level_2")
            saveNewLevel(data: level3, withName: "level_3")
            saveNewLevel(data: level4, withName: "level_4")
            print("levels loaded")
            levelNames = loadLevelNames()
        }
        
        for name in levelNames! {
            if let level = loadLevel(name: name) {
                print("level \(name) loaded")
                levelViews.append(level.levelView)
                levels.append(level)
            }
        }
        
        for (i, levelView) in levelViews.enumerated() {
            let view = UIImageView()
            view.frame = CGRect(x: CGFloat(i) * scrollView.bounds.width + 17,
                                y: 0,
                                width: 341,
                                height: 389)
            view.image = UIImage(named: "scroll-view.png")!
            //view.image = textToImage(drawText: text, inImage: view.image!, atPoint: CGPoint(x: 10, y: 10))
            scrollView.addSubview(view)
            scrollView.addSubview(levelView)
            levelView.center = view.center
            
            scrollView.delegate = self

        }
        scrollView.contentSize = CGSize(width: CGFloat(levelViews.count)*scrollView.bounds.width,
                                        height: scrollView.bounds.height)
        
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false

        
    }
    
    //MARK: UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //find the page number you are on
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1)
        currentIndex = page
    
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if playButton === sender as? UIButton {
            print(segue.identifier!)
            print("index:",currentIndex)
            print("sending level with name \(levels[currentIndex].name)")
            if let destinationViewController = segue.destination as? SokobanViewController {
                destinationViewController.data = levels
                destinationViewController.levelNumber = currentIndex
            }
        }
    }
    
    
    // MARK: NSCoding
    
    func loadLevel(name: String) -> SokobanData? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: SokobanData.getLevelPath(name: name)) as? SokobanData
    }
    
    func saveLevel(level: SokobanData) {
        
        print(SokobanData.getLevelPath(name: level.name))
        let isSuccessfulSave =
            NSKeyedArchiver.archiveRootObject(level, toFile: SokobanData.getLevelPath(name: level.name))
        
        if !isSuccessfulSave {
            print("Failed to save levels...")
        } else {
            print("Saved level - \(level.name)")
            
        }
        
        //adding to  level names list
        var levels = NSKeyedUnarchiver.unarchiveObject(withFile: SokobanData.getLevelPath(name: "levels")) as? [String]
        if levels != nil{
            levels!.append(level.name)
            let isSuccessfulSave =
                NSKeyedArchiver.archiveRootObject(levels!, toFile: SokobanData.getLevelPath(name: "levels"))
            if isSuccessfulSave == true {
                print("added new level to level names file")
            }
        } else {
            let isInitializedLevels =
                NSKeyedArchiver.archiveRootObject([level.name], toFile: SokobanData.getLevelPath(name: "levels"))
            if isInitializedLevels == true {
                print("levels initialized with new level")
            }
        }

    }
    
    
    func saveNewLevel(data: [String: [(Int,Int)]], withName name:String) {
        let sokobanGame = Field(data: data)
        if let sokobanData =
            SokobanData(levelView: getFieldView(sokobanGame: sokobanGame),
                        name: name,
                        walls: SokobanData.tuplesToArray(coords: data["walls"]!),
                        boxes: SokobanData.tuplesToArray(coords: data["boxes"]!),
                        targets: SokobanData.tuplesToArray(coords: data["targets"]!),
                        player: SokobanData.tuplesToArray(coords: data["player"]!),
                        size: SokobanData.tuplesToArray(coords: data["size"]!))
        {
            saveLevel(level: sokobanData)
        }
    }
    
    
    func textToImage(drawText: String, inImage: UIImage, atPoint: CGPoint) -> UIImage{
        
        // Setup the font specific variables
        let textColor = UIColor.white
        let textFont = UIFont(name: "Avenir Light", size: 24)!
        
        // Setup the image context using the passed image
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(inImage.size, false, scale)
        
        // Setup the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
            ] as [String : Any]
        
        // Put the image into a rectangle as large as the original image
        inImage.draw(in: CGRect(x: 0, y: 0, width: inImage.size.width, height: inImage.size.width))
        
        // Create a point within the space that is as bit as the image
        let rect =
            CGRect(x: atPoint.x, y: atPoint.x, width: inImage.size.width, height: inImage.size.height)
        
        // Draw the text into an image
        drawText.draw(in: rect, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //Pass the image back up to the caller
        return newImage!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    let level1 : [String: [(Int, Int)]] = ["walls": [(1,2), (0,6), (1,6), (2,6), (3,6), (4,6), (5,6),
                                                     (3,1), (3,2), (4,2), (4,3), (5,2)],
                                           "boxes": [(2,4), (3,4), (4,4), (6,1), (6,3), (6,4), (6,5)],
                                           
                                           "targets": [(2,1), (3,5), (4,1), (5,4), (6,6), (7,4), (6,3)],
                                           
                                           "player": [(2,3)],
                                           "size" : [(9,8)]
    ]
    
    let level2 : [String: [(Int, Int)]] = ["walls": [(1,11),(1,12),(1,5),(2,5),(3,5),(5,5),(3,7),(3,8),(3,9),(3,10), (4,9), (4,10), (5,12), (6,1), (6,2), (6,3), (6,4), (6,5), (6,7), (6,8), (7,1), (7,2),
                                                     (8,1),(8,2),(9,1),(8,7),(5,7)],
                                           "boxes": [(2,7),(2,10),(3,6),(5,10),(6,9),(6,11),(7,9),(7,11),(7,7),(7,4)],
                                           
                                           "targets": [(1,1),(1,2),(2,1),(2,2),(3,1),(3,2),(4,1),(4,2),(5,1),(5,2)],
                                           
                                           "player": [(4,7)],
                                           "size" : [(10,14)]
    ]
    
    let level3: [String: [(Int, Int)]] = ["walls": [(1,1), (1,5), (1,6), (1,7), (1,8), (1,9),
                                                    (2,1),(2,3),(2,7),(2,8),(2,9),(3,5),(5,5),(6,1),(6,2),(6,3),(6,7),(6,8),(6,9)],
                                          "boxes": [(2,2),(2,4),(2,5),(3,8),(4,3),(5,2)],
                                          
                                          "targets": [(3,4),(3,6),(4,4),(4,6),(5,4),(5,6)],
                                          
                                          "player": [(1,3)],
                                          "size" : [(8,11)]
    ]
    
    let level4: [String: [(Int, Int)]] = ["walls": [(1,6), (3,3), (3,5), (4,1), (4,2), (4,3), (4,5), (4,6),(4,7),(5,3),(5,7),(6,7),(7,3),(7,4),(7,6),(7,7),(8,1),(8,3),(8,4),(8,7),(9,7),(10,4),(10,7),(11,1),(11,2),(11,4),(11,5),(11,6),(11,7),(12,1),(12,2),(12,4)],
                                          "boxes": [(2,3),(2,6),(2,7),(6,2),(6,5),(9,2),(9,5),(13,3),(13,6),(13,7)],
                                          
                                          "targets": [(4,8),(5,8),(6,8),(7,8),(8,8),(9,8),(10,8),(11,8),(7,5),(8,2)],
                                          
                                          "player": [(12,7)],
                                          "size" : [(16,10)]
    ]
}
