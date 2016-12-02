//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Jason Southwell on 11/29/16.
//  Copyright © 2016 Jason Paul Southwell. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController, UIScrollViewDelegate {
    
    var meme: Meme!
    var meme_index: NSIndexPath?

    @IBOutlet var imageZoom: UIScrollView!
    @IBOutlet var memeEditButton: UIBarButtonItem!
    @IBOutlet var memeDetailView: UIImageView!
    
    @IBAction func memeIndexButtonPressed(_ sender: Any) {
        editButtonTapped()
    }
    override func viewDidLoad() {
        
        imageZoom.maximumZoomScale = 5
        imageZoom.minimumZoomScale = 1
        super.viewDidLoad()
        self.memeDetailView!.image = meme.memedImage

    }


    func editButtonTapped() {
 
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let memes = appDelegate.memes
        let MemeEditorViewController = self.storyboard!.instantiateViewController(withIdentifier: "MemeEditorViewController") as! MemeEditorViewController
        MemeEditorViewController.meme = memes[(meme_index! as NSIndexPath).row]
        MemeEditorViewController.memeIndex = meme_index! as NSIndexPath
        self.navigationController!.present(MemeEditorViewController, animated: true)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return memeDetailView
    }

}
