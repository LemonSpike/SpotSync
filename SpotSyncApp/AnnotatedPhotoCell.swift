//
//  AnnotatedPhotoCell.swift
//  RWDevCon
//
//  Created by Mic Pringle on 26/02/2015.
//  Copyright (c) 2015 Ray Wenderlich. All rights reserved.
//

import UIKit

class AnnotatedPhotoCell: UICollectionViewCell {

    var imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 180, height: 180))
    var captionLabel = UILabel(frame: CGRect(x: 0, y: 180, width: 180, height: 20))
    
    var model = Model()
    var constraintss: [NSLayoutConstraint] = []
    
    var playlist: Playlist? {
        didSet {
            if let playlist = playlist {
                model.getPlaylistImages(playlists: [playlist], completionHandler: { data in
                    self.imageView.image = data?[0]
                })
                captionLabel.text = playlist.title
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints=false
        self.addSubview(imageView)
        self.addSubview(captionLabel)
        captionLabel.textColor = UIColor.white
        captionLabel.adjustsFontSizeToFitWidth=true
        imageView.translatesAutoresizingMaskIntoConstraints=false
        captionLabel.translatesAutoresizingMaskIntoConstraints=false
        constraintss.append(imageView.heightAnchor.constraint(equalToConstant: 180))
        constraintss.append(captionLabel.heightAnchor.constraint(equalToConstant: 20))
        constraintss.append(imageView.widthAnchor.constraint(equalToConstant: 180))
        constraintss.append(imageView.centerXAnchor.constraint(equalTo: imageView.superview!.centerXAnchor))
        
        constraintss.append(imageView.topAnchor.constraint(equalTo: imageView.superview!.topAnchor))
        constraintss.append(imageView.widthAnchor.constraint(equalTo: captionLabel.widthAnchor))
        constraintss.append(imageView.bottomAnchor.constraint(equalTo: captionLabel.topAnchor))
        constraintss.append(captionLabel.centerXAnchor.constraint(equalTo: captionLabel.superview!.centerXAnchor))
        NSLayoutConstraint.activate(constraintss)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addSubview(imageView)
        self.addSubview(captionLabel)
        constraintss.append(imageView.heightAnchor.constraint(equalToConstant: 180))
        constraintss.append(captionLabel.heightAnchor.constraint(equalToConstant: 20))
        constraintss.append(imageView.widthAnchor.constraint(equalToConstant: 180))
        constraintss.append(imageView.centerXAnchor.constraint(equalTo: imageView.superview!.centerXAnchor))
        
        constraintss.append(imageView.topAnchor.constraint(equalTo: imageView.superview!.topAnchor))
        constraintss.append(imageView.widthAnchor.constraint(equalTo: captionLabel.widthAnchor))
        constraintss.append(imageView.bottomAnchor.constraint(equalTo: captionLabel.topAnchor))
        constraintss.append(captionLabel.centerXAnchor.constraint(equalTo: captionLabel.superview!.centerXAnchor))
        NSLayoutConstraint.activate(constraintss)
    }
    
    override func prepareForReuse() {
        self.addSubview(imageView)
        self.addSubview(captionLabel)
        constraintss.append(imageView.heightAnchor.constraint(equalToConstant: 180))
        constraintss.append(captionLabel.heightAnchor.constraint(equalToConstant: 20))
        constraintss.append(imageView.widthAnchor.constraint(equalToConstant: 180))
        constraintss.append(imageView.centerXAnchor.constraint(equalTo: imageView.superview!.centerXAnchor))
        
        constraintss.append(imageView.topAnchor.constraint(equalTo: imageView.superview!.topAnchor))
        constraintss.append(imageView.widthAnchor.constraint(equalTo: captionLabel.widthAnchor))
        constraintss.append(imageView.bottomAnchor.constraint(equalTo: captionLabel.topAnchor))
        constraintss.append(captionLabel.centerXAnchor.constraint(equalTo: captionLabel.superview!.centerXAnchor))
        NSLayoutConstraint.activate(constraintss)
    }
    
}

