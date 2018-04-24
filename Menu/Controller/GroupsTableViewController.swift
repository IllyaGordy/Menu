//
//  GroupsTableViewController.swift
//  Menu
//
//  Created by Illya Gordiyenko on 2018-04-23.
//  Copyright © 2018 Illya Gordiyenko. All rights reserved.
//

import UIKit

private let groupCellIdentifier = "groupCell"
private let groupDetailSegue = "groupDetailSegue"

class GroupsTableViewController: UITableViewController {

    var menuManager:MenuManager!
    var groups:[Group] = []
    var groupToPass:Group?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuManager = MenuManager.init()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.reload()
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
        return groups.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: groupCellIdentifier, for: indexPath)
        
        let group = groups[indexPath.row]
        cell.textLabel?.text = group.name
        cell.detailTextLabel?.text = group.imagePath

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.groupToPass = groups[indexPath.row]
        performSegue(withIdentifier: groupDetailSegue, sender: self)
    }
    
    // MARK: - Transitions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == groupDetailSegue {
            if let groupVC = segue.destination as? GroupViewController {
                groupVC.menuManager = self.menuManager
                groupVC.currentGroup = self.groupToPass
            }
        }
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
