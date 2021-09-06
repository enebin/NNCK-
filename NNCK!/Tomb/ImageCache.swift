//    
//        func cacheImages(assets: PHFetchResult<PHAsset>) {
//            var tempAssets = [PHAsset]()
//            for index in 0..<assets.count {
//                tempAssets.append(assets[index])
//            }
//    
//            let requestOptions = PHImageRequestOptions()
//            let imageManager = PHCachingImageManager()
//
//            requestOptions.isSynchronous = true
//            requestOptions.deliveryMode = .highQualityFormat
//            requestOptions.isNetworkAccessAllowed = true
//            let bigSize = CGSize(width: 700, height: 700)
//                    imageManager.startCachingImages(for: tempAssets, targetSize: bigSize, contentMode: .aspectFill, options: requestOptions)
//    
//            print("[AlbumModel]: Caching is done. Count: \(tempAssets.count)")
//        }

//
//
//func cacheThumbnail(assets: PHFetchResult<PHAsset>) {
//    var tempAssets = [PHAsset]()
//    for index in 0..<assets.count {
//        tempAssets.append(assets[index])
//    }
//
//    let requestOptions = PHImageRequestOptions()
//    requestOptions.isSynchronous = true
//    requestOptions.deliveryMode = .highQualityFormat
//    requestOptions.isNetworkAccessAllowed = true
//
//    let imageManager = PHCachingImageManager()
//    imageManager.startCachingImages(for: tempAssets, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: requestOptions)
//
//    print("[AlbumModel]: Caching is done. Count: \(tempAssets.count)")
//}
