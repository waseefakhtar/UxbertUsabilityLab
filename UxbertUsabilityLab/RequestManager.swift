//
//  RequestManager.swift
//  UxbertUsabilityLab
//
//  Created by Waseef Akhtar on 9/9/17.
//  Copyright © 2017 Waseef Akhtar. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

let apiKey = "79641abd35a5225076632c03f5f497c8"

protocol RequestManagerSearchResultsDelegate: class {
    func updateSearchResults(_ sender: RequestManager)
}

class RequestManager {
    weak var delegate: RequestManagerSearchResultsDelegate?

    var searchResults = [JSON]()
    
    func search(_ searchText: String) {
        let url = "https://api.themoviedb.org/3/search/movie?api_key=\(apiKey)&language=en-US&query=\(searchText)"
        
        Alamofire.request(url).responseJSON(completionHandler: { response in
            if let results = response.result.value as? [String:Any] {
                print("Results: \(results)")
                
                let data = JSON(results["results"]!).arrayValue
                self.searchResults += data
                
                if self.delegate != nil {
                    self.delegate?.updateSearchResults(self)
                }
            }
            
        })
    }
    
    func resetSearch() {
        searchResults = []
    }

}
