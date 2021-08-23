//
//  CameraVIewModel.swift
//  NNCK
//
//  Created by 이영빈 on 2021/08/14.
// https://www.youtube.com/watch?v=ZYPNXLABf3c
// https://kavsoft.dev/SwiftUI_2.0/Custom_Camera

import UIKit
import SwiftUI
import AVFoundation
import PhotosUI

/// TODO: - Long Touch로 초점잡기

class Camera: NSObject, ObservableObject {
    // 캡처 세션
    var session = AVCaptureSession()
    
    // 사진 아웃풋
    let output = AVCapturePhotoOutput()
    
    // 사진 데이터
    var photoData = Data(count: 0)
    
    // 사진
    @Published var photo: UIImage?
    
    // 비디오 인풋
    var videoDeviceInput: AVCaptureDeviceInput!
    
    // 비디오 검색 세션
    private let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera], mediaType: .video, position: .unspecified)
    
    // 각종 파라미터
    @Published var isSaved = false
    @Published var isTaken = false
    @Published var isSilent = true
    
    @Published var allPhotos = [UIImage]()
    @Published var imageURLs = [URL]()
    @Published var photoAssets = PHFetchResult<PHAsset>()

    @Published var cameraAuth: SessionSetupResult = .success
    @Published var albumAuth: SessionSetupResult = .success
    @Published var flashMode: AVCaptureDevice.FlashMode = .off
    var errorString : String = ""
    
    // 경고창에 관한 변수들
    public var setupResult: SessionSetupResult = .success
    var tempResult: UIImage?
    
    // MARK: - 카메라 세팅에 관한 것들
    func requestAndCheckPermissions() {
        // 카메라 권한
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            // 권한 요청
            AVCaptureDevice.requestAccess(for: .video) { [weak self] authStatus in
                if authStatus == false {
                    self?.cameraAuth = .notAuthorized
                } else {
                    DispatchQueue.main.async {
                        self?.setUpCamera()
                    }
                }
            }
        case .restricted:
            break
        case .authorized:
            // 이미 권한 받은 경우 셋업
            setUpCamera()
        default:
            // 거절했을 경우
            setupResult = .notAuthorized
            cameraAuth = .notAuthorized
        }
        
        // 앨범 권한
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
            // 권한 요청
            PHPhotoLibrary.requestAuthorization { [weak self] authStatus in
                if authStatus == .denied {
                    self?.albumAuth = .notAuthorized
                }
            }
        case .restricted:
            break
        case .authorized:
            // 이미 권한 받은 경우 셋업
            setUpCamera()
        default:
            // 거절했을 경우
            setupResult = .notAuthorized
            albumAuth = .notAuthorized
        }
    }
    
    func setUpCamera(to position: AVCaptureDevice.Position = .back) {
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) {
            do {
                videoDeviceInput = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(videoDeviceInput) {
                    session.addInput(videoDeviceInput)
                }
                
                if session.canAddOutput(output) {
                    session.addOutput(output)
                    output.isHighResolutionCaptureEnabled = true
                    output.maxPhotoQualityPrioritization = .quality
                }
                session.startRunning()
            } catch {
                print(error)
            }
        }
    }
    
    // MARK: - 카메라 변수 관리
    func switchSilent(to result: Bool) {
        self.isSilent = result
    }
    
    func switchFlash() {
        flashMode = flashMode == .off ? .on : .off
    }
    
    func getPhoto() -> UIImage? {
        if let image = UIImage(data: self.photoData) {
            return image
        } else {
            return nil
        }
    }
    
    // MARK: - 카메라 기능에 관한 것들
    
    // TODO: 카메라 프리뷰 켜기 아님 끄기 + 비율 조정
    
    func changeCamera() {
        let currentPosition = self.videoDeviceInput.device.position
        let preferredPosition: AVCaptureDevice.Position
        let preferredDeviceType: AVCaptureDevice.DeviceType
        
        switch currentPosition {
        case .unspecified, .front:
            preferredPosition = .back
            preferredDeviceType = .builtInWideAngleCamera
            
        case .back:
            preferredPosition = .front
            preferredDeviceType = .builtInWideAngleCamera
            
        @unknown default:
            print("알 수 없는 포지션. 후면카메라로 전환합니다.")
            preferredPosition = .back
            preferredDeviceType = .builtInWideAngleCamera
        }
        
        let devices = self.videoDeviceDiscoverySession.devices
        var newVideoDevice: AVCaptureDevice? = nil
        
        // First, seek a device with both the preferred position and device type. Otherwise, seek a device with only the preferred position.
        if let device = devices.first(where: { $0.position == preferredPosition && $0.deviceType == preferredDeviceType }) {
            newVideoDevice = device
        } else if let device = devices.first(where: { $0.position == preferredPosition }) {
            newVideoDevice = device
        }
        
        if let videoDevice = newVideoDevice {
            do {
                let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                
                self.session.beginConfiguration()
                
                // Remove the existing device input first, because AVCaptureSession doesn't support
                // simultaneous use of the rear and front cameras.
                self.session.removeInput(self.videoDeviceInput)
                
                if self.session.canAddInput(videoDeviceInput) {
                    self.session.addInput(videoDeviceInput)
                    self.videoDeviceInput = videoDeviceInput
                } else {
                    self.session.addInput(self.videoDeviceInput)
                }
                
                if let connection = self.output.connection(with: .video) {
                    if connection.isVideoStabilizationSupported {
                        connection.preferredVideoStabilizationMode = .auto
                    }
                }
                
                output.isHighResolutionCaptureEnabled = true
                output.maxPhotoQualityPrioritization = .quality
                
                self.session.commitConfiguration()
            } catch {
                print("Error occurred while creating video device input: \(error)")
            }
        }
    }
    
    // DONE: - 줌 기능 구현
    func zoom(_ zoom: CGFloat){
        let factor = zoom < 1 ? 1 : zoom
        let device = self.videoDeviceInput.device
        
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = factor
            device.unlockForConfiguration()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    // TODO: - Shake 제스처에 미리보기
    func shake() {
        
    }
    
    // 사진 캡처
    func capturePhoto() {
        isSaved = false; isTaken = false
        
        // 사진 옵션 세팅
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.flashMode = self.flashMode
        
        self.output.capturePhoto(with: photoSettings, delegate: self)
        isTaken = true
        print("[Camera]: Photo's taken")
    }
    
    func fetchPhoto() -> PHFetchResult<PHAsset> {
        /// 페치 및 로컬 페치 데이터 업데이트, 에셋 리턴
        // 이미지 페치 옵션
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        let results: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        self.photoAssets = results
        
        return results
    }
    
    // TODO: 찍은사진 갤러리 뷰
    func getAllPhotos() {
        let results = fetchPhoto()
        
        let size = CGSize(width: 700, height: 700) //You can change size here
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        
        DispatchQueue.main.async {
            if results.count > 0 {
                var photoResult = [UIImage]()
                for i in 0..<results.count {
                    let asset = results.object(at: i)
                    PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { (image, _) in
                        if let image = image {
                            photoResult.append(image)
                        } else {
                            print("error asset to image")
                        }
                        self.allPhotos = photoResult
                    }
                }
            } else {
                self.errorString = "No photos to display"
            }
        }
        print(photoAssets.count, allPhotos.count)
    }
    
    func savePhoto() {
        let watermark = UIImage(named: "pawpaw")
        guard let image = UIImage(data: self.photoData) else { return }
        
        let newImage = image.overlayWith(image: watermark!,
                                         posX: UIScreen.main.bounds.maxX*2.4,
                                         posY: UIScreen.main.bounds.maxY*2.6)
        
        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: newImage)
        }, completionHandler: { success, error in
            guard success else { return }
            
            if let photo = UIImage(data: self.photoData) {
                self.photo = photo
                
                let assets = self.fetchPhoto()
                let requestOptions = PHImageRequestOptions()
                requestOptions.isSynchronous = false
                requestOptions.deliveryMode = .highQualityFormat
                
                guard let asset = assets.firstObject else { return }
                DispatchQueue.main.async {
                    PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 700, height: 700), contentMode: .aspectFill, options: requestOptions) { (image, _) in
                        if let image = image {
                            self.allPhotos.insert(image, at: 0)
                            print("")
                        } else {
                            print("error asset to image")
                        }
                    }
                }
            }
        })
     
        // 사진 저장하기
        print("[Camera]: Photo's saved")
    }
        
    func deletePhoto(_ assets: [PHAsset]) {
        DispatchQueue.main.async {
            PHPhotoLibrary.shared().performChanges({
                            PHAssetChangeRequest.deleteAssets(assets as NSArray)
                        }, completionHandler: {success, error in
                            print(success ? "Success" : "Error" )
                            self.getAllPhotos()
                        })
        }
    }
}

extension Camera: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        if self.isSilent {
            print("[Camera]: Silent sound activated")
            AudioServicesDisposeSystemSoundID(1108)
        }
    }
    func photoOutput(_ output: AVCapturePhotoOutput, didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        if self.isSilent {
            AudioServicesDisposeSystemSoundID(1108)
        }
    }
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        print("[Camera]: Photo'processed")
        
        self.photoData = imageData
        self.savePhoto()
    }
}

//extension Camera : PHPhotoLibraryChangeObserver {
//    func registerPhotoLibrary() {
//        PHPhotoLibrary.shared().register(self)
//    }
//
//    func photoLibraryDidChange(_ changeInstance: PHChange) {
//        let asset = self.fetchPhoto()
//        let changes = changeInstance.changeDetails(for: asset)
//        let fetchResult = changes?.fetchResultAfterChanges
//        OperationQueue.main.addOperation {
////            self.tableView.reloadSections(IndexSet(0...0), with: .automatic)
//        }
//    }
//}

extension UIImage {
    // 워터마크 오버레이 헬퍼 함수
    func overlayWith(image: UIImage, posX: CGFloat, posY: CGFloat) -> UIImage {
        let newSize = CGSize(width: size.width, height: size.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        draw(in: CGRect(origin: CGPoint.zero, size: size))
        image.draw(in: CGRect(origin: CGPoint(x: posX, y: posY), size: image.size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

enum SessionSetupResult {
    case success
    case notAuthorized
    case configurationFailed
}
