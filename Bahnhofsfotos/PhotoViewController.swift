//
//  FotoViewController.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 17.12.16.
//  Copyright © 2016 MrHaitec. All rights reserved.
//

import UIKit
import AAShareBubbles
import MessageUI

class PhotoViewController: UIViewController {

    var imagePicker: UIImagePickerController!

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var shareBarButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
    }

    @IBAction func pickImage(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Foto machen", style: .default) { _ in self.openPicker(type: .camera) })
        alert.addAction(UIAlertAction(title: "Foto aus Galerie", style: .default) { _ in self.openPicker(type: .photoLibrary) })
        alert.addAction(UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    @IBAction func shareTouched(_ sender: Any) {
        let shareBubbles = AAShareBubbles(centeredInWindowWithRadius: 100)
        shareBubbles?.delegate = self
        shareBubbles?.showMailBubble = true
        shareBubbles?.showTwitterBubble = true
        shareBubbles?.showFacebookBubble = true
        shareBubbles?.show()
    }

    func openPicker(type: UIImagePickerControllerSourceType) {
        imagePicker.sourceType = type
        present(imagePicker, animated: true, completion: nil)
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
        guard let name = BahnhofStorage.currentBahnhof?.title else {
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

// MARK: - UINavigationControllerDelegate
// MARK: UIImagePickerControllerDelegate
extension PhotoViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        shareBarButton.isEnabled = true
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
