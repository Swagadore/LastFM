//
//  AlbumDetailViewController.swift
//  Last.fm
//
//  Created by Daniel Sofoluke on 27/09/2018.
//  Copyright © 2018 Daniel Sofoluke. All rights reserved.
//

import UIKit

class AlbumDetailViewController: UIViewController
{
    var selectedAlbum: Album?
    
    @IBOutlet weak var mbidLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mbidLabel.text = selectedAlbum?.artist
        nameLabel.text = selectedAlbum?.name
        artistLabel.text = selectedAlbum?.mbid
        websiteLabel.text = selectedAlbum?.url
        
    }
}
