# CustomViewPresenter

[![Version](https://img.shields.io/cocoapods/v/CustomViewPresenter.svg?style=flat)](https://cocoapods.org/pods/CustomViewPresenter)
[![License](https://img.shields.io/cocoapods/l/CustomViewPresenter.svg?style=flat)](https://cocoapods.org/pods/CustomViewPresenter)
[![Platform](https://img.shields.io/cocoapods/p/CustomViewPresenter.svg?style=flat)](https://cocoapods.org/pods/CustomViewPresenter)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

CustomViewPresenter is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CustomViewPresenter'
```

## Implementation

It is very simple to implement. Make use this method from your view controller to present any view with this Custom Presenter.
```
interactivelyPresent(viewControllerToPresent, isAnimated, completionBlock)
```



You can also customize the appearance of the background view whilst presenting. By default, the background will be blurred but the size will not be adjusted. 
```
shouldBlurBackground: Bool
shouldTransformBackgroundView: Bool
```



You can also customize the appearance of the view by using this method. You can set the 'shouldBeMaximized' property to true to load the view in full screen.

```
interactivelyPresent(viewControllerToPresent, isAnimated, completionBlock, shouldBeMaximised)
```

## Author

vignesh.mariappan@anywhere.co, vignesh.mariappan@anywhere.co

## License

CustomViewPresenter is available under the MIT license. See the LICENSE file for more info.
