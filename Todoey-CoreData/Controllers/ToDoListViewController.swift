//
//  ViewController.swift
//  Todoey-CoreData
//
//  Created by Kenny Loh on 10/6/19.
//  Copyright © 2019 ProApp Concept Pte Ltd. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    
    //MARK: Local global variables
    // FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask
    var filePath: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    var context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var itemArray: [ToDoItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("\(filePath)")
        
        self.LoadingData()
    }
    
    //MARK: Tableview datasource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item: ToDoItem = itemArray[indexPath.row]
        
        // UITableViewCell.AccessoryType.checkmark, UITableViewCell.AccessoryType.none
        cell.textLabel?.text = item.title
        cell.accessoryType = item.completed ? .checkmark : .none
        
        return cell
    }
    
    //MARK: Tableview delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: UITableViewCell = tableView.cellForRow(at: indexPath)!
        let item: ToDoItem = itemArray[indexPath.row]
        
        item.completed = !item.completed
        cell.accessoryType = item.completed ? .checkmark : .none
        
        SavingData()
    }
    
    //MARK: Barbutton methods
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var itemTextField: UITextField = UITextField()
        let alert: UIAlertController = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: UIAlertController.Style.alert)
        let alertAddAction: UIAlertAction = UIAlertAction(title: "Add Item", style: UIAlertAction.Style.default) {
            (action) in
            
            if let description = itemTextField.text {
                if !description.isEmpty {
                    let item: ToDoItem = ToDoItem(context: self.context)
                    item.title = description
                    item.completed = false
                    
                    self.itemArray.append(item)
                    self.SavingData()
                }
            }
        }
        let alertCancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            (action) in
        }
        
        alert.addTextField {
            (textField) in
            
            textField.placeholder = "Create new item"
            itemTextField = textField
        }
        alert.addAction(alertAddAction)
        alert.addAction(alertCancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: Manipulate data methods
    func SavingData() {
        do {
            try context.save()
            tableView.reloadData()
        }
        catch {
            print("Error saving data into core data, \(error)")
        }
    }
    
    func LoadingData(with request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()) {
        do {
            itemArray = try context.fetch(request)
            tableView.reloadData()
        }
        catch {
            print("Error loading data from core data, \(error)")
        }
    }

}

extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        LoadingData(with: request)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            LoadingData()
            
            // Execute the instruction on the main thread immediately.
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}
