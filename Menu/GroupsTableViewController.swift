//
//  GroupsTableViewController.swift
//  Menu
//
//  Created by Illya Gordiyenko on 2018-04-23.
//  Copyright © 2018 Illya Gordiyenko. All rights reserved.
//

import UIKit

let groupCellIdentifier = "groupCell"

class GroupsTableViewController: UITableViewController {

    var menuManager:MenuManager!
    var groups:[Group] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuManager = MenuManager.init()
        self.reload()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func reload() {
        groups = menuManager.fetchGroups()
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return groups.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: groupCellIdentifier, for: indexPath)
        
        let group = groups[indexPath.row]
        cell.textLabel?.text = group.name
        cell.detailTextLabel?.text = group.imagePath

        return cell
    }
    
    // MARK: - Buttons
    @IBAction func addButton(_ sender: UIBarButtonItem) {
        
        _ = menuManager.insertGroup(name: "Test Group", imagePath: "Test path")
        menuManager.save()
        
        self.reload()
        
    }
    @IBAction func removeButton(_ sender: UIBarButtonItem) {
        
        if (groups.count > 0) {
            let group = groups[0]
            
            menuManager.remove(objectID: group.objectID)
            menuManager.save()
            self.reload()
        }
        
        
    }
    
}
