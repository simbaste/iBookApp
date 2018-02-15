//
//  ModelController.swift
//  iBookApp
//
//  Created by Stephane Darcy SIMO MBA on 14/02/2018.
//  Copyright © 2018 Test. All rights reserved.
//

import UIKit
import RxSwift

/*
 A controller object that manages a simple model -- a collection of month names.
 
 The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
 It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
 
 There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
 */

typealias AnyDict = [String: Any]

extension String {
    
    func isValidURL() -> Bool {
        var isValid = false
        
        if self.contains(".") {
            let head       = "((http|https)://)?([(w|W)]{3}+\\.)?"
            let tail       = "\\.+[A-Za-z]{2,3}+(\\.)?+(/(.)*)?"
            
            let urlRegEx = head+"+(.)+"+tail
            
            let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
            isValid = urlTest.evaluate(with: self.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        return isValid
    }
}

enum Type: Int {
    case webview = 1
    case simpleview = 2
}

struct PageType {
    var pageData: String
    var type: Type
    
    init?(dictionary: AnyDict) {
        guard let m_pageData = dictionary["pageData"] as? String,
            let m_type = dictionary["type"] as? Type else {
                return nil
        }
        pageData = m_pageData
        type = m_type
    }
    
    init(pageData: String, type: Type) {
        self.pageData = pageData
        self.type = type
    }
    
    // MARK: - Event -> JSON
    var dictionary: AnyDict {
        return [
            "pageData": pageData,
            "type" : type,
        ]
    }
}

func cachedFileURL(_ fileName: String) -> URL {
    return FileManager.default
        .urls(for: .cachesDirectory, in: .allDomainsMask)
        .first!
        .appendingPathComponent(fileName)
}

class ModelController: NSObject, UIPageViewControllerDataSource {

    var pageData = Variable<[PageType]>([])
    var isDelete = false
    
    var iBookFileURL: URL! = cachedFileURL("iBookApp.plist")
    var iBookArray = [AnyDict]()

    static var shared: ModelController?
    
    var index: Int = 0

    override init() {
        super.init()

        let iBookArray = (NSArray(contentsOf: iBookFileURL) as? [[String: Any]]) ?? []
        
        pageData.value = iBookArray.flatMap { dict in
            let data = dict["pageData"] as! String
            let type = Type(rawValue: dict["type"] as! Int)!

            return PageType(pageData: data, type: type)
        }
    }
    
    func addData(data: String) {
        
        var page = PageType(pageData: data, type: .simpleview)
        if data.isValidURL() {
            page.type = .webview
            if page.pageData.hasPrefix("www.") {
                page.pageData = "http://"+page.pageData
            } else if !page.pageData.hasPrefix("http://www.") {
                if !page.pageData.hasPrefix("https://wwww.") {
                    page.pageData = "http://www."+page.pageData
                }
            }
        }
        if (!pageData.value.isEmpty) {
            if (index >= pageData.value.count) {
                index = pageData.value.count-1
            }
            pageData.value.insert(page, at: index+1)
        } else {
            pageData.value = [page]
        }
    }
    
    func deleteData() {
        if pageData.value.isEmpty {
            return
        }
        let sup = index
        
        if (pageData.value.count > 0) {
            if (index > 0) {
                index = index - 1
            }
        }
        isDelete = true
        pageData.value.remove(at: sup)
    }

    func viewControllerAtIndex(_ my_index: Int, storyboard: UIStoryboard) -> SimpleViewController? {
        // Return the data view controller for the given index.
        if (self.pageData.value.count == 0) || (index >= self.pageData.value.count) {
            return nil
        }

        // Create a new view controller and pass suitable data.
        let dataViewController = storyboard.instantiateViewController(withIdentifier: "SimpleViewController") as! SimpleViewController
        dataViewController.dataObject = self.pageData.value[index].pageData
        dataViewController.type = .simpleview
        if (pageData.value.count > 0) {
            dataViewController.pageNb_ = "page \(index+1)/\(pageData.value.count)"
        }
        return dataViewController
    }
    
    func viewControllerAtIndex(_ my_index: Int, storyboard: UIStoryboard) -> WebViewController? {
        // Return the data view controller for the given index.
        if (self.pageData.value.count == 0) || (index >= self.pageData.value.count) {
            return nil
        }
        
        // Create a new view controller and pass suitable data.
        let dataViewController = storyboard.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        dataViewController.dataObject = self.pageData.value[index].pageData
            dataViewController.type = .webview
        if (pageData.value.count > 0) {
            dataViewController.pageNb_ = "page \(index+1)/\(pageData.value.count)"
        }
        return dataViewController
    }

    func indexOfViewController(_ viewController: DataViewController) -> Int {
        return pageData.value.index(where: { page in
            return viewController.dataObject == page.pageData
        }) ?? NSNotFound
    }

    // MARK: - Page View Controller Data Source

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        index = self.indexOfViewController((viewController as? DataViewController)!)
        if index >= pageData.value.count {
            index = 0
            return nil
        }
        
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index -= 1
        if pageData.value[index].type == .simpleview {
            return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)! as SimpleViewController
        } else {
            return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)! as WebViewController
        }
        
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        index = self.indexOfViewController(viewController as! DataViewController)
        
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        if index >= self.pageData.value.count {
            index = self.pageData.value.count-1
            return nil
        }
        if pageData.value[index].type == .simpleview {
            return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)! as SimpleViewController
        } else {
            return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)! as WebViewController
        }
    }
}

