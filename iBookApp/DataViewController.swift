//
//  DataViewController.swift
//  iBookApp
//
//  Created by Stephane Darcy SIMO MBA on 14/02/2018.
//  Copyright © 2018 Test. All rights reserved.
//

import UIKit

class DataViewController: UIViewController {
    var type: Type?
    var dataObject: String = ""
    var pageNb_: String = ""
}

class SimpleViewController: DataViewController {

    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var pageNb: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.dataLabel!.text = dataObject
        self.pageNb.text = pageNb_
    }
}

class WebViewController: DataViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pagenb: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.pagenb.text = pageNb_
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.delegate = self
        let url = URL(string: dataObject)
        
        if (url != nil) {
            let request = URLRequest(url: url!)
            webView.loadRequest(request)
        }
    }
    
    @IBAction func prevAction(_ sender: Any) {
        webView.goBack()
    }
    
    @IBAction func nextAction(_ sender: Any) {
        webView.goForward()
    }
    
    // MARK: - Web View delegate
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        let textLabel = UILabel()
        textLabel.center = webView.center
        textLabel.font = textLabel.font.withSize(20)
        textLabel.text = error.localizedDescription
        webView.addSubview(textLabel)
    }
    
}

