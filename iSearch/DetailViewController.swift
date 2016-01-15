//
//  DetailViewController.swift
//  iSearch
//
//  Created by Antonio Alves on 1/11/16.
//  Copyright © 2016 Antonio Alves. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    enum AnimationStyle {
        case Slide
        case Fade
    }
    
    var dismissAnimatioStyle = AnimationStyle.Fade
    
    @IBOutlet var popupView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!
    
    var searchResult: SearchResult! {
        didSet {
            if isViewLoaded() {
                updateUI()
            }
        }
    }
    
    var downloadTask:NSURLSessionDownloadTask?
    
    var isPopUp = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .Custom
        transitioningDelegate = self
    }
    
    deinit {
        downloadTask?.cancel()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
        
        view.tintColor = UIColor(red: 20/255, green: 160/255, blue: 160/255,
            alpha: 1)
        
        if isPopUp {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("close:"))
            gestureRecognizer.cancelsTouchesInView = false
            gestureRecognizer.delegate = self
            view.addGestureRecognizer(gestureRecognizer)
            view.backgroundColor = UIColor.clearColor()
        } else {
            self.view.backgroundColor = UIColor(patternImage:UIImage(named: "LandscapeBackground")!)
            popupView.hidden = true
            if let displayName = NSBundle.mainBundle().localizedInfoDictionary?["CFBundleDisplayName"] as? String {
                title = displayName
            }
        }
        
        if searchResult != nil {
            updateUI()
        }
        
    }
    
    
    func updateUI() {
        nameLabel.text = searchResult.name
        
        if searchResult.artistName.isEmpty {
            artistNameLabel.text = NSLocalizedString("Unknown", comment: "Unknown artist name")
        } else {
            artistNameLabel.text = searchResult.artistName
        }
        
        kindLabel.text = searchResult.kindForDisplay()
        genreLabel.text = searchResult.genre
        
        
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        formatter.currencyCode = searchResult.currency
        
        let priceText : String
        if searchResult.price == 0 {
            priceText = NSLocalizedString("Free", comment: "Free download product")
        } else if let text = formatter.stringFromNumber(searchResult.price) {
            priceText = text
        } else {
            priceText = ""
        }
        
        priceButton.setTitle(priceText, forState: .Normal)
        
        if let url = NSURL(string: searchResult.artworkURL100) {
            downloadTask = artworkImageView.loadImageWithURL(url)
        }
        
        popupView.hidden = false
    }
    
    
    @IBAction func openIsStore(sender: AnyObject) {
        if let url = NSURL(string: searchResult.storeURL) {
            UIApplication.sharedApplication().openURL(url)
        }
    }

    @IBAction func close(sender: AnyObject) {
        dismissAnimatioStyle = .Slide
        dismissViewControllerAnimated(true, completion: nil)
    }
}



extension DetailViewController: UIViewControllerTransitioningDelegate {
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationController(presentedViewController:presented,
        presentingViewController: presenting)
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BounceAnimationController()
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        switch dismissAnimatioStyle {
        case .Slide:
            return SlideOutAnimationController()
        case .Fade:
            return FadeOutController()
        }
    }
}


extension DetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,
        shouldReceiveTouch touch: UITouch) -> Bool {
            return (touch.view === self.view)
    }
}