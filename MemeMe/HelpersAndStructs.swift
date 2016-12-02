//
//  Modules.swift
//  MemeMe
//
//  Created by Jason Southwell on 11/29/16.
//  Copyright © 2016 Jason Paul Southwell. All rights reserved.
//

import Foundation
import UIKit

class Helper {
    
    static func setAppDelegate() -> AppDelegate {
        let object = UIApplication.shared.delegate
        let appDelegate = (object as! AppDelegate)
        return appDelegate
        
    }
    
    
    static func deleteDocuments() {
        
        let fileMgr = FileManager()
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        if let directoryContents = try? fileMgr.contentsOfDirectory(atPath: dirPath) {
            for path in directoryContents {
                let fullPath = (dirPath as NSString).appendingPathComponent(path)
                _ = try? fileMgr.removeItem(atPath: fullPath)
            }
        }
        
    }
    
    
    
    static func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory as NSString
    }
    
    
    
    static func saveImageToDocumentsDirectory(memeImageString: String, memeImage: UIImage) {
        
        let documentsDirectoryURL = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let fileURL = documentsDirectoryURL.appendingPathComponent(memeImageString)
        
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try UIImagePNGRepresentation(memeImage)!.write(to: fileURL)
                print("Image Added Successfully")
            } catch {
                print(error)
            }
        } else {
            print("Image Not Added")
        }
        
        
    }
}


extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!)
    }
}

struct Meme {
    let bottomText: String
    let topText: String
    let image: UIImage
    let memedImage: UIImage
    let imageImageIndexString: String
    
    
}



