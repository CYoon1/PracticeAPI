//
//  ApiVM.swift
//  PracticeAPI
//
//  Created by Christopher Yoon on 3/22/23.
//

import Foundation

@MainActor
class MainVM: ObservableObject {
    struct Article : Codable, Identifiable {
        var id = UUID() // Keep separate for internal app use
        // names must match with api
        var title: String
        var url: String
        var imageUrl: String
        
        enum CodingKeys: CodingKey {
            case title
            case url
            case imageUrl
        }
    }
    @Published var articles : [Article] = []
    
    var urlString : String = "https://api.spaceflightnewsapi.net/v3/articles?"
    
    func getData() async {
        // 1) Get URL from urlString
        guard let url = URL(string: urlString) else {
            print("Error")
            return
        }
        
        // 2) Get JSON from URLSession.shared
        guard let (data, _) = try? await URLSession.shared.data(from: url) else {
            print("Error")
            return
        }
        
        // 3) Decode JSON data
        guard let returned = try? JSONDecoder().decode([Article].self, from: data) else {
            print("Error: could not convert json data to Returned Struct")
            return
        }
        
        // 4) Set published var with returned data
        articles = returned
        
    }
}
