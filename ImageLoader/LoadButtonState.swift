//
//  LoadButtonState.swift
//  ImageLoader
//
//  Created by Max Vitruk on 01/03/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

enum LoadButtonState : String {
    case hidden = ""
    case none = "Download"
    case loading = "PAUSE"
    case paused = "RESUME"
}
