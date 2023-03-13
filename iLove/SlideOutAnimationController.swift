//
//  SlideOutAnimationController.swift
//  iLove
//
//  Created by Antonio Alves on 1/12/16.
//  Copyright © 2016 Antonio Alves. All rights reserved.
//

import UIKit

class SlideOutAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)
        let containerView = transitionContext.containerView
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: { () -> Void in
            fromView?.center.y -= containerView.bounds.size.height
            fromView?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            }, completion: { finished in
                transitionContext.completeTransition(finished)
        })
    }
}
