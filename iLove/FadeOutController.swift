//
//  FadeOutController.swift
//  iLove
//
//  Created by Antonio Alves on 1/12/16.
//  Copyright © 2016 Antonio Alves. All rights reserved.
//

import UIKit

class FadeOutController: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) {
            let duration = transitionDuration(using: transitionContext)
            UIView.animate(withDuration: duration, animations: { () -> Void in
                fromView.alpha = 0
                }, completion: { finished in
                    transitionContext.completeTransition(finished)
            })
            
        }
    }
}
