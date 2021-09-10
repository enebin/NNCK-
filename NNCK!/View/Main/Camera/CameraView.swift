//
//  CameraView.swift
//  NNCK
//
//  Created by 이영빈 on 2021/08/14.
//

import SwiftUI
import StoreKit

struct CameraView: View {
    @ObservedObject var viewModel = CameraViewModel()
    @StateObject var storeManager = StoreManager()
    @StateObject var soundViewModel = SoundViewModel()
    @StateObject var settingViewModel = SettingViewModel()
        
    @State var currentZoomFactor: CGFloat = 1.0
    @State var lastScale:CGFloat = 1.0
    @State var showSlider = false
    @State var showMusic = false
    @State var showSound = false
    @State var showAlbum = false
    
    var debug = true
    let productIDs = ["com.enebin.NNCK.full"]
    
    private func collapseAll() {
        showSlider = false
        showSound = false
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // 이펙트를 보일지 결정
                Group {
                    if viewModel.showEffect {
                        switch(viewModel.effectType) {
                        case .laser:
                            LaserEffectView()
                                .environmentObject(self.viewModel)
                        case .floating:
                            FloatingMotionView()
                                .environmentObject(self.viewModel)
                        case .realistic:
                            HuntingEffectView()
                                .environmentObject(self.viewModel)
                        case .dodgeball:
                            DodgeballEffectView()
                                .environmentObject(self.viewModel)
                        }
                    }
                }
                .zIndex(zIndexPriority.top.rawValue)
                
                // 권한 확인
                if viewModel.notYetPermitted {
                    PermissionRequestView().environmentObject(viewModel)
                        .zIndex(zIndexPriority.top.rawValue)
                        .onTapGesture {}
                }
                
                // 기능부
                GeometryReader { geometry in
                    viewModel.backgroundColor.ignoresSafeArea()
                    // 왼쪽 기능 버튼
                    ZStack {
                        VStack(spacing: 0) {
                            // Header buttons
                            Header
                                .padding()
                            Spacer()
                        }
                        HStack {
                            Lefter
                            Spacer()
                        }
                    }
                    .zIndex(zIndexPriority.midHigh.rawValue)
                    
                    // 사진 촬영부
                    HStack {
                        Spacer()
                        Rectangle()
                            .fill(Color.red.opacity(0))
                            .contentShape(Rectangle())
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .position(x: geometry.size.width/2, y: geometry.size.height/2)
                            .gesture(MagnificationGesture()
                                        .onChanged { val in
                                            let delta = val / lastScale
                                            lastScale = val
                                            
                                            print(lastScale)
                                            let newScale = min(max(currentZoomFactor * delta, 1), 5)
                                            let zoomFactor: CGFloat = newScale
                                            viewModel.zoom(with: zoomFactor)
                                            currentZoomFactor = newScale
                                        }
                                        .onEnded { _ in
                                            self.lastScale = 1.0
                                        }
                                     )
                            .gesture(TapGesture().onEnded {
                                viewModel.capturePhoto()
                                collapseAll()
                            })
                        Spacer()
                    }
                    .zIndex(zIndexPriority.middle.rawValue)
                    
                    // 카메라 미리보기
                    let screenSizes = viewModel.screenSize.getSize(geometry: geometry)
                    let width = screenSizes[0]
                    let height = screenSizes[1]
                    
                    CameraPreview(session: viewModel.session)
                        .onAppear {
                            viewModel.configure()
                            storeManager.getProducts(productIDs: productIDs)
                            SKPaymentQueue.default().add(storeManager)
                        }
                        .ignoresSafeArea()
                        .offset(x: viewModel.screenSize == .Fullscreen ? 0 : UIScreen.main.bounds.width - width,
                                y: viewModel.screenSize == .Fullscreen ? 0 : UIScreen.main.bounds.height - height * 1.5)
                        .frame(width: width, height: height)
                        .zIndex(zIndexPriority.low.rawValue)
                    
                    // 아래 버튼들
                    VStack {
                        Spacer()
                        Footer
                    }
                    .zIndex(zIndexPriority.midHigh.rawValue)
                    .padding()
                }
                .blur(radius: viewModel.notYetPermitted ? 5 : 0)
            }
            .sheet(isPresented: $viewModel.showSetting) {
                NavigationView {
                    SettingView()
                        .environmentObject(viewModel)
                        .environmentObject(settingViewModel)
                        .environmentObject(soundViewModel)
                        .environmentObject(storeManager)
                        .navigationBarHidden(true)
                }
                .accentColor(.gray)
            }
            .sheet(isPresented: $showAlbum) {
                NewAlbumView(showAlbum: $showAlbum)
                    .environmentObject(viewModel)
            }
            .opacity(viewModel.isTaken ? 0 : 1)
            .animation(.easeInOut(duration: 0.3))
            .navigationBarHidden(true)
        }
        .accentColor(.gray)
    }
    
    var Header: some View {
        HStack {
            Image(systemName: "gearshape")
                .frame(width: 50, height: 50)
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.switchSetting()
                    collapseAll()
                }
            
            Spacer()
            Button(action: {viewModel.switchScreenSize(); collapseAll()}, label: {Image(systemName: "squareshape.controlhandles.on.squareshape.controlhandles")})
            
            Spacer()
            ConditionalButton(action: { viewModel.switchFlashMode(); collapseAll() }, longPressAction: {}, condition: viewModel.flashMode == .off ? true : false, imageName: ["bolt.fill", "bolt.slash"], trainPadding: 0)
        }
        .font(.system(size: 25))
        .foregroundColor(.white)
    }
    
    var Lefter: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 사운드 버튼
            SoundButtonView()
                .environmentObject(viewModel)
                .environmentObject(soundViewModel)
            
            // 이펙트 버튼과 스피드 슬라이더
            HStack {
                ConditionalButton(action: {
                                    viewModel.switchShowEffect();
                                    collapseAll() },
                                  longPressAction: { showSlider.toggle() },
                                  condition: !viewModel.showEffect, imageName: ["sparkles", "sparkles"])
                if showSlider {
                    EffectSlider
                        .transition(.move(edge: .leading).combined(with: .opacity))
                }
            }
        }
    }
    
    var Footer: some View {
        ZStack {
            // 셔터 버튼
            Button(action: {
                    viewModel.capturePhoto()
                    collapseAll() },
                   label: {
                    Circle().stroke(lineWidth: 6)
                        .foregroundColor(.white)
                        .frame(width: 150, height: 60)})
            HStack {
                // 미리보기
                CapturedPhotoThumbnail()
                    .environmentObject(viewModel)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showAlbum = true
                    }
                Spacer()
                // 카메라 전환
                Button(action: { viewModel.switchCameraPosition(); collapseAll() },
                       label: {Image(systemName: "arrow.triangle.2.circlepath.camera")})
                    .padding(.trailing, 10)
            }
            .font(.system(size: 30))
        }
        .foregroundColor(.white)
    }
    
    var EffectSlider: some View {
        HStack {
            Text("⏩ \(viewModel.animationSpeed==10 ? 10/0 : viewModel.animationSpeed, specifier: "%.1f")")
                .font(.system(size: 15))
            Slider(value: $viewModel.animationSpeed,
                   in: 0...10)
                .padding(10)
                .accentColor(.pink)
                .frame(width: 150)
            Text("+")
        }
    }
    
    enum zIndexPriority: Double {
        case top = 1.0
        case midHigh = 0.9
        case middle = 0.5
        case low = 0.1
    }
}

struct CapturedPhotoThumbnail: View {
    @EnvironmentObject var viewModel: CameraViewModel
    @State var isTouched = false
    
    var body: some View  {
        if let previewImage = viewModel.recentImage {
            Image(uiImage: previewImage)
                .resizable()
                .scaledToFill()
                .frame(width: 70, height: 70)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .aspectRatio(1, contentMode: .fit)
        } else {
            RoundedRectangle(cornerRadius: 15)
                .stroke(lineWidth: 3)
                .foregroundColor(.white)
                .frame(width: 70, height: 70)
        }
    }
}

struct ConditionalButton: View {
    /// - Tag : True - False 순서로 조건 기입.
    let action: () -> ()
    let longPressAction: () -> ()
    let condition: Bool
    let imageName: [String]
    var trainPadding: CGFloat = 10
    
    let hapticImpact = UIImpactFeedbackGenerator()
    
    var body: some View {
        Image(systemName: !condition ? imageName[0] : imageName[1])
            .font(.system(size: 25))
            .foregroundColor(!condition ? .catmint : .white)
            .frame(width: 40, height: 50)
            .contentShape(Rectangle())
            .onTapGesture {
                action()
            }
            .onLongPressGesture(minimumDuration: 0.3, maximumDistance: 3) {
                longPressAction()
                hapticImpact.impactOccurred()
            }
    }
}



struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
