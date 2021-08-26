//
//  Photo.swift
//  NNCK!
//
//  Created by 이영빈 on 2021/08/23.
//

import Foundation
import SwiftUI
import PhotosUI

class Album: ObservableObject {
    @Published var photoAssets = PHFetchResult<PHAsset>()


    func fetchPhoto() -> PHFetchResult<PHAsset> {
        /// 페치 및 로컬 페치 데이터 업데이트, 에셋 리턴
        // 이미지 페치 옵션
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        let results: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        self.photoAssets = results
        
        print("[AlbumModel]: \(photoAssets.count) fetched count")
        return results
    }
    
    func deletePhoto(assets: [PHAsset], completion: @escaping () -> ()) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(assets as NSArray)
        }, completionHandler: {success, error in
            print(success ? "sucess" : "error")
            completion()
        })
    }
}

extension PHAsset {
    //https://stackoverflow.com/questions/30812057/phasset-to-uiimage
    
    var thumbnailImage : UIImage {
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.isNetworkAccessAllowed = true

        var thumbnail = UIImage()
        let imageManager = PHCachingImageManager()
        imageManager.requestImage(for: self, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: requestOptions, resultHandler: { image, _ in
            thumbnail = image!
        })
        return thumbnail
    }
    
    func originalImage(targetSize: CGSize) -> UIImage {
        print("Original Image requested")
        print(self)
       
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.isNetworkAccessAllowed = true

        var thumbnail = UIImage()
        
        let imageManager = PHCachingImageManager()
        imageManager.requestImage(for: self, targetSize: CGSize(width: 700, height: 700), contentMode: .aspectFill, options: requestOptions) { image, info in
            if (info?[PHImageResultIsDegradedKey] as? Bool) ?? false { print("error"); return }
            thumbnail = image!
        }
        return thumbnail
    }
}

struct Share: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let data: [Any]

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        let activityViewController = UIActivityViewController(
            activityItems: data,
            applicationActivities: nil
        )

        if isPresented && uiViewController.presentedViewController == nil {
            uiViewController.present(activityViewController, animated: true)
        }

        activityViewController.completionWithItemsHandler = { (_, _, _, _) in
            isPresented = false
        }
    }
}

