//
//  FadeOutController.swift
//  iSearch
//
//  Created by Antonio Alves on 1/12/16.
//  Copyright © 2016 Antonio Alves. All rights reserved.
//

import UIKit

class FadeOutController: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(_ transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        if let fromView = transitionContext.view(forKey: UITransitionContextFromViewKey) {
            let duration = transitionDuration(transitionContext)
            UIView.animate(withDuration: duration, animations: { () -> Void in
                fromView.alpha = 0
                }, completion: { finished in
                    transitionContext.completeTransition(finished)
            })
            
        }
    }
}
