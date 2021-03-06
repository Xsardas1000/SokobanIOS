//
//  SavesViewController.swift
//  Sokoban
//
//  Created by Максим on 08.11.16.
//  Copyright © 2016 Максим. All rights reserved.
//

import UIKit

class SavesViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var loadButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var hintTextField: UITextField!
    
    var savedLevels: [SokobanData]! = []
    var levels: [SokobanData]!
    var currentIndex: Int! = 0
    
    @IBAction func tapLoad(_ sender: UIButton) {
        
        if savedLevels.count > currentIndex {
            self.performSegue(withIdentifier: "savesToGame", sender: self)
        }
    }
    
    @IBAction func tapDelete(_ sender: UIButton) {
        
        if savedLevels.count > 0 {
            print("Current index = \(currentIndex)")
            scrollView.subviews[currentIndex*2].removeFromSuperview()
            scrollView.subviews[currentIndex*2].removeFromSuperview()
            
            savedLevels.remove(at: currentIndex)
            
            //сдвигает все следущие views влево на страницу
            for (i, view) in scrollView.subviews.enumerated() {
                if i >= currentIndex*2 {
                    view.center.x = view.center.x - scrollView.bounds.width
                }
            }
            scrollView.contentSize = CGSize(width: CGFloat(savedLevels.count)*scrollView.bounds.width,
                                            height: scrollView.bounds.height)

            var saves = NSKeyedUnarchiver.unarchiveObject(withFile: SokobanData.getLevelPath(name: "saves")) as? [String]
            
            if saves != nil {
                if saves!.count > currentIndex {
                    saves!.remove(at: currentIndex)
                    let isSuccessfulSave =
                        NSKeyedArchiver.archiveRootObject(saves!, toFile: SokobanData.getLevelPath(name: "saves"))
                    if isSuccessfulSave == true {
                        print("deleted save")
                    }
                }
            }
        }
    }
    
    func updateScrollView(levels: [SokobanData]) {
        if levels.count == 0 {
            return
        }
        for (i, level) in savedLevels.enumerated() {
            let view = UIImageView()
            view.frame = CGRect(x: CGFloat(i) * scrollView.bounds.width + 17,
                                y: 0,
                                width: 341,
                                height: 389)
            view.image = UIImage(named: "scroll-view.png")!
            //view.image = textToImage(drawText: text, inImage: view.image!, atPoint: CGPoint(x: 10, y: 10))
            scrollView.addSubview(view)
            scrollView.addSubview(level.levelView)
            level.levelView.center = view.center
            
            scrollView.delegate = self
            
        }
        scrollView.contentSize = CGSize(width: CGFloat(savedLevels.count)*scrollView.bounds.width,
                                        height: scrollView.bounds.height)
        
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let levelNames = ["level_1", "level_2", "level_3"]
        levels = []
        for name in levelNames {
            if let level = loadLevel(name: name) {
                print("level \(name) loaded")
                levels.append(level)
            }
        }

        let saves = NSKeyedUnarchiver.unarchiveObject(withFile: SokobanData.getLevelPath(name: "saves")) as? [String]

        if saves != nil {
            print("Saves:", saves!)
            for saveName in saves! {
                if let level = loadLevel(name: saveName) {
                    print("level \(saveName) loaded")
                    savedLevels.append(level)
                }
 
            }
        }
        
        updateScrollView(levels: savedLevels)
    }
    
    
    // MARK: NSCoding
    
    func loadLevel(name: String) -> SokobanData? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: SokobanData.getLevelPath(name: name)) as? SokobanData
    }
    
    //MARK: UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //find the page number you are on
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1)
        currentIndex = page
        if currentIndex > 0 {
            hintTextField.isHidden = true
        } else {
            hintTextField.isHidden = false
        }
        
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "savesToGame" {
            print(segue.identifier!)
            print("index:",currentIndex)
            print("sending saved level with name \(savedLevels[currentIndex].name)")
            if let destinationViewController = segue.destination as? SokobanViewController {
                destinationViewController.data = levels
                destinationViewController.loaded = true
                destinationViewController.sokobanData = savedLevels[currentIndex]
                destinationViewController.levelNumber = currentIndex
            }
        }
    }
}
