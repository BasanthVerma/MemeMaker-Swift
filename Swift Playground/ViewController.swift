//
//  ViewController.swift
//  Swift Playground
//
//  Created by Basanth Verma on 17/02/17.
//  Copyright © 2017 Basanth. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
    UITextFieldDelegate, UIGestureRecognizerDelegate
{
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var addTextFieldButton: UIBarButtonItem!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var toolbar: UIToolbar!
    
    override func viewWillAppear(_ animated: Bool) {
        //Enable camera buttons only if device has a camera
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
        
        self.navigationController?.title = "Meme Maker"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeToKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shareButton.isEnabled = false

    }
    
    
    //Mark: Image methods
    //choose from gallery
    @IBAction func pickPic(_ sender: UIBarButtonItem) {
        let vc = UIImagePickerController()
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }

    //take pic from camera
    @IBAction func takePic(_ sender: UIBarButtonItem) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.sourceType = .camera
        self.present(vc, animated: true, completion: nil)
    }
    

    //delegate, when image is picked or taken
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            imagePickerView.image = image
        }
        picker.dismiss(animated: true, completion: nil)
        shareButton.isEnabled = true
    }
    
    //delegate, image pick was canceled
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                picker.dismiss(animated: true, completion: nil)
    }
    
    
    //Method to share meme
    @IBAction func share()
    {
        let shareVC = UIActivityViewController(activityItems: [generateMemedImage()], applicationActivities: nil)
        self.present(shareVC, animated: true, completion: nil)
    }
    
    //Creates meme based on image and text added
    func generateMemedImage() -> UIImage
    {
        
        //Hide toolbar and navbar
        self.navigationController?.navigationBar.isHidden = true
        toolbar.isHidden = true
       
        
        //Render View to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //Show toolbar and navbar
        self.navigationController?.navigationBar.isHidden = false
        toolbar.isHidden = false
        
        return memedImage
    }
    
    //Programmatically adds moveable text field on the image
    @IBAction func addTextFieldOnMeme()
    {
        createTextField()
    }
    
    //Creates moveable text field
    func createTextField() -> Void {
        
        let memeTextAttributes:[String:Any] = [
            
            NSStrokeColorAttributeName: UIColor.black,
            NSForegroundColorAttributeName: UIColor.clear,
      
        
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 36)!,
            NSStrokeWidthAttributeName: 2
            
        ]

        let textField:UITextField = UITextField()
        textField.text = "Enter text"
        textField.delegate = self
        textField.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width*0.95, height: 40.0)
        textField.center = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height/2)
        textField.defaultTextAttributes = memeTextAttributes
        textField.adjustsFontSizeToFitWidth = true
        textField.backgroundColor = UIColor.clear
        self.view.addSubview(textField)
        
        //Gesture recongiser to recognise and move text
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged(gestureRecognizer:)))
        textField.addGestureRecognizer(gesture)
        textField.isUserInteractionEnabled = true
        gesture.delegate = self
    }
    
    //Delegate, to detect text being dragged
    func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            let translation = gestureRecognizer.translation(in:self.view)
   
            if(gestureRecognizer.view!.center.y < self.view.frame.size.height*0.95) {
                gestureRecognizer.view!.center = CGPoint(x:gestureRecognizer.view!.center.x, y:gestureRecognizer.view!.center.y + translation.y)
            }else {
                gestureRecognizer.view!.center = CGPoint(x:gestureRecognizer.view!.center.x, y:self.view.frame.size.height*0.95)
            }
            gestureRecognizer.setTranslation(CGPoint(x:0,y:0), in: self.view)
        }
        
    }
    
    //Mark: Text field methods
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    //Mark: Keyboard methods
    func keyboardWillShow(notification: NSNotification)
    {
        self.view.frame.origin.y -= getKeyboardHeight(notification: notification)
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        self.view.frame.origin.y += getKeyboardHeight(notification: notification)
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as!NSValue
        return keyboardSize.cgRectValue.height
        
    }
    
    func subscribeToKeyboardNotifications() {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow , object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide , object: nil)
    }
    
    func unsubscribeToKeyboardNotifications()
    {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidHide, object: nil)
    }
}

