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
}

public extension CustomViewPresentable where Self: UIViewController {
    func maximizeToFullScreen() {
        if let presentation = navigationController?.presentationController as? CustomViewPresentationController, presentation.state == .mini {
            let duration: DispatchTime = .now() + 0.35
            DispatchQueue.main.asyncAfter(deadline: duration) {
                presentation.adjustViewTo(to: .max)
            }
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
