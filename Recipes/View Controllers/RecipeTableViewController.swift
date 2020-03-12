//
//  RecipeTableViewController.swift
//  Recipes
//
//  Created by Marc Jacques on 3/11/20.
//  Copyright © 2020 Lambda Inc. All rights reserved.
//

import UIKit

class RecipeTableViewController: UITableViewController {
    
    // MARK: - Properties
    let networkClient = RecipesNetworkClient()
    var recipes: [Recipe] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    var filteredRecipes: [Recipe] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.reloadData()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Recipes"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        networkClient.fetchRecipes { allRecipes, error in
                if let error = error {
                    NSLog("Error while fetching all recipes: \(error)")
                    return
                }
                DispatchQueue.main.async {
                    if let allRecipes = allRecipes {
                        self.recipes = allRecipes
                    }
                }
            }
        }
 

    var isSearchEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        return searchController.isActive && !isSearchEmpty
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       if isFiltering{
                return filteredRecipes.count
            }
            return recipes.count
        }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath)
        let recipe: Recipe
        if isFiltering {
            recipe = filteredRecipes[indexPath.row]
        } else {
            recipe = recipes[indexPath.row]
        }
        cell.textLabel?.text = recipe.name
        return cell
    }
        // MARK: - Functions and methods
    
    func filterContentForSearchText(_ searchText: String) {
        filteredRecipes = recipes.filter { (recipe: Recipe) -> Bool in
            return recipe.name.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
    
    
        // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            guard
                segue.identifier == "DetailVCSegue",
                let indexPath = tableView.indexPathForSelectedRow,
                let detailVC = segue.destination as? RecipeDetailViewController
                else { return }
            // Pass the selected object to the new view controller.
            let recipe: Recipe
            if isFiltering {
                recipe = filteredRecipes[indexPath.row]
            } else {
                recipe = recipes[indexPath.row]
            }
            detailVC.recipe = recipe
        }
    }



extension RecipeTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
         let searchBar = searchController.searchBar
               filterContentForSearchText(searchBar.text!)
    }
}
