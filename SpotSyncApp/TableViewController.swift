//
//  ViewController.swift
//  Spot_Tutorial_Jared
//
//  Created by Ravi Kumar on 01/06/2017.
//  Copyright © 2017 Pranav Kasetti. All rights reserved.
//

import UIKit
import AVFoundation

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    var model: Model!
    var tracks = [Song]()
    var images = [UIImage]()
    var player: AVAudioPlayer!
    
    var errorText: String!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //self.searchBar.delegate=self
        self.tableView.delegate=self
        self.tableView.dataSource=self
        
        self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard (searchBar.text != nil && searchBar.text != errorText) else {
            return
        }
        
        errorText=searchBar.text
        
        model.requestTracks(query: searchBar.text!) { data in
            self.tracks=data!
            self.model.getImages(songs: self.tracks) { data in
                self.images=data!
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell")!
        cell.textLabel?.numberOfLines=0
        cell.textLabel?.minimumScaleFactor = 0.7
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.textLabel?.text = tracks[indexPath.row].title
        cell.detailTextLabel?.text = tracks[indexPath.row].album
        
        UIGraphicsBeginImageContext(CGSize(width: 80, height: 80))
        let imageRect = CGRect(x: 10, y: 10, width: 80, height: 80)
        let newImage = images[indexPath.row]
        newImage.draw(in: imageRect)
        cell.imageView!.image=newImage.withRenderingMode(.automatic)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tracks[indexPath.row].previewURL != nil {
            downloadFileFromURL(url: URL(string:tracks[indexPath.row].previewURL!)!)
        } else {
            print("no preview url!")
        }
    }
    
    func downloadFileFromURL(url:URL){
        weak var weakSelf = self
        var downloadTask: URLSessionDownloadTask
        downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: { (URL, response, error) -> Void in
            
            weakSelf!.play(url: URL!)
            
        })
        
        downloadTask.resume()
        
    }
    
    func play(url: URL) {
        do {
            self.player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.volume = 1.0
            player.play()
        } catch let error {
            print(error)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

}

