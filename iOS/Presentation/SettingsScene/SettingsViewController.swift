//
//  SettingsViewController.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 17.12.16.
//  Copyright © 2016 MrHaitec. All rights reserved.
//

import Combine
import Data
import Domain
import CPDAcknowledgements
import Eureka
import Shared
import SwiftyUserDefaults
import Toast_Swift

class SettingsViewController: FormViewController {

  private enum FormSection: String {
    case download = "Bahnhofsdaten"
    case license = "Lizenzierung"
    case link = "Verlinkung"
    case upload = "Direkt-Upload"
  }

  private enum RowTag: String {
    case loadCountries
    case countryPicker
    case loadStations
    case licensePicker
    case photoOwner
    case linkPhotos
    case accountType
    case accountName
    case twitter
    case accountNickname
    case accountEmail
    case requestToken
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    createForm()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: true)
    tableView.reloadData()
  }

  private lazy var countriesUseCase: CountriesUseCase = {
    CountriesUseCase(countriesRepository: CountriesRepository())
  }()

  private lazy var stationsUseCase: StationsUseCase = {
    StationsUseCase(stationsRepository: StationsRepository())
  }()

  private var cancellables = [AnyCancellable]()

  // MARK: - Eureka

  private func createForm() {
    form
      +++ createDownloadSection()
      +++ createLicenseSection()
      +++ createLinkSection()
      +++ createUploadSection()
      +++ createUploadTokenSection()
      +++ Section()
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

      self.countriesUseCase.fetchCountries()
        .replaceError(with: [])
        .sink { _ in
          row.title = rowTitle
          row.value = ""
          row.updateCell()
          Helper.setIsUserInteractionEnabled(in: self, to: true)
          self.view.hideToastActivity()
        }
        .store(in: &self.cancellables)
    }
  }

  // Creates row for picking the country
  private func createCountryPickerRow() -> PickerInlineRow<Country> {
    let getCountries = {
      return (
        all: CountryStorage.countries,
        current: CountryStorage.countries.first { (country) -> Bool in
          return country.code == Defaults.country
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
      Defaults.country = row.value?.code ?? ""
    }
  }
  
  // Creates thw row for getting the stations
  private func createGetStationsRow() -> LabelRow {
    let rowTitle = "Bahnhofsdaten aktualisieren"
    
    return LabelRow(RowTag.loadStations.rawValue) { row in
      row.title = rowTitle
      row.hidden = .function([RowTag.countryPicker.rawValue]) { _ in
        return Defaults.country == ""
      }
      if let lastUpdate = Defaults.lastUpdate {
        row.value = lastUpdate.relativeDateString
      }
      }.onCellSelection { (_, row) in
        row.title = "Bahnhofsdaten herunterladen"
        row.value = nil
        row.updateCell()
        
        Helper.setIsUserInteractionEnabled(in: self, to: false)
        self.view.makeToastActivity(.center)

        self.stationsUseCase.fetchStations()
          .replaceError(with: [])
          .sink { stations in
            row.title = rowTitle
            if let lastUpdate = Defaults.lastUpdate {
              row.value = lastUpdate.relativeDateString
            }
            row.updateCell()

            Helper.setIsUserInteractionEnabled(in: self, to: true)
            self.view.hideToastActivity()
          }
          .store(in: &self.cancellables)
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
  
  private func createLicensePickerRow() -> LabelRow {
    return LabelRow() { row in
      row.title = "Lizenz"
      row.value = "CC0 - ohne Namensnennung"
    }
  }
  
  private func createPhotoOwnerRow() -> SwitchRow {
    return SwitchRow(RowTag.photoOwner.rawValue) { row in
      row.title = "Urheber der Fotos"
      row.value = Defaults.photoOwner
      }.onChange { row in
        guard let value = row.value else { return }
        Defaults.photoOwner = value
    }
  }
  
  private func createLicenseSection() -> Section {
    return Section(FormSection.license.rawValue)
      <<< createLicensePickerRow()
      <<< createPhotoOwnerRow()
  }

  // MARK: Linking

  private func createLinkSection() -> Section {
    return Section(FormSection.link.rawValue)

      <<< SwitchRow(RowTag.linkPhotos.rawValue) { row in
        row.title = "Fotos verlinken"
        row.value = Defaults.accountLinking
      }.onChange { row in
        guard let value = row.value else { return }
        Defaults.accountLinking = value
      }

      <<< PickerInlineRow<AccountType>(RowTag.accountType.rawValue) { row in
        row.title = "Account"
        row.hidden = .function([RowTag.linkPhotos.rawValue]) { _ in
          return !Defaults.accountLinking
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
        row.value = Defaults.accountType
      }.onChange { row in
        guard let value = row.value else { return }
        Defaults.accountType = value
      }

      <<< TextRow(RowTag.accountName.rawValue) { row in
        row.value = Defaults.accountName
        row.placeholder = "Accountname"
      }.onChange { row in
        Defaults.accountName = row.value ?? ""
      }.onCellHighlightChanged { _, row in
        if !row.isHighlighted {
          row.value = (row.value ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        }
      }

  }
  
  // MARK: Upload
  
  private func createUploadSection() -> Section {
    return Section(FormSection.upload.rawValue)

      <<< TextRow(RowTag.accountNickname.rawValue) { row in
        row.value = Defaults.accountNickname
        row.placeholder = "Nickname"
      }.onChange { row in
        Defaults.accountNickname = row.value ?? ""
      }.onCellHighlightChanged { _, row in
        if !row.isHighlighted {
          row.value = (row.value ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        }
      }

      <<< TextRow(RowTag.accountEmail.rawValue) { row in
        row.value = Defaults.accountEmail
        row.placeholder = "E-Mailadresse"
      }.onChange { row in
        Defaults.accountEmail = row.value ?? ""
      }.onCellHighlightChanged { _, row in
        if !row.isHighlighted {
          row.value = (row.value ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        }
      }
    
      <<< ButtonRow(RowTag.requestToken.rawValue) { row in
        row.title = "Token anfordern"
        row.hidden = Condition.function([
          RowTag.photoOwner.rawValue,
          RowTag.linkPhotos.rawValue,
          RowTag.accountType.rawValue,
          RowTag.accountName.rawValue,
          RowTag.accountNickname.rawValue,
          RowTag.accountEmail.rawValue
        ], { form -> Bool in
          guard
            let nickname = Defaults.accountNickname,
            let email = Defaults.accountEmail,
            let name = Defaults.accountName
            else {
              return true
          }

          return !(Defaults.photoOwner
            && nickname.count > 2
            && email.count > 2
            && name.count > 2)
        })
      }.onCellSelection { cell, row in
        // check if token was created recently
        if let lastRequest = Defaults.uploadTokenRequested {
          guard Date() > lastRequest.addingTimeInterval(60 * 5) else {
            self.view.makeToast("Der Token wurde erst vor kurzem erstellt.")
            return
          }
        }

        Helper.setIsUserInteractionEnabled(in: self, to: false)
        self.view.makeToastActivity(.center)

        // request token
        API.register { success in
          self.view.hideToastActivity()
          Helper.setIsUserInteractionEnabled(in: self, to: true)

          let date = Date()
          if success {
            Defaults.uploadTokenRequested = date
            let alert = UIAlertController(title: "Token angefordert", message: "Der Token wurde per E-Mail verschickt.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
          } else {
            self.view.makeToast("Fehler beim Anfordern des Token.")
          }
          row.value = date.relativeDateString
        }
      }
  }
  
  private func createUploadTokenSection() -> Section {
    return Section()

      <<< TextRow { row in
        row.value = Defaults.uploadToken
        row.placeholder = "Upload Token"
      }.onChange { row in
        Defaults.uploadToken = row.value ?? ""
      }.onCellHighlightChanged { _, row in
        if !row.isHighlighted {
          row.value = (row.value ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        }
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
