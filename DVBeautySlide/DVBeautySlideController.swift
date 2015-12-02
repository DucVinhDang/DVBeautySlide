//
//  DVBeautySlideController.swift
//  DVBeautySlide
//
//  Created by Vinh Dang Duc on 6/27/15.
//  Copyright © 2015 Vinh Dang Duc. All rights reserved.
//

import UIKit

class DVBeautySlideController: UIViewController {
    
    enum SlideCurrentState {
        case None
        case Left
        case Right
    }
    
    enum SlideLiveState {
        case None
        case MovingLeftPanel
        case MovingRightPanel
    }
    
    // Variables
    
    weak var centerVC: UIViewController!
    weak var leftVC: UIViewController?
    weak var rightVC: UIViewController?
    
    weak var panGesture: UIPanGestureRecognizer?
    var slideCurrentState: SlideCurrentState = .None
    var slideLiveState: SlideLiveState = .None
    
    let deviceWidth = UIScreen.mainScreen().bounds.width
    let deviceHeight = UIScreen.mainScreen().bounds.height
    let distanceOffset: CGFloat = 70.0
    let timeInterval: NSTimeInterval = 0.5
    let shadowValue: Float = 0.7
    
    // MARK: - Init Methods
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(centerViewController: UIViewController, leftViewController: UIViewController, rightViewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        self.centerVC = centerViewController
        self.leftVC = leftViewController
        self.rightVC = rightViewController

        addCenterVC()
        addLeftVC()
        addRightVC()
        
        addPanGesture()
    }
    
    init(centerViewController: UIViewController, leftViewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        self.centerVC = centerViewController
        self.leftVC = leftViewController
        
        addCenterVC()
        addLeftVC()
        
        addPanGesture()
    }
    
    init(centerViewController: UIViewController, rightViewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        self.centerVC = centerViewController
        self.rightVC = rightViewController
        
        addCenterVC()
        addRightVC()
        
        addPanGesture()
    }
    
    // MARK: - Loading View States
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = true
        self.view.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
//        if toInterfaceOrientation.isLandscape {
//            if(slideCurrentState == .Right) {
//                animateViewToNewOriginX(rightVC!.view, posX: view.bounds.height - rightVC!.view.bounds.width, animate: true)
//                animateViewToNewOriginX(centerVC.view, posX: -300, animate: true)
//                //rightVC?.view.frame.origin.x = view.bounds.height - rightVC!.view.bounds.width
//            } else {
//                animateViewToNewOriginX(rightVC!.view, posX: view.bounds.height, animate: true)
//                //rightVC?.view.frame.origin.x = view.bounds.height
//            }
//        } else if toInterfaceOrientation.isPortrait {
//            if(slideCurrentState == .Right) {
//                animateViewToNewOriginX(rightVC!.view, posX: distanceOffset, animate: true)
//                //rightVC?.view.frame.origin.x = distanceOffset
//            } else {
//                animateViewToNewOriginX(rightVC!.view, posX: view.bounds.height, animate: true)
//                //rightVC?.view.frame.origin.x = view.bounds.height
//            }
//        }
//    }
    
    
    // MARK: - Add/Remove View Methods
    
    private func addCenterVC() {
        if centerVC != nil {
            centerVC.view.frame = view.frame
            centerVC.view.translatesAutoresizingMaskIntoConstraints = true
            centerVC.view.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
            self.addChildViewController(centerVC)
            self.view.addSubview(centerVC.view)
            centerVC.didMoveToParentViewController(self)
        }
    }
    
    private func addLeftVC() {
        if leftVC != nil {
            leftVC?.view.frame = CGRectMake(-(view.bounds.width - distanceOffset), 0, view.bounds.width - distanceOffset, view.bounds.height)
            leftVC?.view.translatesAutoresizingMaskIntoConstraints = true
            leftVC?.view.autoresizingMask = UIViewAutoresizing.FlexibleHeight
            self.addChildViewController(leftVC!)
            self.view.addSubview(leftVC!.view)
            leftVC?.didMoveToParentViewController(self)
        }
    }
    
    private func addRightVC() {
        if rightVC != nil {
            rightVC?.view.frame = CGRectMake(view.bounds.width, 0, view.bounds.width - distanceOffset, view.bounds.height)
            rightVC?.view.translatesAutoresizingMaskIntoConstraints = true
            rightVC?.view.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleLeftMargin]
            self.addChildViewController(rightVC!)
            self.view.addSubview(rightVC!.view)
            rightVC?.didMoveToParentViewController(self)
        }
    }
    
    // MARK: UIGestureRecognizer Methods
    
    private func addPanGesture() {
        let panG = UIPanGestureRecognizer(target: self, action: Selector("handlePanGesture:"))
        centerVC.view.addGestureRecognizer(panG)
        panGesture = panG
    }
    
    func handlePanGesture(panGesture: UIPanGestureRecognizer) {
        let moveFromLeftToRight = panGesture.velocityInView(view).x > 0
        switch panGesture.state {
        case .Began:
            if slideLiveState == .None {
                if moveFromLeftToRight {
                    slideLiveState = .MovingLeftPanel
                    //addShadowOpacityToView(currentView: leftVC!.view, shadowValue: shadowValue)
                } else {
                    slideLiveState = .MovingRightPanel
                    //addShadowOpacityToView(currentView: rightVC!.view, shadowValue: shadowValue)
                }
            } else {
                if slideLiveState == .MovingLeftPanel {
                    if moveFromLeftToRight && leftVC?.view.frame.origin.x >= 0 { return }
                } else {
                    if !moveFromLeftToRight && rightVC?.view.frame.origin.x <= distanceOffset { return }
                }
            }
            break
        case .Changed:
            if slideLiveState != .None {
                if slideLiveState == .MovingLeftPanel && leftVC?.view.frame.origin.x <= 0 {
                    leftVC?.view.frame.origin.x += panGesture.translationInView(view).x
                    centerVC.view.frame.origin.x += panGesture.translationInView(view).x/2
                    panGesture.setTranslation(CGPointZero, inView: view)
                } else if slideLiveState == .MovingRightPanel {
                    if (UIDevice.currentDevice().orientation.isPortrait.boolValue && rightVC?.view.frame.origin.x >= distanceOffset) || (UIDevice.currentDevice().orientation.isLandscape.boolValue && rightVC?.view.frame.origin.x >= distanceOffset + view.bounds.width - view.bounds.height) {
                        rightVC?.view.frame.origin.x += panGesture.translationInView(view).x
                        centerVC.view.frame.origin.x += panGesture.translationInView(view).x/2
                        panGesture.setTranslation(CGPointZero, inView: view)
                    }
                }
                
            }
            break
        case .Ended:
            if slideLiveState != .None {
                var checkMove = true
                if slideLiveState == .MovingLeftPanel {
                    checkMove = leftVC?.view.center.x >= 0
                } else if slideLiveState == .MovingRightPanel {
                    checkMove = rightVC?.view.center.x <= view.bounds.width
                }
                analysingCurrentPositionOfPanel(checkMove)
            }
            break
        default:
            break
        }
    }
    
    // MARK: Animation Of Slide Methods
    
    private func analysingCurrentPositionOfPanel(canSlide: Bool) {
        if canSlide {
            if slideLiveState == .MovingLeftPanel {
                animatePanelToNewOriginX(leftVC!.view, posX: 0, showPanel: true, animate: true)
            } else if slideLiveState == .MovingRightPanel {
                if UIDevice.currentDevice().orientation.isLandscape.boolValue {
                    animatePanelToNewOriginX(rightVC!.view, posX: distanceOffset + view.bounds.width - view.bounds.height, showPanel: true, animate: true)
                } else if UIDevice.currentDevice().orientation.isPortrait.boolValue {
                    animatePanelToNewOriginX(rightVC!.view, posX: distanceOffset, showPanel: true, animate: true)
                }
            }
        } else {
            hidePanel()
        }
    }
    
    private func animatePanelToNewOriginX(panelView: UIView, posX: CGFloat, showPanel: Bool, animate: Bool) {
        UIView.animateWithDuration(timeInterval, animations: {
            if showPanel {
                var newDistanceForCenter: CGFloat = 0
                if self.slideLiveState == .MovingLeftPanel {
                    if self.slideCurrentState != .Left {
                        newDistanceForCenter =  CGFloat(abs(Int(CGRectGetMinX(self.leftVC!.view.frame)/2)))
                        self.centerVC.view.frame.origin.x += newDistanceForCenter
                    } else {
                        self.centerVC.view.frame.origin.x = self.leftVC!.view.frame.width/2
                    }
                } else if self.slideLiveState == .MovingRightPanel {
                    if UIDevice.currentDevice().orientation.isLandscape.boolValue {
                        if self.slideCurrentState != .Right {
                            newDistanceForCenter = CGFloat(abs(Int((self.distanceOffset + self.view.bounds.width - self.view.bounds.height) - CGRectGetMinX(self.rightVC!.view.frame))/2))
                            self.centerVC.view.frame.origin.x -= newDistanceForCenter
                        } else {
                            self.centerVC.view.frame.origin.x = -(self.rightVC!.view.frame.width/2)
                        }
                    } else if UIDevice.currentDevice().orientation.isPortrait.boolValue {
                        if self.slideCurrentState != .Right {
                            newDistanceForCenter = CGFloat(abs(Int(self.distanceOffset - CGRectGetMinX(self.rightVC!.view.frame))/2))
                            self.centerVC.view.frame.origin.x -= newDistanceForCenter
                        } else {
                            self.centerVC.view.frame.origin.x = -(self.rightVC!.view.frame.width/2)
                        }
                    }
                    
                }
                
            } else {
                self.centerVC.view.frame.origin.x = 0
            }
            panelView.frame.origin.x = posX
            }, completion: { finished in
                if showPanel {
                    if self.slideLiveState == .MovingLeftPanel {
                        self.slideCurrentState = .Left
                    } else if self.slideLiveState == .MovingRightPanel {
                        self.slideCurrentState = .Right
                    }
                } else {
                    if self.slideLiveState != .None {
//                        if self.slideLiveState == .MovingLeftPanel {
//                            self.removeShadowOpacityToView(self.leftVC!.view)
//                        } else if self.slideLiveState == .MovingRightPanel {
//                            self.removeShadowOpacityToView(self.rightVC!.view)
//                        }
                        self.slideLiveState = .None
                    }
                    if self.slideCurrentState != .None {
                        self.slideCurrentState = .None
                    }
                }
        })
    }
    
    private func animateViewToNewOriginX(currentView: UIView, posX: CGFloat, animate: Bool) {
        UIView.animateWithDuration(0.3, animations: {
            currentView.frame.origin.x = posX
            }, completion: { finished in
        })
    }
    
    private func hidePanel() {
        if slideLiveState == .MovingLeftPanel {
            if UIDevice.currentDevice().orientation.isLandscape.boolValue {
                animatePanelToNewOriginX(leftVC!.view, posX: -(view.bounds.height - distanceOffset), showPanel: false, animate: true)
            } else if UIDevice.currentDevice().orientation.isPortrait.boolValue {
                animatePanelToNewOriginX(leftVC!.view, posX: -(view.bounds.width - distanceOffset), showPanel: false, animate: true)
            }
        } else if slideLiveState == .MovingRightPanel {
            animatePanelToNewOriginX(rightVC!.view, posX: view.bounds.width, showPanel: false, animate: true)
        }
    }
    
    // MARK: - Supporting Methods
    
    private func addShadowOpacityToView(currentView currentView: UIView, shadowValue: Float) {
        currentView.layer.shadowOpacity = shadowValue
    }
    
    private func removeShadowOpacityToView(viewToRemove: UIView) {
        viewToRemove.layer.shadowOpacity = 0
    }
    
    // MARK: - Request Methods
    
    func animationLeftPanel() {
        if slideLiveState == .None {
            slideLiveState = .MovingLeftPanel
            animatePanelToNewOriginX(leftVC!.view, posX: 0, showPanel: true, animate: true)
        } else {
            hideCurrentPanel()
        }
    }
    
    func animationRightPanel() {
        if slideLiveState == .None {
            slideLiveState = .MovingRightPanel
            if UIDevice.currentDevice().orientation.isLandscape.boolValue {
                animatePanelToNewOriginX(rightVC!.view, posX: distanceOffset + view.bounds.width - view.bounds.height, showPanel: true, animate: true)
            } else if UIDevice.currentDevice().orientation.isPortrait.boolValue {
                animatePanelToNewOriginX(rightVC!.view, posX: distanceOffset, showPanel: true, animate: true)
            }
        } else {
            hideCurrentPanel()
        }
    }
    
    func hideCurrentPanel() {
        hidePanel()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIViewController {
    func dvBeautySlideController() -> DVBeautySlideController? {
        var viewController: UIViewController? = self
        while viewController != nil {
            if viewController is DVBeautySlideController {
                return viewController as? DVBeautySlideController
            }
            viewController = viewController?.parentViewController
        }
        return nil
    }
    
    func toggleLeftPanel() {
        dvBeautySlideController()?.animationLeftPanel()
    }
    
    func toggleRightPanel() {
        dvBeautySlideController()?.animationRightPanel()
    }
}
