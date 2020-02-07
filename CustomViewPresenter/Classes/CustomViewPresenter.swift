
//
//  CustomViewPresenter.swift
//
//  Created by Vignesh on 07/01/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit

public enum ModalScaleState {
    case max
    case mini
}

/// This variable denotes whether the background should be blurred while presenting the view. Set to TRUE by default.
public var shouldBlurBackground = true

/// This boolean property denotes whether the bakground view should be transformed to 90% when presenting a view. Set to FALSE by default
public var shouldTransformBackgroundView = false

public var shouldExpandToFullScreen = false
var maxY = CGFloat(0)

public class CustomViewPresentationController: UIPresentationController {
    
    var panGestureRecognizer: UIPanGestureRecognizer
    var velocity: CGFloat = 0
    var state: ModalScaleState = .mini
    var isMaximized = false
    
    var _blurredView: UIView?
    
    var keyboardHeight: CGFloat = 0
    
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
    
    var minHeightOfPresentedView: CGFloat {
        
        if let view = presentedView as? CustomViewPresentable, let height = view.heightForMiniMode {
            return height
        } else if let navController = self.presentedViewController as? UINavigationController, let viewController = navController.topViewController as? CustomViewPresentable, let height = viewController.heightForMiniMode {
            if UIDevice.current.hasNotch {
                return height + 34
            }
            return height
        } else {
            return containerView!.bounds.height / 2
        }
    }
    
    override public init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        self.panGestureRecognizer = UIPanGestureRecognizer()
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        panGestureRecognizer.delegate = self
        panGestureRecognizer.addTarget(self, action: #selector(onPan(pan:)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIApplication.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIApplication.keyboardWillHideNotification, object: nil)
        if #available(iOS 11.0, *) {
            presentedView?.setRoundedTopCorners()
        } else {
            // Fallback on earlier versions
        }
        //        setupNavBarIfNeeded()
        //        if let navController = presentedViewController as? UINavigationController {
        //            navController.navigationBar.addGestureRecognizer(panGestureRecognizer)
        //        } else {
        presentedViewController.view.addGestureRecognizer(panGestureRecognizer)
        //        }
    }
    
    private func setupNavBarIfNeeded() {
        
        guard let navController = presentedViewController as? UINavigationController else { return }
        
        if state == .max, shouldExpandToFullScreen {
            return
        }
        navController.navigationBar.layer.cornerRadius = 15
        if #available(iOS 11.0, *) {
            navController.navigationBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
        navController.topViewController?.view.layer.cornerRadius = 15
        navController.topViewController?.view.clipsToBounds = true
        navController.navigationBar.clipsToBounds = true
        
    }
    
    // Uncomment to apply the minimized view changes
    override public var frameOfPresentedViewInContainerView: CGRect {
        guard self.state == .mini else {
            
            return CGRect(x: 0, y: 64, width: containerView!.bounds.width, height: containerView!.bounds.height - 64)
        }
        maxY = containerView!.bounds.height / 2
        return CGRect(x: 0, y: containerView!.bounds.height - minHeightOfPresentedView, width: containerView!.bounds.width, height: minHeightOfPresentedView)
    }
    
    @objc func onPan(pan: UIPanGestureRecognizer) {
        
        presentedView?.endEditing(true)
        var endPoint = pan.translation(in: pan.view?.superview)
        guard abs(endPoint.x) < abs(endPoint.y) else {
            return
        }
        if !shouldExpandToFullScreen, state == .max {
            endPoint = CGPoint(x: endPoint.x, y: endPoint.y + 64)
        }
        switch pan.state {
            
        case .changed:
            
            let velocity = pan.velocity(in: pan.view?.superview)
            self.velocity = endPoint.y
            if state == .max {
                self.velocity -= 64
            }
            switch state {
            case .mini:
                presentedView!.frame.origin.y = endPoint.y + containerView!.bounds.height - minHeightOfPresentedView
                presentedView!.frame.size.height = minHeightOfPresentedView - endPoint.y
            case .max:
                presentedView!.frame.origin.y = endPoint.y
                presentedView!.frame.size.height = containerView!.bounds.height - endPoint.y
            }
            
            
        case .ended:
            adjustViewForAction()
        default:
            break
        }
    }
    
    func adjustViewForAction() {
        if keyboardHeight != 0 {
            //            self.keyboardHeight = 0
            //            adjustViewTo(to: self.state)
            return
        }
        if self.velocity < -30 {
            adjustViewTo(to: .max)
        } else if self.velocity > 30 {
            dismissView()
        } else {
            adjustViewTo(to: self.state)
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
                                                   y: containerFrame.height - self.minHeightOfPresentedView),
                                   size: CGSize(width: containerFrame.width,
                                                height: self.minHeightOfPresentedView))
            
            var fullFrame = CGRect(origin: CGPoint(x: 0,
                                                   y: 64),
                                   size: CGSize(width: containerFrame.width,
                                                height: containerFrame.height - 64))
            let frame = state == .max ? fullFrame : halfFrame
            if self.presentedViewController is UINavigationController {
                fullFrame.origin.y += 44
                fullFrame.size.height -= 44
            }
            maxY = frame.origin.y
            presentedView.frame = frame
            if let navController = self.presentedViewController as? UINavigationController, !navController.isNavigationBarHidden, shouldExpandToFullScreen {
                
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
            guard self.state != state else { return }
            self.state = state
            if state == .max {
                if let navController = self.presentedViewController as? UINavigationController, let viewController = navController.topViewController as? CustomViewPresentable {
                    viewController.didChangeToFullScreen()
                } else if let presentedVC = self.presentedViewController as? CustomViewPresentable {
                    presentedVC.didChangeToFullScreen()
                }
            }
        })
    }
}

extension CustomViewPresentationController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer.view is UITableView, let translation = (otherGestureRecognizer as? UIPanGestureRecognizer)?.translation(in: otherGestureRecognizer.view?.superview), abs(translation.x) > abs(translation.y) {
            return true
        }
        return false
    }
}

extension CustomViewPresentationController {
    
    override public func presentationTransitionWillBegin() {
        
        let blurredView = viewToBeBlurred
        setupNavBarIfNeeded()
        if let containerView = self.containerView, let coordinator = presentingViewController.transitionCoordinator {
            
            if shouldBlurBackground {
                blurredView.alpha = 0
                containerView.addSubview(blurredView)
                blurredView.addSubview(presentedViewController.view)
            } else {
                containerView.addSubview(presentedViewController.view)
            }
            
            coordinator.animate(alongsideTransition: { (_) -> Void in
                if shouldBlurBackground {
                    blurredView.alpha = 1
                }
                if shouldTransformBackgroundView {
                    self.presentingViewController.view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                }
            }, completion: nil)
        }
    }
    
    override public func dismissalTransitionWillBegin() {
        if let coordinator = presentingViewController.transitionCoordinator {
            
            coordinator.animate(alongsideTransition: { (_) -> Void in
                if shouldBlurBackground {
                    self.viewToBeBlurred.alpha = 0
                }
                if shouldTransformBackgroundView {
                    self.presentingViewController.view.transform = CGAffineTransform .identity
                }
            }, completion: { (_) -> Void in
                print("done dismiss animation")
            })
            
        }
    }
    
    override public func dismissalTransitionDidEnd(_ completed: Bool) {
        print("dismissal did end: \(completed)")
        
        if completed {
            if shouldBlurBackground {
                viewToBeBlurred.removeFromSuperview()
                _blurredView = nil
            }
            isMaximized = false
        }
    }
}

extension CustomViewPresentationController {
    
    @objc
    private func keyboardWillShow(notification: Notification) {
        
        guard keyboardHeight == 0 else { return }
        DispatchQueue.main.async {
            let keyboardHeight = self.presentedViewController.getKeyboardHeight(fromNotification: notification)
            let keyboardTransitionDuration = self.presentedViewController.getKeyboardTransitionDuration(fromNotification: notification)
            self.keyboardHeight = keyboardHeight
            UIView.animate(withDuration: keyboardTransitionDuration) {
                switch self.state {
                case .mini:
                    self.presentedView?.frame.origin.y -= keyboardHeight
                    if UIDevice.current.hasNotch {
                        self.presentedView?.frame.origin.y += 34
                        self.presentedView?.frame.size.height -= 34
                    }
                case .max:
                    self.presentedView?.frame.size.height -= keyboardHeight
                }
                self.presentedView?.layoutIfNeeded()
            }
        }
    }
    
    @objc
    private func keyboardWillHide(notification: Notification) {
        
        guard keyboardHeight != 0 else { return }
        let duration = self.presentedViewController.getKeyboardTransitionDuration(fromNotification: notification)
        UIView.animate(withDuration: duration) {
            switch self.state {
            case .mini:
                self.presentedView?.frame.origin.y += self.keyboardHeight
                if UIDevice.current.hasNotch {
                    self.presentedView?.frame.origin.y -= 34
                    self.presentedView?.frame.size.height += 34
                }
            case .max:
                self.presentedView?.frame.size.height += self.keyboardHeight
                self.keyboardHeight = 0
            }
            self.presentedView?.layoutIfNeeded()
        }
    }
}

extension UIDevice {
    var hasNotch: Bool {
        guard #available(iOS 11.0, *) else {
            return false
            
        }
        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
}
