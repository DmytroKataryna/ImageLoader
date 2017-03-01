//
//  OpenImageViewController.swift
//  ImageLoader
//
//  Created by Max Vitruk on 01/03/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import UIKit

class OpenImageViewController: UIViewController {
    @IBOutlet weak var scrollView : UIScrollView!
    
    var sourceItem : SourceItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = sourceItem?.imageOriginalPath else {return}
        
        DispatchQueue.global(qos: .background).async {
            let image = ImageLoaderManager.shared.originalImage(from: url)
            
            DispatchQueue.main.async {
                let imageView = UIImageView.init(image: image)
                
                self.scrollView.addSubview(imageView)
                self.scrollView.contentSize = imageView.bounds.size
            }
        }
    }
}
