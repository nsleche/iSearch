//
//  Search.swift
//  iSearch
//
//  Created by Antonio Alves on 1/13/16.
//  Copyright © 2016 Antonio Alves. All rights reserved.
//

import UIKit

typealias SearchComplete = (Bool) -> Void

class Search {
    
    enum Category: Int {
        case all = 0
        case music = 1
        case software = 2
        case eBooks = 3
        
        var entityName:String {
            switch self {
            case .all: return ""
            case .music: return NSLocalizedString("musicTrack", comment: "Localized kind: musicTrack")
            case .software: return NSLocalizedString("software", comment: "Localized kind: software")
            case .eBooks: return NSLocalizedString("ebook", comment: "Localized kind: ebook")
            }
        }
    }
    
    enum State {
        case notSearchedYet
        case loading
        case noResults
        case results([SearchResult])
    }
    
    private var dataTask : URLSessionDataTask? = nil
    
    private(set) var state:State = .notSearchedYet
    
    func performSearchForText(_ text: String, category: Category, completion: SearchComplete) {
        if !text.isEmpty {
            dataTask?.cancel()
            UIApplication.shared().isNetworkActivityIndicatorVisible = true
            
            state = .loading
            
            let url = urlWithSearchText(text, category: category)
            
            let session = URLSession.shared()
            
            dataTask = session.dataTask(with: url, completionHandler: { data, response, error in
                self.state = .notSearchedYet
                var success = false
                if let error = error where error.code == -999 {
                    return
                }
                if let httpResponse = response as? HTTPURLResponse where httpResponse.statusCode == 200 {
                    if let data = data, dictionary = self.parseJSON(data) {
                        var searchResults = self.parseDictionary(dictionary)
                        if searchResults.isEmpty {
                            self.state = .noResults
                        } else {
                            searchResults.sort(isOrderedBefore: { (r1, r2) -> Bool in
                                return r1.name.localizedStandardCompare(r2.name) == .orderedAscending
                            })
                            self.state = .results(searchResults)
                        }
                        success = true
                    }
                }
                DispatchQueue.main.async {
                    completion(success)
                    UIApplication.shared().isNetworkActivityIndicatorVisible = false
                }
                
            })
            dataTask?.resume()
        }

    }
    
    
    
    private func urlWithSearchText(_ searchText:String, category: Category) -> URL {
        
        let entityName = category.entityName
        let locale = Locale.autoupdatingCurrent()
        let language = locale.localeIdentifier
        let countryCode = locale.object(forKey: Locale.Key.countryCode) as! String
        
        let escapedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        let urlString = String(format:"https://itunes.apple.com/search?term=%@&limit=200&entity=%@&lang=%@&country=%@", escapedSearchText, entityName, language, countryCode)
        let url = URL(string: urlString)
        return url!
    }
    
    
    private func parseJSON(_ jsonData: Data) -> [String:AnyObject]? {
        do {
            return try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String:AnyObject]
        } catch {
            print("Error parsing")
            return nil
        }
    }
    
    private func parseDictionary(_ dictionary: [String:AnyObject]) -> [SearchResult] {
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
