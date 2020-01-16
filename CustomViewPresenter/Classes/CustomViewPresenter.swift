
//
//  CustomViewPresenter.swift
//
//  Created by Vignesh on 07/01/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit

enum ModalScaleState {
    case max
    case mini
}

public class CustomViewPresentationController: UIPresentationController {
    
    var panGestureRecognizer: UIPanGestureRecognizer
    var velocity: CGFloat = 0
    var state: ModalScaleState = .mini
    var isMaximized = false
    
    var _blurredView: UIView?
    
    private let cornerRadius: CGFloat = 20
    private var presentationWrappingView: UIView?
    
    var viewToBeBlurred: UIView {
        if let dimmedView = _blurredView {
            return dimmedView
        }
        let view = UIView(frame: CGRect(origin: CGPoint.zero, size: containerView?.frame.size ?? CGSize.zero))
        view.backgroundColor = UIColor(red: 58/255, green: 65/255, blue: 77/255, alpha: 0.34)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        view.addGestureRecognizer(tapGesture)
        _blurredView = view
        return view
    }
    
    @objc private func dismissView() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    override public init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        self.panGestureRecognizer = UIPanGestureRecognizer()
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        panGestureRecognizer.addTarget(self, action: #selector(onPan(pan:)))
//        if let navController = presentedViewController as? UINavigationController {
//            navController.navigationBar.addGestureRecognizer(panGestureRecognizer)
//        } else {
            presentedViewController.view.addGestureRecognizer(panGestureRecognizer)
//        }
    }
    
    // Uncomment to apply the minimized view changes
    override public var frameOfPresentedViewInContainerView: CGRect {
        return CGRect(x: 0, y: containerView!.bounds.height / 2, width: containerView!.bounds.width, height: containerView!.bounds.height / 2)
    }
    
    @objc func onPan(pan: UIPanGestureRecognizer) {
        
        presentedView?.endEditing(true)
        let endPoint = pan.translation(in: pan.view?.superview)
        
        switch pan.state {
            
            case .changed:
                
                let velocity = pan.velocity(in: pan.view?.superview)
                if velocity.y != 0 {
                    self.velocity = velocity.y
                }
                switch state {
                case .mini:
                    presentedView!.frame.origin.y = endPoint.y + containerView!.frame.height / 2
                    presentedView!.frame.size.height = containerView!.frame.height / 2 - endPoint.y
                case .max:
                    presentedView!.frame.origin.y = endPoint.y
                    presentedView!.frame.size.height = containerView!.frame.height - endPoint.y
                }
                
                
            case .ended:
                if self.velocity < 0 {
                    adjustViewTo(to: .max)
                } else {
                    dismissView()
                }
                
            default:
                break
            }
    }
    
    func adjustViewTo(to state: ModalScaleState) {
        
        guard let presentedView = presentedView, let containerView = self.containerView else {
            return
        }
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .beginFromCurrentState, animations: { () -> Void in
            let containerFrame = containerView.frame
            presentedView.frame = containerFrame
            
            let halfFrame = CGRect(origin: CGPoint(x: 0,
                                                   y: containerFrame.height / 2),
                                   size: CGSize(width: containerFrame.width,
                                                height: containerFrame.height / 2))
            
            let fullFrame = CGRect(origin: CGPoint(x: 0,
                            y: 64),
            size: CGSize(width: containerFrame.width,
                         height: containerFrame.height - 64))
            let frame = state == .max ? fullFrame : halfFrame
            
            presentedView.frame = frame
            
            if let navController = self.presentedViewController as? UINavigationController, !navController.isNavigationBarHidden {
                
                self.isMaximized = true
                presentedView.frame = containerView.frame
                navController.setNeedsStatusBarAppearanceUpdate()
                navController.navigationBar.layer.cornerRadius = 0
                navController.navigationBar.clipsToBounds = false
                // Force the navigation bar to update its size
                navController.isNavigationBarHidden = true
                navController.isNavigationBarHidden = false
            }
        }, completion: { _ in
            self.state = state
            if let navController = self.presentedViewController as? UINavigationController {
                navController.topViewController?.didChangeToMaxMode()
            } else {
                self.presentedViewController.didChangeToMaxMode()
            }
        })
    }
}

extension CustomViewPresentationController {
    
    override public func presentationTransitionWillBegin() {
        
            let blurredView = viewToBeBlurred
            
            if let containerView = self.containerView, let coordinator = presentingViewController.transitionCoordinator {
                
                blurredView.alpha = 0
                containerView.addSubview(blurredView)
                blurredView.addSubview(presentedViewController.view)
    
                coordinator.animate(alongsideTransition: { (_) -> Void in
                    blurredView.alpha = 1
                }, completion: nil)
            }
    }
        
    override public func dismissalTransitionWillBegin() {
            if let coordinator = presentingViewController.transitionCoordinator {
                
                coordinator.animate(alongsideTransition: { (_) -> Void in
                    self.viewToBeBlurred.alpha = 0
//                    self.presentingViewController.view.transform = CGAffineTransform.identity
                }, completion: { (_) -> Void in
                    print("done dismiss animation")
                })
                
            }
        }
        
    override public func dismissalTransitionDidEnd(_ completed: Bool) {
            print("dismissal did end: \(completed)")
            
            if completed {
                viewToBeBlurred.removeFromSuperview()
                _blurredView = nil
                isMaximized = false
            }
        }

}

protocol CustomViewPresentable { }

extension CustomViewPresentable where Self: UIViewController {
    func maximizeToFullScreen() {
        if let presentation = navigationController?.presentationController as? CustomViewPresentationController {
            presentation.adjustViewTo(to: .max)
        }
    }
}

extension CustomViewPresentable where Self: UINavigationController {
    func isHalfModalMaximized() -> Bool {
        if let presentationController = presentationController as? CustomViewPresentationController {
            return presentationController.isMaximized
        }
        return false
    }
}

public class CustomViewTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    var viewController: UIViewController
    var presentingViewController: UIViewController
    var interactiveDismiss = true
    
    public init(viewController: UIViewController, presentingViewController: UIViewController) {
        self.viewController = viewController
        self.presentingViewController = presentingViewController
        
        super.init()
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomViewTransitionAnimator(type: .Dismiss)
    }
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomViewPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

class CustomViewTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var type: CustomTransitionAnimatorType
    
    init(type: CustomTransitionAnimatorType) {
        self.type = type
    }
    
    @objc func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let from = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { () -> Void in
            
            from!.view.frame.origin.y = 800
            
        }) { (_) -> Void in
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
}

internal enum CustomTransitionAnimatorType {
    case Present
    case Dismiss
}

public protocol CustomViewDelegateProtocol {
    func didChangeToMaxMode()
}

extension UIViewController: CustomViewDelegateProtocol {
    
    @objc public func didChangeToMaxMode() {
    }
}
