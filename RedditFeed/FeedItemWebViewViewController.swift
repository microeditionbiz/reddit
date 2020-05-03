//
//  FeedItemViewController.swift
//  RedditFeed
//
//  Created by Pablo Ezequiel Romero Giovannoni on 01/05/2020.
//  Copyright © 2020 Microedition.biz. All rights reserved.
//

import UIKit
import WebKit

class FeedItemWebViewViewController: UIViewController, MessagePresenter {

    weak var webView: WKWebView?
    fileprivate var spinner: UIActivityIndicatorView!

    var viewModel: FeedItemViewModelProtocol? {
        willSet {
            if newValue?.mainContent != viewModel?.mainContent {
                removeWebView()
            }
        }
        didSet {
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    func updateUI() {
        guard isViewLoaded else { return }
        title = viewModel?.title
        if let url = viewModel?.mainContent {
            loadWebView(url: url)
        }
    }
    
    private func loadWebView(url: URL) {
        if webView == nil {
            let webConfiguration = WKWebViewConfiguration()
            let webView = WKWebView(frame: self.view.bounds, configuration: webConfiguration)
            webView.translatesAutoresizingMaskIntoConstraints = false
            
            self.view.addSubview(webView)
        
            NSLayoutConstraint.activate([
                webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
            ])
            
            webView.navigationDelegate = self
            
            webView.backgroundColor = .clear
            webView.scrollView.backgroundColor = .clear
            webView.isOpaque = false
            webView.navigationDelegate = self
            
            self.webView = webView
        }
        
        webView!.load(URLRequest(url: url))
    }
    
    private func removeWebView() {
        guard isViewLoaded else { return }
        webView?.removeFromSuperview()
        webView = nil
    }
    
    private func setLoadingMode(_ loadingModeOn: Bool) {
        if loadingModeOn && spinner == nil {
            let spinner = UIActivityIndicatorView(style: .large)
            spinner.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(spinner)
            
            spinner.startAnimating()
            spinner.center = CGPoint(x: view.bounds.size.width / 2.0,
                                     y: view.bounds.size.height / 2.0)
            
            NSLayoutConstraint.activate([
                spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ])
          
            self.spinner = spinner
        } else if !loadingModeOn && spinner != nil {
            spinner?.removeFromSuperview()
            spinner = nil
        }
    }
    
    @IBAction func shareButtonTouched(_ sender: UIBarButtonItem) {
        presentActivityViewController()
    }
    
    fileprivate func presentActivityViewController() {
        guard let url = viewModel?.mainContent else {
            presentAlert(withMessage: NSLocalizedString("Invalid Link", comment: ""))
            return
        }
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(vc, animated: true, completion: nil)
    }
    
}

// MARK: -

extension FeedItemWebViewViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        setLoadingMode(true)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        setLoadingMode(false)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        setLoadingMode(false)
    }
    
}
