//
//  ViewController.swift
//  MemeMe
//
//  Created by Jason Paul Southwell on 11/7/16.
//  Copyright © 2016 Jason Paul Southwell. All rights reserved.
//

import UIKit


//Extension of UIImage to save view as image

extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!)
    }
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate  {

    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var initialViewPlaceHolder: UIView!
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var topLabel: UITextField!
    @IBOutlet weak var bottomLabel: UITextField!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    
    @IBAction func cancelButton(_ sender: Any) {
        self.setInitialView()
    }
    @IBAction func libraryPickerButton(_ sender: Any) {
        selectPicture()
    }
    @IBAction func actionButton(_ sender: Any) {
        shareMeme()
    }
    @IBAction func selectOrTakePhotoButton(_ sender: Any) {
        alertForCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        subscribeToKeyboardNotifications()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //        unsubscribeFromKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setInitialView()
        self.memeImageView.frame = self.view.bounds
        // Do any additional setup after loading the view, typically from a nib.
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
    
    func setInitialView() {
        imagePicker.delegate = self
        self.memeImageView.image = nil
        self.topLabel.text = "Top Label"
        self.topLabel.defaultTextAttributes = memeTextAttributes
        self.topLabel.textAlignment = NSTextAlignment.center
        self.bottomLabel.text = "Bottom Label"
        self.bottomLabel.defaultTextAttributes = memeTextAttributes
        self.bottomLabel.textAlignment = NSTextAlignment.center
        self.topLabel.delegate = self
        self.bottomLabel.delegate = self
        self.initialViewPlaceHolder.isHidden = false
        self.actionButton.isEnabled = false
    }
    
    var memeImage: UIImage?
    
    let imagePicker = UIImagePickerController()
    
    func selectPicture() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    
    func takePicture() {
        let camera = UIImagePickerController()
        camera.sourceType = .camera
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
        self.actionButton.isEnabled = true
        self.memeImage = newImage
        self.initialViewPlaceHolder.isHidden = true
        self.memeImageView.image = self.memeImage
        
        dismiss(animated: true)
    }
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.black,
        NSForegroundColorAttributeName : UIColor.white,
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -1.0,
        ] as [String : Any]
    
    struct Meme {
        let bottomText: String
        let topText: String
        let image: UIImage
        let memedImage: UIImage
    }
    
    func shareMeme() {
        let meme = generateMemedImage()
        let shareView = UIActivityViewController(activityItems: [meme], applicationActivities: nil)
        self.present(shareView, animated: true, completion: nil)
                shareView.completionWithItemsHandler = {
                    (s, ok, items, error) in
                    if self.memeImage != nil {
                        self.save()
                    }
                }
    }
    
    func generateMemedImage() -> UIImage {
        
        // Hide toolbar and navbar
        self.toolBar.isHidden = true
        self.navBar.isHidden = true
        // Render view to an image
        let image = UIImage(view: self.view)
        // Show toolbar and navbar
        self.toolBar.isHidden = false
        self.navBar.isHidden = false
        return image
    }
    
    func alertForCamera() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let takeAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.takePicture()
        }
        let pickAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            self.selectPicture()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            alertController.addAction(takeAction)
        }
        alertController.addAction(pickAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func save() {
        let meme = Meme(bottomText: bottomLabel.text!, topText: topLabel.text!, image: memeImage!, memedImage: generateMemedImage())
        let alertController = UIAlertController(title: "Save to Photo Roll", message: "Would you like to save this meme?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            UIImageWriteToSavedPhotosAlbum(meme.memedImage, nil, nil, nil)
            let okActionController = UIAlertController(title: "Saved!", message: nil, preferredStyle: .alert)
            let dismissOK = UIAlertAction(title: "OK", style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            okActionController.addAction(dismissOK)
            self.present(okActionController, animated: true, completion: nil)
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //    func subscribeToKeyboardNotifications() {
    //        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow)    , name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    //        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide)    , name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    //    }
    //
    //
    //    func keyboardWillHide() {
    //        self.viewFrameLocation = 0
    //        view.frame.origin.y = 0
    //    }
    //
    //    func unsubscribeFromKeyboardNotifications() {
    //        NotificationCenter.default.removeObserver(self, name:
    //            NSNotification.Name.UIKeyboardWillShow, object: nil)
    //
    //    }
    //
    //   func keyboardWillShow(notification: NSNotification) {
    //        self.viewFrameLocation = view.frame.origin.y
    //        view.frame.origin.y -= getKeyboardHeight(notification: notification)
    //  }
    //
    //
    //    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
    //        let userInfo = notification.userInfo
    //        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
    //        return keyboardSize.cgRectValue.height
    //    }
    //

    
    
}

