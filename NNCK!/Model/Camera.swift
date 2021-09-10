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
    @Published var recentImage: UIImage?

    // 비디오 인풋
    var videoDeviceInput: AVCaptureDeviceInput!
    
    // 비디오 검색 세션
    private let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera], mediaType: .video, position: .unspecified)
    
    // 각종 파라미터
    @Published var isSaved = false
    @Published var isTaken = false
    @Published var isSilent = true
    @Published var isWaterMarked = true
    
    @Published var cameraAuth: SessionSetupResult = .success
    @Published var albumAuth: SessionSetupResult = .success
    @Published var flashMode: AVCaptureDevice.FlashMode = .off
    @Published var isCameraBusy = false


    var errorString : String = ""
    
    // 경고창에 관한 변수들
    public var setupResult: SessionSetupResult = .success
    
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
    
    func switchWaterMark(to result: Bool) {
        self.isWaterMarked = result
    }
    
    func switchFlash() {
        flashMode = flashMode == .off ? .on : .off
    }
    
    // MARK: - 카메라 기능에 관한 것들
    
    // TODO: 카메라 프리뷰 켜기 아님 끄기 + 비율 조정
    
    func changeCamera() {
        let currentPosition = self.videoDeviceInput.device.position
        let preferredPosition: AVCaptureDevice.Position
        let preferredDeviceType: AVCaptureDevice.DeviceType
        
        switch currentPosition {
        case .unspecified, .front:
            print("후면카메라로 전환합니다.")
            preferredPosition = .back
            preferredDeviceType = .builtInWideAngleCamera
            
        case .back:
            print("전면카메라로 전환합니다.")
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
                if let inputs = session.inputs as? [AVCaptureDeviceInput] {
                    for input in inputs {
                        session.removeInput(input)
                    }
                }
                if self.session.canAddInput(videoDeviceInput) {
                    self.session.addInput(videoDeviceInput)
                    self.videoDeviceInput = videoDeviceInput
                } else {
                    self.session.addInput(self.videoDeviceInput)
                }
            
                if let connection =
                    self.output.connection(with: .video) {
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
    
    
    func savePhoto() {
        var watermark = UIImage(named: "")

        if self.isWaterMarked {
            watermark = UIImage(named: "pawpaw")
        }
        
        guard let image = UIImage(data: self.photoData) else { return }
        
        let newImage = image.overlayWith(image: watermark!,
                                         posX: UIScreen.main.bounds.maxX*2.4,
                                         posY: UIScreen.main.bounds.maxY*2.6)
        
        PHPhotoLibrary.shared().performChanges({
            _ = PHAssetChangeRequest.creationRequestForAsset(from: newImage)
        }, completionHandler: { success, error in
            guard success else { return }
        })
        
        // 사진 저장하기
        print("[Camera]: Photo's saved")
    }
    
}

extension Camera: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        self.isCameraBusy = true
    }
    
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
        print("[CameraModel]: Capture routine's done")
        
        self.photoData = imageData
        self.recentImage = UIImage(data: imageData)
        self.savePhoto()
        self.isCameraBusy = false
    }
}

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
