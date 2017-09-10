//
//  FavoritesViewController.swift
//  UxbertUsabilityLab
//
//  Created by Waseef Akhtar on 9/11/17.
//  Copyright © 2017 Waseef Akhtar. All rights reserved.
//

import UIKit
import RealmSwift

class FavoritesViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var moviesList : Results<MovieModel>!
    
    var movieList = try! Realm().objects(MovieModel)

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension FavoritesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 128.0
    }
    
}

// MARK: - Table view data source

extension FavoritesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieList.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "customCell"
        
        tableView.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! CustomTableViewCell
        
        let rowData = movieList[indexPath.row]
        
        cell.movieLabel.text = rowData["movieTitle"] as? String
        cell.ratingLabel.text = rowData["ratingText"] as? String
        cell.releaseDateLabel.text = rowData["releaseDateText"] as? String
        cell.yearLabel.text = rowData["yearText"] as? String
        
        // Grab the Poster.
        if let urlString = rowData["imageURLText"] as? String {
            if let imgURL: URL = URL(string: urlString) {
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
            let rowData = movieList[(indexPath?.row)!]

            // Grab the Poster.
            if let urlString = rowData["imageURLText"] as? String {
                if let imgURL: URL = URL(string: urlString) {
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
            let rowData = movieList[(indexPath?.row)!]
            
            try! realm.write{
                movieModel.movieTitle = (rowData["movieTitle"] as? String)!
                movieModel.ratingText = (rowData["ratingText"] as? String)!
                movieModel.releaseDateText = (rowData["releaseDateText"] as? String)!
                
                if let range = movieModel.releaseDateText.range(of: "-") {
                    let firstPart = movieModel.releaseDateText[(movieModel.releaseDateText.startIndex)..<range.lowerBound]
                    movieModel.yearText = firstPart
                }
                
                // Grab the Poster.
                if let urlString = rowData["imageURLText"] as? String {
                    movieModel.imageURLText = urlString
                }
                
                realm.add(movieModel)
                
            }
        }
    }
}

