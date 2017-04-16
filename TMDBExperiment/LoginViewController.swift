//
//  LoginViewController.swift
//  TMDBExperiment
//
//  Created by Online Training on 4/16/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//
/*
 About LoginViewController.swift
 VC to provide functionality to commence login process for TMDB.
 Upon pressing of login button, VC creates a dataTask to retrieve a new token.
 Successful retrieval of token will launch WebAuthVC
 */
import UIKit

class LoginViewController: UIViewController {

    // hard-code tmdb params
    let scheme = "https"
    let host = "api.themoviedb.org"
    let path = "/3"
    let apiKey = "aadfd5df8a93f2adb470ffac7193bad9"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // login button action
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        /*
         Hard-code parameters/path to create task for new token.
         This is working..able to retrieve token and launch WebAuthVC
        */
        let params = ["api_key": "aadfd5df8a93f2adb470ffac7193bad9"]
        let url = urlFromParams(params as [String : AnyObject], pathExtentions: "/authentication/token/new")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            guard error == nil else {
                print("new token request: error")
                return
            }
            
            guard let sc = (response as? HTTPURLResponse)?.statusCode,
                sc >= 200, sc <= 299 else {
                    print("new token requst: non-2xx status code")
                    return
            }
            
            guard let data = data else {
                print("new token request: no data returned")
                return
            }
            
            let json:[String:AnyObject]!
            do {
                json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            }
            catch {
                print("new token request: bad json")
                return
            }
            
            // test json for token
            if let token = json["request_token"] as? String {
                // good token..print success message
                print("New token success")
                print(json)
                
                // invoke WebAuthVC..set token property in VC
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "WebAuthViewController") as! WebAuthViewController
                controller.token = token
                
                DispatchQueue.main.async {
                    self.present(controller, animated: true, completion: nil)
                }
            }
        }
        task.resume()
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

