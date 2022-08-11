//
//  CustomViewTransitioningDelegate.swift
//  CustomViewPresenter
//
//  Created by Vignesh on 05/02/20.
//

import UIKit

public class CustomViewTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    var viewController: UIViewController
    var presentingViewController: UIViewController
    var interactiveDismiss = true
    var shouldBeMaximized = false
    
    public init(viewController: UIViewController, presentingViewController: UIViewController, shouldBeMaximised: Bool) {
        self.viewController = viewController
        self.presentingViewController = presentingViewController
        self.shouldBeMaximized = shouldBeMaximised
        super.init()
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomViewTransitionAnimator(type: .dismiss)
    }
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = CustomViewPresentationController(
            presentedViewController: presented,
            presenting: presenting
        )
        if shouldBeMaximized {
            presentationController.state = .max
        }
        return presentationController
    }
}
