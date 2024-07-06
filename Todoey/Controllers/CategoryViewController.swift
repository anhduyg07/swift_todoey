//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Brazel on 4/7/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist. ")}
        //        guard let navBarScroll = navigationController?.navigationBar.scrollEdgeAppearance else {fatalError("Navigation controller does not exist. ")}
        
        if let navBarColour = UIColor(hexString: "1D9BF6") {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = navBarColour
            appearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColour, returnFlat: true)]
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColour, returnFlat: true)]
            
            navBar.standardAppearance = appearance
            navBar.scrollEdgeAppearance = appearance
            
            navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
        }
        
        
    }
    
    // MARK: - Add new category
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { action in
            
            if ((textField.text?.isEmpty) == false) {
                
                let newCategory = Category()
                
                newCategory.name = textField.text!
                newCategory.colour = UIColor.randomFlat().hexValue()
                
                self.saveData(category: newCategory)
                
            }
            
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create a new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    
    // MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categories?[indexPath.row] {
            
            cell.textLabel?.text = category.name
            guard let categoryColour = UIColor(hexString: category.colour) else { fatalError()}
            
            cell.backgroundColor = categoryColour
            cell.textLabel?.textColor = ContrastColorOf(categoryColour, returnFlat: true)
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.seletedCategory = categories?[indexPath.row]
        }
    }
    
    
    // MARK: - Data Manipulatior Methods
    
    func saveData(category: Category) {
        do {
            try realm.write {
                realm.add(category)            }
        }
        catch {
            print("Error when saving data \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadData (){
        
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    // MARK: - Delete data from SwipeCell
    
    override func updateModel(at indexPath: IndexPath) {
        if let category = self.categories?[indexPath.row]{
            do {
                try self.realm.write {
                    self.realm.delete(category)
                }
                
            } catch {
                print ("Error when deleting category \(error)")
            }
        }
    }
}

