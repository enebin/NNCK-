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
    var selection = 0
    var hidePreviewHeader = false

    // 앨범 관련 변수
    @Published var gridSpacing: CGFloat = 4
    
    @Published var photoAssets = PHFetchResult<PHAsset>()
    @Published var currentPhoto = UIImage()
    @Published var chosenMultipleAssets: [PHAsset] = [PHAsset]()
    
    @Published var showImageViewer = true
    @Published var showShare = false
    @Published var isSelectionMode = false
    
    func configure() {
        DispatchQueue.main.async {
            self.photoAssets = self.model.fetchPhoto()
        }
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
        model.deletePhoto(assets: assets, ifSucess: {
            DispatchQueue.main.async {
                self.chosenMultipleAssets = [PHAsset]()
                self.configure()
            }
        })
    }
    
    init() {
        configure()
//
//        model.$photoAssets.sink { [weak self] (photoAssets) in
//            self?.photoAssets = photoAssets
//        }
//        .store(in: &self.subscriptions)
    }
}
