//
//  CardModel.swift
//  Meeting
//
//  Created by Деним Мержан on 26.04.23.
//

import Foundation
import UIKit


struct CardModel {
    
    
    var usersArr = [User]()
    
    
    
    mutating func appendUser(){
        
        usersArr.append(User(name: "Карина",imageArr: [UIImage(named: "1")!,UIImage(named: "2")!,UIImage(named: "3")!,UIImage(named: "4")!]))
        usersArr.append(User(name: "Света",imageArr: [UIImage(named: "S1")!,UIImage(named: "S2")!,UIImage(named: "S3")!,UIImage(named: "S4")!,UIImage(named: "S5")!]))
        usersArr.append(User(name: "Екатерина",imageArr: [UIImage(named: "K1")!,UIImage(named: "K2")!,UIImage(named: "K3")!]))
        usersArr.append(User(name: "Ольга",imageArr: [UIImage(named: "O1")!,UIImage(named: "O2")!]))
        usersArr.append(User(name: "Викуся",imageArr: [UIImage(named: "V1")!,UIImage(named: "V2")!,UIImage(named: "V3")!]))
        usersArr.append(User(name: "Таня",imageArr: [UIImage(named: "T1")!,UIImage(named: "T2")!,UIImage(named: "T3")!]))
        
    }
    
    func createCard(textName:String,image: [UIImage]) -> CardView {
        
        
        let frame =  CGRect(x: 16, y: 118, width: 361, height: 603)
        
        let label = UILabel(frame: CGRect(x: 10, y: 480, width: 331, height: 48.0))
        label.text = textName
        label.font = .boldSystemFont(ofSize: 48)
        label.textColor = .white
        
        let likeHeart = UIImageView(frame: CGRect(x: 0.0, y: 8.0, width: 106, height: 79))
        let dislikeHeart = UIImageView(frame: CGRect(x: 234, y: 0.0, width: 127, height: 93))
        
        likeHeart.image = UIImage(named: "LikeHeart")!
        dislikeHeart.image = UIImage(named: "DislikeHeart")!
        
        likeHeart.isHidden = true
        dislikeHeart.isHidden = true
        
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 361, height: 603))
        imageView.image = image[0]
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true /// Ограничиваем фото в размерах
    
        
        let gradient = CAGradientLayer() /// Создаем градиент
        gradient.frame = CGRect(x: 0, y: 400, width: 361, height: 203)
        gradient.locations = [0.0, 1.0]
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        imageView.layer.insertSublayer(gradient, at: 0)
                    
        let card = CardView(frame: frame,heartLikeImage: likeHeart ,heartDislikeImage: dislikeHeart ,label: label,imageUser: imageView,imageArr: image)
        
        card.addSubview(imageView)
        card.addSubview(likeHeart)
        card.addSubview(dislikeHeart)
        card.addSubview(label)
      
        
        
        
        
        return card
        
        
    }
    
    
    func createEmptyCard() -> CardView {
        
        let frame =  CGRect(x: 16, y: 118, width: 361, height: 603)
        
        let label = UILabel(frame: CGRect(x: 8.0, y: 494, width: 331, height: 48.0))
        label.text = "Пары закончились("
        
        let likeHeart = UIImageView(frame: CGRect(x: 0.0, y: 8.0, width: 106, height: 79))
        let dislikeHeart = UIImageView(frame: CGRect(x: 234, y: 0.0, width: 127, height: 93))
       
        let card = CardView(frame: frame,heartLikeImage: likeHeart ,heartDislikeImage: dislikeHeart ,label: label,imageUser: nil,imageArr: nil)
        
        
        card.addSubview(label)
        
        return card
    }
    
}
