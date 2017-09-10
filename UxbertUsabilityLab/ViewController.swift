//
//  ViewController.swift
//  UxbertUsabilityLab
//
//  Created by Waseef Akhtar on 9/9/17.
//  Copyright © 2017 Waseef Akhtar. All rights reserved.
//

import UIKit
import SwiftyJSON
import PINRemoteImage
import RealmSwift

class ViewController: UIViewController, RequestManagerSearchResultsDelegate {

    @IBOutlet weak var tableView: UITableView!
    
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
        
        // Locate Realm file in local directory.
        print(Realm.Configuration.defaultConfiguration.fileURL!)

    }
    
    func updateSearchResults(_ sender: RequestManager) {
        tableView.reloadData()
    }
    
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 128.0
    }
    
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
        
        let cellIdentifier = "customCell"
        
        tableView.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! CustomTableViewCell
        
        rowData = (searchResults[indexPath.row] as JSON).dictionaryObject! as [String : AnyObject]
        
        
        cell.movieLabel.text = rowData["title"] as? String
        cell.ratingLabel.text = "IMDB Rating: \(String(describing: rowData["vote_average"]!))"
        cell.releaseDateLabel.text = rowData["release_date"] as? String
        cell.yearLabel.text = rowData["release_date"] as? String
        
        if let range = cell.releaseDateLabel.text?.range(of: "-") {
            let firstPart = cell.releaseDateLabel.text?[(cell.releaseDateLabel.text?.startIndex)!..<range.lowerBound]
            cell.yearLabel.text = firstPart
        }

        // Grab the Poster.
        if let urlString = rowData["poster_path"] {
            if let imgURL: URL = URL(string: "https://image.tmdb.org/t/p/w640\(urlString)") {
                cell.movieImageView.pin_setImage(from: imgURL)
            }
        }
        
        cell.shareButton.tag = indexPath.row
        cell.shareButton.addTarget(self, action:#selector(shareButtonTapped(sender:)), for: UIControlEvents.touchUpInside)
        
        cell.addToFavorites.tag = indexPath.row
        cell.addToFavorites.addTarget(self, action: #selector(favoritesButtonTapped(sender:)), for: UIControlEvents.touchUpInside)
        
        
        return cell
        
    }
    
    func shareButtonTapped(sender:UIButton) {
        
        var shareImage = UIImage()
        
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        if indexPath != nil {
            rowData = (searchResults[(indexPath?.row)!] as JSON).dictionaryObject! as [String : AnyObject]
            
            // Grab the Poster.
            if let urlString = rowData["poster_path"] {
                if let imgURL: URL = URL(string: "https://image.tmdb.org/t/p/w640\(urlString)") {
                    DispatchQueue.global().async {
                        if let data = try? Data(contentsOf: imgURL) {
                            DispatchQueue.main.async {
                                shareImage = UIImage(data: data)!
                                self.displayShareSheet(shareContent: shareImage)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func displayShareSheet(shareContent:UIImage) {
        let activityViewController = UIActivityViewController(activityItems: [shareContent], applicationActivities: nil)
        present(activityViewController, animated: true, completion: {})
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    func favoritesButtonTapped(sender: UIButton) {
        
        var movieModel = MovieModel()
        
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        if indexPath != nil {
            rowData = (searchResults[(indexPath?.row)!] as JSON).dictionaryObject! as [String : AnyObject]
            
            try! realm.write{
                movieModel.movieTitle = (rowData["title"] as? String)!
                movieModel.ratingText = "IMDB Rating: \(String(describing: rowData["vote_average"]!))"
                movieModel.releaseDateText = (rowData["release_date"] as? String)!
                
                if let range = movieModel.releaseDateText.range(of: "-") {
                    let firstPart = movieModel.releaseDateText[(movieModel.releaseDateText.startIndex)..<range.lowerBound]
                    movieModel.yearText = firstPart
                }
                
                // Grab the Poster.
                if let urlString = rowData["poster_path"] {
                    movieModel.imageURLText = "https://image.tmdb.org/t/p/w640\(urlString)"
                }
                
                realm.add(movieModel)
                
            }
        }
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


