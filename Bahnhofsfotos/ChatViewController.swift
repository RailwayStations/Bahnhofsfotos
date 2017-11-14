//
//  ChatViewController.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 20.04.17.
//  Copyright © 2017 Railway-Stations. All rights reserved.
//

import FirebaseAuth
import FirebaseDatabase
import JSQMessagesViewController
import UIKit

class ChatViewController: JSQMessagesViewController {

  private lazy var channelRef: DatabaseReference? = Database.database().reference()
  fileprivate lazy var messageRef: DatabaseReference? = self.channelRef?.child("messages")
  private var newMessageRefHandle: DatabaseHandle?
  var messages = [DataSnapshot]()
  var avatars = [String: UIImage]()

  fileprivate lazy var incomingBubbleImage: JSQMessagesBubbleImage =
    JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: Helper.alternativeTintColor)
  fileprivate lazy var outgoingBubbleImage: JSQMessagesBubbleImage = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: Helper.tintColor)

  fileprivate lazy var isoDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.calendar = Calendar(identifier: .iso8601)
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
    return dateFormatter
  }()

  fileprivate lazy var customDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "de_DE")
    dateFormatter.dateFormat = "dd.MM.yyyy @ HH:mm"
    return dateFormatter
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    guard Auth.auth().currentUser != nil else {
      Helper.signOut()
      return
    }

    configureDatabase()
    configureChat()
  }

  deinit {
    if let refHandle = newMessageRefHandle {
      messageRef?.removeObserver(withHandle: refHandle)
    }
  }

  private func configureDatabase() {
    view.makeToastActivity(.center)

    channelRef = Database.database().reference()
    // Listen for new messages in the Firebase database
    guard let messageQuery = messageRef?.queryLimited(toLast: 25) else { return }

    newMessageRefHandle = messageQuery.observe(.childAdded, with: { snapshot in
      self.messages.append(snapshot)
      self.loadAvatars()
      self.view.hideToastActivity()
      self.finishReceivingMessage()
    })
  }

  private func configureChat() {
    guard let user = Auth.auth().currentUser else { return }
    senderId = user.uid
    senderDisplayName = user.displayName

    collectionView.tintColor = UIColor.black

    inputToolbar.contentView.leftBarButtonItem = nil
  }

  fileprivate func getDate(fromString from: String) -> Date? {
    var date = isoDateFormatter.date(from: from)

    // date isn't iso 8601
    if date == nil {
      date = customDateFormatter.date(from: from)
    }

    return date
  }

  fileprivate func getJSQMessage(fromSnapshot snapshot: DataSnapshot) -> JSQMessage? {
    guard let message = snapshot.value as? [String: String] else { return nil }
    let userId = message[Constants.MessageFields.userId] ?? message[Constants.MessageFields.name] ?? ""
    let name = message[Constants.MessageFields.name] ?? ""

    guard let text = message[Constants.MessageFields.text], text.characters.count > 0  else {
      debugPrint("Error! Could not decode message data")
      return nil
    }

    if let chatTimeStamp = message[Constants.MessageFields.chatTimeStamp],
      let date = getDate(fromString: chatTimeStamp) {
      return JSQMessage(senderId: userId, senderDisplayName: name, date: date, text: text)
    }

    return JSQMessage(senderId: userId, displayName: name, text: text)
  }

  private func loadAvatars() {
    DispatchQueue.global(qos: .utility).async {
      for snapshot in self.messages {
        guard let message = snapshot.value as? [String: String] else { continue }
        guard let key = message[Constants.MessageFields.name], self.avatars[key] == nil else { continue }

        if let photoURL = message[Constants.MessageFields.photoURL], let URL = URL(string: photoURL),
          let data = try? Data(contentsOf: URL) {
          if let image = UIImage(data: data) {
            self.avatars[key] = image
          }
        }
      }
      DispatchQueue.main.async {
        self.collectionView.reloadData()
      }
    }
  }

}

// MARK: - JSQMessagesCollectionViewDataSource
extension ChatViewController {

  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return messages.count
  }

  override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
    return getJSQMessage(fromSnapshot: messages[indexPath.item])
  }

  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = super.collectionView(collectionView, cellForItemAt: indexPath)

    if let jsqCell = cell as? JSQMessagesCollectionViewCell {
      let snapshot = messages[indexPath.row]
      if let message = snapshot.value as? [String: String] {
        let userId = message[Constants.MessageFields.userId] ?? message[Constants.MessageFields.name] ?? ""
        jsqCell.textView?.textColor = userId == senderId ? UIColor.white : UIColor.black
        return jsqCell
      }
    }

    return cell
  }

  override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
    let snapshot = messages[indexPath.row]
    guard let message = snapshot.value as? [String: String] else { return incomingBubbleImage }
    let userId = message[Constants.MessageFields.userId] ?? message[Constants.MessageFields.name] ?? ""
    return userId == senderId ? outgoingBubbleImage : incomingBubbleImage
  }

  override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
    let snapshot = messages[indexPath.row]
    guard let message = snapshot.value as? [String: String] else { return nil }

    var label = message[Constants.MessageFields.name]?.capitalized ?? ""
    if let date = getDate(fromString: message[Constants.MessageFields.chatTimeStamp] ?? "") {
      let dateString = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)
      label += ", " + dateString
    }

    return NSAttributedString(string: label)
  }

  override func collectionView(_ collectionView: JSQMessagesCollectionView!,
                               layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!,
                               heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
    return kJSQMessagesCollectionViewCellLabelHeightDefault
  }

  override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
    let snapshot = messages[indexPath.row]
    guard let message = snapshot.value as? [String: String] else { return nil }

    if let key = message[Constants.MessageFields.name], let avatar = avatars[key] {
      return JSQMessagesAvatarImageFactory.avatarImage(with: avatar, diameter: 30)
    }

    let initials = message[Constants.MessageFields.name]?.components(separatedBy: " ").map { $0.characters.first != nil ? String($0.characters.first!) : "" }.joined()

    let userId = message[Constants.MessageFields.userId] ?? message[Constants.MessageFields.name] ?? ""

    return JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: initials?.uppercased(),
                                                     backgroundColor: userId == senderId ? Helper.tintColor : Helper.alternativeTintColor,
                                                     textColor: userId == senderId ? UIColor.white : UIColor.black,
                                                     font: UIFont.systemFont(ofSize: 14),
                                                     diameter: 34)
  }

}

extension ChatViewController {

  override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
    guard let itemRef = self.messageRef?.childByAutoId() else { return }
    let messageItem = [
      Constants.MessageFields.userId: senderId,
      Constants.MessageFields.name: senderDisplayName,
      Constants.MessageFields.photoURL: Auth.auth().currentUser?.photoURL?.absoluteString,
      Constants.MessageFields.chatTimeStamp: customDateFormatter.string(from: Date()),
      Constants.MessageFields.text: text
    ]

    itemRef.setValue(messageItem)

    JSQSystemSoundPlayer.jsq_playMessageSentSound()

    finishSendingMessage()
  }

}
