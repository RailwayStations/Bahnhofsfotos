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
import UIKit

class PhotoViewController: UIViewController {

  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var shareBarButton: UIBarButtonItem!
  @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
  @IBOutlet weak var progressView: UIProgressView!

  var savedPhoto: Photo?

  override func viewDidLoad() {
    super.viewDidLoad()

    title = StationStorage.currentStation?.name
    shareBarButton.isEnabled = false
    progressView.alpha = 0

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
      var image: LightboxImage
      if let license = station.license, let photographer = station.photographer {
        let text = license + " - " + photographer
        image = LightboxImage(image: imageView.image!, text: text, videoURL: nil)
      } else {
        image = LightboxImage(image: imageView.image!)
      }
      let lightboxController = LightboxController(images: [image], startIndex: 0)
      present(lightboxController, animated: true, completion: nil)
      return
    }

    let configuration = ImagePickerConfiguration()
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
    if Defaults.uploadToken != nil {
      var title = "Direkt-Upload"
      if let size = getSizeStringOfImage() {
        title += " [\(size)]"
      }
      controller.addAction(UIAlertAction(title: title, style: .default) { _ in
        self.shareByUpload()
      })
    }

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
    if let imageData = UIImageJPEGRepresentation(image, 0.5) {
      Helper.setIsUserInteractionEnabled(in: self, to: false)
      UIApplication.shared.isNetworkActivityIndicatorVisible = true
      activityIndicatorView.startAnimating()
      progressView.alpha = 1
      progressView.progress = 0
      imageView.isHidden = true

      API.uploadPhoto(imageData: imageData, ofStation: station, inCountry: country, progressHandler: { progress in
        self.progressView.setProgress(Float(progress), animated: true)
      }) { result in
        Helper.setIsUserInteractionEnabled(in: self, to: true)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.activityIndicatorView.stopAnimating()
        self.progressView.progress = 1
        self.progressView.alpha = 0
        self.imageView.isHidden = false

        do {
          try result()
          self.showError("Foto wurde erfolgreich hochgeladen")
          self.setPhotoAsShared()
        } catch API.Error.message(let msg) {
          self.showError(msg)
        } catch {
          self.showError(error.localizedDescription)
        }
      }
    }
  }

  // Share by sending an email
  private func shareByEmail() {
    guard let station = StationStorage.currentStation, let country = CountryStorage.currentCountry else { return }
    guard let image = imageView.image else { return }

    if MFMailComposeViewController.canSendMail() {
      if let email = CountryStorage.currentCountry?.email {
        guard let username = Defaults.accountName else {
          showError("Kein Accountname hinterlegt. Bitte unter \"Einstellungen\" angeben.")
          return
        }

        var text = "Bahnhof: \(station.name)\n"
        text += "Lizenz: CC0\n"
        text += "Verlinkung: \(Defaults.accountLinking == true ? "Ja" : "Nein")\n"
        text += "Accounttyp: \(Defaults.accountType)\n"
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
    guard let country = CountryStorage.currentCountry else { return }
    let text = "\(station.name) \(country.twitterTags ?? "")"

    let activityController = UIActivityViewController(activityItems: [station.name, image, text], applicationActivities: nil)
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
    shareBarButton.isEnabled = false
    savedPhoto?.uploadedAt = Date()
    guard let photo = savedPhoto else { return }
    try? PhotoStorage.save(photo)
  }

  private func getSizeStringOfImage() -> String? {
    guard
      let image = imageView.image,
      let data = UIImageJPEGRepresentation(image, 1)
    else { return nil }

    let sizeInMegaBytes = Double(data.count) / 1024 / 1024

    let numberFormatter = NumberFormatter()
    numberFormatter.minimumFractionDigits = 1
    numberFormatter.maximumFractionDigits = 1
    if let readableSize = numberFormatter.string(from: NSNumber(value: sizeInMegaBytes)) {
      return "\(readableSize) MB"
    }

    return nil
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
        self.savedPhoto = photo
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
