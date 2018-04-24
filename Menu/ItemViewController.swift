//
//  ItemViewController.swift
//  Menu
//
//  Created by Illya Gordiyenko on 2018-04-23.
//  Copyright © 2018 Illya Gordiyenko. All rights reserved.
//

import UIKit

class ItemViewController: UIViewController {
    
    var menuManager:MenuManager!
    var currentItem:Item!

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var detailsField: UITextField!
    @IBOutlet weak var imagePathField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameField.text = currentItem.name
        imagePathField.text = currentItem.imagePath
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
