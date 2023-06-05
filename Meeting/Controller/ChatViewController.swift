//
//  ChatViewController.swift
//  Meeting
//
//  Created by Деним Мержан on 22.05.23.
//

import UIKit

class ChatViewController: UIViewController {

    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var verticalScrollView: UIScrollView!
    @IBOutlet weak var mostViewScrolling: UIView!
    @IBOutlet weak var meetingLabel: UILabel!
    @IBOutlet weak var heightMostScrollView: NSLayoutConstraint!
    
    
    var selectedUser: User?
    var currentAuthUser: CurrentAuthUser?
    let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
    
    private var widthHorizontalScrollview = CGFloat() {
        didSet {
            if widthHorizontalScrollview < mostViewScrolling.frame.width {
                contenView.frame.size.width = mostViewScrolling.frame.width + 50
                horizontalScrollView.contentSize.width = mostViewScrolling.frame.width + 50
            }else {
                contenView.frame.size.width = widthHorizontalScrollview
                horizontalScrollView.contentSize.width = widthHorizontalScrollview
            }
        }
    }
    
    private lazy var horizontalScrollView: UIScrollView =  {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.frame = CGRect(x: 10, y: 60, width: view.frame.width, height: 155)
        scrollView.contentSize = CGSize(width: widthHorizontalScrollview, height: 155)
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var contenView: UIView = {
        let contentView = UIView()
        contentView.backgroundColor = .clear
        contentView.frame.size = CGSize(width: widthHorizontalScrollview, height: 155)
        return contentView
    }()
    
    var collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 200, height: 155), collectionViewLayout: UICollectionViewFlowLayout.init())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let vc = self.tabBarController?.viewControllers![0] as? PairsViewController {
            currentAuthUser = vc.currentAuthUser
        }
        
  
        
        
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "ChatCell")
        tableView.rowHeight = 100
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        
        collectionView.dataSource = self
        collectionView.backgroundColor = .red
        layout.scrollDirection = .horizontal
        
        mostViewScrolling.addSubview(horizontalScrollView)
        horizontalScrollView.addSubview(contenView)
        contenView.addSubview(collectionView)
        
        
        collectionView.register(UINib(nibName: "PotentialChatCell", bundle: nil), forCellWithReuseIdentifier: "potentialChatCell")
        
        contenView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.rightAnchor.constraint(equalTo: contenView.rightAnchor),
            collectionView.topAnchor.constraint(equalTo: contenView.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contenView.bottomAnchor),
            
        ])
    }
    
}



//MARK: -  Создание ячеек чатов пользователя и потенциальных чатов

extension ChatViewController {
    
//    func createChatViewCell()  {
//
//        guard let authUser = currentAuthUser else {return}
//
//        if authUser.matchArr.count == 0 {
//            creatEmptyPotentialCell()
//            return
//        }
//
//        createPotentialChatt()
//        creatEmptyPotentialCell()
//    }
    
//MARK: -  Создание EmptyChatCell
    
//    func createPotentialChatt(){
//
//        guard let authUser = currentAuthUser else {return}
//        print(authUser.matchArr.count, " -  Count")
//        for user in authUser.matchArr {
//
//            guard let chatUser = currentAuthUser?.chatArr.first(where: {$0.ID == user.ID }) else {return}
//
//            if chatUser.messages.count == 0 {
//                let potentialChatCell = CustomPotenial(frame: CGRect(x: 0, y: 0, width: 105, height: 155), avatar: user.avatar, name: user.name,ID: user.ID)
//
//                potenitalChatCellArr.append(potentialChatCell)
//                horizontalStackView.addArrangedSubview(potentialChatCell)
//            }
//
//        }
//    }
    
    //MARK: -  Создание EmptyChatCell
        
//        func creatEmptyPotentialCell(){
//
//            if potenitalChatCellArr.count < 4 {
//                for _ in 0...4 - potenitalChatCellArr.count - 1 {
//                    let cell = CustomPotenial(frame: CGRect(x: 0, y: 0, width: 105, height: 155), avatar: nil, name: nil,ID: nil)
//                    potenitalChatCellArr.append(cell)
//                    horizontalStackView.addArrangedSubview(cell)
//                }
//            }
//        }
}



////MARK: -  Настройка Горизонтального ScrollView
//
//extension ChatViewController {
//
//    private func setupContentViewContstains(){
//
//        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            horizontalStackView.topAnchor.constraint(equalTo: contenView.topAnchor),
//            horizontalStackView.bottomAnchor.constraint(equalTo: contenView.bottomAnchor),
//            horizontalStackView.leftAnchor.constraint(equalTo: contenView.leftAnchor)
//        ])
//
//        for view in horizontalStackView.arrangedSubviews {
//            NSLayoutConstraint.activate([
//                view.widthAnchor.constraint(equalToConstant: 105),
//                view.heightAnchor.constraint(equalToConstant: 155)
//            ])
//        }
//    }
//}


//MARK: - TableViewDataSource and Delegate

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let authUser = currentAuthUser else {return 0}
        
        let height = CGFloat(authUser.matchArr.count * 100) + 280
        
        heightMostScrollView.constant = height /// Обновляем константу вертикального ScrollView  в зависимости от количества чатов
        
        view.layoutIfNeeded()
        
        return authUser.matchArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatCell
        
        guard let authUser = currentAuthUser else {return cell}
        let pairUser = authUser.matchArr[indexPath.row]
        guard let chat = currentAuthUser?.chatArr.first(where: {$0.ID == pairUser.ID }) else {return cell}
        
        cell.scrollView = verticalScrollView
        
        cell.avatar.image = pairUser.avatar
        cell.nameLabel.text = pairUser.name
        cell.commentLabel.text = chat.messages.last?.body /// Последнее сообщение от нее
        
        let action = UIAction { [weak self] UIAction in
            authUser.matchArr.remove(at: indexPath.row)
            self?.tableView.reloadData()
        }

        cell.deleteView.button.addAction(action, for: .touchUpInside)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let authUser = currentAuthUser else {return}
        selectedUser = authUser.matchArr[indexPath.row]
        performSegue(withIdentifier: "goToChat", sender: self)
    }
    
}



//MARK: - UICollectionViewDataSource

extension ChatViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 10
        print("Yeah")
//        guard let authUser = currentAuthUser else {return 0}
//        for chat in authUser.chatArr {
//            if chat.messages.count > 0 {
//                count += 1
//            }
//        }
        widthHorizontalScrollview = CGFloat(count * 115) + 15
        return count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "potentialChatCell", for: indexPath) as! PotentialChatCell
        return cell
    }
}




//MARK: - Переход в контроллер чата с пользователем

extension ChatViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destanationVC = segue.destination as? ChatUserController else  {return}
        guard let user = selectedUser else {return}
        destanationVC.selectedUser = user
    }
}


//MARK: -  Переход с MatchController в ChatUserController

extension ChatViewController: passDataDelegate {
    func goToMatchVC( matchController: UIViewController?, matchUser: User) {
        selectedUser = matchUser
        performSegue(withIdentifier: "goToChat", sender: self)
    }
}




