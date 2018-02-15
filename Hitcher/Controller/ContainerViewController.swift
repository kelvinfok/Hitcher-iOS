//
//  ContainerViewController.swift
//  Hitcher
//
//  Created by Kelvin Fok on 11/2/18.
//  Copyright © 2018 Kelvin Fok. All rights reserved.
//

import UIKit
import QuartzCore

enum PanelState {
    case COLLAPSED
    case EXPANDED
}

enum Screen {
    case HOME
}


var showingScreen: Screen = .HOME

class ContainerViewController: UIViewController {
    
    private let whiteCoverViewTag = 25
    
    lazy var homeViewController: HomeViewController = {
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        return viewController
    }()
    
    lazy var panelViewController: PanelViewController = {
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "PanelViewController") as! PanelViewController
        return viewController
    }()
    
    var centerViewController: UIViewController!
    
    var panelState: PanelState = .COLLAPSED {
        didSet {
            shouldShowShadowForCenterViewController(panelState == .EXPANDED)
        }
    }
    
    var isHidden = false
    let expandedOffset :CGFloat = 160
    
    var tap: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupUser()
    }
    
    func setupViews() {
        
        // Home View Controller
        homeViewController.delegate = self
        addChildViewController(homeViewController)
        homeViewController.didMove(toParentViewController: self)
        
        // Panel View Controller
        view.insertSubview(panelViewController.view, at: 0)
        addChildViewController(panelViewController)
        panelViewController.didMove(toParentViewController: self)
        
        // Center View Controller
        centerViewController = homeViewController
        view.addSubview(centerViewController.view)
        addChildViewController(centerViewController)
        centerViewController.didMove(toParentViewController: self)
    }
    
    func setupUser() {
        
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
    override var prefersStatusBarHidden: Bool {
        return isHidden
    }
}

extension ContainerViewController: CenterViewControllerDelegate {
    
    @objc func toggleLeftPanel() {
        switch panelState {
        case .COLLAPSED:
            isHidden = !isHidden
            animateStatusBar()
            setupWhiteCoverView()
            panelState = .EXPANDED
            animateCenterPanelXPosition(targetPosition: centerViewController.view.frame.width - expandedOffset)
        case .EXPANDED:
            isHidden = !isHidden
            animateStatusBar()
            hideWhiteCoverView()
            animateCenterPanelXPosition(targetPosition: 0, completion: { (isFinished) in
                if isFinished {
                    self.panelState = .COLLAPSED
                }
            })
        }
    }
    
    func animateStatusBar() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        })
    }
    
    func animateCenterPanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.centerViewController.view.frame.origin.x = targetPosition
        }, completion: completion)
    }
    
    func setupWhiteCoverView() {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        let whiteCoverView = UIView(frame: frame)
        whiteCoverView.alpha = 0.0
        whiteCoverView.backgroundColor = .white
        whiteCoverView.tag = whiteCoverViewTag
        self.centerViewController.view.addSubview(whiteCoverView)
        whiteCoverView.fadeTo(alphaValue: 0.75, withDuration: 0.2)
        tap = UITapGestureRecognizer(target: self, action: #selector(toggleLeftPanel))
        tap.numberOfTapsRequired = 1
        centerViewController.view.addGestureRecognizer(tap)
    }
    
    func hideWhiteCoverView() {
        centerViewController.view.removeGestureRecognizer(tap)
        for subview in self.centerViewController.view.subviews {
            if subview.tag == whiteCoverViewTag {
                UIView.animate(withDuration: 0.2, animations: {
                    subview.alpha = 0.0
                }, completion: { (finished) in
                    if finished {
                        subview.removeFromSuperview()
                    }
                })
            }
        }
    }
    
    func shouldShowShadowForCenterViewController(_ shouldShow: Bool) {
        if shouldShow {
            centerViewController.view.layer.shadowOpacity = 0.6
        } else {
            centerViewController.view.layer.shadowOpacity = 0.0
        }
    }
}
