//
//  IntroView.swift
//  Gridy
//
//  Created by Am GHAZNAVI on 05/09/2019.
//  Copyright © 2019 Am GHAZNAVI. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

class IntroView: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate {
    
    var creation = Creation.init()
    var localImages = [UIImage].init()
    let imagePickerController = UIImagePickerController()
    var newImage = UIImage.init()
    var imageForImageEditorView = UIImage()
    
    // MARK: - IntroView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        collectLocalImageSet()
    }
    
    @IBAction func PickButton(_ sender: UIButton) {
        pickRandom()
    }
    
    @IBAction func CameraButton(_ sender: UIButton) {
        displayCamera()
    }
    
    @IBAction func PhotoLibraryButton(_ sender: UIButton) {
        displayLibrary()
    }
    
    // MARK: - accessing image
    // accessing camera
    func displayCamera() {
        let sourceType = UIImagePickerController.SourceType.camera
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            let noPermissionMessage = "Oops Gridy not been able to access your camera! Please check your settings"
            switch status {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {(granted) in
                    if granted {
                        self.presentImagePicker(sourceType: sourceType)
                    } else {
                        self.troubleAlert(message: noPermissionMessage)
                    }
                })
            case .authorized:
                self.presentImagePicker(sourceType: sourceType)
            case .denied, .restricted:
                self.troubleAlert(message: noPermissionMessage)
            @unknown default:
                fatalError(noPermissionMessage)
            }
        } else {
            troubleAlert(message: "Sincere apologise, it looks like we can't access your camera at this time")
        }
    }
    
    // accessing photo library
    func displayLibrary() {
        let sourceType = UIImagePickerController.SourceType.photoLibrary
        
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let status = PHPhotoLibrary.authorizationStatus()
            let noPermissionStatusMessage = "Oops Gridy not been able to access your Photo Library! Please check your settings"
            switch status {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({ (newStatus) in
                    if newStatus == .authorized {
                        self.presentImagePicker(sourceType: sourceType)
                    } else {
                        self.troubleAlert(message: noPermissionStatusMessage)
                    }
                })
            case .authorized:
                self.presentImagePicker(sourceType: sourceType)
            case .denied, .restricted:
                self.troubleAlert(message: noPermissionStatusMessage)
            @unknown default:
                self.presentImagePicker(sourceType: sourceType)
            }
        } else {
            troubleAlert(message: "Sincere apologise, it looks like we can't access your photo library at this time")
        }
    }
    
    // image picker controller
    func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let newImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        processPicked(image: newImage)
        dismiss(animated: true, completion: { () -> Void in
            self.performSegue(withIdentifier: "ImageEditorViewSegue", sender: self)
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func troubleAlert(message: String?) {
        let alertController = UIAlertController(title: "Oops...", message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Got it.", style: .cancel)
        alertController.addAction(OKAction)
        present(alertController, animated: true)
    }
    
    // randome image
    func randomImage() -> UIImage? {
        let currentImage = creation.image
        if localImages.count > 0 {
            while true {
                let randomIndex = Int(arc4random_uniform(UInt32(localImages.count)))
                let newImage = localImages[randomIndex]
                if newImage != currentImage {
                    return newImage
                }
            }
        }
        print("randomImage()=nil")
        troubleAlert(message: "No Image")
        return nil
    }
    
    func collectLocalImageSet() {
        localImages.removeAll()
        let imageNames = ["Boats", "Car", "Crocodile", "Park", "TShirts"]
        for name in imageNames {
            if let image = UIImage.init(named: name) {
                localImages.append(image)
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ImageEditorViewSegue" {
            let imageEditorView = segue.destination as! ImageEditorView
            imageEditorView.imageReceivedIntroView = creation.image
        }
    }
    
    func pickRandom() {
        processPicked(image: randomImage())
        performSegue(withIdentifier: "ImageEditorViewSegue", sender: self)
    }
    
    func processPicked(image: UIImage?) {
        if  let newImage = image {
            creation.image = newImage
        }
    }
    
}




