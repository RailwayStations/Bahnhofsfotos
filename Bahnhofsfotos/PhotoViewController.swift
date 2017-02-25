//
//  FotoViewController.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 17.12.16.
//  Copyright © 2016 MrHaitec. All rights reserved.
//

import AAShareBubbles
import ImagePicker
import MessageUI
import UIKit

class PhotoViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var shareBarButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem?.title = "BACK"
        navigationItem.title = StationStorage.currentStation?.title
    }

    @IBAction func pickImage(_ sender: Any) {
        var configuration = Configuration()
        configuration.allowMultiplePhotoSelection = false
        configuration.allowedOrientations = .landscape
        configuration.cancelButtonTitle = "Abbruch"
        configuration.doneButtonTitle = "Fertig"

        let imagePicker =  ImagePickerController(configuration: configuration)
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func shareTouched(_ sender: Any) {
        let shareBubbles = AAShareBubbles(centeredInWindowWithRadius: 100)
        shareBubbles?.delegate = self
        shareBubbles?.showMailBubble = true
        shareBubbles?.showTwitterBubble = true
        shareBubbles?.showFacebookBubble = true
        shareBubbles?.show()
    }

    func showError(_ error: String) {
        let alert = UIAlertController(title: nil, message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func showMailController() {
        guard let image = imageView.image else {
            return
        }
        guard let name = StationStorage.currentStation?.title else {
            return
        }
        if MFMailComposeViewController.canSendMail() {
            let mailController = MFMailComposeViewController()
            mailController.mailComposeDelegate = self
            mailController.setToRecipients(["fotos@bahn.hof"])
            mailController.setSubject("Neues Bahnhofsfoto: \(name)")
            if let data = UIImagePNGRepresentation(image) {
                mailController.addAttachmentData(data, mimeType: "image/jpeg", fileName: "\(name)-haitec")
            }
            present(mailController, animated: true, completion: nil)
        } else {
            showError("Es können keine E-Mail verschickt werden.")
        }
    }

    func closeShare() {
        _ = navigationController?.popViewController(animated: true)
    }

}

// MARK: - ImagePickerDelegate
extension PhotoViewController: ImagePickerDelegate {

    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.showGalleryView()
    }

    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        if !images.isEmpty {
            imageView.image = images[0]
            shareBarButton.isEnabled = true
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }

    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }

}

// MARK: - AAShareBubblesDelegate
extension PhotoViewController: AAShareBubblesDelegate {

    func aaShareBubbles(_ shareBubbles: AAShareBubbles!, tappedBubbleWith bubbleType: AAShareBubbleType) {
        switch bubbleType {
        case .mail:
            showMailController()
        case .twitter:
            debugPrint("twitter")
        case .facebook:
            debugPrint("facebook")
        default:
            break
        }
    }

}

// MARK: - MFMailComposeViewControllerDelegate
extension PhotoViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if result == .cancelled || result == .failed {
            controller.dismiss(animated: true, completion: nil)
        } else {
            controller.dismiss(animated: true) { self.closeShare() }
        }
    }

}
