//
//  ImageEditorView.swift
//  Gridy
//
//  Created by Am GHAZNAVI on 05/09/2019.
//  Copyright © 2019 Am GHAZNAVI. All rights reserved.
//

import UIKit
import CoreImage

class ImageEditorView: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate {
    
    var imageReceivedIntroView: UIImage?
    var panRecognizer: UIPanGestureRecognizer?
    var pinchRecognizer: UIPinchGestureRecognizer?
    var rotateRecognizer: UIRotationGestureRecognizer?
    var imageForPlayFieldView = [UIImage]()
    var screenshot = UIImage()
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var creationFrame: UIView!
    @IBOutlet weak var creationImageView: UIImageView!
    
    // MARK: - ImageEditorView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureImage()
    }
    
    @IBAction func startButton(_ sender: UIButton) {
        prepareImageForPlayFieldView()
    }
    
    @IBAction func cancellButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func configureImage() {
        if let randomImageReceived = imageReceivedIntroView {
            creationImageView.image = randomImageReceived
            backgroundImage.image = randomImageReceived
        }
        
        // create gestures
        self.panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(recognizer:)))
        panRecognizer?.delegate = self
        self.creationImageView.addGestureRecognizer(panRecognizer!)
        self.pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.handlePinch(recognizer:)))
        pinchRecognizer?.delegate = self
        self.creationImageView.addGestureRecognizer(pinchRecognizer!)
        self.rotateRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(self.handleRotate(recognizer:)))
        rotateRecognizer?.delegate = self
        self.creationImageView.addGestureRecognizer(rotateRecognizer!)
    }
    
    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        let gview = recognizer.view
        if recognizer.state == .began || recognizer.state == .changed {
            let translation = recognizer.translation(in: gview?.superview)
            gview?.center = CGPoint(x: (gview?.center.x)! + translation.x, y: (gview?.center.y)! + translation.y)
            recognizer.setTranslation(CGPoint.zero, in: gview?.superview)
        }
    }
    
    @objc func handlePinch(recognizer: UIPinchGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
            recognizer.view?.transform = (recognizer.view?.transform.scaledBy(x: recognizer.scale, y: recognizer.scale))!
            recognizer.scale = 1.0
        }
    }
    
    @objc func handleRotate(recognizer: UIRotationGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
            recognizer.view?.transform = (recognizer.view?.transform.rotated(by: recognizer.rotation))!
            recognizer.rotation = 0.0
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.view != creationImageView {
            return false
        }
        if gestureRecognizer is UITapGestureRecognizer
            || otherGestureRecognizer is UITapGestureRecognizer
            || gestureRecognizer is UIPanGestureRecognizer
            || otherGestureRecognizer is UIPanGestureRecognizer {
            return false
        }
        return true
    }
    
    //slicing image for playfield view
    func composeCreationImage(completion: @escaping (UIImage) -> Void) {
        DispatchQueue.main.async {
            UIGraphicsBeginImageContextWithOptions(self.creationFrame.bounds.size, false, 0)
            self.creationFrame.drawHierarchy(in: self.creationFrame.bounds, afterScreenUpdates: true)
            self.screenshot = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            completion(self.screenshot)
        }
    }
    
    func slice(screenshot: UIImage, into howMany: Int) -> [UIImage] {
        let width: CGFloat
        let height: CGFloat
        
        switch screenshot.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            width = screenshot.size.height
            height = screenshot.size.width
        default:
            width = screenshot.size.width
            height = screenshot.size.height
        }
        
        let tileWidth = Int(width / CGFloat(howMany))
        let tileHeight = Int(height / CGFloat(howMany))
        
        let scale = Int(screenshot.scale)
        var images = [UIImage]()
        let cgImage = screenshot.cgImage!
        
        var adjustedHeight = tileHeight
        
        var y = 0
        for row in 0 ..< howMany {
            if row == (howMany - 1) {
                adjustedHeight = Int(height) - y
            }
            var adjustedWidth = tileWidth
            var x = 0
            for column in 0 ..< howMany {
                if column == (howMany - 1) {
                    adjustedWidth = Int(width) - x
                }
                let origin = CGPoint(x: x * scale, y: y * scale)
                let size = CGSize(width: adjustedWidth * scale, height: adjustedHeight * scale)
                let tileCGImage = cgImage.cropping(to: CGRect(origin: origin, size: size))!
                images.append(UIImage(cgImage: tileCGImage, scale: screenshot.scale, orientation: screenshot.imageOrientation))
                x += tileWidth
            }
            y += tileHeight
        }
        return images
    }
    
    func prepareImageForPlayFieldView() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.composeCreationImage { image in
                self.imageForPlayFieldView = self.slice(screenshot: image, into: 4)
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "PlayfieldViewSegue", sender: self)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PlayfieldViewSegue" {
            let playfieldViewController = segue.destination as! PlayfieldView
            playfieldViewController.imageReceivedFromImageEditorView = imageForPlayFieldView
            playfieldViewController.popUpImage = self.screenshot
        }
    }
    //slicing imahge ... <<< end >>>
}
