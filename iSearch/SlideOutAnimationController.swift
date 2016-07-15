//
//  SlideOutAnimationController.swift
//  iSearch
//
//  Created by Antonio Alves on 1/12/16.
//  Copyright © 2016 Antonio Alves. All rights reserved.
//

import UIKit

class SlideOutAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(_ transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        let fromView = transitionContext.view(forKey: UITransitionContextFromViewKey)
        let containerView = transitionContext.containerView()
        let duration = transitionDuration(transitionContext)
        UIView.animate(withDuration: duration, animations: { () -> Void in
            fromView?.center.y -= containerView.bounds.size.height
            fromView?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            }, completion: { finished in
                transitionContext.completeTransition(finished)
        })
    }
}
