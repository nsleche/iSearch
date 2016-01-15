
//  SearchViewController.swift
//  iSearch
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
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        cellNib = UINib(nibName: "NothingFoundTableViewCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
        
        
        title = NSLocalizedString("Search", comment: "Split-view master button")
        
        if UIDevice.currentDevice().userInterfaceIdiom != .Pad {
            searchBar.becomeFirstResponder()
        }
    }
    
    func hideMasterPane() {
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.splitViewController!.preferredDisplayMode = .PrimaryHidden
            }) { _ in
                self.splitViewController!.preferredDisplayMode = .Automatic
        }
    }
    
    
    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
        switch newCollection.verticalSizeClass {
        case .Compact:
            showLandscapeViewWithCoordinator(coordinator)
        case .Regular, .Unspecified:
            hideLandscapeViewWithCoordinator(coordinator)
        }
    }
    
    func showLandscapeViewWithCoordinator(coordinator:UIViewControllerTransitionCoordinator) {
        precondition(landscapeViewController == nil)
        
        landscapeViewController = storyboard!.instantiateViewControllerWithIdentifier("LandscapeViewController") as? LandscapeViewController
        if let controller = landscapeViewController {
            controller.search = search
            controller.view.frame = view.bounds
            controller.view.alpha = 0
            view.addSubview(controller.view)
            addChildViewController(controller)
            
            coordinator.animateAlongsideTransition({ _ in
                controller.view.alpha = 1
                self.searchBar.resignFirstResponder()
                if self.presentedViewController != nil {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                }, completion: { _ in
                    controller.didMoveToParentViewController(self)
            })
        }
    }
    
    func hideLandscapeViewWithCoordinator(coordinator:UIViewControllerTransitionCoordinator) {
        if let controller = landscapeViewController {
            controller.willMoveToParentViewController(nil)
            
            coordinator.animateAlongsideTransition({ _ in
                if self.presentedViewController != nil {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                controller.view.alpha = 0
                }, completion: { _ in
                    controller.view.removeFromSuperview()
                    controller.removeFromParentViewController()
                    self.landscapeViewController = nil
            })
            
        }
    }
    
        

    func showNetworkError() {
        let alert = UIAlertController(title: NSLocalizedString("Whoops", comment: "Network error"), message:NSLocalizedString("There was an error reading from the iTunes store. Please try again!", comment: "Try search again, got a network error"), preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            if case .Results(let list) = search.state {
                let detailViewController = segue.destinationViewController as! DetailViewController
                let indexPath = sender as! NSIndexPath
                let searchResult = list[indexPath.row]
                detailViewController.searchResult = searchResult
                detailViewController.isPopUp = true
            }
        }
    }
    
    @IBAction func segmentChanged(sender: UISegmentedControl) {
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
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        performSearch()
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}


extension SearchViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch search.state {
        case .NotSearchedYet:
            return 0
        case .Loading:
            return 1
        case .NoResults:
            return 1
        case .Results(let list):
            return list.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch search.state {
        case .NotSearchedYet :
            fatalError("Should Never get here")
        case .Loading:
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath)
            let spinner = cell.viewWithTag(1) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        case .NoResults:
            return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath)
        case .Results(let list):
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultsTableViewCell
            let searchResult = list[indexPath.row]
            cell.confugureSearchResult(searchResult)
            return cell
        }
    }
    
    
    
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        searchBar.resignFirstResponder()
        
        if view.window!.rootViewController!.traitCollection.horizontalSizeClass == .Compact {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            performSegueWithIdentifier("ShowDetail", sender: indexPath)
        } else {
            if case .Results(let list) = search.state {
                splitViewDetail?.searchResult = list[indexPath.row]
            }
            if splitViewController!.displayMode != .AllVisible {
                hideMasterPane()
            }
        }
        
        
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        switch search.state {
        case .NotSearchedYet:
            return nil
        case .Results:
            return indexPath
        default:
            return nil
        }
    }

    
}