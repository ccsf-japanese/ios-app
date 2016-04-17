//
//  Level.swift
//  japanize
//
//  Created by Dylan Smith on 3/17/16.
//  Copyright © 2016 Codepath. All rights reserved.
//

import UIKit

class Level: NSObject {
  
  var id: String?
  var name: String?
  var chapter: Int?
  var characters: [Character]?
  var words: [Word]?
  
  init(dictionary: NSDictionary) {
    id = dictionary["id"] as? String
    name = dictionary["name"] as? String
    chapter = dictionary["chapter"] as? Int
    characters = dictionary["characters"] as? [Character]
  }
  
}

/* var number: Int?
 var level: Int!
 var kanjiCount: Int?
 var wordMatchCount: Int?
 var wordSayCount: Int?
 var phraseCount: Int? */