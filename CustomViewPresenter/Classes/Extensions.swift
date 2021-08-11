//
//  Extensions.swift
//  CustomViewPresenter
//
//  Created by Vignesh on 05/02/20.
//

import UIKit

public extension UIViewController {
    
    /// This method presents the view in an interactive way using the custom view presenter.
    /// - Parameters:
    ///   - viewController: The view controller to be presented.
    ///   - animated: A bool property that denotes whether the presentation should be animated or not.
    ///   - completionBlock: A block which will occur after the view has been presented.
    ///   - shouldBeMaximised: A bool property to denote the initial state of the presented view. FALSE - HalfSizeMode, TRUE - FullScreenMode
    final func interactivelyPresent(_ viewController: UIViewController, animated: Bool, onCompletion completionBlock: (()->Void)?, shouldBeMaximized: Bool = false) {
        
        let transitioningDelegate = CustomViewTransitioningDelegate(viewController: self, presentingViewController: viewController, shouldBeMaximised: shouldBeMaximized)
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = transitioningDelegate
        self.present(viewController, animated: animated, completion: completionBlock)
    }
    

    final func getKeyboardHeight(fromNotification notification: Notification) -> CGFloat {
        
        guard let userInfo = notification.userInfo, let rect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return 0
        }
        
        return self.view.convert(rect, from: nil).height
    }

    final func getKeyboardTransitionDuration(fromNotification notification: Notification) -> TimeInterval {
        
        guard let userInfo = notification.userInfo, let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return 0
        }
        
        return duration
    }

}

extension UIView {
    @available(iOS 11.0, *)
    func setRoundedTopCorners(withCornerRadius cornerRadius: CGFloat = 20) {
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
}
