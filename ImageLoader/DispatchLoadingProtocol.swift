//
//  DispatchLoadingProtocol.swift
//  ImageLoader
//
//  Created by Max Vitruk on 01/03/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

protocol DispatchLoadingProtocol : class {
    func sourceItem(for index : IndexPath )-> SourceItem?
    
    func didUpdateProgress(for index : IndexPath, progress : Float)
    
    func didFinishLoad(itemFor index : IndexPath, path : URL)
    
    func didCancel(itemFor index : IndexPath)
    
    func didPause(itemFor index : IndexPath)
    
    func didResume(itemFor index : IndexPath)
}
