//
//  CameraVIewModel.swift
//  NNCK
//
//  Created by 이영빈 on 2021/08/14.
import SwiftUI
import AVFoundation
import PhotosUI
import Combine


/// TODO : - 공유기능
class CameraViewModel: ObservableObject {
    // 카메라 관련 세션
    private let model = Camera()
    private var subscriptions = Set<AnyCancellable>()
    let session: AVCaptureSession
    
    // 설정창 관련 변수
    @Published var showSetting = false
    
    // 앨범 관련 변수
    @Published var isSelectionMode = false
    @Published var showLargeImage = true
    @Published var showFullScreen = false
    @Published var albumElements = [albumElement]()
    
    @Published var takenPhoto: UIImage?  // 찍힌 사진
    @Published var allPhotos = [UIImage]() // 저장된 모든 사진
    @Published var selectedPhoto: UIImage? // 앨범에서 선택한 사진
    @Published var selectedMultiplePhotos = [UIImage]() // 앨범에서 선택한 사진'들'
    @Published var photoAssets = PHFetchResult<PHAsset>() // 편집에 사용되는 에셋 데이터
    // 사진 관련 변수
    @Published var showEffect = false
    @Published var isSilent = true
    @Published var isTaken = false
    @Published var animationSpeed: Double = 5

    @Published var flashMode: AVCaptureDevice.FlashMode = .off
    @Published var screenSize = ScreenSize.Fullscreen
    @Published var cameraAuth: SessionSetupResult = .success
    @Published var albumAuth: SessionSetupResult = .success
    
    let debug = false
    
    var notYetPermitted: Bool {
        return self.debug ? !self.debug : self.cameraAuth != .success || self.albumAuth != .success
    }
    
    // MARK: - 세팅
    func configure() {
        model.requestAndCheckPermissions()
        model.getAllPhotos()
    }
    
    // MARK: - 내부값 수정하는 메소드들
    func setSelectedPhoto(_ image: UIImage) {
        selectedPhoto = image
    }
    
    func switchTaken() {
        isTaken = isTaken == true ? false : true
    }
    
    func switchSilent() {
        isSilent = isSilent == true ? false : true
        model.switchSilent(to: isSilent)
    }
    
    func switchShowEffect() { // 참고할 곳: LaserEffectView
        showEffect = showEffect == true ? false : true
    }
    
    func switchSetting() {
        showSetting = showSetting == true ? false : true
    }
    
    func switchCameraPosition() {
        model.changeCamera()
    }
    
    func switchScreenSize() {
        screenSize = screenSize.next()
    }
    
    func switchFlashMode() {
        model.switchFlash()
    }
    
    // 앨범 관련
    func switchSelectionMode() {
        isSelectionMode = isSelectionMode == true ? false : true
    }
    
    func setSelectionModeDefault() {
        isSelectionMode = isSelectionMode == true ? false : true
        for index in (0..<albumElements.count) {
            albumElements[index].checkMark = false
        }
        selectedMultiplePhotos = [UIImage]()
    }
    
    func setAlbumDefault() {
        isSelectionMode = false
        showLargeImage = true
        showFullScreen = false
    }
    
    
    
    // MARK: - 카메라 기능
    func zoom(with factor: CGFloat) {
        model.zoom(factor)
    }
    
    func capturePhoto() {
        print("[CameraViewcameraModel]: Photo's taken")
        model.capturePhoto()
        
        DispatchQueue.main.async {
            self.switchTaken()
        }   // 셔터 애니메이션 딜레이는 여기서 조정 --->
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.switchTaken()
        }
        print(photoAssets.count, allPhotos.count)
    }
    
    // MARK: - 앨범 기능
    func deletePhoto(images: [UIImage]) {
        var assets = [PHAsset]()
        for image in images {
            print(image)
            guard let index = allPhotos.firstIndex(of: image) else { return }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                self.allPhotos.remove(at: index)
//            }
            assets.append(photoAssets[index])
        }
        
        model.deletePhoto(assets)
        takenPhoto = nil
    }
    
    // MARK: -시스템
    init() {
        self.session = model.session
        
        model.$photo.sink { [weak self] (photo) in
            guard let pic = photo else { return }
            self?.takenPhoto = pic
        }
        .store(in: &self.subscriptions)
        
        model.$flashMode.sink { [weak self] (flashMode) in
            self?.flashMode = flashMode
        }
        .store(in: &self.subscriptions)
        
        model.$cameraAuth.sink { [weak self] (cameraAuth) in
            self?.cameraAuth = cameraAuth
        }
        .store(in: &self.subscriptions)
        
        model.$albumAuth.sink { [weak self] (albumAuth) in
            self?.albumAuth = albumAuth
        }
        .store(in: &self.subscriptions)
        
        model.$allPhotos.sink { [weak self] (allPhotos) in
            self?.allPhotos = allPhotos
        }
        .store(in: &self.subscriptions)
        
        model.$photoAssets.sink { [weak self] (photoAssets) in
            self?.photoAssets = photoAssets
        }
        .store(in: &self.subscriptions)
    }
    
    public enum ScreenSize: CaseIterable {
        case Fullscreen
        case Minimize
        case Hide
        
        func getSize(geometry: GeometryProxy) -> [CGFloat] {
            let width = geometry.size.width
            let height = geometry.size.height
            switch self {
            case .Fullscreen:
                return [width, height]
            case .Minimize:
                let width_3 = width/3
                return [width_3, width_3*(7/4)]
            case .Hide:
                return [0, 0]
            }
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    class VideoPreviewView: UIView {
        override class var layerClass: AnyClass {
             AVCaptureVideoPreviewLayer.self
        }
        
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }
    
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        view.backgroundColor = .black
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        view.videoPreviewLayer.cornerRadius = 0
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.connection?.videoOrientation = .portrait

        return view
    }
    
    func updateUIView(_ uiView: VideoPreviewView, context: Context) {
        
    }
}


extension CaseIterable where Self: Equatable {
    func next() -> Self {
        let all = Self.allCases
        let idx = all.firstIndex(of: self)!
        let next = all.index(after: idx)
        return all[next == all.endIndex ? all.startIndex : next]
    }
}
