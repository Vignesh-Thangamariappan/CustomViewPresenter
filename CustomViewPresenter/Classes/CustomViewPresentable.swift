//
//  CustomViewPresentable.swift
//  CustomViewPresenter
//
//  Created by Vignesh on 05/02/20.
//

import UIKit

public protocol CustomViewPresentable {
    
    func didChangeToFullScreen()
    var heightForMiniMode: CGFloat? { get set }
    var shouldExpandToMaxMode: Bool { get }
}

public extension CustomViewPresentable {
    
    var shouldExpandToMaxMode: Bool {
        return true
    }
}

public extension CustomViewPresentable where Self: UIViewController {
    func maximizeToFullScreen() {
        guard let presentation = navigationController?.presentationController as? CustomViewPresentationController, presentation.state == .mini,
              self.shouldExpandToMaxMode else { return }
        let duration: DispatchTime = .now() + 0.35
        DispatchQueue.main.asyncAfter(deadline: duration) {
            presentation.adjustViewTo(to: .max)
        }
    }
}

public extension CustomViewPresentable where Self: UINavigationController {
    func isHalfModalMaximized() -> Bool {
        if let presentationController = presentationController as? CustomViewPresentationController, !presentationController.isMaximized {
            return presentationController.isMaximized
        }
        return false
    }
}

internal enum CustomTransitionAnimatorType {
    case present
    case dismiss
}

public protocol CustomViewDelegateProtocol {
    func didChangeToMaxMode()
}
