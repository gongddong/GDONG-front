//
//  Model.swift
//  GDONG
//
//  Created by JoSoJeong on 2021/04/21.
//

import Foundation

struct Board: Codable { // response
    var sell: Bool?
    var __v: Int?
    var _id: String?
    var author: String?
    var postid: Int?
    var title: String?
    var content: String?
    var images: [String]?
    var profileImage: String?
    var category: String?
    var price: Int?
    var view: Int?
    var interest: Int?
    var needPeople: Int?
    var nowPeople: Int
    var link: String?
    var tags: [String]?
    var createdAt: String?
    var updatedAt: String?
    var location: Location?
    var email: String?
    
    enum CodingKeys: String, CodingKey {
        case sell
        case __v
        case _id
        case author
        case title
        case content
        case images
        case category
        case price
        case view
        case needPeople
        case nowPeople
        case link
        case postid
        case tags
        case createdAt
        case updatedAt
        case interest = "likes"
        case profileImage = "profileImg"
        case location
        case email

    }
    
    init(__v: Int, _id: String, author: String, postid: Int, title: String, content: String, images: [String], profileImage: String, category: String, price: Int, view: Int, interest: Int, needPeople: Int, nowPeople: Int, link: String, tags: [String], createdAt: String, updatedAt: String, location: Location, email: String) {
      
        self.__v = __v
        self._id = _id
        self.author = author
        self.postid = postid
        self.title = title
        self.content = content
        self.images = images
        self.profileImage = profileImage
        self.category = category
        self.price = price
        self.view = view
        self.interest = interest
        self.needPeople = needPeople
        self.nowPeople = nowPeople
        self.link = link
        self.tags = tags
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.location = location
        self.email = email
        
    }
    
}

struct BoardResponse: Codable { // response
    var __v: Int = 0
    var _id: String = ""
    var author: String = ""
    var postid: Int = 0
    var title: String = "" // ??? ??????
    var content: String = "" // ??? ??????
    var images: [String] = []
    var profileImage: String = ""  // ??? ?????? ?????????
    var category: String = "" // ??? ????????????
    var price: Int = 0 //??????
    var view: Int = 0 // ?????????
    var interest: Int = 0 // ?????????
    var needPeople: Int = 0// ?????? ??????
    var nowPeople: Int = 0 // ????????? ??????
    var link: String = ""
    var tags: [String] = []
    var createdAt: String = ""
    var updatedAt: String = ""
    var location: Location = Location(_id: "", coordinates: [0,0], type: "")
    var email: String = ""
    
    enum CodingKeys: String, CodingKey {
        case __v
        case _id
        case author
        case title
        case content
        case images
        case category
        case price
        case view
        case needPeople
        case nowPeople
        case link
        case postid
        case tags
        case createdAt
        case updatedAt
        case interest = "likes"
        case profileImage = "profileImg"
        case location
        case email

    }
    
}



struct Users: Codable {
    var __v: Int = 0
    var _id: String = ""
    var email: String = "" // ?????? ?????????
    var name: String = "" //?????? ??????
    var authProvider: String = "" //?????? ????????? ??????
    var isSeller: Bool = false//?????? ??????
    var chatRoomList: [Int] = [] // ?????? ?????? ?????? ??? ID
    var nickName: String = "" //?????? ?????????
    var profileImageUrl: String = "" // ?????? ????????? ????????? url
    var followers: [String] = [] //?????? follow ?????? nickName
    var following: [String] = []//?????? following ?????? ??????
    var createdAt: String = ""
    var updatedAt: String = ""
    var deviceToken: String = ""
    //?????? ??????
    var location: Location = Location()
    var posts:[Int] = []
    var likes: [Int] = []
    var n_followers: Int = 0
    var n_following: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case __v
        case _id
        case email
        case name
        case authProvider
        case isSeller
        case chatRoomList = "chatroomList"
        case nickName = "nickname"
        case profileImageUrl = "profileImg"
        case followers
        case following
        case createdAt
        case updatedAt
        case deviceToken
        case location
        case posts
        case likes
        case n_followers
        case n_following

    }
}

struct Location: Codable {
    var _id: String = ""
    var coordinates: [Double] = []
    var type: String = ""
    var dictionary: [String: Any] {
        return ["coordinates": [coordinates]]
    }
}

extension Location {
    init?(dictionary: [String:Any]) {
        guard let location = dictionary["coordinates"] as? [Double] else { return nil }
        self.init(coordinates: location)
    }
}

//juso
struct JusoResponse: Codable {
    var results: JusoResults!
}

struct JusoResults: Codable {
    var common: Common!
    var juso: [Juso]!
}

struct Common: Codable {
    var errorCode: String!
    var currentPage: String!
    var totalCount: String!
    var errorMessage: String!
}

struct Juso: Codable {
    var roadAddr: String!
    var jibunAddr: String!
}

struct Category {
    var categoryImage: String
    var categoryText: String
}

//struct PostBoard: Codable {
//    var author : String? //???????????? ????????? ??????
//    var title : String?
//    var content : String?
//    var link : String?
//    var needPeople : String? //????????? post ??????, ????????? ??? ??????
//    var price : String?
//    var category : String?
//    var images : [Data]?
//}


struct PostBoard: Codable { // for request
    var author : String = "" //???????????? ????????? ??????
    var title : String = ""
    var content : String = ""
    var link : String = ""
    var needPeople : String = "" //????????? post ??????, ????????? ??? ??????
    var price : Int = 0
    var category : String = ""
    var images : [Data] = []
    var location : Location? = Location(dictionary: ["coordinates" : [0, 0]])
}
