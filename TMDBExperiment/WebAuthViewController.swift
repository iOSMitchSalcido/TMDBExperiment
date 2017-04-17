//
//  WebAuthViewController.swift
//  TMDBExperiment
//
//  Created by Online Training on 4/16/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//
/*
 About WebAuthViewController.swift:
 Present a webView with request for tmdb auth url. Upon successful completion of tmdb login
 within the webView, retrieve session ID.
 
 This is where I'm having problems. Unable to consistantly retrieve session id. It seems I can very rarely
 get a session id, but only after I reset iPhone simulator and do a clean build. Even if I can get it to work,
 it won't work subsequent times.
 */
import UIKit

class WebAuthViewController: UIViewController {

    // hard-code tmdb params
    let scheme = "https"
    let host = "api.themoviedb.org"
    let path = "/3"
    let apiKey = "e1e8307ad4cd932629ea3e3504541260"
    
    // ref to webView
    @IBOutlet weak var webView: UIWebView!
    
    // ref to token..retrieved and set in LoginVC
    var token:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // delegate
        webView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // create auth url, load into webView
        let urlString = "https://www.themoviedb.org/authenticate/" + token
        let url = URL(string: urlString)
        let request = URLRequest(url: url!)
        webView.loadRequest(request)
    }
    
    // create url from parameters and path extension
    func urlFromParams(_ params: [String:AnyObject], pathExtentions: String? = nil) -> URL {
        
        var components = URLComponents()
        components.path = path + (pathExtentions ?? "")
        components.scheme = scheme
        components.host = host
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in params {
            let item = URLQueryItem(name: key, value: "\(value)")
            components.queryItems?.append(item)
        }
        return components.url!
    }
}

extension WebAuthViewController: UIWebViewDelegate {
 
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        // request url string
        let requestString = request.url!.absoluteString
        
        // authString..this is what's expected for successful auth
        let authString = "https://www.themoviedb.org/authenticate/" + token + "/allow"
        
        // test for succes
        if requestString == authString {
            
            /*
             Currently in webView the "Access Granted" page has just been loaded
             */
            
            
            /*
             Hard-code parameters/path to create task for new tsession.
             !!! THIS IS NOT WORKING...ACTUALLY ALMOST NEVER WORKS !!
             Every once in a while, after I reset the iPhone simulator and do a clean
             build I get success.
             Fails at status code test "401"
             */
            let params = ["api_key": apiKey,
                          "request_token": token]
            let url = urlFromParams(params as [String : AnyObject], pathExtentions: "/authentication/session/new")
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.dataTask(with: request) {
                (data, response, error) in
                
                
                guard error == nil else {
                    print("sessionID error")
                    return
                }
                
                // !! Fails here
                guard let sc = (response as? HTTPURLResponse)?.statusCode,
                    sc >= 200, sc <= 299 else {
                        print("sessionID non-2xx status code")
                        return
                }
                
                guard let data = data else {
                    print("sessionID no data returned")
                    return
                }
                
                let json:[String:AnyObject]!
                do {
                    json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                }
                catch {
                    print("sessionID no json")
                    return
                }
                
                if let _ = json["session_id"] as? String {
                    print("sessionID success")
                    print(json)
                }
            }
            task.resume()
        }
        return true
    }
}
