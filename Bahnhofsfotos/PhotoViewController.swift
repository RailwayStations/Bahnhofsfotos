//
//  PhotoViewController.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 17.12.16.
//  Copyright © 2016 MrHaitec. All rights reserved.
//

import Imaginary
import ImagePicker
import Lightbox
import MessageUI
import SwiftyUserDefaults
import TwitterKit
import UIKit

class PhotoViewController: UIViewController {

  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var shareBarButton: UIBarButtonItem!
  @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

  var savedPhoto: Photo?

  override func viewDidLoad() {
    super.viewDidLoad()

    title = StationStorage.currentStation?.name
    shareBarButton.isEnabled = false

    guard let station = StationStorage.currentStation else { return }

    if station.hasPhoto {
      if let photoUrl = station.photoUrl, let imageUrl = URL(string: photoUrl) {
        imageView.image = nil
        activityIndicatorView.startAnimating()
        imageView.setImage(url: imageUrl) { result in
          self.activityIndicatorView.stopAnimating()
        }
      }
    } else {
      do {
        savedPhoto = try PhotoStorage.fetch(id: station.id)
        if let photo = savedPhoto {
          imageView.image = UIImage(data: photo.data)
          
          // allow to share assigned photo
          if photo.uploadedAt == nil {
            shareBarButton.isEnabled = true
          }
        }
      } catch {
        debugPrint(error.localizedDescription)
      }
    }
  }

  @IBAction func pickImage(_ sender: Any) {
    guard let station = StationStorage.currentStation else { return }
    if station.hasPhoto && imageView.image != nil {
      LightboxConfig.PageIndicator.enabled = false
      let lightboxController = LightboxController(images: [LightboxImage(image: imageView.image!)], startIndex: 0)
      present(lightboxController, animated: true, completion: nil)
      return
    }

    let configuration = Configuration()
    configuration.allowMultiplePhotoSelection = false
    configuration.allowedOrientations = .landscape
    configuration.cancelButtonTitle = "Abbruch"
    configuration.doneButtonTitle = "Fertig"

    let imagePicker =  ImagePickerController(configuration: configuration)
    imagePicker.delegate = self
    present(imagePicker, animated: true, completion: nil)
  }

  @IBAction func shareTouched(_ sender: Any) {
    let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

    // Share by upload
    if Defaults[.uploadToken] != nil {
      controller.addAction(UIAlertAction(title: "Direkt-Upload", style: .default) { _ in
        self.shareByUpload()
      })
    }

    // Share via twitter
    controller.addAction(UIAlertAction(title: "Twitter", style: .default) { _ in
      self.shareViaTwitter()
    })

    // Share by email
    if CountryStorage.currentCountry?.email != nil {
      controller.addAction(UIAlertAction(title: "E-Mail", style: .default) { _ in
        self.shareByEmail()
      })
    }

    // Share by installed apps
    controller.addAction(UIAlertAction(title: "Sonstiges", style: .default) { _ in
      self.shareByOthers()
    })

    controller.addAction(UIAlertAction(title: "Schließen", style: .cancel, handler: nil))
    present(controller, animated: true, completion: nil)
  }

  @IBAction func closeTouched(_ sender: Any) {
    navigationController?.popViewController(animated: true)
  }

  @IBAction func openNavigation(_ sender: Any) {
    if let station = StationStorage.currentStation {
      Helper.openNavigation(to: station)
    }
  }

  // Share via twitter
  private func shareByUpload() {
    guard let image = imageView.image else { return }
    guard let station = StationStorage.currentStation, let country = CountryStorage.currentCountry else { return }
    if let imageData = UIImageJPEGRepresentation(image, 1) {
      API.uploadPhoto(imageData: imageData, ofStation: station, inCountry: country, completionHandler: { result in
        do {
          try result()
          self.showError("Foto wurde erfolgreich hochgeladen")
          self.setPhotoAsShared()
        } catch API.Error.message(let msg) {
          self.showError(msg)
        } catch {
          self.showError(error.localizedDescription)
        }
      })
    }
  }

  // Share via twitter
  private func shareViaTwitter() {
    if (TWTRTwitter.sharedInstance().sessionStore.hasLoggedInUsers()) {
      // App must have at least one logged-in user to compose a Tweet
      self.showTwitterComposer()
    } else {
      // Log in, and then check again
      TWTRTwitter.sharedInstance().logIn { session, error in
        if session != nil { // Log in succeeded
          self.showTwitterComposer()
        } else {
          self.showError("Kein Zugriff auf Twitter Account")
        }
      }
    }
  }

  // Create and show a Twitter composer view controller
  private func showTwitterComposer() {
    guard let station = StationStorage.currentStation, let country = CountryStorage.currentCountry else { return }
    guard let image = imageView.image else { return }

    #if DEBUG
      let text = "\(station.name)"
    #else
      let text = "\(station.name) \(country.twitterTags ?? "")"
    #endif

    let composer = TWTRComposerViewController(initialText: text, image: image, videoData: nil)
    composer.delegate = self
    self.present(composer, animated: true, completion: nil)
  }

  // Share by sending an email
  private func shareByEmail() {
    guard let station = StationStorage.currentStation, let country = CountryStorage.currentCountry else { return }
    guard let image = imageView.image else { return }

    if MFMailComposeViewController.canSendMail() {
      if let email = CountryStorage.currentCountry?.email {
        guard let username = Defaults[.accountName] else {
          showError("Kein Accountname hinterlegt. Bitte unter \"Einstellungen\" angeben.")
          return
        }

        var text = "Bahnhof: \(station.name)\n"
        text += "Lizenz: \(Defaults[.license] == .cc40 ? "CC4.0" : "CC0")\n"
        text += "Verlinkung: \(Defaults[.accountLinking] == true ? "Ja" : "Nein")\n"
        text += "Accounttyp: \(Defaults[.accountType])\n"
        text += "Accountname: \(username)"

        let mailController = MFMailComposeViewController()
        mailController.mailComposeDelegate = self
        mailController.setToRecipients([email])
        mailController.setSubject("Neues Bahnhofsfoto: \(station.name)")
        mailController.setMessageBody(text, isHTML: false)
        if let data = UIImageJPEGRepresentation(image, 1) {
          mailController.addAttachmentData(data, mimeType: "image/jpeg", fileName: "\(username)-\(country.code.lowercased())-\(station.id).jpg")
        }
        present(mailController, animated: true, completion: nil)
      }
    } else {
      showError("Es können keine E-Mails verschickt werden.")
    }
  }

  // Share by using installed apps
  private func shareByOthers() {
    guard let station = StationStorage.currentStation else { return }
    guard let image = imageView.image else { return }

    let activityController = UIActivityViewController(activityItems: [station.name, image], applicationActivities: nil)
    present(activityController, animated: true, completion: nil)
  }

  // Show error message
  private func showError(_ error: String) {
    let alert = UIAlertController(title: nil, message: error, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    present(alert, animated: true, completion: nil)
  }

  // Set photo as shared
  private func setPhotoAsShared() {
    guard let photo = savedPhoto else { return }
    shareBarButton.isEnabled = false
    photo.uploadedAt = Date()
    try? PhotoStorage.save(photo)
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
      if let station = StationStorage.currentStation, let imageData = UIImageJPEGRepresentation(images[0], 1) {
        let photo = Photo(data: imageData, withId: station.id)
        try? PhotoStorage.save(photo)
      }
    }
    imagePicker.dismiss(animated: true, completion: nil)
  }

  func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
    imagePicker.dismiss(animated: true, completion: nil)
  }

}

// MARK: - MFMailComposeViewControllerDelegate
extension PhotoViewController: MFMailComposeViewControllerDelegate {

  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    if result == .sent {
      setPhotoAsShared()
    }
    controller.dismiss(animated: true, completion: nil)
  }

}

extension PhotoViewController: TWTRComposerViewControllerDelegate {

  func composerDidSucceed(_ controller: TWTRComposerViewController, with tweet: TWTRTweet) {
    setPhotoAsShared()
  }

}
