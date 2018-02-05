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
import TwitterKit

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
        guard let value = row.value else { return }
        Defaults[.license] = value
    }
  }
  
  private func createPhotoOwnerRow() -> SwitchRow {
    return SwitchRow(RowTag.photoOwner.rawValue) { row in
      row.title = "Urheber der Fotos"
      row.value = Defaults[.photoOwner]
      }.onChange { row in
        guard let value = row.value else { return }
        Defaults[.photoOwner] = value
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
        guard let value = row.value else { return }
        Defaults[.accountType] = value
      }

      <<< TextRow(RowTag.accountName.rawValue) { row in
        row.value = Defaults[.accountName]
        row.placeholder = "Accountname"
        row.hidden = .function([RowTag.accountType.rawValue]) { _ in
          return Defaults[.accountType] == .twitter
        }
      }.onChange { row in
        Defaults[.accountName] = row.value ?? ""
      }.onCellHighlightChanged { _, row in
        if !row.isHighlighted {
          row.value = (row.value ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        }
      }

      <<< LabelRow(RowTag.twitter.rawValue) { row in
        row.hidden = .function([RowTag.accountType.rawValue]) { _ in
          return Defaults[.accountType] != .twitter
        }

        row.title = getTwitterAccountName()
        row.value = nil

        if TWTRTwitter.sharedInstance().sessionStore.hasLoggedInUsers() {
          row.value = "Abmelden"
        }
      }.onCellSelection { cell, row in
        let store = TWTRTwitter.sharedInstance().sessionStore
        if (store.hasLoggedInUsers()) {
          if let session = store.session() {
            store.logOutUserID(session.userID)
          }
          Defaults[.accountName] = nil
          row.title = self.getTwitterAccountName()
          row.value = nil
          row.updateCell()
        } else {
          TWTRTwitter.sharedInstance().logIn { [weak self] (session, error) in
            if let error = error, let weakSelf = self {
              let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
              alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
              weakSelf.present(alert, animated: true, completion: nil)
            } else if let session = session {
              Defaults[.accountName] = session.userName
              row.title = session.userName
              row.value = "Abmelden"
              row.updateCell()
            }
          }
        }
      }
  }

  // Returns the first session found
  private func getTwitterAccountName() -> String {
    let store = TWTRTwitter.sharedInstance().sessionStore

    if let session = store.session() {
      for existingUserSession in store.existingUserSessions() {
        if let userSession = existingUserSession as? TWTRSession {
          if userSession.userID == session.userID {
            return userSession.userName
          }
        }
      }
    }

    if store.hasLoggedInUsers() {
      if let accountName = Defaults[.accountName] {
        return accountName
      }
    }

    return "Mit Twitter anmelden"
  }
  
  // MARK: Upload
  
  private func createUploadSection() -> Section {
    return Section(FormSection.upload.rawValue)

      <<< TextRow(RowTag.accountNickname.rawValue) { row in
        row.value = Defaults[.accountNickname]
        row.placeholder = "Nickname"
      }.onChange { row in
        Defaults[.accountNickname] = row.value ?? ""
      }.onCellHighlightChanged { _, row in
        if !row.isHighlighted {
          row.value = (row.value ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        }
      }

      <<< TextRow(RowTag.accountEmail.rawValue) { row in
        row.value = Defaults[.accountEmail]
        row.placeholder = "E-Mailadresse"
      }.onChange { row in
        Defaults[.accountEmail] = row.value ?? ""
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
            let nickname = Defaults[.accountNickname],
            let email = Defaults[.accountEmail],
            let name = Defaults[.accountName]
            else {
              return true
          }

          return !(Defaults[.photoOwner]
            && nickname.count > 2
            && email.count > 2
            && name.count > 2)
        })
      }.onCellSelection { cell, row in
        // check if token was created recently
        if let lastRequest = Defaults[.uploadTokenRequested] {
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
            Defaults[.uploadTokenRequested] = date
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
        row.value = Defaults[.uploadToken]
        row.placeholder = "Upload Token"
      }.onChange { row in
        Defaults[.uploadToken] = row.value ?? ""
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
