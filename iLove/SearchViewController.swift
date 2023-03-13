
//  SearchViewController.swift
//  iLove
//
//  Created by Antonio Alves on 1/7/16.
//  Copyright © 2016 Antonio Alves. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    let search = Search()
    
    var landscapeViewController:LandscapeViewController?
    weak var splitViewDetail: DetailViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = 80.0
        var cellNib = UINib(nibName: "SearchResultsCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        cellNib = UINib(nibName: "NothingFoundTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
        
        
        title = NSLocalizedString("Search", comment: "Split-view master button")
        
        if UIDevice.current.userInterfaceIdiom != .pad {
            searchBar.becomeFirstResponder()
        }
    }
    
    func hideMasterPane() {
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.splitViewController!.preferredDisplayMode = .primaryHidden
            }) { _ in
                self.splitViewController!.preferredDisplayMode = .automatic
        }
    }
    
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        let rect = UIScreen.main.bounds
        if (rect.width == 736 && rect.height == 414) ||
            (rect.width == 414 && rect.height == 736) {
                if presentedViewController != nil {
                    dismiss(animated: true, completion: nil)
                }
        } else if UIDevice.current.userInterfaceIdiom != .pad {
        
            switch newCollection.verticalSizeClass {
            case .compact:
                showLandscapeViewWithCoordinator(coordinator)
            case .regular, .unspecified:
                hideLandscapeViewWithCoordinator(coordinator)
            @unknown default:
                hideLandscapeViewWithCoordinator(coordinator)
            }
        }
    }
    
    func showLandscapeViewWithCoordinator(_ coordinator:UIViewControllerTransitionCoordinator) {
        precondition(landscapeViewController == nil)
        
        landscapeViewController = storyboard!.instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeViewController
        if let controller = landscapeViewController {
            controller.search = search
            controller.view.frame = view.bounds
            controller.view.alpha = 0
            view.addSubview(controller.view)
            addChild(controller)
            
            coordinator.animate(alongsideTransition: { _ in
                controller.view.alpha = 1
                self.searchBar.resignFirstResponder()
                if self.presentedViewController != nil {
                    self.dismiss(animated: true, completion: nil)
                }
                }, completion: { _ in
                    controller.didMove(toParent: self)
            })
        }
    }
    
    func hideLandscapeViewWithCoordinator(_ coordinator:UIViewControllerTransitionCoordinator) {
        if let controller = landscapeViewController {
            controller.willMove(toParent: nil)
            
            coordinator.animate(alongsideTransition: { _ in
                if self.presentedViewController != nil {
                    self.dismiss(animated: true, completion: nil)
                }
                controller.view.alpha = 0
                }, completion: { _ in
                    controller.view.removeFromSuperview()
                    controller.removeFromParent()
                    self.landscapeViewController = nil
            })
            
        }
    }
    
        

    func showNetworkError() {
        let alert = UIAlertController(title: NSLocalizedString("Whoops", comment: "Network error"), message:NSLocalizedString("There was an error reading from the iTunes store. Please try again!", comment: "Try search again, got a network error"), preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            if case .results(let list) = search.state {
                let detailViewController = segue.destination as! DetailViewController
                let indexPath = sender as! IndexPath
                let searchResult = list[(indexPath as NSIndexPath).row]
                detailViewController.searchResult = searchResult
                detailViewController.isPopUp = true
            }
        }
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        performSearch()
    }
    
    

}


struct TableViewCellIdentifiers {
    static let searchResultCell = "SearchResultCell"
    static let nothingFoundCell = "NothingFoundCell"
    static let loadingCell = "LoadingCell"
}


extension SearchViewController: UISearchBarDelegate {
    func performSearch() {
        
        if let category = Search.Category(rawValue: segmentedControl.selectedSegmentIndex) {
            search.performSearchForText(searchBar.text!, category: category, completion: { success in
                if !success {
                    self.showNetworkError()
                }
                self.landscapeViewController?.searchResultsReceived()
                self.tableView.reloadData()
            })
        
            tableView.reloadData()
            searchBar.resignFirstResponder()
        }

    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}


extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch search.state {
        case .notSearchedYet:
            return 0
        case .loading:
            return 1
        case .noResults:
            return 1
        case .results(let list):
            return list.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch search.state {
        case .notSearchedYet :
            fatalError("Should Never get here")
        case .loading:
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loadingCell, for: indexPath)
            let spinner = cell.viewWithTag(1) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        case .noResults:
            return tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.nothingFoundCell, for: indexPath)
        case .results(let list):
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.searchResultCell, for: indexPath) as! SearchResultsTableViewCell
            let searchResult = list[(indexPath as NSIndexPath).row]
            cell.confugureSearchResult(searchResult)
            return cell
        }
    }
    
    
    
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        
        if view.window!.rootViewController!.traitCollection.horizontalSizeClass == .compact {
            tableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: "ShowDetail", sender: indexPath)
        } else {
            if case .results(let list) = search.state {
                splitViewDetail?.searchResult = list[(indexPath as NSIndexPath).row]
            }
            if splitViewController!.displayMode != .allVisible {
                hideMasterPane()
            }
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch search.state {
        case .notSearchedYet:
            return nil
        case .results:
            return indexPath
        default:
            return nil
        }
    }

    
}
