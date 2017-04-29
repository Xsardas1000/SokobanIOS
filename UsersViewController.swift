//
//  UsersViewController.swift
//  Sokoban
//
//  Created by Максим on 23.12.16.
//  Copyright © 2016 Максим. All rights reserved.
//

import UIKit

class UsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var array: [String] = ["User1", "User2", "User3"]

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addPlayerButton: UIButton!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var newNameLabel: UILabel!
    
    
    @IBOutlet weak var newNameTextField: UITextField!
    @IBAction func addPlayer(_ sender: UIButton) {
        showView(view: blurView)
        //var newPlayerName = "User4"
        //array.append(newPlayerName)
        //tableView.reloadData()
        
    }
    
    func showView(view: UIView) {
        let translate = CGAffineTransform(translationX: 375, y: 0)
        view.transform = translate
        view.isHidden = false
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            let translate = CGAffineTransform(translationX: 0, y: 0)
            view.transform = translate
        })
    }
    
    
    func hideView(view: UIView) {
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            let translate = CGAffineTransform(translationX: 375, y: 0)
            view.transform = translate
        })
    }
    
    
    func addBlurEffect(_ view: UIView, style: UIBlurEffectStyle) {
        
        view.backgroundColor = UIColor.clear
        
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        view.insertSubview(blurEffectView, at: 0)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        blurView.isHidden = true
        
        addBlurEffect(blurView, style: .light)
        
        tableView.tableFooterView = UIView()
        
    }
    
    
    
    
    //MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //только что выделили ячейку == нажали на кнопку
        //некий переход на другой экран
        
        let item = array[indexPath.row]
        
        
        //переход на другой экран по segue
        //self.performSegue(withIdentifier: "menuToItem", sender: item)
        
        //убрать выделение
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    
    
    //MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell") as? MenuItemCell
        //print(indexPath.row)  //номер текущей строчки
        let item = array[indexPath.row]
        
        if cell != nil {
            cell?.userName.text = item
            cell?.numPlayer.text = String(indexPath.row + 1)
            
        } 
        return cell!
    }


}
