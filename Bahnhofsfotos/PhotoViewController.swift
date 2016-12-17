//
//  FotoViewController.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 17.12.16.
//  Copyright © 2016 MrHaitec. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {

    var imagePicker: UIImagePickerController!

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!

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

    @IBAction func saveTouched(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }

    func openPicker(type: UIImagePickerControllerSourceType) {
        imagePicker.sourceType = type
        present(imagePicker, animated: true, completion: nil)
    }
}

extension PhotoViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        saveBarButton.isEnabled = true
        imagePicker.dismiss(animated: true, completion: nil)
    }

}
