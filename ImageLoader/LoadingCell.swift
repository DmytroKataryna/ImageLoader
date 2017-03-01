//
//  LoadingCell.swift
//  ImageLoader
//
//  Created by Max Vitruk on 01/03/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import UIKit

class LoadingCell : UITableViewCell {
    static let id = "LoadingCell"
    
    @IBOutlet weak var imageLoad : UIImageView!
    @IBOutlet weak var progress : UIProgressView!
    @IBOutlet weak var progressLabel : UILabel!
    @IBOutlet weak var buttonLoad : UIButton!
    
    weak var delegate : LoadingCellDelegate?

    var state : LoadState = .none {
        didSet{
            modifyViewAccesebulity(forState: self.state)
        }
    }
    
    @IBAction func loadButtonAction(_ sender : UIButton){
        delegate?.didTapLoadingButton(in: self)
    }
    
    private func modifyViewAccesebulity(forState state : LoadState){
        switch state {
        case .none:
            imageLoad.isHidden = true
            progress.isHidden = true
            progressLabel.isHidden = true
            updateButton(for: .none)
            break
        case .ready:
            imageLoad.isHidden = false
            progress.isHidden = true
            progressLabel.isHidden = true
            updateButton(for: .hidden)
            break
        case .paused:
            imageLoad.isHidden = true
            progress.isHidden = false
            progressLabel.isHidden = false
            updateButton(for: .paused)
            break
        case .loading:
            imageLoad.isHidden = true
            progress.isHidden = false
            progressLabel.isHidden = false
            
            updateButton(for: .loading)
            break
        }
    }
    
    private func updateButton(for state : LoadButtonState){
        buttonLoad.isHidden = state == .hidden
        buttonLoad.setTitle(state.rawValue, for: .normal)
    }
}
