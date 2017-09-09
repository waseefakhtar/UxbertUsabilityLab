//
//  ViewController.swift
//  UxbertUsabilityLab
//
//  Created by Waseef Akhtar on 9/9/17.
//  Copyright © 2017 Waseef Akhtar. All rights reserved.
//

import UIKit
import SwiftyJSON

class ViewController: UIViewController, RequestManagerSearchResultsDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var rowData: [String: AnyObject] = [:]

    let requestManager = RequestManager()
    let searchController = UISearchController(searchResultsController: nil)

    var searchResults: [JSON] {
        return requestManager.searchResults
    }
    
    var validatedText: String {
        return searchController.searchBar.text!.replacingOccurrences(of: " ", with: "%20")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search Movies"
        searchController.searchBar.sizeToFit()
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        requestManager.delegate = self
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        

    }
    
    func updateSearchResults(_ sender: RequestManager) {
        tableView.reloadData()
    }
    
}

extension ViewController: UITableViewDelegate {
    
}

// MARK: - Table view data source

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as UITableViewCell
        
        rowData = (searchResults[indexPath.row] as JSON).dictionaryObject! as [String : AnyObject]
        
        print("Row Data: \(rowData)")
        
        cell.textLabel?.text = rowData["title"] as? String
        cell.detailTextLabel?.text = "Average Vote: \(rowData["vote_average"] as? String)"
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let selectedCell = moviesArray[indexPath.row]
    }
    
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        requestManager.resetSearch()
        tableView.reloadData()
        requestManager.search(validatedText)
        
        self.searchController.searchBar.endEditing(true)
        //self.searchController.dismissKeyboard()
        self.searchController.searchBar.resignFirstResponder()
        
    }
}


