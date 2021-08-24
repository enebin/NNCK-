//
//  AlbumViewModel.swift
//  NNCK!
//
//  Created by 이영빈 on 2021/08/23.
//

import SwiftUI
import PhotosUI
import Combine

class AlbumViewModel: ObservableObject {
    private let model = Album()
    private var subscriptions = Set<AnyCancellable>()
    
    // 앨범 관련 변수
    @Published var isSelectionMode = false
    @Published var showLargeImage = true
    @Published var hideHeader = false

    @Published var takenPhoto: UIImage?  // 찍힌 사진
    @Published var isDeleted = false // 삭제 되었는지?
    
    @Published var photoAssets = PHFetchResult<PHAsset>()
    @Published var chosenAsset = PHAsset()
    
    func configure() {
        photoAssets = model.fetchPhoto()
        print("[AlbumViewModel]: \(photoAssets.count) fetched count")
    }
    
    func setSelectedPhoto(asset: PHAsset) {
        chosenAsset = asset
    }
    
    // 앨범 관련
    func switchSelectionMode() {
        isSelectionMode = isSelectionMode == true ? false : true
    }
    
    // MARK: - 앨범 기능
//    func requestImage(asset: PHAsset) -> UIImage? {
//        let image: UIImage?
//        image = model.requestPhoto(asset: asset)
//        
//        return image
//    }
//    
    func deletePhoto(assets: [PHAsset]) {
        model.deletePhoto(assets: assets)
    }
    
    init() {
        configure()
        
//        model.$photoAssets.sink { [weak self] (photoAssets) in
//            self?.photoAssets = photoAssets
//        }
//        .store(in: &self.subscriptions)
    }
}
