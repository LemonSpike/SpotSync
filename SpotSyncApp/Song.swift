//
//  Song.swift
//  SpotSyncApp
//
//  Created by Ravi Kumar on 03/06/2017.
//  Copyright © 2017 Pranav Kasetti. All rights reserved.
//

import UIKit
import ObjectMapper
import AlamofireObjectMapper

class TrackResponse: NSObject, Mappable {
    
    var tracks: [Song] = []
    var tracksCount: Int = 0
    
    convenience required init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map) {
        tracks <- map["tracks.items"]
        tracksCount = tracks.count
    }
    
}

class PlaylistResponse: NSObject, Mappable {
    
    var playlists: [Playlist]?
        
    override init() { }
        
    convenience required init?(map: Map){
        self.init()
        mapping(map: map)
    }
        
    func mapping(map: Map) {
        playlists <- map["playlists.items"]
    }
    
}

class CategoriesResponse: NSObject, Mappable {
    
    var categories: [MusicCategory]?
    
    override init() { }
    
    convenience required init?(map: Map){
        self.init()
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        categories <- map["categories.items"]
    }
    
}

class MusicCategory: NSObject, Mappable {
    
    var id: String!
    var name: String!

    override init() { }
    
    convenience required init?(map: Map){
        self.init()
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
    }
    
}

class Playlist: NSObject, Mappable {
    var title: String?
    var imageURL: String?
    var songsURL: String?
    var numSongs: Int?
    
    override init() {}
    
    convenience required init?(map: Map){
        self.init()
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        title <- map["name"]
        imageURL <- map["images.0.url"]
        songsURL <- map["tracks.href"]
        numSongs <- map["tracks.total"]
    }
    
}


class Song: NSObject, Mappable {
    
    var title: String?
    var album: String?
    var artists: [Artist]?
    var imageURL: String?
    var previewURL: String?
    
    override init() {}
    
    convenience required init?(map: Map){
        self.init()
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        title <- map["name"]
        album <- map["album.name"]
        artists <- map["artists"]
        imageURL <- map["album.images.1.url"]
        previewURL <- map["preview_url"]
    }
}

class Artist: NSObject, Mappable {
    
    var name: String?
    
    override init() {}
    
    convenience required init?(map: Map){
        self.init()
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        name <- map["name"]
    }
    
}
