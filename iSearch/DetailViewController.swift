//
//  DetailViewController.swift
//  iSearch
//
//  Created by Antonio Alves on 1/11/16.
//  Copyright © 2016 Antonio Alves. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    
    @IBOutlet var popupView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .Custom
        transitioningDelegate = self
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor = UIColor(red: 20/255, green: 160/255, blue: 160/255,
            alpha: 1)
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("close:"))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        
    }
    
    

    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}



extension DetailViewController: UIViewControllerTransitioningDelegate {
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationController(presentedViewController:presented,
        presentingViewController: presenting)
    }
}


extension DetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,
        shouldReceiveTouch touch: UITouch) -> Bool {
            return (touch.view === self.view)
    }
}