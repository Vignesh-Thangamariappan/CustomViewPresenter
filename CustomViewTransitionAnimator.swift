//
//  CustomViewTransitionAnimator.swift
//  CustomViewPresenter
//
//  Created by Vignesh on 05/02/20.
//

import UIKit

class CustomViewTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var type: CustomTransitionAnimatorType
    
    init(type: CustomTransitionAnimatorType) {
        self.type = type
    }
    
    @objc func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let from = transitionContext.viewController(forKey: .from)
        let destinationView = transitionContext.viewController(forKey: .to)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { () -> Void in
            
            from!.view.frame.origin.y = maxY
            destinationView!.view.frame = from!.view.frame
            
        }) { (_) -> Void in
             transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
}
