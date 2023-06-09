//
//  ChatUserController.swift
//  Meeting
//
//  Created by Деним Мержан on 24.05.23.
//

import UIKit
import FirebaseFirestore

class ChatUserController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topElementView: UIView!
    @IBOutlet weak var avatarUser: UIImageView!
    @IBOutlet weak var nameUser: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    var currentAuthUser = CurrentAuthUser(ID: "")
    var selectedUser = User(ID: "")
    var listener: ListenerRegistration?
    
    var statusSendMessage: String {
        get {
            for messages in chatArr {
                if messages.messagedWritingOnServer == false {return "Идет отправка..."}
            }
            return  "Отправлено"
        }
    }
    
    var chatArr: [message] {
        get {
            guard let chatArr = currentAuthUser.chatArr.first(where: {$0.ID.contains(selectedUser.ID) })?.messages else {return [message]()}
            return chatArr
        }
    }
    
    let widthMessagView = UIScreen.main.bounds.width - 90 /// 45 - ширина аватара, 25 - ширина сердечка справа, 20 - отуступы от краев и от друг друга
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSetings()
    }
    
    
    @IBAction func exitButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        
        guard let body = textField.text else {return}
        if textField.text?.count == 0 {return}
        textField.text = ""
        
        currentAuthUser.sendMessageToServer(pairUserID: selectedUser.ID, body: body)
        
        if currentAuthUser.chatArr.firstIndex(where: {$0.ID.contains(selectedUser.ID)}) == nil { /// Если чата не существует, значит это первое сообщение
            
            var chatID = String()
            if currentAuthUser.ID > selectedUser.ID {
                chatID = currentAuthUser.ID + "\\" + selectedUser.ID
            }else {
                chatID = selectedUser.ID + "\\" + currentAuthUser.ID
            }
            
            var chat = Chat(ID: chatID,dateLastMessageRead: Date().timeIntervalSince1970)
            chat.messages.append(message(sender: currentAuthUser.ID, body: body))
            currentAuthUser.chatArr.append(chat)
            loadMessage()
        }
        
    }
    
    @objc func userReturnedToChat(){ /// Когда пользователь снова открывает приложение, мы снова загружаем чаты
        loadMessage()
    }
    
    deinit {
        print("Denit")
        listener?.remove() /// Удаляем прослушивателя
        
        if let chatIndex = currentAuthUser.chatArr.firstIndex(where: {$0.ID.contains(selectedUser.ID)}) {
            currentAuthUser.chatArr[chatIndex].lastUnreadMessage = nil
        } /// После того как пользователь прочитал сообщения обнуляем последнее не прочитанное сообщение
        
        NotificationCenter.default.removeObserver(self,name: Notification.Name("sceneWillEnterForeground"), object: nil)
    }
}


//MARK: -  Стартовые настройки

extension ChatUserController {
    
    func setupSetings(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(userReturnedToChat), name: Notification.Name(rawValue: "sceneWillEnterForeground"), object: nil)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "CurrentChatCell", bundle: nil), forCellReuseIdentifier: "currentChatCell")
        tableView.sectionHeaderHeight = 40
        
        
        avatarUser.layer.cornerRadius = avatarUser.frame.width / 2
        avatarUser.clipsToBounds = true
        topElementView.addBottomShadow()
        
        textField.layer.cornerRadius = textField.frame.height / 2
        textField.backgroundColor = UIColor(named: "PlaceHolderChatColor")
        textField.layer.borderWidth = 0.2
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.masksToBounds = true
        
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.gray,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15)
        ]
        textField.attributedPlaceholder = NSAttributedString(string: "Сообщение",attributes: attributes)
        
        avatarUser.image = selectedUser.avatar
        nameUser.text = selectedUser.name
        print(tableView.numberOfSections)
        loadMessage()
        
    }
}

//MARK: - UITableViewDataSource

extension ChatUserController: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatArr.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "currentChatCell", for: indexPath) as! CurrentChatCell
        
        cell.messageLabel.text = chatArr[indexPath.row].body
        cell.selectionStyle = .none
        
        let id = chatArr[indexPath.row].sender
        
        let label = UILabel() /// Лейбл с постоянной высотой 45 и шириной что бы всегда расчитывать одну и ту же идеальную ширину текста для ячейки
        
        label.text = cell.messageLabel.text
        label.font = cell.messageLabel.font
        label.frame.size.width = widthMessagView - 20
        label.frame.size.height = 45
        
        if id == currentAuthUser.ID {
            
            cell.statusMessage.isHidden = false
            if chatArr[indexPath.row].messagedWritingOnServer == false {
                cell.statusMessage.image = UIImage(named: "SendMessageTimer")
            }
            
            cell.heartLikeView.isHidden = true
            cell.rightMessageViewConstrains.isActive = false
            cell.avatar.image = UIImage()
            cell.rightConstrainsToSuperView.isActive = true /// Дополнительная константа которая говорит что MessageView будт на расстояние от SuperView на 5 пунктов
            
            cell.messageLabel.textAlignment = .right
            cell.messageView.backgroundColor = UIColor(named: "CurrentUserMessageColor")
            cell.messageLabel.textColor = .white
            
            let width = label.intrinsicContentSize.width
            
            if width < widthMessagView {
                let newLeftConstant = widthMessagView - width - 32/// Получаем новую разницу между mesage view и avatar 32 - расстояние от лейбла до правой стороны и левой стороны messageView
                cell.leftMessageViewConstrains.constant = newLeftConstant + 5 + 30
            }else {
                cell.leftMessageViewConstrains.constant = 5
            }
            
            
        }else {
            cell.statusMessage.isHidden = true
            cell.labelRightConstrains.constant = 5
            cell.messageLabel.textAlignment = .left
            cell.messageView.backgroundColor = UIColor(named: "GrayColor")
            cell.avatar.image = selectedUser.avatar
            cell.messageLabel.textColor = .black
            
            let width = label.intrinsicContentSize.width
            
            if width < widthMessagView {
                let newRightConstrains = widthMessagView - width - 20
                cell.rightMessageViewConstrains.constant = newRightConstrains + 5
            }else {
                cell.rightMessageViewConstrains.constant = 5
            }
        }
        
        if indexPath.row + 1 < chatArr.count && chatArr[indexPath.row + 1].sender == id {
            cell.avatar.image = UIImage()
            cell.bottomMessageViewConstrains.constant = 0
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = viewForHeaderSection(section: section)
        return view
    }
        
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard section == tableView.numberOfSections - 1 else {return nil}
        let view = viewForFooterSection(section: section)
        return view
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        print("SwipeStart")
        return .some(.init())
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == tableView.numberOfSections - 1 ? 20 : 0
    }
    
}

//MARK: -  Отслеживание изменений на сервере

extension ChatUserController {
    
    func loadMessage(){
        
        guard let indexChat = currentAuthUser.chatArr.firstIndex(where: {$0.ID.contains(selectedUser.ID)}) else  {return}
        let authUser = currentAuthUser
        
        listener?.remove()
        
        let indexChatOnServer = currentAuthUser.chatArr[indexChat].ID
        let db = Firestore.firestore()
        
        let listener = db.collection("Chats").document(indexChatOnServer).collection("Messages").order(by: "Date").addSnapshotListener(includeMetadataChanges: true) { [weak self] QuerySnapshot, err in
            
            
            if let error = err {print("Ошибка прослушивания снимков с сервера - \(error)"); return}
            
            print("LoadMessage")
            
            guard let document = QuerySnapshot else {return}
            authUser.chatArr[indexChat].messages.removeAll()
               
            for data in document.documents {
                
                if let body = data["Body"] as? String, let sender = data["Sender"] as? String, let date = data["Date"] as? Double {
                    var message = message(sender: sender, body: body)
                    if authUser.chatArr[indexChat].dateLastMessageRead >= date { /// Если пользователь был в сети к моменту когда это сообщения было отправлено, то помечаем его что оно доставленно на сервер
                        message.messagedWritingOnServer = true
                    }
                    self?.currentAuthUser.chatArr[indexChat].messages.append(message)
                }
            }
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                let count = self?.currentAuthUser.chatArr[indexChat].messages.count ?? 1
                let sectionNumber = self?.tableView.numberOfSections ?? 1
                let indexPath = IndexPath(row: count - 1, section: sectionNumber - 1)
                self?.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
            }
        }
        self.listener = listener
    }
    
}


//MARK: -  Тень для TopView

extension UIView {
    func addBottomShadow() {
        layer.masksToBounds = false
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.3
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0 , height: 0.5)
        layer.shadowPath = UIBezierPath(rect: CGRect(x: 0,
                                                     y: bounds.maxY - layer.shadowRadius,
                                                     width: bounds.width,
                                                     height: layer.shadowRadius)).cgPath
    }
}

//MARK: -  Создание View для колонтитулов

extension ChatUserController {
    
    func viewForHeaderSection(section: Int) -> UIView {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        label.textColor = .gray
        label.textAlignment = .center
        label.center = view.center
        view.addSubview(label)
        
        let attrs1 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12), NSAttributedString.Key.foregroundColor : UIColor.darkGray]
        let attrs2 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor : UIColor.gray]
        let attributedString1 = NSMutableAttributedString(string:"Четверг ", attributes:attrs1)
        let attributedString2 = NSMutableAttributedString(string:"16:52", attributes:attrs2)
        attributedString1.append(attributedString2)
        
        if section == 0 {
            label.text = "Вы образовали пару 19.04.23"
        }else {
            label.attributedText = attributedString1
        }
        
        return view
    }
    
    func viewForFooterSection(section: Int) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 20))
        
        let label = UILabel(frame: CGRect(x: view.frame.maxX - 110, y: 0, width: 100, height: 20))
        label.textColor = .gray
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12)
        
        label.text = statusSendMessage
        
        view.addSubview(label)
        
        return view
    }
    
}
