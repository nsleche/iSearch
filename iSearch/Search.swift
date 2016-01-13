//
//  Search.swift
//  iSearch
//
//  Created by Antonio Alves on 1/13/16.
//  Copyright © 2016 Antonio Alves. All rights reserved.
//

import Foundation

typealias SearchComplete = (Bool) -> Void

class Search {
    
    enum Category: Int {
        case All = 0
        case Music = 1
        case Software = 2
        case EBooks = 3
        
        var entityName:String {
            switch self {
            case .All: return ""
            case .Music: return "musicTrack"
            case .Software: return "software"
            case .EBooks: return "ebook"
            }
        }
    }
    
    enum State {
        case NotSearchedYet
        case Loading
        case NoResults
        case Results([SearchResult])
    }
    
    private var dataTask : NSURLSessionDataTask? = nil
    
    private(set) var state:State = .NotSearchedYet
    
    func performSearchForText(text: String, category: Category, completion: SearchComplete) {
        if !text.isEmpty {
            dataTask?.cancel()
            
            state = .Loading
            
            let url = urlWithSearchText(text, category: category)
            
            let session = NSURLSession.sharedSession()
            
            dataTask = session.dataTaskWithURL(url, completionHandler: { data, response, error in
                self.state = .NotSearchedYet
                var success = false
                if let error = error where error.code == -999 {
                    return
                }
                if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 200 {
                    if let data = data, dictionary = self.parseJSON(data) {
                        var searchResults = self.parseDictionary(dictionary)
                        if searchResults.isEmpty {
                            self.state = .NoResults
                        } else {
                            searchResults.sortInPlace({ (r1, r2) -> Bool in
                                return r1.name.localizedStandardCompare(r2.name) == .OrderedAscending
                            })
                            self.state = .Results(searchResults)
                        }
                        success = true
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    completion(success)
                }
                
            })
            dataTask?.resume()
        }

    }
    
    
    
    private func urlWithSearchText(searchText:String, category: Category) -> NSURL {
        
        let entityName = category.entityName
        
        let escapedSearchText = searchText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let urlString = String(format:"https://itunes.apple.com/search?term=%@&limit=200&entity=%@", escapedSearchText, entityName)
        let url = NSURL(string: urlString)
        return url!
    }
    
    
    private func parseJSON(jsonData: NSData) -> [String:AnyObject]? {
        do {
            return try NSJSONSerialization.JSONObjectWithData(jsonData, options: []) as? [String:AnyObject]
        } catch {
            print("Error parsing")
            return nil
        }
    }
    
    private func parseDictionary(dictionary: [String:AnyObject]) -> [SearchResult] {
        guard let array = dictionary["results"] as? [AnyObject] else {
            print("Expected 'results' array")
            return []
        }
        
        var searchResults = [SearchResult]()
        
        for resultDict in array {
            if let resultDict = resultDict as? [String:AnyObject] {
                var searchResult: SearchResult?
                if let wrapperType = resultDict["wrapperType"] as? String {
                    switch wrapperType {
                    case "track":
                        searchResult = Parse.parseTrack(resultDict)
                    case "audiobook":
                        searchResult = Parse.parseAudioBook(resultDict)
                    case "software":
                        searchResult = Parse.parseSoftware(resultDict)
                        
                    default:
                        break
                    }
                } else if let kind = resultDict["kind"] as? String where kind == "ebook"{
                    searchResult = Parse.parseEBook(resultDict)
                }
                if let result = searchResult {
                    searchResults.append(result)
                }
            }
        }
        return searchResults
    }
    
    

}