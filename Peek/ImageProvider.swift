//
//  File.swift
//  Peek
//
//  Created by Naga Praveen Kumar Pendyala on 5/23/16.
//  Copyright © 2016 Peek. All rights reserved.
//

import Foundation
import UIKit

class ImageProvider {
    
    // Optional - you can create the object and pass it instead
    static let sharedInstance = ImageProvider()
    
    let imageCache = NSCache()
    
    // Gets an image.
    func imageWithName(name: String, completion: (image: UIImage) -> Void) {
        
        let imageFileName = name
        let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let imagePath = (documents as NSString).stringByAppendingPathComponent(name)

        if let cachedImage = imageCache.objectForKey(name) as? UIImage {
            completion(image: cachedImage)
        } else {
            dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_DEFAULT.rawValue), 0)) {
                if let cachedImage = UIImage(contentsOfFile: imagePath) {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.imageCache.setObject(cachedImage, forKey: name)
                        completion(image: cachedImage)
                    }
                } else {
                    dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_DEFAULT.rawValue), 0)) {
                        if let url = NSURL(string: imageFileName), data = NSData(contentsOfURL: url), let image = UIImage(data: data) {
                            UIImageJPEGRepresentation(image, 100)!.writeToFile(imagePath, atomically: true)
                            dispatch_async(dispatch_get_main_queue()) {
                                self.imageCache.setObject(image, forKey: name)
                                completion(image: image)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Call this method to clear the cache on a memory warning.
    func clearCache() {
        imageCache.removeAllObjects()
    }
}

