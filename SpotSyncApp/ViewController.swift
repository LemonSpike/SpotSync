//
//  ViewController.swift
//  SpotSyncApp
//
//  Created by Ravi Kumar on 03/06/2017.
//  Copyright © 2017 Pranav Kasetti. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var model: Model!
    var playlists:[[Playlist]]!
    var categories:[MusicCategory]!
    
    var i=0
    var collectionViews: [UICollectionView] = []
    var constraints = [NSLayoutConstraint]()
    
    var stackView = UIStackView(frame: CGRect(x: 12, y: 66 , width: 200, height: 200))
    var scrollView = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|", options: .alignAllCenterX, metrics: nil, views: ["scrollView": scrollView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollView]|", options: .alignAllCenterX, metrics: nil, views: ["scrollView": scrollView]))
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        scrollView.addSubview(stackView)
        scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[stackView]-12-|", options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: ["stackView": stackView]))
        scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackView]", options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: ["stackView": stackView]))
        
        self.playlists=[[]]
        self.categories=[]
        //self.layoutCollectionViews(completionHandler: self.reloadViews)
        model.requestFeaturedPlaylists(completionHandler: { data in
            if (data! != []) {
                self.playlists.append(data!)
            }
            self.model.requestCategories(completionHandler: { data in
                self.categories=data
                self.getCategoryPlaylists(categories: self.categories)
            })
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        //This was removed! Check for mistakes.
        scrollView.contentSize = CGSize(width: stackView.frame.width, height: stackView.frame.height)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playlists[collectionView.tag].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnnotatedPhotoCell", for: indexPath) as! AnnotatedPhotoCell
        cell.playlist = playlists[collectionView.tag][indexPath.row]
        //print(cell)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 200)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
        var label = header.viewWithTag(128) as? UILabel
        if (label == nil) {
            label = UILabel(frame: header.frame)
            label?.font=UIFont.boldSystemFont(ofSize: 15)
            label?.tag=128
            label?.textColor=UIColor.white
            label?.adjustsFontSizeToFitWidth=true
            header.addSubview(label!)
        }
        if ((playlists.count-categories.count)..<playlists.count).contains(collectionView.tag) {
            var str = categories[collectionView.tag-2].id!
            str.replaceSubrange(str.startIndex..<str.index(after: str.startIndex), with: String(str[str.startIndex]).uppercased())
            label!.text = str
        } else if (0..<(playlists.count-categories.count)).contains(collectionView.tag) {
            label!.text="Featured Playlists"
        }
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 120, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
        //return playlists.count
    }
    
    func getCategoryPlaylists(categories: [MusicCategory]) {
        self.model.requestCategoryPlaylists(category: self.categories[self.i], completionHandler: { data in
            if (data != []) {
                self.playlists.append(data)
            }
            print(data)
            self.i = self.i+1
            if self.i != self.categories.count {
                self.getCategoryPlaylists(categories: self.categories)
            
            } else {
                self.layoutCollectionViews(completionHandler: self.reloadViews)
            }
            
        })
    }
    
    func layoutCollectionViews(completionHandler: @escaping () -> ()) {
        let tests = playlists.filter { $0.count == 0 }
        for _ in tests {
            let index = playlists.index(where: { (item) -> Bool in
                item.count == 0 // test if this is the item you're looking for
            })!
            categories.remove(at: index)
            playlists.remove(at: index)
        }
        
        
        //playlists=playlists.filter { $0.count != 0 }
        for _ in 1...playlists.count {
            let flowLayout = UICollectionViewFlowLayout()
            flowLayout.scrollDirection = .horizontal
            flowLayout.itemSize = CGSize(width: 150, height: 150)
            flowLayout.minimumInteritemSpacing=0
            flowLayout.minimumLineSpacing=0
            let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 200), collectionViewLayout: flowLayout)
            //collectionView.backgroundColor = UIColor.red
            collectionViews.append(collectionView)
        }
        var j=0
        for collectionView in collectionViews {
            collectionView.tag=j
            collectionView.delegate=self
            collectionView.dataSource=self
            collectionView.register(AnnotatedPhotoCell.self, forCellWithReuseIdentifier: "AnnotatedPhotoCell")
            collectionView.clipsToBounds = false
            collectionView.cellForItem(at: IndexPath(index: 0))
            collectionView.register(UICollectionReusableView.self , forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header")
            //var view = self.stackView
            j+=1
        }
        //print(collectionViews.count)
        completionHandler()
    }
    
    func reloadViews() {
        for collectionView in collectionViews {
            self.stackView.addArrangedSubview(collectionView)
        }
        self.addConstraints()
        NSLayoutConstraint.activate(constraints)
        self.stackView.layoutIfNeeded()
        self.stackView.layoutSubviews()
        print(stackView)
        for collectionView in collectionViews {
            //print(collectionView)
            collectionView.reloadData()
        }
    }
    
    func addConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints=false
        constraints.append(stackView.centerXAnchor.constraint(equalTo: stackView.superview!.centerXAnchor))
        self.extendedLayoutIncludesOpaqueBars=false
        self.automaticallyAdjustsScrollViewInsets=false
        self.edgesForExtendedLayout = []
        //constraints.append(stackView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor))
        //constraints.append(stackView.topAnchor.constraint(equalTo: stackView.superview!.topAnchor, constant: 66))
        //constraints.append(stackView.trailingAnchor.constraint(equalTo: stackView.superview!.trailingAnchor, constant: 12))
        //constraints.append(stackView.superview!.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 12))
        
        for collectionView in collectionViews {
            collectionView.translatesAutoresizingMaskIntoConstraints=false
            constraints.append(collectionView.heightAnchor.constraint(equalToConstant: 200))
            constraints.append(collectionView.centerXAnchor.constraint(equalTo: (collectionView.superview!).centerXAnchor, constant: 0))
            constraints.append(collectionView.trailingAnchor.constraint(equalTo: collectionView.superview!.trailingAnchor, constant: 0))
            constraints.append(collectionView.leadingAnchor.constraint(equalTo: collectionView.superview!.leadingAnchor, constant: 0))
        }
        //constraints.append(collectionViews[0].topAnchor.constraint(equalTo: (collectionViews[0].superview!).topAnchor, constant: 0))
        for collectionView in Array(collectionViews[1...(collectionViews.count-1)]) {
            //constraints.append(collectionView.topAnchor.constraint(equalTo: collectionViews[collectionViews.index(of: collectionView)!-1].bottomAnchor , constant: 20))
        }
        
    }
    
    
}

