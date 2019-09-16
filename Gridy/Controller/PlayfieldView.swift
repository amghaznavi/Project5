//
//  PlayfieldView.swift
//  Gridy
//
//  Created by Am GHAZNAVI on 05/09/2019.
//  Copyright © 2019 Am GHAZNAVI. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

class PlayfieldView: UIViewController, AVAudioPlayerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    var interactionData: Int = 0
    var scoreData: Int = 0
    var soundPlay: AVAudioPlayer?
    var gridySoundOn: Bool = true
    var playfieldCollectionViewIndexPath: IndexPath?
    var imageReceivedFromImageEditorView = [UIImage]()
    var popUpImage = UIImage()
    var imageArrayCVOne :[UIImage]!
    var imageArrayCVTwo = [UIImage]()
    var fixedImagesViewController = [UIImage(named: "Gridy-lookup")]
    
    @IBOutlet weak var soundOnOffButton: UIButton!
    @IBOutlet weak var playfieldViewCollectionViewOne: UICollectionView!
    @IBOutlet weak var playfieldViewCollectionViewTwo: UICollectionView!
    @IBOutlet weak var playfieldViewScoreLabel: UILabel!
    @IBOutlet weak var playfieldViewPopUpView: UIImageView!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GridyGameOverViewSegue" {
            let gameOverView = segue.destination as! GridyGameOverView
            gameOverView.gameOverInteractionData = interactionData
            gameOverView.gameOverScoreData = yourScore()
            gameOverView.frameImage = popUpImage
        }
    }
    
    // sound
    func playGridySound() {
        if gridySoundOn == true {
            soundPlay = AVAudioPlayer()
            let soundURL = Bundle.main.url(forResource: "GridySound", withExtension: "wav")
            do {
                soundPlay = try AVAudioPlayer(contentsOf: soundURL!)
                print("sound is playing!!")
            }
            catch {
                print (error.localizedDescription)
            }
            soundPlay!.play()
        }
    }
    
    @IBAction func soundOnOffButton(_ sender: UIButton) {
        soundOnOffButton.isSelected = !soundOnOffButton.isSelected
        if sender .isSelected {
            gridySoundOn = false
        } else {
            gridySoundOn = true
        }
    }
    
    // MARK: - PlayfieldView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imageArrayCVOne = imageReceivedFromImageEditorView
        imageArrayCVOne.shuffle()
        playfieldViewCollectionViewOne.reloadData()
        playfieldViewPopUpView.image = popUpImage
        playfieldViewPopUpView.isHidden = true
        for image in fixedImagesViewController {
            if let image = image {
                imageArrayCVOne.append(image)
            }
        }
        playfieldViewCollectionViewOne.dragInteractionEnabled = true
        playfieldViewCollectionViewTwo.dragInteractionEnabled = true
        if imageArrayCVTwo.count == 0 {
            if let blank = UIImage(named: "Placeholder") {
                var temp = [UIImage]()
                for _ in imageReceivedFromImageEditorView {
                    temp.append(blank)
                }
                imageArrayCVTwo = temp
                playfieldViewCollectionViewTwo.reloadData()
            }
        }
        soundOnOffButton.setImage(#imageLiteral(resourceName: "Sound-on"), for: .normal)
        soundOnOffButton.setImage(#imageLiteral(resourceName: "Sound-off"), for: .selected)
    }
    
    // new game button
    @IBAction func playfieldViewNewGameButton(_ sender: UIButton) {
    }
    
    // confirgure collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == self.playfieldViewCollectionViewOne ? imageArrayCVOne.count : imageArrayCVTwo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlayfieldViewCollectionViewCell", for: indexPath) as! PlayfieldViewCVImageView
        
        // collection view 1
        if collectionView == playfieldViewCollectionViewOne {
            let width = (playfieldViewCollectionViewOne.frame.size.width - 30) / 6
            let layout = playfieldViewCollectionViewOne.collectionViewLayout as! UICollectionViewFlowLayout
            layout.itemSize = CGSize(width: width, height: width)
            cell.playfieldImageView.image = imageArrayCVOne[indexPath.item]
            
            // collection view 2
        } else {
            let width = (playfieldViewCollectionViewTwo.frame.size.width - 10) / 4
            let layout = playfieldViewCollectionViewTwo.collectionViewLayout as! UICollectionViewFlowLayout
            layout.itemSize = CGSize(width: width, height: width)
            cell.playfieldImageView.image = imageArrayCVTwo[indexPath.item]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == (imageArrayCVOne.count - 1) {
            playfieldViewPopUpView.isHidden = false
            Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.hidePopUpImage), userInfo: nil, repeats: false)
        }
    }
    
    @objc func hidePopUpImage() {
        playfieldViewPopUpView.isHidden = true
    }
    // collection view ... <<< end >>>
}

// drag and drop
extension PlayfieldView: UICollectionViewDragDelegate, UICollectionViewDropDelegate, UIDropInteractionDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        self.playfieldCollectionViewIndexPath = indexPath
        let item: UIImage
        let image = imageArrayCVOne[indexPath.item]
        if (image == fixedImagesViewController.last) || (image == fixedImagesViewController.first) {
            return []
        }
        if collectionView == playfieldViewCollectionViewOne {
            item = image
        } else {
            item = (self.imageArrayCVTwo[indexPath.row])
        }
        let itemProvider = NSItemProvider(object: item as UIImage)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if destinationIndexPath?.row == 16 || destinationIndexPath?.row == 17 {
            return UICollectionViewDropProposal(operation: .forbidden)
        } else if collectionView === playfieldViewCollectionViewTwo {
            return UICollectionViewDropProposal(operation: .move, intent: .insertIntoDestinationIndexPath)
        } else if collectionView === playfieldViewCollectionViewOne && playfieldViewCollectionViewTwo.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertIntoDestinationIndexPath)
        } else {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let dip: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            dip = indexPath
        } else {
            let section = collectionView.numberOfSections - 1
            let row = collectionView.numberOfItems(inSection: section)
            dip = IndexPath(row: row, section: section)
        }
        if dip.row == 16 || dip.row == 17 {
            return
        }
        if collectionView === playfieldViewCollectionViewTwo {
            moveItems(coordinator: coordinator, destinationIndexPath: dip, collectionView: collectionView)
        } else if collectionView === playfieldViewCollectionViewOne {
            return
        }
    }
    
    // drap and drop interactions
    private func moveItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
        let items = coordinator.items
        totalInteraction(interactionData: interactionData + 1) // total touches
        collectionView.performBatchUpdates({
            let dragItem = items.first!.dragItem.localObject as! UIImage
            if dragItem === imageReceivedFromImageEditorView[destinationIndexPath.item] {
                scoreData += 1
                self.imageArrayCVTwo.insert(items.first!.dragItem.localObject as! UIImage, at: destinationIndexPath.row)
                playfieldViewCollectionViewTwo.insertItems(at: [destinationIndexPath])
                if let selected = playfieldCollectionViewIndexPath {
                    imageArrayCVOne.remove(at: selected.row)
                    if let temp = UIImage(named: "Placeholder") {
                        let blank = temp
                        imageArrayCVOne.insert(blank, at: selected.row)
                    }
                    playfieldViewCollectionViewOne.reloadData()
                    playGridySound()
                }
            }
        })
        collectionView.performBatchUpdates({
            if items.first!.dragItem.localObject as! UIImage === imageReceivedFromImageEditorView[destinationIndexPath.item] {
                self.imageArrayCVTwo.remove(at: destinationIndexPath.row + 1)
                let nextIndexPath = NSIndexPath(row: destinationIndexPath.row + 1, section: 0)
                playfieldViewCollectionViewTwo.deleteItems(at: [nextIndexPath] as [IndexPath])
            } else {
                
            }
        })
        coordinator.drop(items.first!.dragItem, toItemAt: destinationIndexPath)
        if scoreData == imageArrayCVTwo.count {
            performSegue(withIdentifier: "GridyGameOverViewSegue", sender: nil)
        }
    }
}

// scoring
extension PlayfieldView {
    func totalInteraction(interactionData: Int) {
        self.interactionData += 1
        playfieldViewScoreLabel.text = "\(interactionData)"
    }
    
    func yourScore() -> Int {
        let score = scoreData * scoreData - (interactionData - scoreData)
        return score
    }
}




    

