//
//  ViewController.swift
//  MemeMe
//
//  Created by Jason Paul Southwell on 11/7/16.
//  Copyright © 2016 Jason Paul Southwell. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIScrollViewDelegate  {
    
    @IBOutlet var imageZoom: UIScrollView!
    
    
    @IBAction func scaleImage(_ sender: UIPinchGestureRecognizer) {
        self.memeImageView.transform = self.memeImageView.transform.scaledBy(x: sender.scale, y: sender.scale)
        sender.scale = 1
        
    }
    
    
    
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var navBar: UINavigationBar!
//    @IBOutlet weak var initialViewPlaceHolder: UIView!
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var topLabel: UITextField!
    @IBOutlet weak var bottomLabel: UITextField!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet var cancelButton: UIBarButtonItem!
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func actionButton(_ sender: Any) {
        shareMeme()
    }
    
    @IBAction func action(_ sender: UIBarButtonItem) {
        if sender.tag == 1{
            pick(sourceType: .camera)
        } else{
            pick(sourceType: .photoLibrary)
        }
    }
    
    var meme: Meme?
    var memeIndex: NSIndexPath?
    var appDelegate: AppDelegate?
    
    override func viewDidLoad() {
        
        self.imageZoom.maximumZoomScale = 5
        self.imageZoom.minimumZoomScale = 1
        

        appDelegate = Helper.setAppDelegate()
        super.viewDidLoad()
        memeImageView.frame = self.view.bounds
        if memeIndex == nil {
            setInitialView()
            print("meme is nil")
        } else {
            meme = retrieveMemeFromAppDelegate(memeIndex: memeIndex!)
            setEditView()
            print("meme is not nil")
        }
        
        if !checkForCamera() {
            cameraButton.isEnabled = false
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return memeImageView
    }
    
    
    
    func checkForCamera() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var newText = textField.text! as NSString
        newText = newText.replacingCharacters(in: range, with: string) as NSString
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    @IBOutlet var memeShareButton: UIBarButtonItem!
    @IBAction func memeShareAction(_ sender: Any) {
        shareMeme()
        
    }
    @IBOutlet var memeCancelButton: UIBarButtonItem!
  
    @IBAction func memeCancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
//    func setInitialView() {
//        imagePicker.delegate = self
//        memeImageView.image = nil
//        initialViewPlaceHolder.isHidden = false
//        actionButton.isEnabled = false
//        prepareTextField(textField: topLabel, defaultText: "Top Label")
//        prepareTextField(textField: bottomLabel, defaultText: "Bottom Label")
//    }
    
    func setInitialView() {
        imagePicker.delegate = self
        memeImageView.image = nil
//        initialViewPlaceHolder.isHidden = false
        memeShareButton.isEnabled = false
        prepareTextField(textField: topLabel, defaultText: "Top Label")
        prepareTextField(textField: bottomLabel, defaultText: "Bottom Label")
    }
    
    
    func prepareTextField(textField: UITextField, defaultText: String) {
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.black,
            NSForegroundColorAttributeName : UIColor.white,
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : -1.0,
            ] as [String : Any]
        textField.text = defaultText
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = NSTextAlignment.center
        topLabel.delegate = self
        bottomLabel.delegate = self
    }
    var memeImage: UIImage?
    
    let imagePicker = UIImagePickerController()
    
    func pick(sourceType:UIImagePickerControllerSourceType) {
        let camera = UIImagePickerController()
        camera.sourceType = sourceType
        camera.delegate = self
        present(camera, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var newImage: UIImage
        
        if let possibleImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            newImage = possibleImage
            
        } else if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            newImage = possibleImage
            
        } else {
            return
        }
//        actionButton.isEnabled = true
        memeShareButton.isEnabled = true
        memeImage = newImage
//        initialViewPlaceHolder.isHidden = true
        memeImageView.image = memeImage
        
        dismiss(animated: true)
    }
    
    
    func shareMeme() {
        let meme = generateMemedImage()
        let shareView = UIActivityViewController(activityItems: [meme], applicationActivities: nil)
        present(shareView, animated: true, completion: nil)
        shareView.completionWithItemsHandler = {
            (s, ok, items, error) in
            if ok{
                self.save()
            }
        }
    }
    
    func generateMemedImage() -> UIImage {
        
        // Hide toolbar and navbar
        toolBar.isHidden = true
        navBar.isHidden = true
        // Render view to an image
        let image = UIImage(view: self.view)
        // Show toolbar and navbar
        toolBar.isHidden = false
        navBar.isHidden = false
        return image
    }
    
    func alertForCamera() {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(displayCameraAlertMessage(message: "Photo Library", sourceType: .photoLibrary))
        alertController.addAction(displayCameraAlertMessage(message: "Camera", sourceType: .camera))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
        })
        present(alertController, animated: true, completion: nil)
    }
    
    func displayCameraAlertMessage(message:String, sourceType: UIImagePickerControllerSourceType) -> UIAlertAction {
        
        let action = UIAlertAction(title: message, style: .default) { (action) in
            self.pick(sourceType: sourceType)
        }
        return action
    }
    
    func save() {
        
        let memeImageIndexString = "memeImage_\(appDelegate?.memeImageIndex).png"
        
        let meme = Meme(bottomText: bottomLabel.text!, topText: topLabel.text!, image: memeImage!, memedImage: generateMemedImage(), imageImageIndexString: memeImageIndexString)
        
        
        let alertController = UIAlertController(title: "Save to Photo Roll", message: "Would you like to save this meme?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            
            if self.memeIndex != nil {
                self.appDelegate?.memes.remove(at: (self.memeIndex?.row)!)
            }
            
            self.appDelegate?.memes.append(meme)
            Helper.saveImageToDocumentsDirectory(memeImageString: memeImageIndexString, memeImage: self.memeImage!)
            self.appDelegate?.memeImageIndex += 1
            
            let okActionController = UIAlertController(title: "Saved!", message: nil, preferredStyle: .alert)
            
            let dismissOK = UIAlertAction(title: "OK", style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            
            okActionController.addAction(dismissOK)
            
            self.present(okActionController, animated: true, completion: nil)
        }
        alertController.addAction(OKAction)
        
        present(alertController, animated: true, completion: nil)
        
        
    }
    
    
    func retrieveMemeFromAppDelegate(memeIndex: NSIndexPath) -> Meme {
        let memes = appDelegate?.memes
        let meme = memes?[(memeIndex as NSIndexPath).row]
        return meme!
    }
    
    func setEditView() {
        imagePicker.delegate = self
        memeImage = getImage(memeImageString: (meme?.imageImageIndexString)!)
        memeImageView.image = memeImage
        prepareTextField(textField: topLabel, defaultText: (meme?.topText)!)
        prepareTextField(textField: bottomLabel, defaultText: (meme?.bottomText)!)
    }
    
    func getImage(memeImageString: String) -> UIImage {
        let fileManager = FileManager.default
        let imagePath = (Helper.getDocumentsDirectory() as NSString).appendingPathComponent(memeImageString)
        if fileManager.fileExists(atPath: imagePath){
            print("Found Image")
            return UIImage(contentsOfFile: imagePath)!
        }else{
            print("No Image")
            return memeImage!
        }
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    
    
    
}



