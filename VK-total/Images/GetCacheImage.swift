//
//  GetCacheImage.swift
//  VK-total
//
//  Created by Сергей Никитин on 03.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

enum CacheLifeTimeOnTypeImage: TimeInterval {
    // фото на аватарке - срок жизни 1 месяц
    case avatarImage = 2_678_400
    // фото пользователя - срок жизни 2 месяца
    case userPhotoImage = 5_356_800
    // фото на стене пользователя - срок жизни 1 неделя
    case userWallImage = 604_800
    // фото на новостной стене или на стене группы - срок жизни 1 час
    case newsFeedImage = 3_600
    // фото в сообщении или комментарии - срок жизни 1 год
    case messageImage = 31_536_000
    // картинка в формате gif - срок жизни 1 час
    case gifImage = 3_599
}

class GetCacheImage: Operation {
    
    private let url: String
    private let cacheLifeTime: CacheLifeTimeOnTypeImage
    var outputImage: UIImage?
    
    private static let pathName: String = {
        
        let pathName = "images"
        
        guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return pathName }
        let url = cachesDirectory.appendingPathComponent(pathName, isDirectory: true)
        
        if !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        
        return pathName
    }()
    
    private lazy var filePath: String? = {
        guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }
        
        let hasheName = String(describing: url.hashValue)
        
        return cachesDirectory.appendingPathComponent(GetCacheImage.pathName + "/" + hasheName).path
    }()
    
    init(url: String, lifeTime: CacheLifeTimeOnTypeImage) {
        self.url = url
        self.cacheLifeTime = lifeTime
    }
    
    override func main() {
        
        guard filePath != nil && !isCancelled else { return }
        
        if getImageFromCache() { return }
        guard !isCancelled else { return }
        
        if !downloadImage() { return }
        guard !isCancelled else { return }
        
        saveImageToCache()
    }
    
    private func getImageFromCache() -> Bool {
        
        guard let fileName = filePath,
            let info = try? FileManager.default.attributesOfItem(atPath: fileName),
            let modificationDate = info[FileAttributeKey.modificationDate] as? Date else { return false }
        
        let lifeTime = Date().timeIntervalSince(modificationDate)
        guard lifeTime <= cacheLifeTime.rawValue,
            let image = UIImage(contentsOfFile: fileName) else { return false }
        
        self.outputImage = image
        return true
    }
    
    private func downloadImage() -> Bool {
        
        guard let url = URL(string: url),
            let data = try? Data(contentsOf: url),
            let image = UIImage(data: data) else { return false }
        
        self.outputImage = image
        return true
    }
    
    private func saveImageToCache() {
        guard let fileName = filePath, let image = outputImage else { return }
        let data = image.pngData()
        FileManager.default.createFile(atPath: fileName, contents: data, attributes: nil)
    }
    
    
}
