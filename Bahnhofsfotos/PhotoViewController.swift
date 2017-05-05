//
//  PhotoViewController.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 17.12.16.
//  Copyright © 2016 MrHaitec. All rights reserved.
//

import AAShareBubbles
import ImagePicker
import MessageUI
import Social
import SwiftyUserDefaults
import UIKit

class PhotoViewController: UIViewController {

  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var shareBarButton: UIButton!
  @IBOutlet weak var titleLabel: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()

    titleLabel.text = StationStorage.currentStation?.name
    shareBarButton.isEnabled = false
    shareBarButton.isHidden = true
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

  @IBAction func closeTouched(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }

  @IBAction func openNavigation(_ sender: Any) {
    if let station = StationStorage.currentStation {
      Helper.openNavigation(to: station)
    }
  }

  // show error message
  func showError(_ error: String) {
    let alert = UIAlertController(title: nil, message: error, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    present(alert, animated: true, completion: nil)
  }

  // show mail controller
  func showMailController() {
    guard let image = imageView.image else { return }
    guard let name = StationStorage.currentStation?.title else { return }
    guard let email = CountryStorage.currentCountry?.mail else { return }

    if MFMailComposeViewController.canSendMail() {
      guard let username = Defaults[.accountName] else {
        showError("Kein Accountname hinterlegt. Bitte unter \"Meine Daten\" angeben.")
        return
      }

      var text = "Bahnhof: \(name)\n"
      text += "Lizenz: \(Defaults[.license] == License.cc40 ? "CC4.0" : "CC0")\n"
      text += "Accountname: \(username)\n"
      text += "Verlinkung: \(Defaults[.accountLinking] == true ? "Ja" : "Nein")\n"
      text += "Accounttyp: \(Defaults[.accountType] ?? AccountType.none)"

      let mailController = MFMailComposeViewController()
      mailController.mailComposeDelegate = self
      mailController.setToRecipients([email])
      mailController.setSubject("Neues Bahnhofsfoto: \(name)")
      mailController.setMessageBody(text, isHTML: false)
      if let data = UIImageJPEGRepresentation(image, 1) {
        mailController.addAttachmentData(data, mimeType: "image/jpeg", fileName: "\(name)-\(username).jpg")
      }
      present(mailController, animated: true, completion: nil)
    } else {
      showError("Es können keine E-Mail verschickt werden.")
    }
  }

  // show twitter controller
  func showTwitterController() {
    guard let name = StationStorage.currentStation?.title,
      let tags = CountryStorage.currentCountry?.twitterTags else { return }
    guard let image = imageView.image else {
      showError("Kein Bild ausgewählt.")
      return
    }
    guard SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) else {
      showError("Twitter nicht im System gefunden.")
      return
    }

    if let twitterController = SLComposeViewController(forServiceType: SLServiceTypeTwitter) {
      twitterController.setInitialText("\(name) \(tags)")
      twitterController.add(image)
      twitterController.completionHandler = { result in
        if result == .done {
          DispatchQueue.main.async {
            self.removeStationAndCloseView()
          }
        }
      }
      present(twitterController, animated: true, completion: nil)
    } else {
      showError("Es können keine Tweets verschickt werden.")
    }
  }

  func removeStationAndCloseView() {
    if let station = StationStorage.currentStation {
      try? StationStorage.delete(station: station)
    }
    dismiss(animated: true, completion: nil)
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
      shareBarButton.isHidden = false
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
      showTwitterController()
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
      controller.dismiss(animated: true) { self.removeStationAndCloseView() }
    }
  }

}
