//
//  Pokemon.swift
//  PracticeAPI
//
//  Created by Christopher Yoon on 3/23/23.
//

import Foundation

struct Pokemon: Codable, Identifiable {
    var id = UUID()
    var name: String
    var url: String
    
    
    enum CodingKeys: CodingKey {
        case name
        case url
    }
}
