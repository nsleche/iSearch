//
//  DimmingPresentationController.swift
//  iSearch
//
//  Created by Antonio Alves on 1/11/16.
//  Copyright © 2016 Antonio Alves. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController {
    
    lazy var dimmingView = GrandienView(frame: CGRect.zero)
    
    override func presentationTransitionWillBegin() {
        dimmingView.frame = containerView!.bounds
        containerView!.insertSubview(dimmingView, at: 0)
        dimmingView.alpha = 0
        if let transitionCoordinator = presentedViewController.transitionCoordinator() {
            transitionCoordinator.animate(alongsideTransition: { _ in
                self.dimmingView.alpha = 1
                }, completion: nil)
        }
    }
    
    override func dismissalTransitionWillBegin() {
        if let transitionCoordinator = presentedViewController.transitionCoordinator() {
            transitionCoordinator.animate(alongsideTransition: { _ in
                self.dimmingView.alpha = 0
                }, completion: nil)
        }
    }
    
    override func shouldRemovePresentersView() -> Bool {
        return false
    }
}
