//
//  SourceItem.swift
//  ImageLoader
//
//  Created by Max Vitruk on 01/03/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import UIKit

struct SourceItem {
    init(imageUrl : String) {
        self.imageUrl = imageUrl
        
        state = .none
        progress = 0
        imageScaled = nil
        imageOriginalPath = nil
    }
    
    var state : LoadState
    var progress : Float
    var imageUrl : String
    var imageScaled : UIImage?
    var imageOriginalPath : URL?
}
