//
//  ProfileViewController.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 17.12.16.
//  Copyright © 2016 MrHaitec. All rights reserved.
//

import Eureka
import SwiftyUserDefaults
import Toast_Swift

class ProfileViewController: FormViewController {

    private enum FormSection: String {
        case download = "Bahnhofsdaten"
        case license = "Lizenzierung"
        case link = "Verlinkung"
    }

    private enum RowTag: String {
        case loadCountries
        case countryPicker
        case accountType
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        createForm()
    }

    // MARK: - Eureka

    private func createForm() {
        form
            +++ createDownloadSection()
            +++ createLicenseSection()
            +++ createLinkSection()
    }

    // MARK: Download

    // Creates thw row for getting the countries
    private func createGetCountriesRow() -> LabelRow {
        let rowTitle = "Länderdaten aktualisieren"

        return LabelRow(RowTag.loadCountries.rawValue) { row in
            row.title = rowTitle
        }.onCellSelection { (cell, row) in
            row.title = "Länderdaten laden"
            row.updateCell()

            self.setIsUserInteractionEnabled(false)
            self.view.makeToastActivity(.center)

            self.loadCountries {
                row.title = rowTitle
                row.value = ""
                row.updateCell()
                self.setIsUserInteractionEnabled(true)
                self.view.hideToastActivity()
            }
        }
    }

    // Creates row for picking the country
    private func createCountryPickerRow() -> PickerInlineRow<Country> {
        let getCountries = {
            return (
                all: CountryStorage.countries,
                current: CountryStorage.countries.first { (country) -> Bool in
                    return country.countryflag == Defaults[.country]
                }
            )
        }

        return PickerInlineRow<Country>(RowTag.countryPicker.rawValue) { row in
            row.title = "Aktuelles Land"
            row.disabled = .function([RowTag.loadCountries.rawValue], { _ in
                let empty = CountryStorage.countries.count == 0
                if !empty {
                    let countries = getCountries()
                    row.options = countries.all
                    row.value = countries.current
                    if row.value == nil {
                        row.value = row.options[0]
                    }
                }
                return empty
            })
            row.displayValueFor = { (value: Country?) in
                return value.map { $0.country }
            }
            let countries = getCountries()
            row.options = countries.all
            row.value = countries.current
        }.onChange { (row) in
            Defaults[.country] = row.value?.countryflag ?? ""
        }
    }

    // Creates the row for getting the stations
    private func createGetStationsRow() -> LabelRow {
        let rowTitle = "Bahnhofsdaten aktualisieren"

        return LabelRow() { row in
            row.title = rowTitle
            if let lastUpdate = Defaults[.lastUpdate] {
                row.value = self.getNiceDateString(fromDate: lastUpdate)
            }
            row.disabled = .function([RowTag.countryPicker.rawValue], { _ in
                return Defaults[.country].characters.count == 0
            })
        }.onCellSelection { (cell, row) in
            if row.isDisabled {
                return
            }
            row.title = "Bahnhofsdaten herunterladen"
            row.value = nil
            row.updateCell()

            self.setIsUserInteractionEnabled(false)
            self.view.makeToastActivity(.center)

            self.loadStations(progressHandler: { progress, count in
                row.title = "Bahnhof speichern: \(progress)/\(count)"
                row.value = "\(UInt(Float(progress) / Float(count) * 100))%"
                row.updateCell()
            }) {
                row.title = rowTitle
                if let lastUpdate = Defaults[.lastUpdate] {
                    row.value = self.getNiceDateString(fromDate: lastUpdate)
                }
                row.updateCell()

                self.setIsUserInteractionEnabled(true)
                self.view.hideToastActivity()
            }
        }
    }

    // Creates the download section
    private func createDownloadSection() -> Section {
        return Section(FormSection.download.rawValue)
            <<< createGetCountriesRow()
            <<< createCountryPickerRow()
            <<< createGetStationsRow()
    }

    // MARK: License

    private func createLicenseSection() -> Section {
        let license = { (license: License?) in
            return (text: license == .cc4_0 ? "CC4.0 mit Namensnennung" : "CC0 - ohne Namensnennung", value: license == .cc4_0)
        }

        return Section(FormSection.license.rawValue)

            <<< LabelRow() { row in
                row.title = "Lizenz deiner Fotos?"
            }

            <<< SwitchRow() { row in
                    row.title = license(Defaults[.license]).text
                    row.value = license(Defaults[.license]).value
                }.onChange { row in
                    guard let value = row.value else { return }
                    Defaults[.license] = value ? .cc4_0 : .cc0
                    row.title = license(Defaults[.license]).text
                    row.updateCell()
                }
    }

    // MARK: Verlinkung

    private func createLinkSection() -> Section {
        return Section(FormSection.link.rawValue)

            <<< LabelRow() { row in
                    row.title = "Möchtest Du verlinkt werden?"
                }

            <<< PickerInlineRow<AccountType>(RowTag.accountType.rawValue) { row in
                    row.title = "Account"
                    row.options = [
                        AccountType.none,
                        AccountType.twitter,
                        AccountType.facebook,
                        AccountType.instagram,
                        AccountType.snapchat,
                        AccountType.xing,
                        AccountType.web,
                        AccountType.misc
                    ]
                    row.displayValueFor = { (value: AccountType?) in
                        return value?.rawValue
                    }
                    row.value = Defaults[.accountType]
                }.onChange { row in
                    Defaults[.accountType] = row.value
                }

            <<< TextRow() { row in
                    row.value = Defaults[.accountLink]
                    row.placeholder = "Accountname oder URL (http://...)"
                    row.hidden = .function([RowTag.accountType.rawValue], { _ in
                        return Defaults[.accountType] == AccountType.none
                    })
                }.onChange { row in
                    Defaults[.accountLink] = row.value ?? ""
                }
    }

    // MARK: - Helpers

    // Disables the view for user interaction
    private func setIsUserInteractionEnabled(_ enabled: Bool) {
        view.isUserInteractionEnabled = enabled
        navigationController?.view.isUserInteractionEnabled = enabled
    }

    // Get date string based on (to)day
    private func getNiceDateString(fromDate date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .short)
        } else {
            return DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .none)
        }
    }

    // Get and save countries
    private func loadCountries(completionHandler: @escaping () -> Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        API.getCountries { countries in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false

            // Save countries in background
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try CountryStorage.removeAll()

                    for country in countries {
                        try country.save()
                    }
                    try CountryStorage.fetchAll()
                } catch {
                    debugPrint(error)
                }

                DispatchQueue.main.async {
                    completionHandler()
                }
            }
        }
    }

    // Get and save stations
    private func loadStations(progressHandler: @escaping (Int, Int) -> Void, completionHandler: @escaping () -> Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        API.getStations(withPhoto: false) { stations in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false

            let dispatchSource = DispatchSource.makeUserDataAddSource(queue: .main)
            dispatchSource.setEventHandler() {
                progressHandler(Int(dispatchSource.data), stations.count)
            }
            dispatchSource.resume()

            // Save stations in background
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try StationStorage.removeAll()
                    try StationStorage.create(stations: stations, progressHandler: { counter in
                        dispatchSource.add(data: UInt(counter))
                    })
                    Defaults[.dataComplete] = true
                    Defaults[.lastUpdate] = StationStorage.lastUpdatedAt
                    try StationStorage.fetchAll()
                } catch {
                    debugPrint(error)
                }

                DispatchQueue.main.async {
                    completionHandler()
                }
            }
        }
    }

}
