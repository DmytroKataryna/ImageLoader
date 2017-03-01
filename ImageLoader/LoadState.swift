//
//  LoadState.swift
//  ImageLoader
//
//  Created by Max Vitruk on 01/03/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

enum LoadState{
    case none
    case loading
    case paused
    case ready
    
    var nextState : LoadState {
        switch self {
        case .none:
            return .loading
        case .loading:
            return .paused
        case .paused:
            return .loading
        case .ready:
            return .ready
        }
    }
}
