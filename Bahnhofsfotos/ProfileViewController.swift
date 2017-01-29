//
//  ProfileViewController.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 17.12.16.
//  Copyright © 2016 MrHaitec. All rights reserved.
//

import Former
import SwiftyUserDefaults
import Toast_Swift

class ProfileViewController: FormViewController {

    let textFont = UIFont(name: "AvenirNext-Regular", size: 17)

    override func viewDidLoad() {
        super.viewDidLoad()

        createDownloadForm()
        createLizenzForm()
        createVerlinkungForm()
    }

    // Download
    private func createDownloadForm() {
        let labelText = "Bahnhofsdaten aktualisieren"

        let labelRow = CustomRowFormer<FormLabelCell>().configure {
            $0.cell.titleLabel?.text = labelText
            $0.cell.titleLabel.font = textFont
            if let lastUpdate = Defaults[.lastUpdate] {
                $0.cell.subTextLabel.font = textFont
                $0.cell.subTextLabel.adjustsFontSizeToFitWidth = true
                if Calendar.current.isDateInToday(lastUpdate) {
                    $0.cell.subTextLabel.text = DateFormatter.localizedString(from: lastUpdate, dateStyle: .none, timeStyle: .short)
                } else {
                    $0.cell.subTextLabel.text = DateFormatter.localizedString(from: lastUpdate, dateStyle: .short, timeStyle: .none)
                }
            }
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
                            Defaults[.dataComplete] = true
                            Defaults[.lastUpdate] = StationStorage.lastUpdatedAt
                            try StationStorage.fetchAll()
                        } catch {
                            debugPrint(error)
                        }

                        DispatchQueue.main.async {
                            row.cell.titleLabel?.text = labelText
                            if let lastUpdate = Defaults[.lastUpdate] {
                                row.cell.subTextLabel.text = DateFormatter.localizedString(from: lastUpdate, dateStyle: .short, timeStyle: .none)
                            }
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

    // Lizenzierung
    private func createLizenzForm() {
        let labelRow = LabelRowFormer<FormLabelCell>().configure {
            $0.cell.textLabel?.font = textFont
            $0.cell.textLabel?.text = "Lizenz deiner Fotos?"
            $0.cell.textLabel?.numberOfLines = 2
            $0.enabled = false
        }

        var lizenzSwitchRow: SwitchRowFormer<FormSwitchCell>!
        lizenzSwitchRow = SwitchRowFormer<FormSwitchCell>() {
            $0.textLabel?.font = self.textFont
            $0.textLabel?.text = Defaults[.license] == .cc4_0 ? "CC4.0 mit Namensnennung" : "CC0 - ohne Namensnennung"
            }.onSwitchChanged {
                Defaults[.license] = $0 ? .cc4_0 : .cc0
                lizenzSwitchRow.cell.textLabel?.text = $0 ? "CC4.0 mit Namensnennung" : "CC0 - ohne Namensnennung"
            }
        lizenzSwitchRow.switched = Defaults[.license] == .cc4_0

        let header = LabelViewFormer<FormLabelHeaderView>() {
            $0.textLabel?.text = "Lizenzierung"
        }

        let section = SectionFormer(rowFormer: labelRow, lizenzSwitchRow)
            .set(headerViewFormer: header)
        former.append(sectionFormer: section)
    }

    // Verlinkung
    private func createVerlinkungForm() {
        let labelRow = LabelRowFormer<FormLabelCell>().configure {
            $0.cell.textLabel?.font = textFont
            $0.cell.textLabel?.text = "Möchtest Du verlinkt werden?"
            $0.cell.textLabel?.numberOfLines = 2
            $0.enabled = false
        }

        let accountInlinePickerRow: InlinePickerRowFormer<FormInlinePickerCell, String>!
        accountInlinePickerRow = InlinePickerRowFormer<FormInlinePickerCell, String>() {
            $0.textLabel?.font = self.textFont
            $0.textLabel?.text = "Account"
            $0.displayLabel.font = self.textFont
            $0.displayLabel.adjustsFontSizeToFitWidth = true
            }.configure { row in
                row.pickerItems = [
                    InlinePickerItem(title: "Kein", displayTitle: nil, value: AccountType.none.rawValue),
                    InlinePickerItem(title: "Twitter", displayTitle: nil, value: AccountType.twitter.rawValue),
                    InlinePickerItem(title: "Facebook", displayTitle: nil, value: AccountType.facebook.rawValue),
                    InlinePickerItem(title: "Instagram", displayTitle: nil, value: AccountType.instagram.rawValue),
                    InlinePickerItem(title: "Snapchat", displayTitle: nil, value: AccountType.snapchat.rawValue),
                    InlinePickerItem(title: "Xing", displayTitle: nil, value: AccountType.xing.rawValue),
                    InlinePickerItem(title: "Webpage", displayTitle: nil, value: AccountType.web.rawValue),
                    InlinePickerItem(title: "Sonstiges", displayTitle: nil, value: AccountType.misc.rawValue)
                ]
            }
            .onValueChanged({ item in
                if let value = item.value {
                    Defaults[.accountType] = AccountType(rawValue: value)
                } else {
                    Defaults[.accountType] = .none
                }
            })

        // Select saved accountType
        accountInlinePickerRow.selectedRow = accountInlinePickerRow.pickerItems.index { item -> Bool in
            if let value = item.value {
                return value == (Defaults[.accountType] ?? AccountType.none).rawValue
            }
            return false
        } ?? 0

        let urlLabelRow = LabelRowFormer<FormLabelCell>().configure {
            $0.cell.textLabel?.font = textFont
            $0.cell.textLabel?.text = "Bitte trage hier Deinen Account ein:"
            $0.cell.textLabel?.numberOfLines = 3
            $0.enabled = false
        }

        let textFieldRow = TextFieldRowFormer<FormTextFieldCell>().configure {
            $0.cell.textField.font = textFont
            $0.placeholder = "Account-URL (http://...)"
        }.onTextChanged {
            Defaults[.accountLink] = $0
        }
        textFieldRow.text = Defaults[.accountLink]

        let header = LabelViewFormer<FormLabelHeaderView>() {
            $0.textLabel?.text = "Verlinkung"
        }

        let section = SectionFormer(rowFormer: labelRow, accountInlinePickerRow, urlLabelRow, textFieldRow)
            .set(headerViewFormer: header)
        former.append(sectionFormer: section)
    }

}
