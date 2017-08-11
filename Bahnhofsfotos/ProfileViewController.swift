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

  // Creates the download section
  private func createDownloadSection() -> Section {
    return Section(FormSection.download.rawValue)
      <<< createGetCountriesRow()
      <<< createCountryPickerRow()
  }

  // MARK: License

  private func createLicenseSection() -> Section {
    let license = { (license: License?) in
      return (text: license == .cc40 ? "CC4.0 mit Namensnennung" : "CC0 - ohne Namensnennung", value: license == .cc40)
    }

    return Section(FormSection.license.rawValue)

      <<< LabelRow { row in
        row.title = "Lizenz deiner Fotos?"
      }

      <<< SwitchRow { row in
        row.title = license(Defaults[.license]).text
        row.value = license(Defaults[.license]).value
      }.onChange { row in
        guard let value = row.value else { return }
        Defaults[.license] = value ? .cc40 : .cc0
        row.title = license(Defaults[.license]).text
        row.updateCell()
      }
  }

  // MARK: Verlinkung

  private func createLinkSection() -> Section {
    return Section(FormSection.link.rawValue)

      <<< LabelRow { row in
        row.title = "Möchtest Du verlinkt werden?"
      }

      <<< SwitchRow { row in
        row.title = Defaults[.accountLinking] ? "Ja" : "Nein"
        row.value = Defaults[.accountLinking]
      }.onChange { row in
        guard let value = row.value else { return }
        Defaults[.accountLinking] = value
        row.title = Defaults[.accountLinking] ? "Ja" : "Nein"
        row.updateCell()
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
        row.hidden = .function([RowTag.accountType.rawValue], { _ in
          return Defaults[.accountType] == AccountType.none
        })
      }.onChange { row in
        Defaults[.accountName] = row.value ?? ""
      }
  }

}
