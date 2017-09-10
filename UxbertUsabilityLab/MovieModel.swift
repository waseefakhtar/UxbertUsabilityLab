//
//  MovieModel.swift
//  UxbertUsabilityLab
//
//  Created by Waseef Akhtar on 9/10/17.
//  Copyright © 2017 Waseef Akhtar. All rights reserved.
//

import Foundation
import RealmSwift

class MovieModel: Object {
    dynamic var movieTitle = ""
    dynamic var yearText = ""
    dynamic var releaseDateText = ""
    dynamic var ratingText = ""
    dynamic var imageURLText = ""
}
