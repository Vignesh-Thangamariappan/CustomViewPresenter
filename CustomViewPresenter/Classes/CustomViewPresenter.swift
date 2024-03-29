//
//  CustomViewPresenter.swift
//
//  Created by Vignesh on 07/01/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import UIKit
import DeviceUtility

public enum ModalScaleState {
    case max
    case mini
}

struct PresenterConstants {
    static var heightToAdjust: CGFloat = 34
    static var topAnchorToUpdate: CGFloat = 64
}

public struct PresentationConfiguration {
    /// This variable denotes whether the background should be blurred while presenting the view. Set to TRUE by default.
    public var shouldBlurBackground = true

    /// This boolean property denotes whether the bakground view should be transformed to 90% when presenting a view. Set to FALSE by default
    public var shouldTransformBackgroundView = false

    public var shouldExpandToFullScreen = false
    public var shouldShowNotchOnTop = false
}

var maxY = CGFloat(0)
var presentationConfig = PresentationConfiguration(
    shouldBlurBackground: true,
    shouldTransformBackgroundView: false,
    shouldExpandToFullScreen: false,
    shouldShowNotchOnTop: true
)

public class CustomViewPresentationController: UIPresentationController {
    
    var panGestureRecognizer: UIPanGestureRecognizer
    var velocity: CGFloat = 0
    var state: ModalScaleState = .mini
    var isMaximized = false
    
    var _blurredView: UIView?
    
    var keyboardHeight: CGFloat = 0
    
    private let cornerRadius: CGFloat = 20
    private var presentationWrappingView: UIView?
    
    var shouldExpandToMaxMode: Bool = true
    
    lazy var topIndicatorView: UIView = {
       
        var minorNotch: UILabel = {
            var label = UILabel()
            label.frame = CGRect(x: containerView!.bounds.width/2 - 32.5, y: 2, width: 65, height: 5)
            label.backgroundColor = UIColor(red: 0.847, green: 0.847, blue: 0.847, alpha: 1)
            label.layer.cornerRadius = 3
            label.clipsToBounds = true
            return label
        }()
        
        let view = UIView()
        view.backgroundColor = .white
        view.addSubview(minorNotch)
        view.frame = CGRect(x: 0, y: 0, width: containerView!.bounds.width, height: 10)
        return view
        
    }()
    var viewToBeBlurred: UIView {
        if let dimmedView = _blurredView {
            return dimmedView
        }
        let view = UIView(
            frame: CGRect(
                origin: CGPoint.zero,
                size: containerView?.frame.size ?? CGSize.zero
            )
        )
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
        
        if let view = presentedViewController as? CustomViewPresentable, let height = view.heightForMiniMode {
            return height
        } else if let navController = self.presentedViewController as? UINavigationController,
                  let viewController = navController.topViewController as? CustomViewPresentable,
                  let height = viewController.heightForMiniMode {
            if DeviceUtility.currentDevice.hasNotch {
                return height + PresenterConstants.heightToAdjust
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
        }
        presentedViewController.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    private func setupNavBarIfNeeded() {
        
        guard let navController = presentedViewController as? UINavigationController else { return }
        
        if state == .max, presentationConfig.shouldExpandToFullScreen {
            return
        }
        navController.navigationBar.layer.cornerRadius = 15
        if #available(iOS 11.0, *) {
            navController.navigationBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        navController.topViewController?.view.layer.cornerRadius = 15
        navController.topViewController?.view.clipsToBounds = true
        navController.navigationBar.clipsToBounds = true
        
    }
    
    // Uncomment to apply the minimized view changes
    override public var frameOfPresentedViewInContainerView: CGRect {
        guard self.state == .mini else {
            return CGRect(
                x: 0,
                y: PresenterConstants.topAnchorToUpdate,
                width: containerView!.bounds.width,
                height: containerView!.bounds.height - PresenterConstants.topAnchorToUpdate
            )
        }
        maxY = containerView!.bounds.height / 2
        return CGRect(
            x: 0,
            y: containerView!.bounds.height - minHeightOfPresentedView,
            width: containerView!.bounds.width,
            height: minHeightOfPresentedView
        )
    }
    
    @objc func onPan(pan: UIPanGestureRecognizer) {
        
        if let presentedVC = self.presentedViewController as? CustomViewPresentable, state == .mini,  !presentedVC.shouldExpandToMaxMode {
            return
        } else if let navController = self.presentedViewController as? UINavigationController, let presentedVC = navController.topViewController as? CustomViewPresentable, state == .mini,  !presentedVC.shouldExpandToMaxMode {
            return
        }
        presentedView?.endEditing(true)
        var endPoint = pan.translation(in: pan.view?.superview)
        guard abs(endPoint.x) < abs(endPoint.y) else {
            return
        }
        if !presentationConfig.shouldExpandToFullScreen, state == .max {
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
            adjustViewTo(to: self.state)
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
        
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: .beginFromCurrentState,
            animations: { () -> Void in
                
                let containerFrame = containerView.frame
                presentedView.frame = containerFrame
                
                let halfFrame = CGRect(
                    origin: CGPoint(
                        x: 0,
                        y: containerFrame.height - self.minHeightOfPresentedView
                    ),
                    size: CGSize(
                        width: containerFrame.width,
                        height: self.minHeightOfPresentedView
                    )
                )
                
                var fullFrame = CGRect(
                    origin: CGPoint(
                        x: 0,
                        y: 64
                    ),
                    size: CGSize(
                        width: containerFrame.width,
                        height: containerFrame.height - 64
                    )
                )
                let frame = state == .max ? fullFrame : halfFrame
                if self.presentedViewController is UINavigationController {
                    fullFrame.origin.y += 44
                    fullFrame.size.height -= 44
                }
                maxY = frame.origin.y
                self.topIndicatorView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: 10)
                presentedView.frame = CGRect(
                    x: frame.origin.x,
                    y: frame.origin.y + 10,
                    width: frame.size.width,
                    height: frame.size.height - 1
                )
                if let navController = self.presentedViewController as? UINavigationController, !navController.isNavigationBarHidden, presentationConfig.shouldExpandToFullScreen {
                    
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
                guard state == .max else { return }
                if let navController = self.presentedViewController as? UINavigationController,
                   let viewController = navController.topViewController as? CustomViewPresentable {
                    viewController.didChangeToFullScreen()
                } else if let presentedVC = self.presentedViewController as? CustomViewPresentable {
                    presentedVC.didChangeToFullScreen()
                }
            })
    }
}

extension CustomViewPresentationController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        if otherGestureRecognizer.view is UITableView,
            let translation = (otherGestureRecognizer as? UIPanGestureRecognizer)?.translation(in: otherGestureRecognizer.view?.superview),
           abs(translation.x) > abs(translation.y) {
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
            
            if presentationConfig.shouldBlurBackground {
                blurredView.alpha = 0
                containerView.addSubview(blurredView)
                blurredView.addSubview(presentedViewController.view)
                topIndicatorView.backgroundColor = presentedViewController.view.backgroundColor
                presentedViewController.view.addSubview(topIndicatorView)
            } else {
                containerView.addSubview(presentedViewController.view)
                topIndicatorView.backgroundColor = presentedViewController.view.backgroundColor
                presentedViewController.view.addSubview(topIndicatorView)
            }
            
            coordinator.animate(alongsideTransition: { (_) -> Void in
                if presentationConfig.shouldBlurBackground {
                    blurredView.alpha = 1
                }
                if presentationConfig.shouldTransformBackgroundView {
                    self.presentingViewController.view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                }
            }, completion: nil)
        }
    }
    
    override public func dismissalTransitionWillBegin() {
        guard let coordinator = presentingViewController.transitionCoordinator else { return }
        
        coordinator.animate(alongsideTransition: { (_) -> Void in
            if presentationConfig.shouldBlurBackground {
                self.viewToBeBlurred.alpha = 0
            }
            if presentationConfig.shouldTransformBackgroundView {
                self.presentingViewController.view.transform = CGAffineTransform .identity
            }
        }, completion: { (_) -> Void in
            
        })
        
    }
    
    override public func dismissalTransitionDidEnd(_ completed: Bool) {
        guard completed else { return }
        if presentationConfig.shouldBlurBackground {
            viewToBeBlurred.removeFromSuperview()
            _blurredView = nil
        }
        isMaximized = false
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
                    if let currentY = self.presentedView?.frame.origin.y, currentY - keyboardHeight > 30 {
                        self.presentedView?.frame.origin.y = currentY - keyboardHeight
                    } else {
                        self.presentedView?.frame.origin.y = 30
                        self.presentedView?.frame.size.height = self.containerView!.bounds.height - keyboardHeight - 30
                    }
                    if DeviceUtility.currentDevice.hasNotch {
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
            self.adjustViewTo(to: self.state)
            self.keyboardHeight = 0
            self.presentedView?.layoutIfNeeded()
        }
    }
}
