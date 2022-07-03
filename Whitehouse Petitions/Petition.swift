//
//  Petition.swift
//  Whitehouse Petitions
//
//  Created by Camilo Hernández Guerrero on 26/06/22.
//

import Foundation

struct Petition: Codable {
    var title: String
    var body: String
    var signatureCount: Int
}
