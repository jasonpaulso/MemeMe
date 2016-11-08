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

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate  {

    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var initialViewPlaceHolder: UIView!
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var topLabel: UITextField!
    @IBOutlet weak var bottomLabel: UITextField!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBAction func cancelButton(_ sender: Any) {
        setInitialView()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setInitialView()
        memeImageView.frame = self.view.bounds
        if !checkForCamera() {
            cameraButton.isEnabled = false
        }
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
    
    func setInitialView() {
        imagePicker.delegate = self
        memeImageView.image = nil
        initialViewPlaceHolder.isHidden = false
        actionButton.isEnabled = false
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
        actionButton.isEnabled = true
        memeImage = newImage
        initialViewPlaceHolder.isHidden = true
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
        
        present(alertController, animated: true, completion: nil)
    }

    
}

