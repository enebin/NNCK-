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
    // 카메라 관련
    let session: AVCaptureSession
    private let model = Camera()
    private var subscriptions = Set<AnyCancellable>()
    
    private var isCameraBusy = false
    private let hapticImpact = UIImpactFeedbackGenerator()
    
    // 설정창 관련 변수
    @Published var showSetting = false
    @Published var showEffect = false
    @Published var effectType: Effects = .laser
    @Published var numOfEffect = 1
    @Published var sizeOfEffect: CGFloat = 34
    
    // 사진 관련 변수
    @Published var recentImage: UIImage?
    @Published var isSilent = true
    @Published var isWatermark = true
    @Published var isTaken = false
    @Published var animationSpeed: Double = 5

    @Published var flashMode: AVCaptureDevice.FlashMode = .off
    @Published var screenSize = ScreenSize.Fullscreen
    @Published var cameraAuth: SessionSetupResult = .success
    @Published var albumAuth: SessionSetupResult = .success
    
    // 디자인 관련 변수
    @Published var backgroundColor = Color.yellow
    @Published var effectObjectIndex: Int?
    @Published var effectObject: String?
    
    let debug = false
    let objectSet =
        ["기본값" ,"🐶", "🐸", "🐛", "🪲", "🪰",
         "🦀", "🦎", "👻", "💀", "☠️", "👽",
         "🐝", "🪱", "🎃", "🪳", "🌕", "⭐️",
         "🥩", "🍗", "🥎", "👁", "☄️", "🐽"]
    
    var notYetPermitted: Bool {
        return self.debug ? !self.debug : self.cameraAuth != .success || self.albumAuth != .success
    }
    
    // MARK: - 세팅
    func configure() {
        model.requestAndCheckPermissions()
//        model.getAllPhotos()
    }
    
    // MARK: - 내부값 수정하는 메소드들
    func switchTaken() {
        isTaken = isTaken == true ? false : true
    }
    
    func switchSilent() {
        isSilent = isSilent == true ? false : true
        model.switchSilent(to: isSilent)
    }
    
    func switchWatermark() {
        isWatermark = isWatermark == true ? false : true
        model.switchWaterMark(to: isWatermark)
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
    
    func increaseEffectNo() {
        let maximum = 10
        if numOfEffect >= maximum {
            return
        } else {
            self.numOfEffect = self.numOfEffect + 1
        }
    }
    
    func decreaseEffectNo() {
        if numOfEffect <= 1 {
            return
        } else {
            self.numOfEffect = self.numOfEffect - 1
        }
    }
    
    // MARK: - 카메라 기능
    func zoom(with factor: CGFloat) {
        model.zoom(factor)
    }
    
    func capturePhoto() {
        if isCameraBusy == false {
            print("[CameraViewModel]: Photo's taken")
            model.capturePhoto()
            hapticImpact.impactOccurred()
            DispatchQueue.main.async {
                self.switchTaken()
            }   // 셔터 애니메이션 딜레이는 여기서 조정 --->
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.switchTaken()
            }
        } else {
            print("[CameraViewModel] !!Error!! Camera is busy")
        }
    }
    
    
    // MARK: -시스템
    init() {
        self.session = model.session
        
        model.$recentImage.sink { [weak self] (photo) in
            guard let pic = photo else { return }
            self?.recentImage = pic
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
        
        model.$isCameraBusy.sink { [weak self] (isCameraBusy) in
            self?.isCameraBusy = isCameraBusy
        }
        .store(in: &self.subscriptions)
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
    let orientationChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
                .makeConnectable()
                .autoconnect()
    
    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
//        let app = UIApplication.shared.windows
//        switch app.first(where: { $0.isKeyWindow })?.windowScene?.interfaceOrientation {
//        case .portrait:
//            view.videoPreviewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
//        case .portraitUpsideDown:
//            view.videoPreviewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
//        case .landscapeLeft:
//            view.videoPreviewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
//        case .landscapeRight:
//            view.videoPreviewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
//        default:
//            view.videoPreviewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
//        }
        
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
extension CaseIterable where Self: Equatable {
    func next() -> Self {
        let all = Self.allCases
        let idx = all.firstIndex(of: self)!
        let next = all.index(after: idx)
        return all[next == all.endIndex ? all.startIndex : next]
    }
}
