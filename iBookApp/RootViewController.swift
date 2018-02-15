//
//  RootViewController.swift
//  iBookApp
//
//  Created by Stephane Darcy SIMO MBA on 14/02/2018.
//  Copyright © 2018 Test. All rights reserved.
//

import UIKit
import RxSwift

class RootViewController: UIViewController, UIPageViewControllerDelegate {

    @IBOutlet weak var delButton: UIBarButtonItem!
    
    var pageViewController: UIPageViewController?
    let disposeBag = DisposeBag()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ModelController.shared = {
            if _modelController == nil {
                _modelController = ModelController()
            }
            return _modelController!
        }()
        subscribeToData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        delButton.isEnabled = false
        self.pageViewController = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
        self.pageViewController!.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func subscribeToData() {
        ModelController.shared?.pageData
            .asObservable()
            .subscribe(onNext: { element in
                
                var nbr: Int = (ModelController.shared?.pageData.value.count)!
                if (ModelController.shared?.isDelete)! {
                    ModelController.shared?.isDelete = false
                    if nbr > 0 {
                        let index = ModelController.shared?.index
                        
                        self.initPageViewController(type: (ModelController.shared?.pageData.value[index!].type)!, index: index!)
                    } else {
                        self.delButton.isEnabled = false
                        ModelController.shared?.index = 0
                        self.pageViewController?.willMove(toParentViewController: nil)
                        self.pageViewController?.view.removeFromSuperview()
                        self.pageViewController?.removeFromParentViewController()
                        self.pageViewController = UIPageViewController()

                    }
                } else if (nbr > 0 && (self.pageViewController?.viewControllers == nil || self.pageViewController?.viewControllers?.count == 0)) {
                    self.initPageViewController(type: (ModelController.shared?.pageData.value[0].type)!, index: 0)
                } else {
                        self.pageViewController?.reloadInputViews()
                        nbr = (self.pageViewController?.viewControllers?.count)!
                    
                        if (self.pageViewController?.viewControllers != nil &&
                        nbr > 0) {
                            let currentViewController = self.pageViewController!.viewControllers![0] as! DataViewController
                            if let nextViewController = ModelController.shared?.pageViewController(self.pageViewController!, viewControllerAfter: currentViewController) {
                                self.pageViewController?.setViewControllers([nextViewController], direction: .forward, animated: false, completion: nil)
                            }
                        } else {
                            self.pageViewController?.setViewControllers([], direction: .forward, animated: true, completion: nil)
                    }
                }
                
                let iBookArray = element.map { elem -> AnyDict in
                    let type: Int = elem.type == .webview ? 1 : 2
                    return ["pageData": elem.pageData, "type": NSNumber(value: type)]
                } as NSArray
                if !iBookArray.write(to: (ModelController.shared?.iBookFileURL)!, atomically: true) {
                }
            })
            .disposed(by: disposeBag)
    }
    
    func initPageViewController(type: Type, index: Int) {
        if type == .simpleview {
            let startingViewController: SimpleViewController = ModelController.shared!.viewControllerAtIndex(index, storyboard: self.storyboard!)!
            let viewControllers = [startingViewController]
            
            self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: false, completion: {done in })
        } else {
            let startingViewController: WebViewController = ModelController.shared!.viewControllerAtIndex(index, storyboard: self.storyboard!)!
            let viewControllers = [startingViewController]
            
            self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: false, completion: {done in })
        }
        
        delButton.isEnabled = true
        self.pageViewController!.dataSource = ModelController.shared
        
        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)
        
        // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
        var pageViewRect = self.view.bounds
        if UIDevice.current.userInterfaceIdiom == .pad {
            pageViewRect = pageViewRect.insetBy(dx: 40.0, dy: 40.0)
        }
        self.pageViewController!.view.frame = pageViewRect
        
        self.pageViewController!.didMove(toParentViewController: self)
    }
    
    // MARK: Add action
    
    @IBAction func addViewAction(_ sender: Any) {
        //let popUpView = Bundle.main.loadNibNamed("PopUpViewController", owner: self, options: nil)?.first as! PopUPViewController
        
        let popUpView = self.storyboard?.instantiateViewController(withIdentifier: "PopUPViewController") as! PopUPViewController
        self.addChildViewController(popUpView)
        self.view.addSubview(popUpView.view)
        popUpView.didMove(toParentViewController: self)
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        ModelController.shared?.deleteData()
    }
    
    var _modelController: ModelController?
    
    // MARK: - UIPageViewController delegate methods

    func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewControllerSpineLocation {

        if (orientation == .portrait) || (orientation == .portraitUpsideDown) || (UIDevice.current.userInterfaceIdiom == .phone) {
            // In portrait orientation or on iPhone: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to true, so set it to false here.
            let currentViewController = self.pageViewController!.viewControllers![0]
            let viewControllers = [currentViewController]
            self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: true, completion: {done in })

            self.pageViewController!.isDoubleSided = false
            return .min
        }

        // In landscape orientation: Set set the spine location to "mid" and the page view controller's view controllers array to contain two view controllers. If the current page is even, set it to contain the current and next view controllers; if it is odd, set the array to contain the previous and current view controllers.
        let currentViewController = self.pageViewController!.viewControllers![0] as! DataViewController
        var viewControllers: [UIViewController]
        let indexOfCurrentViewController: Int
        
        if currentViewController.type == .simpleview {
            
            indexOfCurrentViewController = (ModelController.shared?.indexOfViewController(currentViewController as! SimpleViewController))!
        } else {
            indexOfCurrentViewController = (ModelController.shared?.indexOfViewController(currentViewController as! WebViewController))!
        }
        
        if (indexOfCurrentViewController == 0) || (indexOfCurrentViewController % 2 == 0) {
            let nextViewController = ModelController.shared?.pageViewController(self.pageViewController!, viewControllerAfter: currentViewController)
            viewControllers = [currentViewController, nextViewController!]
        } else {
            let previousViewController = ModelController.shared?.pageViewController(self.pageViewController!, viewControllerBefore: currentViewController)
            viewControllers = [previousViewController!, currentViewController]
        }
        self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: true, completion: {done in })

        return .mid
    }


}

