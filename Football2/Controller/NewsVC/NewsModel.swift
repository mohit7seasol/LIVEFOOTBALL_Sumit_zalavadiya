//
//  NewsModel.swift
//  
//
//  Created by Mohit Kanpara on 29/04/26.
//

import Foundation

struct NewsResponse: Decodable {
    let message: String
    let data: [NewsModel]
}

struct NewsModel: Decodable {
    let id: String
    let title: String
    let imageUrl: String
    let subDesc: String
    let article: String
}
