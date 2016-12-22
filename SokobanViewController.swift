//
//  SokobanViewController.swift
//  Sokoban
//
//  Created by Максим on 09.10.16.
//  Copyright © 2016 Максим. All rights reserved.
//

import UIKit

class SokobanViewController: UIViewController {

    @IBOutlet weak var labelSteps: UILabel!
    
    @IBOutlet weak var labelUndos: UILabel!
    
    @IBOutlet weak var gesturesView: UIView!
    @IBOutlet weak var winView: UIView!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var blurView: UIView!

    @IBOutlet weak var placeView: UIView!
    
    @IBOutlet weak var buttonUp: UIButton!
    @IBOutlet weak var buttonLeft: UIButton!
    @IBOutlet weak var buttonDown: UIButton!
    @IBOutlet weak var buttonRight: UIButton!
    
    @IBOutlet weak var buttonOptions: UIButton!
    
    @IBOutlet weak var buttonContinue: UIButton!

    @IBOutlet weak var buttonSave: UIButton!
    
    @IBOutlet weak var buttonRestart: UIButton!
    
    @IBOutlet weak var buttonExit: UIButton!
    
    @IBOutlet weak var buttonNextLevel: UIButton!
    
    @IBOutlet weak var buttonUndo: UIButton!

    
    var sokobanGame : Field!
    var sokobanData: SokobanData! //if loaded from saves
    var data: [SokobanData]!
    var storage: Storage!
    var fieldView : UIView!
    var levelNumber : Int!
    var loaded: Bool! = false
    
    
    
    var animator: UIDynamicAnimator!
    var attachmentBehavior: UIAttachmentBehavior!
    var snapBehavior: UISnapBehavior!

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        showGame()
        
        let scale = CGAffineTransform(scaleX: 3, y: 3)
        let translate = CGAffineTransform(translationX: 0, y: 0)
        fieldView.transform = scale.concatenating(translate)
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            let scale = CGAffineTransform(scaleX: 1, y: 1)
            let translate = CGAffineTransform(translationX: 0, y: 0)
            self.fieldView.transform = scale.concatenating(translate)
        })
        print("field animation completed")
        
    }

    
    
    @IBAction func tapRestart(_ sender: UIButton) {
        hideBlurView()
        print("restart level")
        sokobanGame = storage.initialField.copy() as! Field
        storage.deleteStates()
        showGame()

    }
    @IBAction func tapSave(_ sender: UIButton) {
        hideBlurView()
        
        var saves = NSKeyedUnarchiver.unarchiveObject(withFile: SokobanData.getLevelPath(name: "saves")) as? [String]
        
        if saves != nil{
            print("Saves:",saves!)
            
            let saveName = "Save" + String(saves!.count + 1)
            saveLevel(level: SokobanData.makeSokobanData(fromField: sokobanGame, withName: saveName, andView: getFieldView(sokobanGame: sokobanGame)))
            
            saves!.append(saveName)
            let isSuccessfulSave =
                NSKeyedArchiver.archiveRootObject(saves!, toFile: SokobanData.getLevelPath(name: "saves"))
            if isSuccessfulSave == true {
                print("added new saveName")
            }

        } else {
            let isInitializedSaves =
                NSKeyedArchiver.archiveRootObject([], toFile: SokobanData.getLevelPath(name: "saves"))
            if isInitializedSaves == true {
                print("saves initialized")
            }
        }
        
    }

    @IBAction func tapContinue(_ sender: UIButton) {
        
        hideBlurView()

        print("tapped to continue playing")
    }
    
    @IBAction func tapExit(_ sender: UIButton) {
        print("tapped Exit")
    }
    
    @IBAction func tapNextLevel(_ sender: UIButton) {
        levelNumber = (levelNumber + 1) % data.count
        sokobanGame = Field(data: data[levelNumber].makeDictionary())
        storage = Storage(field: sokobanGame.copy() as! Field)
        winView.isHidden = true
        print("showing level number \(levelNumber)")
        showGame()

    }
    
    @IBAction func tapUndo(_ sender: UIButton) {
        print("tapped undo")
        if let previousState = storage.popField() {
            if previousState.player == sokobanGame.player {
                if let beforeState = storage.popField() {
                    sokobanGame = beforeState
                }
            } else {
                sokobanGame = previousState
            }
        }
        showGame()
    }
    
    
    func showBlurView() {
        let translate = CGAffineTransform(translationX: 375, y: 0)
        self.blurView.transform = translate
        self.blurView.isHidden = false

        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            let translate = CGAffineTransform(translationX: 0, y: 0)
            self.blurView.transform = translate
        })
    }
    
    
    func hideBlurView() {

        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            let translate = CGAffineTransform(translationX: 375, y: 0)
            self.blurView.transform = translate
        })
    }
    
    @IBAction func tapOptions(_ sender: UIButton) {
        
        showBlurView()
        
        
        /*let blurView = UIView(frame: self.mainView.frame)
        addBlurEffect(blurView, style: .light)
        mainView.addSubview(blurView)
        
        
        let buttonSave = UIButton(frame: CGRect(x: 56, y: 533, width: 263, height: 56))
        let buttonExit = UIButton(frame: CGRect(x: 56, y: 589, width: 263, height: 56))
        
        let textFont = UIFont(name: "Avenir Light", size: 24)!
        let textColor = UIColor.black
        
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
            
            ] as [String : Any]
        
        buttonSave.setAttributedTitle(NSAttributedString(string: "Save", attributes: textFontAttributes),
                                                            for: .normal)
        buttonSave.setBackgroundImage(UIImage(named: "button-options-save-view.png"), for: .normal)
        blurView.addSubview(buttonSave)
        
        
        buttonExit.setAttributedTitle(NSAttributedString(string: "Save", attributes: textFontAttributes),
                                      for: .normal)
        buttonExit.setBackgroundImage(UIImage(named: "button-options-save-exit.png"), for: .normal)
        blurView.addSubview(buttonExit)
        */
        
    }
    
    func addBlurEffect(_ view: UIView, style: UIBlurEffectStyle) {
        
        view.backgroundColor = UIColor.clear
        
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        view.insertSubview(blurEffectView, at: 0)
    }
    
    
    
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
    
    func showGame() {
        labelSteps.text = "Steps: " + String(sokobanGame.steps)
        labelUndos.text = "Undos: " + String(storage.undos)
        if fieldView != nil {
            for view in fieldView.subviews {
                view.removeFromSuperview()
            }
            fieldView.removeFromSuperview()
        }
        
        fieldView = getFieldView(sokobanGame: sokobanGame)
        placeView.addSubview(fieldView)

        fieldView.center = CGPoint(x: CGFloat(placeView.frame.size.width) / 2,
                                   y: CGFloat(placeView.frame.size.height) / 2)
        
        if sokobanGame.checkWin() == true {
            winView.isHidden = false
            print("win")
        }
        
    }
    
    func handleSwipe(recognizer: UISwipeGestureRecognizer) {
        var direction: Direction?
        
        //запоминаем
        storage.pushField(field: sokobanGame)

        switch recognizer.direction {
        case UISwipeGestureRecognizerDirection.up:
            print("up")
            direction = Direction.Up

        case UISwipeGestureRecognizerDirection.down:
            print("down")
            direction = Direction.Down

        case UISwipeGestureRecognizerDirection.left:
            print("left")
            direction = Direction.Left

        case UISwipeGestureRecognizerDirection.right:
            print("right")
            direction = Direction.Right

        default:
            print("unknown")
        }
        if direction != nil {
            sokobanGame.movePlayerWithDirection(direction: direction!)
        }
        showGame()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if loaded == false {
            sokobanGame = Field(data: data[levelNumber].makeDictionary())
            storage = Storage(field: sokobanGame.copy() as! Field)
        } else {
            sokobanGame = Field(data: sokobanData.makeDictionary())
            storage = Storage(field: sokobanGame.copy() as! Field)
        }

        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe))
        swipeUp.direction = .up
        gesturesView.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe))
        swipeDown.direction = .down
        gesturesView.addGestureRecognizer(swipeDown)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe))
        swipeLeft.direction = .left
        gesturesView.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe))
        swipeRight.direction = .right
        gesturesView.addGestureRecognizer(swipeRight)

        gesturesView.isUserInteractionEnabled = true

        addBlurEffect(blurView, style: .light)
        addBlurEffect(winView, style: .light)
        winView.isHidden = true
        blurView.isHidden = true
        //showGame()
    }
    
    
    // Do any additional setup after loading the view.
        //вызывается каждый раз перед показом
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: NSCoding
    func saveLevel(level: SokobanData) {
        
        print(SokobanData.getLevelPath(name: level.name))
        let isSuccessfulSave =
            NSKeyedArchiver.archiveRootObject(level, toFile: SokobanData.getLevelPath(name: level.name))
        
        if !isSuccessfulSave {
            print("Failed to save levels...")
        } else {
            print("Saved level - \(level.name)")
        }
    }
}
