//
//  TweetDownload.swift
//  Peek
//
//  Created by Naga Praveen Kumar Pendyala on 5/23/16.
//  Copyright © 2016 Peek. All rights reserved.
//

import Foundation

protocol TweetDownloadDelegate{
    func finishedDownloading()
}

public class TweetDownload:NSObject {
    
    var tweets = [Tweet]()
    
    var delegate:TweetDownloadDelegate?
    
    let consumerKey = "OUJk9zSQKsRcT1AS3g9DqZHYA"
    let consumerSecret = "cpBqmecKhV5N2PYiicm4ve5pmzIIX453gpQfnPR3VcHLrQfu9b"
    let host = "api.twitter.com"
    
    // MARK:- Bearer Token
    func getBearerToken(completion:(bearerToken: String) ->Void) {
        
        let components = NSURLComponents()
        components.scheme = "https";
        components.host = self.host
        components.path = "/oauth2/token";
        
        let url = components.URL;
        
        let request = NSMutableURLRequest(URL:url!)
        
        request.HTTPMethod = "POST"
        request.addValue("Basic " + getBase64EncodeString(), forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        let grantType =  "grant_type=client_credentials"
        
        request.HTTPBody = grantType.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        NSURLSession.sharedSession() .dataTaskWithRequest(request, completionHandler: { (data: NSData?, response:NSURLResponse?, error: NSError?) -> Void in
            
            do {
                if let results: NSDictionary = try NSJSONSerialization .JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments  ) as? NSDictionary {
                    if let token = results["access_token"] as? String {
                        completion(bearerToken: token)
                    } else {
                        print(results["errors"])
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }).resume()
        
    }
    
    
    // MARK:- base64Encode String
    
    func getBase64EncodeString() -> String {
        
        let consumerKeyRFC1738 = consumerKey.stringByAddingPercentEncodingWithAllowedCharacters( NSCharacterSet.URLQueryAllowedCharacterSet())
        
        let consumerSecretRFC1738 = consumerSecret.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
        let concatenateKeyAndSecret = consumerKeyRFC1738! + ":" + consumerSecretRFC1738!
        
        let secretAndKeyData = concatenateKeyAndSecret.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)
        
        let base64EncodeKeyAndSecret = secretAndKeyData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
        
        return base64EncodeKeyAndSecret!
    }
    
    // MARK:- Service Call
    
    func getResponseForRequest(url:String, refresh: Bool) {
        
        getBearerToken({ (bearerToken) -> Void in
            
            let request = NSMutableURLRequest(URL: NSURL(string: url)!)
            request.HTTPMethod = "GET"
            
            let token = "Bearer " + bearerToken
            
            request.addValue(token, forHTTPHeaderField: "Authorization")
            
            NSURLSession.sharedSession() .dataTaskWithRequest(request, completionHandler: { (data: NSData?, response:NSURLResponse?, error: NSError?) -> Void in
                self.processResult(data!, response: response!, error: error, refresh: refresh)
                
            }).resume()
        })
        
    }
    
    func postRequest(url:String, completionBolck:(message : String) -> Void){
        
        var errMsg: String = "None"
        
        getBearerToken({ (bearerToken) -> Void in
            
            let request = NSMutableURLRequest(URL: NSURL(string: url)!)
            request.HTTPMethod = "POST"
            
            let token = "Bearer " + bearerToken
            
            request.addValue(token, forHTTPHeaderField: "Authorization")
            
            NSURLSession.sharedSession() .dataTaskWithRequest(request, completionHandler: { (data: NSData?, response:NSURLResponse?, error: NSError?) -> Void in
                 errMsg = self.Result(data!, response: response!, error: error)
                 completionBolck(message: errMsg)
            }).resume()
        })
    }
    
    func Result(data: NSData, response:NSURLResponse, error: NSError?) -> String{
        
        var errMsg: String = "None"
        
        do {
            
            if let results: NSDictionary = try NSJSONSerialization .JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments  ) as? NSDictionary {
                
                if let statuses = results["statuses"] as? NSMutableArray {
                    for status in statuses {
                        return status["id"] as! String
                    }
                    
                } else {
                    let errors = results["errors"] as? NSMutableArray
                    let error = errors![0] as! NSDictionary
                    errMsg = error["message"] as! String
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return errMsg
    }
    
    // MARK:- Process results
    
    func processResult(data: NSData, response:NSURLResponse, error: NSError?, refresh: Bool){
        
        do {
            if let results: NSDictionary = try NSJSONSerialization .JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments  ) as? NSDictionary {
                if let statuses = results["statuses"] as? NSMutableArray {
                    if(refresh == true)
                    {
                        tweets.removeAll() 
                    }
                    for status in statuses {
                        let user = status["user"] as? NSDictionary
                        let tweet = Tweet(name: user!["name"] as! String, tweet: status["text"] as! String, avatar: user!["profile_image_url_https"] as! String, id: status["id_str"] as! String)
                        tweets.append(tweet)
                    }
                    self.delegate?.finishedDownloading()
                    
                } else {
                    print(results["errors"])
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }


}