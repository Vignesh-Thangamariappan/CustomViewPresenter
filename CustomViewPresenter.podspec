#
# Be sure to run `pod lib lint CustomViewPresenter.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CustomViewPresenter'
  s.version          = '0.1.4'
  s.summary          = 'A custom presenter to display views.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A simple and customizable pod to adaptively present your views with a smooth and interactive transition.
                       DESC

  s.homepage         = 'https://github.com/Vignesh-Thangamariappan/CustomViewPresenter/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'vignesh.mariappan@anywhere.co' => 'vignesh.mariappan@anywhere.co' }
  s.source           = { :git => 'https://github.com/Vignesh-Thangamariappan/CustomViewPresenter.git' }

  s.ios.deployment_target = '8.0'

  s.source_files = 'CustomViewPresenter/Classes/**/*'
  s.swift_version = '5.0'
  # s.resource_bundles = {
  #   'CustomViewPresenter' => ['CustomViewPresenter/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
end
