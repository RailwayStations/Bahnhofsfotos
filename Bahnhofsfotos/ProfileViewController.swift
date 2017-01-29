//
//  ProfileViewController.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 17.12.16.
//  Copyright © 2016 MrHaitec. All rights reserved.
//

import Former
import Toast_Swift

class ProfileViewController: FormViewController {

//    var lizenzSwitchRow: SwitchRowFormer<FormSwitchCell>!
//    var urheberSwitchRow: SwitchRowFormer<FormSwitchCell>!
//    var verlinkungSwitchRow: SwitchRowFormer<FormSwitchCell>!
//    var accountInlinePickerRow: InlinePickerRowFormer<FormInlinePickerCell, String>!

    override func viewDidLoad() {
        super.viewDidLoad()

        createDownloadForm()

//        createLizenzForm()
//        createUrheberForm()
//        createVerlinkungForm()
    }

    // Download
    private func createDownloadForm() {
        let labelText = "Bahnhofsdaten aktualisieren"

        let labelRow = CustomRowFormer<FormLabelCell>().configure {
            $0.cell.titleLabel?.text = labelText
            $0.onSelected({ row in

                row.cell.isSelected = false
                row.cell.titleLabel.text = "Bahnhofsdaten herunterladen"
                self.view.isUserInteractionEnabled = false
                self.navigationController?.view.isUserInteractionEnabled = false
                self.view.makeToastActivity(.center)
                UIApplication.shared.isNetworkActivityIndicatorVisible = true

                API.getStations(withPhoto: false) { stations in
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false

                    let dispatchSource = DispatchSource.makeUserDataAddSource(queue: .main)
                    dispatchSource.setEventHandler() {
                        row.cell.titleLabel.text = "Bahnhof speichern: \(dispatchSource.data)/\(stations.count)"
                        row.cell.subTextLabel?.text = "\(UInt(Float(dispatchSource.data) / Float(stations.count) * 100))%"
                    }
                    dispatchSource.resume()

                    // Save stations in background
                    DispatchQueue.global(qos: .userInitiated).async {
                        do {
                            try StationStorage.removeAll()
                            var counter: UInt = 1

                            for station in stations {
                                // Update progress
                                dispatchSource.add(data: counter)
                                try station.save()
                                counter += 1
                            }
                            try StationStorage.fetchAll()
                        } catch {
                            debugPrint(error)
                        }

                        DispatchQueue.main.async {
                            row.cell.titleLabel?.text = labelText
                            row.cell.subTextLabel.text = nil
                            self.view.isUserInteractionEnabled = true
                            self.navigationController?.view.isUserInteractionEnabled = true
                            self.view.hideToastActivity()
                        }
                    }
                }
            })
        }

        let header = LabelViewFormer<FormLabelHeaderView>() {
            $0.textLabel?.text = "Bahnhofsdaten"
        }

        let section = SectionFormer(rowFormer: labelRow)
            .set(headerViewFormer: header)

        former.append(sectionFormer: section)
    }

    /*
    // Lizenzierung
    private func createLizenzForm() {
        let labelRow = LabelRowFormer<FormLabelCell>().configure {
            $0.cell.textLabel?.text = "Unter welcher Lizenz möchtest Du Deine Fotos einreichen?"
            $0.cell.textLabel?.numberOfLines = 3
            $0.enabled = false
        }

        lizenzSwitchRow = SwitchRowFormer<FormSwitchCell>() {
            $0.titleLabel.text = "CC0 - ohne Namensnennung"
            }.onSwitchChanged {
                self.lizenzSwitchRow.cell.titleLabel.text = $0 ? "CC4.0 mit Namensnennung" : "CC0 - ohne Namensnennung"
            }
        let header = LabelViewFormer<FormLabelHeaderView>() {
            $0.textLabel?.text = "Lizenzierung"
        }
        let section = SectionFormer(rowFormer: labelRow, lizenzSwitchRow)
            .set(headerViewFormer: header)
        former.append(sectionFormer: section)
    }

    // Urheber
    private func createUrheberForm() {
        let labelRow = LabelRowFormer<FormLabelCell>().configure {
            $0.cell.textLabel?.text = "Handelt es sich bei den Fotos um Deine eigenen...?"
            $0.cell.textLabel?.numberOfLines = 3
            $0.enabled = false
        }

        urheberSwitchRow = SwitchRowFormer<FormSwitchCell>() {
            $0.titleLabel.text = "Nein"
            }.onSwitchChanged {
                self.urheberSwitchRow.cell.titleLabel.text = $0 ? "Ja" : "Nein"
            }
        let header = LabelViewFormer<FormLabelHeaderView>() {
            $0.textLabel?.text = "Urheber"
        }
        let section = SectionFormer(rowFormer: labelRow, urheberSwitchRow)
            .set(headerViewFormer: header)
        former.append(sectionFormer: section)
    }

    // Verlinkung
    private func createVerlinkungForm() {
        let labelRow = LabelRowFormer<FormLabelCell>().configure {
            $0.cell.textLabel?.text = "Möchtest Du in unserer Fotodatenbank verlinkt werden?"
            $0.cell.textLabel?.numberOfLines = 3
            $0.enabled = false
        }

        verlinkungSwitchRow = SwitchRowFormer<FormSwitchCell>() {
            $0.titleLabel.text = "Nein"
            }.onSwitchChanged {
                self.verlinkungSwitchRow.cell.titleLabel.text = $0 ? "Ja" : "Nein"
            }
        accountInlinePickerRow = InlinePickerRowFormer<FormInlinePickerCell, String>() {
            $0.titleLabel.text = "Account"
            }.configure { row in
                row.pickerItems = [
                    InlinePickerItem(title: "Kein"),
                    InlinePickerItem(title: "Twitter"),
                    InlinePickerItem(title: "Instagram"),
                    InlinePickerItem(title: "Snapchat"),
                    InlinePickerItem(title: "Xing"),
                    InlinePickerItem(title: "Webpage"),
                ]
            }
        let urlLabelRow = LabelRowFormer<FormLabelCell>().configure {
            $0.cell.textLabel?.text = "Bitte trage hier die URL zu Deinem Account ein:"
            $0.cell.textLabel?.numberOfLines = 3
            $0.enabled = false
        }
        let textFieldRow = TextFieldRowFormer<FormTextFieldCell>().configure {
            $0.placeholder = "Account-URL (http://...)"
        }
        let header = LabelViewFormer<FormLabelHeaderView>() { view in
            view.textLabel?.text = "Verlinkung"
        }
        let section = SectionFormer(rowFormer: labelRow, verlinkungSwitchRow, accountInlinePickerRow, urlLabelRow, textFieldRow)
            .set(headerViewFormer: header)
        former.append(sectionFormer: section)
    }
    */

}
