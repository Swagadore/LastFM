//
//  Album.swift
//  Last.fm
//
//  Created by Daniel Sofoluke on 27/09/2018.
//  Copyright © 2018 Daniel Sofoluke. All rights reserved.
//

import Foundation

struct Album {
    let streamable : String
    let mbid : String
    let name : String
    let url : String
    let artist : String
}

extension Album {
    
    init? (json: [String:Any])
    {
        guard let streamable = json["streamable"] as? String,
            let mbid = json["mbid"] as? String,
            let name = json["name"] as? String,
            let url = json["url"] as? String,
            let artist = json["artist"] as? String
        else
        {
            return nil
        }
        
        self.streamable = streamable
        self.mbid = mbid
        self.name = name
        self.url = url
        self.artist = artist
    }
}

