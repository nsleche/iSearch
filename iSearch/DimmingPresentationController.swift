//
//  DimmingPresentationController.swift
//  iSearch
//
//  Created by Antonio Alves on 1/11/16.
//  Copyright © 2016 Antonio Alves. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController {
    
    override func shouldRemovePresentersView() -> Bool {
        return false
    }
}
