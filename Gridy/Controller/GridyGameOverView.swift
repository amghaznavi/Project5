//
//  GridyGameOverView.swift
//  Gridy
//
//  Created by Am GHAZNAVI on 05/09/2019.
//  Copyright © 2019 Am GHAZNAVI. All rights reserved.
//

import UIKit

class GridyGameOverView: UIViewController {
    
    var gameOverInteractionData = Int()
    var gameOverScoreData = Int()
    var frameImage = UIImage()
    
    @IBOutlet weak var yourScore: UILabel!
    @IBOutlet weak var totalInteractions: UILabel!
    @IBOutlet weak var gameOverViewBackgroundImage: UIImageView!
    
    // MARK: - GridyGameOverView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        yourScore.text = "Your final score: \(gameOverScoreData)"
        totalInteractions.text = "Total interactions: \(gameOverInteractionData)"
        gameOverViewBackgroundImage.image = frameImage
    }
    
    @IBAction func optionsButton(_ sender: UIButton) {
        self.showAlert()
    }
    
    // alert message
    func showAlert() {
        let alert = UIAlertController(title: "Well done!", message: "Your final score: \(gameOverScoreData) \nTotal interactions: \(gameOverInteractionData)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Play again!", style: UIAlertAction.Style.default) {(action) in
            self.performSegue(withIdentifier: "IntroViewSegue", sender: self)
        })
        alert.addAction(UIAlertAction(title: "Share your score :)", style: .default) {(action) in
            self.displaySharingOptions()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive) {(action) in
        })
        self.present(alert, animated: true, completion: nil)
    }
}

// share
extension GridyGameOverView {
    func displaySharingOptions() {
        let note = "IT'S DONE!"
        let image = frameImage
        let items = [image as Any, note as Any]
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        //adapt for iPad
        activityViewController.popoverPresentationController?.sourceView = view
        //present activity view controller
        present(activityViewController, animated: true, completion: nil)
    }
}

