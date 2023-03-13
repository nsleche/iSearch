//
//  MenuTableViewController.swift
//  iLove
//
//  Created by Antonio Alves on 1/15/16.
//  Copyright © 2016 Antonio Alves. All rights reserved.
//

import UIKit

protocol MenuTableViewControllerDelegate: AnyObject {
    func menuViewControllerSendSupportEmail(_ controller:MenuTableViewController)
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row == 0 {
            delegate?.menuViewControllerSendSupportEmail(self)
        }
    }
    
    
}


