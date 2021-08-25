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
    @Published var hideHeader = false
    @Published var gridSpacing: CGFloat = 4

    @Published var takenPhoto: UIImage?  // 찍힌 사진
    
    @Published var photoAssets = PHFetchResult<PHAsset>()
    @Published var currentPhoto = UIImage()
    @Published var chosenIndex = 0
    @Published var chosenMultipleAssets = [PHAsset]()
    
    @Published var showImageViewer = true
    @Published var showShareInViewer = false
    @Published var showShareInAlbum = false
    @Published var isSelectionMode = false
    @Published var draggedOffset = CGSize.zero
//    @Published var differenceParameter = abs(draggedOffset.height/2000)

    let originalSize = CGSize(width: 700, height: 700)
    
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
    
    // MARK: - 앨범 기능
        
    func deletePhoto(assets: [PHAsset]) {
        model.deletePhoto(assets: assets, completion: self.configure)
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
