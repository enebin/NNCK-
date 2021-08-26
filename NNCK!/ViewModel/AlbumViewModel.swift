//
//  AlbumViewModel.swift
//  NNCK!
//
//  Created by 이영빈 on 2021/08/23.
//

import SwiftUI
import PhotosUI
import DequeModule
import Combine

class AlbumViewModel: ObservableObject {
    private let model = Album()
    private var subscriptions = Set<AnyCancellable>()
    let originalSize = CGSize(width: 700, height: 700)
    let interval = 10
    
    // 앨범 관련 변수
    @Published var hideHeader = false
    @Published var gridSpacing: CGFloat = 4
    
    @Published var photoAssets = PHFetchResult<PHAsset>()
    @Published var currentPhoto = UIImage()
    @Published var chosenMultipleAssets = [PHAsset]()
    @Published var selection = 0
    
    @Published var showImageViewer = true
    @Published var showShare = false
    @Published var isSelectionMode = false
    @Published var draggedOffset = CGSize.zero
//    @Published var differenceParameter = abs(draggedOffset.height/2000)

    var tempImage = [UIImage](repeating: UIImage(), count: 100)
    
    @Published var photoCache = cache(id: nil, image: [UIImage](repeating: UIImage(), count: 100))
    
    struct cache {
        var id: Int?
        var image = [UIImage](repeating: UIImage(), count: 100)
    }
    
    func configure() {
        self.photoAssets = self.model.fetchPhoto()
        print("[AlbumViewModel]: \(photoAssets.count) fetched count")
    }
    
    
    // 앨범 관련
    func switchSelectionMode(to result: Bool) {
        isSelectionMode = result
        
        if isSelectionMode == false {
            chosenMultipleAssets = [PHAsset]()
        }
        gridSpacing = isSelectionMode == true ? 8 : 4
    }
    
    func deletePhoto(assets: [PHAsset]) {
        model.deletePhoto(assets: assets, completion: self.configure)
    }
    
//    func requestPhoto(index originalIndex: Int) -> UIImage {
//        let id: Int = originalIndex / interval
//        let index: Int = originalIndex % interval
//
//
//        if photoCache.id == nil || photoCache.id != id {
//            print(id, photoCache.id)
//            let requestOptions = PHImageRequestOptions()
//            requestOptions.isSynchronous = false
//            requestOptions.deliveryMode = .highQualityFormat
//            requestOptions.isNetworkAccessAllowed = true
//
//            let imageManager = PHCachingImageManager()
//            for assetIndex in (id * interval ... id * interval + interval) {
//                imageManager.requestImage(for: photoAssets[assetIndex], targetSize: CGSize(width: 700, height: 700), contentMode: .aspectFill, options: requestOptions) { [self] image, info in
//                    if (info?[PHImageResultIsDegradedKey] as? Bool) ?? false { print("error"); return }
//                    photoCache.image[assetIndex / interval] = image ?? UIImage()
//                }
//                print("[AlbumViewModel]: Caching is done")
//            }
//            photoCache.id = id
//        }
//
//        return photoCache.image[index]
//    }
    
    init() {
        configure()
//
//        model.$photoAssets.sink { [weak self] (photoAssets) in
//            self?.photoAssets = photoAssets
//        }
//        .store(in: &self.subscriptions)
    }
}
