//
//  CategoryViewController.swift
//  Todoey-CoreData
//
//  Created by Kenny Loh on 11/6/19.
//  Copyright © 2019 ProApp Concept Pte Ltd. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    //MARK: Local global variables
    // FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask
    var filePath: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var categoryArray: [Category] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("\(filePath)")
        
        LoadingData()
    }
    
    //MARK: Tableview datasource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category: Category = categoryArray[indexPath.row]
        
        cell.textLabel?.text = category.name
        
        return cell
    }
    
    //MARK: Tableview delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "GoToItem", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let descVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            descVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
    //MARK: Barbutton methods
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var categoryTextField: UITextField = UITextField()
        let alert: UIAlertController = UIAlertController(title: "Add New Todoey Cateogry", message: "", preferredStyle: .alert)
        let alertAddAction: UIAlertAction = UIAlertAction(title: "Add", style: .default) {
            (action) in
            
            if let description = categoryTextField.text {
                if !description.isEmpty {
                    let category: Category = Category(context: self.context)
                    category.name = description
                    
                    self.categoryArray.append(category)
                    self.SavingData()
                }
            }
        }
        let alertCancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) {
            (action) in
        }
        
        alert.addTextField {
            (textField) in
            
            textField.placeholder = "Create new category"
            categoryTextField = textField
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
    
    func LoadingData(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            categoryArray = try context.fetch(request)
            tableView.reloadData()
        }
        catch {
            print("Error loading data from core data, \(error)")
        }
    }
    
}
