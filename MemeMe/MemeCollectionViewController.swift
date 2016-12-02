//
//  MemeCollectionCollectionViewController.swift
//  MemeMe
//
//  Created by Jason Southwell on 11/29/16.
//  Copyright © 2016 Jason Paul Southwell. All rights reserved.
//

import UIKit

private let reuseIdentifier = "MemeCollectionViewCell"

class MemeCollectionViewController: UICollectionViewController {
    
    @IBOutlet var flowLayout: UICollectionViewFlowLayout!
    
    var memes = [Meme]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.reloadData()
    
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let orientation = UIApplication.shared.statusBarOrientation
        if(orientation == .landscapeLeft || orientation == .landscapeRight){
            return CGSize(width:( collectionView.frame.size.width-10)/2, height: (collectionView.frame.size.height-10)/2)
        }
        else{
            return CGSize(width:(collectionView.frame.size.width-5)/2, height: (collectionView.frame.size.height-10)/3)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.collectionView!.reloadData()
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        memes = appDelegate.memes
        print("updated")
        return memes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> MemeCollectionViewCellController {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemeCollectionViewCell", for: indexPath) as! MemeCollectionViewCellController

        let meme = memes[(indexPath as NSIndexPath).row]
        
        cell.memeImageView?.image = meme.memedImage

        return cell
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let memeDetailController = self.storyboard!.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController
        memeDetailController.meme = self.memes[(indexPath as NSIndexPath).row]
        memeDetailController.meme_index = indexPath as NSIndexPath?
        self.navigationController!.pushViewController(memeDetailController, animated: true)
        
    }
    
    

    

}
