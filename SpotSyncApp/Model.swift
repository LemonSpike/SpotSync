
//
//  Model.swift
//  Spot_Tutorial_Jared
//
//  Created by Ravi Kumar on 01/06/2017.
//  Copyright © 2017 Pranav Kasetti. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import AlamofireImage

class Model: NSObject {

    var searchUrl = "https://api.spotify.com/v1/search"
    var featuredPlaylistsUrl = "https://api.spotify.com/v1/browse/featured-playlists"
    var categoriesUrl = "https://api.spotify.com/v1/browse/categories"
    var categoryPlaylistsUrl = "https://api.spotify.com/v1/browse/categories/"
    var loginUrl: URL!
    
    var auth = SPTAuth.defaultInstance()!
    var session:SPTSession!
    var clientId = "92e3c1c70c9d46db9bacbc117447a0e5"
    var clientSecret = "f2e0a923191841baba2e6b45ed104f3a"
    
    var filled=0
    var trackArray = [Song]()
    var imageUrlArray = [String]()
    var imageArray = [UIImage]()
    var playlistArray = [Playlist]()
    var categoryArray = [MusicCategory]()
    var categoryPlaylistArray = [Playlist]()
    
    func setup() {
        SPTAuth.defaultInstance().clientID=clientId
        SPTAuth.defaultInstance().redirectURL=URL(string: "SpotSyncApp://returnAfterLogin")
        SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistModifyPublicScope,SPTAuthPlaylistModifyPrivateScope]
        loginUrl = SPTAuth.defaultInstance().spotifyWebAuthenticationURL()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateAfterFirstLogin), name: NSNotification.Name("loginSuccessful"), object: nil)
    }
    
    func updateAfterFirstLogin () {
        let userDefaults=UserDefaults()
        if let sessionObj:AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject? {
            let sessionDataObj = sessionObj as! Data
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            self.session = firstTimeSession
            NotificationCenter.default.post(name: Notification.Name(rawValue: "sessionStarted"), object: nil)
        }
    }
    
    func requestTracks(query: String, completionHandler:@escaping (_ data: [Song]?) -> ()) -> () {
        self.trackArray=[]
        self.imageArray=[]
        self.imageUrlArray=[]
        Alamofire.request(searchUrl, method: .get, parameters: ["q":query, "type":"track"], encoding: URLEncoding.default, headers: ["Authorization": "Bearer "+session.accessToken]).responseObject { (response: DataResponse<TrackResponse>) in
            DispatchQueue.main.async {
                let tracksResponse = response.result.value
                if let tracks = tracksResponse?.tracks {
                    for song in tracks {
                        self.trackArray.append(song)
                        //print("Title: "+song.title!)
                        //print("Album: "+song.album!)
                        //print("Image: "+song.imageURL!)
                        if song.previewURL != nil {
                            //print("Preview: "+song.previewURL!)
                        }
                        for i in 0..<song.artists!.count {
                            //print("Artist: "+song.artists![i].name!)
                        }
                    }
                    //print("Tracks: \(self.trackArray.count)")
                    completionHandler(self.trackArray)
                }
            }
        }
    }
    
    func requestFeaturedPlaylists(completionHandler:@escaping (_ data: [Playlist]?) -> ()) -> () {
        self.playlistArray=[]
        Alamofire.request(featuredPlaylistsUrl, method: .get, parameters: nil, encoding: URLEncoding.default, headers: ["Authorization": "Bearer "+session.accessToken]).responseObject { (response: DataResponse<PlaylistResponse>) in
            DispatchQueue.main.async {
                let playlistResponse = response.result.value
                if let playlists = playlistResponse?.playlists {
                    for playlist in playlists {
                        //print(playlist.title!)
                        self.playlistArray.append(playlist)
                    }
                    completionHandler(self.playlistArray)
                }
            }
        }
    }
    
    //This function needs to be done
    
    func requestUserPlaylists(completionHandler:@escaping (_ data: [Playlist]?) -> ()) -> () {
        self.playlistArray=[]
        Alamofire.request(featuredPlaylistsUrl, method: .get, parameters: nil, encoding: URLEncoding.default, headers: ["Authorization": "Bearer "+session.accessToken]).responseObject { (response: DataResponse<PlaylistResponse>) in
            DispatchQueue.main.async {
                let playlistResponse = response.result.value
                if let playlists = playlistResponse?.playlists {
                    for playlist in playlists {
                        print(playlist.title!)
                        self.playlistArray.append(playlist)
                    }
                    completionHandler(self.playlistArray)
                }
            }
        }
    }
    
    func requestCategories(completionHandler:@escaping (_ data: [MusicCategory]?) -> ()) -> () {
        self.categoryArray=[]
        Alamofire.request(categoriesUrl, method: .get, parameters: ["limit":"50"], encoding: URLEncoding.default, headers: ["Authorization": "Bearer "+session.accessToken]).responseObject { (response: DataResponse<CategoriesResponse>) in
            DispatchQueue.main.async {
                let categoriesResponse = response.result.value
                if let categories = categoriesResponse?.categories {
                    for category in categories {
                        //print(category.id!)
                        self.categoryArray.append(category)
                    }
                    completionHandler(self.categoryArray)
                }
            }
        }
    }
    
    func requestCategoryPlaylists(category: MusicCategory, completionHandler:@escaping (_ data: [Playlist]) -> ()) -> () {
        self.categoryPlaylistArray=[]
        self.filled=0
        Alamofire.request(categoryPlaylistsUrl+category.id+"/playlists", method: .get, parameters: ["limit":"5"], encoding: URLEncoding.default, headers: ["Authorization": "Bearer "+session.accessToken]).responseObject { (response: DataResponse<PlaylistResponse>) in
            DispatchQueue.main.async {
                let playlistResponse = response.result.value
                if let playlists = playlistResponse?.playlists {
                    for playlist in playlists {
                        //print(playlist.title!)
                        self.categoryPlaylistArray.append(playlist)
                        self.filled += 1
                    }
                    if self.filled>=4 || (category.id == "comedy" && self.filled == 3) {
                        completionHandler(self.categoryPlaylistArray)
                    }
                }
            }
        }
    }
    
    func getImages(songs: [Song], completionHandler:@escaping (_ data: [UIImage]?) -> ()) -> () {
        self.filled=0
        self.imageUrlArray=[String?](repeating: "", count: songs.count) as! [String]
        self.imageArray=[UIImage?](repeating: UIImage(), count: songs.count) as! [UIImage]
        for i in 0..<songs.count {
            let imageUrlString = songs[i].imageURL
            imageUrlArray[i]=imageUrlString!
            Alamofire.request(imageUrlString!).responseImage {
                response in
                //print(response.request!.description)
                let index = self.imageUrlArray.index(of: response.request!.description)
                //print(index)
                if var image = response.result.value {
                    //print("image downloaded: \(image)")
                    let size = CGSize(width: 80.0, height: 80.0)
                    image=image.af_imageAspectScaled(toFit: size)
                    if index != nil {
                        self.imageArray[index!]=image
                    }
                    self.filled += 1
                }
                if self.filled==songs.count {
                    completionHandler(self.imageArray)
                }
            }
        
        }
        
    }
    
    func getPlaylistImages(playlists: [Playlist], completionHandler:@escaping (_ data: [UIImage]?) -> ()) -> () {
        self.filled=0
        self.imageUrlArray=[String?](repeating: "", count: playlists.count) as! [String]
        self.imageArray=[UIImage?](repeating: UIImage(), count: playlists.count) as! [UIImage]
        for i in 0..<playlists.count {
            let playlistImageUrl = playlists[i].imageURL
            imageUrlArray[i]=playlistImageUrl!
            Alamofire.request(playlistImageUrl!).responseImage { response in
                //print(response.request?.description)
                let index = self.imageUrlArray.index(of: response.request!.description)
                if var image = response.result.value {
                    let size = CGSize(width: 80.0, height: 80.0)
                    image=image.af_imageAspectScaled(toFit: size)
                    if index != nil {
                        self.imageArray[index!]=image
                    }
                    self.filled += 1
                }
                if self.filled==playlists.count {
                    completionHandler(self.imageArray)
                }
            }
        }
    }
    
    
    
}
