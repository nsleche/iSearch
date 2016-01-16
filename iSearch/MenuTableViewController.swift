//
//  MenuTableViewController.swift
//  iSearch
//
//  Created by Antonio Alves on 1/15/16.
//  Copyright © 2016 Antonio Alves. All rights reserved.
//

import UIKit

protocol MenuTableViewControllerDelegate: class {
    func menuViewControllerSendSupportEmail(controller:MenuTableViewController)
}

class MenuTableViewController: UITableViewController {
    
    weak var delegate: MenuTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            delegate?.menuViewControllerSendSupportEmail(self)
        }
    }
    
    
}


