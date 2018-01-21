//
//  SettingsViewController.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 17.12.16.
//  Copyright © 2016 MrHaitec. All rights reserved.
//

import CPDAcknowledgements
import Eureka
import SwiftyUserDefaults
import Toast_Swift

class SettingsViewController: FormViewController {

  private enum FormSection: String {
    case download = "Bahnhofsdaten"
    case license = "Lizenzierung"
    case link = "Verlinkung"
  }

  private enum RowTag: String {
    case loadCountries
    case countryPicker
    case loadStations
    case licensePicker
    case linkPhotos
    case accountType
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    createForm()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: true)
  }

  // MARK: - Eureka

  private func createForm() {
    form
      +++ createDownloadSection()
      +++ createLicenseSection()
      +++ createLinkSection()
      +++ createInformationSection()
  }

  // MARK: Download

  // Creates thw row for getting the countries
  private func createGetCountriesRow() -> LabelRow {
    let rowTitle = "Länderdaten aktualisieren"

    return LabelRow(RowTag.loadCountries.rawValue) { row in
      row.title = rowTitle
    }.onCellSelection { (_, row) in
      row.title = "Länderdaten laden"
      row.updateCell()

      Helper.setIsUserInteractionEnabled(in: self, to: false)
      self.view.makeToastActivity(.center)

      Helper.loadCountries {
        row.title = rowTitle
        row.value = ""
        row.updateCell()
        Helper.setIsUserInteractionEnabled(in: self, to: true)
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
          return country.code == Defaults[.country]
        }
      )
    }

    return PickerInlineRow<Country>(RowTag.countryPicker.rawValue) { row in
      row.title = "Aktuelles Land"
      row.hidden = .function([RowTag.loadCountries.rawValue]) { _ in
        return CountryStorage.countries.count == 0
      }
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
        return value.map { $0.name }
      }
      let countries = getCountries()
      row.options = countries.all
      row.value = countries.current
    }.onChange { (row) in
      Defaults[.country] = row.value?.code ?? ""
    }
  }
  
  // Creates thw row for getting the stations
  private func createGetStationsRow() -> LabelRow {
    let rowTitle = "Bahnhofsdaten aktualisieren"
    
    return LabelRow(RowTag.loadStations.rawValue) { row in
      row.title = rowTitle
      row.hidden = .function([RowTag.countryPicker.rawValue]) { _ in
        return Defaults[.country] == ""
      }
      if let lastUpdate = Defaults[.lastUpdate] {
        row.value = lastUpdate.relativeDateString
      }
      }.onCellSelection { (_, row) in
        row.title = "Bahnhofsdaten herunterladen"
        row.updateCell()
        
        Helper.setIsUserInteractionEnabled(in: self, to: false)
        self.view.makeToastActivity(.center)

        Helper.loadStations(progressHandler: { progress, count in
          row.title = "Bahnhof speichern: \(progress)/\(count)"
          row.value = "\(UInt(round(Float(progress) / Float(count) * 100)))%"
          row.updateCell()
        }) {
          row.title = rowTitle
          if let lastUpdate = Defaults[.lastUpdate] {
            row.value = lastUpdate.relativeDateString
          }
          row.updateCell()
          
          Helper.setIsUserInteractionEnabled(in: self, to: true)
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
  
  private func createLicensePickerRow() -> PickerInlineRow<License> {
    return PickerInlineRow<License>(RowTag.licensePicker.rawValue) { row in
      row.title = "Lizenz"
      row.displayValueFor = { (value: License?) in
        switch value {
        case .cc40?:
          return "CC4.0 mit Namensnennung"
        default:
          return "CC0 - ohne Namensnennung"
        }
      }
      row.options = License.allValues
      row.value = Defaults[.license]
      }.onChange { (row) in
        Defaults[.license] = License(rawValue: row.value?.rawValue ?? "")
    }
  }
  
  private func createLicenseSection() -> Section {
    return Section(FormSection.license.rawValue)
      <<< createLicensePickerRow()
  }

  // MARK: Linking

  private func createLinkSection() -> Section {
    return Section(FormSection.link.rawValue)

      <<< SwitchRow(RowTag.linkPhotos.rawValue) { row in
        row.title = "Fotos verlinken"
        row.value = Defaults[.accountLinking]
      }.onChange { row in
        guard let value = row.value else { return }
        Defaults[.accountLinking] = value
      }

      <<< PickerInlineRow<AccountType>(RowTag.accountType.rawValue) { row in
        row.title = "Account"
        row.hidden = .function([RowTag.linkPhotos.rawValue]) { _ in
          return !Defaults[.accountLinking]
        }
        row.options = [
          AccountType.none,
          AccountType.twitter,
          AccountType.facebook,
          AccountType.instagram,
          AccountType.snapchat,
          AccountType.xing,
          AccountType.misc
        ]
        row.displayValueFor = { (value: AccountType?) in
          return value?.rawValue
        }
        row.value = Defaults[.accountType]
      }.onChange { row in
        Defaults[.accountType] = row.value
      }

      <<< TextRow { row in
        row.value = Defaults[.accountName]
        row.placeholder = "Accountname"
      }.onChange { row in
        Defaults[.accountName] = row.value ?? ""
      }
  }
  
  // MARK: Informations
  
  private func createInformationsRow() -> LabelRow {
    return LabelRow() { row in
      row.title = "Informationen"
      row.onCellSelection({ (_, row) in
        let acknowledgementsViewController = CPDAcknowledgementsViewController()
        self.navigationController?.pushViewController(acknowledgementsViewController, animated: true)
        acknowledgementsViewController.navigationController?.setNavigationBarHidden(false, animated: true)
      })
    }
  }
  
  private func createInformationSection() -> Section {
    return Section()
      <<< createInformationsRow()
  }

}