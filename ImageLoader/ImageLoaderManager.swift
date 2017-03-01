//
//  ImageLoaderManager.swift
//  ImageLoader
//
//  Created by Max Vitruk on 01/03/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import UIKit

class ImageLoaderManager : NSObject {
    static let shared = ImageLoaderManager()
    
    weak var delegate : DispatchLoadingProtocol?
    
    var processMap = [IndexPath : URLSessionDownloadTask]()
    lazy var session : URLSession! = self.setupSession()
    
    
    func dispatch(new state : LoadState, for index : IndexPath){
        guard let task = processMap[index] else {
            newTask(for: index)
            return
        }
        
        switch state {
        case .paused:
            task.suspend()
            delegate?.didPause(itemFor: index)
        case .loading:
            task.resume()
            delegate?.didResume(itemFor: index)
        default:
            break
        }
    }
    
    private func newTask(for index : IndexPath) {
        guard let item = delegate?.sourceItem(for: index) else { return }
        guard let url = URL.init(string: item.imageUrl) else { return }
        
        let task = session.downloadTask(with: url)
        task.resume()
        
        processMap[index] = task
    }
    
    private func setupSession() -> URLSession {
        let sessionConfiguration = URLSessionConfiguration.background(withIdentifier: "lemberg.com")
        return URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
    }
    
    fileprivate func copyPath(location : URL, for index : IndexPath) -> URL? {
        let fileManager = FileManager.default
        
        //Get documents directory URL
        let documentsDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        
        let path = documentsDirectory.appendingPathComponent(index.description + ".jpg")
        
        //Remove file if alredy exist
        
        do {
            try fileManager.removeItem(at: path)
        } catch {
            print("Error on delete \(error)")
            return nil
        }
        
        
        do {
            try fileManager.copyItem(at: location, to: path)
        } catch let error {
            print("Error on copy \(error)")
            return nil
        }
        
        return path
    }
}

extension ImageLoaderManager : URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL){
        let item = self.processMap.filter({$0.value == downloadTask})
        guard let indexPath = item.first?.key else {return}
        guard let realPath = copyPath(location : location , for: indexPath) else {return}
        
        self.delegate?.didFinishLoad(itemFor: indexPath, path: realPath)
        self.processMap.removeValue(forKey: indexPath)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64){
        let item = processMap.filter({$0.value == downloadTask})
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        
        DispatchQueue.main.async {
            guard let indexPath = item.first?.key else {return}
            self.delegate?.didUpdateProgress(for: indexPath, progress: progress)
        }
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        print(error.debugDescription)
    }
}


extension ImageLoaderManager {
    
    func scaledImage(from path : URL) -> UIImage? {
        guard let image = originalImage(from: path) else {return nil}
        return resizeImage(image: image, newWidth: 375.0)  //375.0 - HARDCODE
    }
    
    func originalImage(from path : URL) -> UIImage? {
        let data = try! Data.init(contentsOf: path)
        if let image = UIImage.init(data: data){
            return image
        }
        return nil
    }
    
    private func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        let size = CGSize(width : newWidth, height : newHeight)
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
