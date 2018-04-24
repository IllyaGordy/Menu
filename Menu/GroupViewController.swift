//
//  GroupViewController.swift
//  Menu
//
//  Created by Illya Gordiyenko on 2018-04-23.
//  Copyright © 2018 Illya Gordiyenko. All rights reserved.
//

import UIKit

private let itemCellIdentifier = "itemCellIdentifier"
private let itemDetailSegue = "itemDetailSegue"

class GroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var menuManager:MenuManager!
    var items:[Item] = []
    var itemToPass:Item?
    
    var currentGroup:Group!
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var imagePathField: UITextField!
    
    
    @IBOutlet weak var itemsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemsTableView.delegate = self
        itemsTableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.reload()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reload() {
        nameField.text = currentGroup.name
        imagePathField.text = currentGroup.imagePath
        
        items = menuManager.fetchItems(from: currentGroup)
        self.itemsTableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: itemCellIdentifier, for: indexPath)
        
        let item = items[indexPath.row]
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = item.imagePath
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.itemToPass = items[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: itemDetailSegue, sender: self)
    }
    
    // MARK: - Transitions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == itemDetailSegue {
            if let itemVC = segue.destination as? ItemViewController {
                itemVC.menuManager = self.menuManager
                itemVC.currentItem = self.itemToPass
            }
        }
    }
    
    // MARK: - Buttons
    
    @IBAction func updateGroup(_ sender: UIButton) {
        
        currentGroup = menuManager.updateGroup(group: currentGroup,
                                               name: nameField.text,
                                               imagePath: imagePathField.text)
        menuManager.save()
        
        self.reload()
    }
    
    @IBAction func deleteGroup(_ sender: UIButton) {
        
        menuManager.remove(objectID: currentGroup.objectID)
        menuManager.save()
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addItem(_ sender: UIButton) {
        
        _ = menuManager.insertItem(into: currentGroup!,
                                   name: "Test Item",
                                   detail: "Test Detail",
                                   imagePath: "Test imagePath",
                                   price: 10.1111)
        menuManager.save()
        
        self.reload()
        
    }
    
    @IBAction func removeItem(_ sender: UIButton) {
        
        if (items.count > 0) {
            let item = items[0]
            
            menuManager.remove(objectID: item.objectID)
            menuManager.save()
            self.reload()
        }
        
    }
    
}
