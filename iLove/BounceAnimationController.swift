//
//  BounceAnimationController.swift
//  iLove
//
//  Created by Antonio Alves on 1/12/16.
//  Copyright © 2016 Antonio Alves. All rights reserved.
//

import UIKit

class BounceAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    
    func transitionDuration(_ transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toViewController = transitionContext.viewController(forKey: UITransitionContextToViewControllerKey)
        let toView = transitionContext.view(forKey: UITransitionContextToViewKey)
        let containerView = transitionContext.containerView()
        toView?.frame = transitionContext.finalFrame(for: toViewController!)
        containerView.addSubview(toView!)
        
        UIView.animateKeyframes(withDuration: transitionDuration(transitionContext), delay: 0, options: .calculationModeCubic, animations: { () -> Void in
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.334, animations: { () -> Void in
                toView?.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.334, relativeDuration: 0.333, animations: { () -> Void in
                toView?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.666, relativeDuration: 0.333, animations: { () -> Void in
                toView?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            })
            }, completion: { (bool) -> Void in
                transitionContext.completeTransition(bool)
        })
    }
    
    
}
