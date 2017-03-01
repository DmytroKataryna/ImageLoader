//
//  ViewController.swift
//  ImageLoader
//
//  Created by Max Vitruk on 01/03/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let openImageSegue = "segueOpenFull"
    
    @IBOutlet weak var tableView : UITableView!
    
    var itemList = FakeSorceCreator.source
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ImageLoaderManager.shared.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? OpenImageViewController {
            let index = sender as! Int
            let item = itemList[index]
            vc.sourceItem = item
        }
    }
}

extension ViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if itemList[indexPath.item].state == .ready {
            performSegue(withIdentifier: openImageSegue, sender: indexPath.item)
        }
    }
}

extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LoadingCell.id) as? LoadingCell else {
            assertionFailure("Could not load cell for id \(LoadingCell.id)")
            return UITableViewCell()
        }
        let item = itemList[indexPath.item]
        
        cell.state = item.state
        
        cell.progress.setProgress(item.progress, animated: false)
        cell.progressLabel.text = item.progress.rounded().description + " %"
        cell.imageLoad.image = item.imageScaled

        cell.delegate = self
        
        return cell
    }
}

extension ViewController : LoadingCellDelegate {
    func didTapLoadingButton(in cell : LoadingCell){
        if let indexPath = tableView.indexPath(for: cell){
            let item = itemList[indexPath.item]
            let newState = item.state.nextState
            
            ImageLoaderManager.shared.dispatch(new: newState, for: indexPath)
            
            itemList[indexPath.item].state = newState
            
            cell.state = newState
        }
    }
}

extension ViewController : DispatchLoadingProtocol {
    func sourceItem(for index : IndexPath )-> SourceItem?{
        if index.item >= itemList.count {
            return nil
        }
        
        return itemList[index.item]
    }
    
    func didUpdateProgress(for index : IndexPath, progress : Float){
        guard tableView.indexPathsForVisibleRows?.filter({$0 == index}).first != nil else {return}
        let percentProgress = progress * 100
        itemList[index.item].progress = percentProgress
        
        guard let cell = tableView.cellForRow(at: index) as? LoadingCell else {return}
        cell.progress.setProgress(progress, animated: false)
        cell.progressLabel.text = percentProgress.rounded().description + " %"
    }
    
    func didFinishLoad(itemFor index : IndexPath, path : URL){
        guard let scaledImage = ImageLoaderManager.shared.scaledImage(from: path) else {return}
        print(path)
        itemList[index.item].imageOriginalPath = path
        itemList[index.item].imageScaled = scaledImage
        itemList[index.item].state = .ready
        
        DispatchQueue.main.async {
            guard let cell = self.tableView.cellForRow(at: index) as? LoadingCell else {return}
            cell.state = .ready
            cell.imageLoad.image = scaledImage
        }
    }
    
    func didCancel(itemFor index : IndexPath){
        //skip
    }
    
    func didPause(itemFor index : IndexPath){
        guard let cell = tableView.cellForRow(at: index) as? LoadingCell else {return}
        cell.state = .paused

        itemList[index.item].state = .ready
    }
    
    func didResume(itemFor index : IndexPath){
        guard let cell = tableView.cellForRow(at: index) as? LoadingCell else {return}
        cell.state = .loading
        
        itemList[index.item].state = .loading
    }
}

