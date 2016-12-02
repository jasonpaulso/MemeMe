//
//  MemeTableViewController.swift
//  MemeMe
//
//  Created by Jason Southwell on 11/29/16.
//  Copyright © 2016 Jason Paul Southwell. All rights reserved.
//

import UIKit

class MemeTableViewController: UITableViewController {
    
    var memes = [Meme]()
    
    var appDelegate: AppDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView!.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView!.reloadData()
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let appDelegate = Helper.setAppDelegate()
        memes = appDelegate.memes
        return memes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemeTableViewCellCustom", for: indexPath) as! MemeTableViewCellController
        let meme = memes[(indexPath as NSIndexPath).row]
        cell.memeTableViewImage.image = meme.memedImage
        cell.memeTableCellBottomLabel.text = meme.bottomText
        cell.memeTableCellTopLabel.text = meme.topText
        return cell
    }
    

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected")
        let memeDetailController = self.storyboard!.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController
        memeDetailController.meme = self.memes[(indexPath as NSIndexPath).row]
        memeDetailController.meme_index = indexPath as NSIndexPath?
        self.navigationController!.pushViewController(memeDetailController, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let appDelegate = Helper.setAppDelegate()
        if editingStyle == .delete {
            appDelegate.memes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//        }
    }

}
