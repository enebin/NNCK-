//
//  CameraView.swift
//  NNCK
//
//  Created by 이영빈 on 2021/08/14.
//

import SwiftUI

struct CameraView: View {
    @ObservedObject var viewModel = CameraViewModel()
    
    @State var currentZoomFactor: CGFloat = 1.0
    @State var showSlider = false
    @State var showMusic = false
    @State var showSound = false
    @State var showImagePicker = false
    
    let hapticImpact = UIImpactFeedbackGenerator()
    var debug = true
    
    private func collapseAll() {
        showSlider = false
        showSound = false
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.showEffect {  // 이펙트를 보일지 결정
                    LaserEffectView()
                        .environmentObject(self.viewModel)
                        .zIndex(zIndexPriority.top.rawValue)
                }
                
                // 권한 확인
                if viewModel.notYetPermitted {
                    PermissionRequestView().environmentObject(viewModel)
                        .zIndex(zIndexPriority.top.rawValue)
                        .onTapGesture {}
                }
                
                GeometryReader { geometry in
                    Color.yellow.ignoresSafeArea()
                    ZStack {
                        VStack(spacing: 0) {
                            // Header buttons
                            Header
                                .padding()
                            
                            if viewModel.showSetting {
                                SettingView()
                                    .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.25)
                                    .background(RoundedRectangle(cornerRadius: 20)
                                                    .fill(Color.black.opacity(0.6)))
                            }
                            Spacer()
                        }
                        HStack {
                            Lefter
                            Spacer()
                        }
                    }
                    .zIndex(zIndexPriority.midHigh.rawValue)
                    
                    HStack {
                        Spacer()
                        Rectangle()
                            .fill(Color.red.opacity(0))
                            .contentShape(Rectangle())
                            .frame(width: geometry.size.width * 0.85, height: geometry.size.height * 0.75)
                            .position(x: geometry.size.width/2+20, y: geometry.size.height/2-30)
                            .onTapGesture {
                                viewModel.capturePhoto()
                                hapticImpact.impactOccurred()
                                collapseAll()
                            }
                            .gesture( // Zoom에 관한 함수구문
                                DragGesture().onChanged({ (val) in
                                    //  Only accept vertical drag
                                    if abs(val.translation.height) > abs(val.translation.width) {
                                        //  Get the percentage of vertical screen space covered by drag
                                        let percentage: CGFloat = -(val.translation.height / geometry.size.height)
                                        //  Calculate new zoom factor
                                        let calc = currentZoomFactor + percentage
                                        //  Limit zoom factor to a maximum of 5x and a minimum of 1x
                                        let zoomFactor: CGFloat = min(max(calc, 1), 5)
                                        //  Store the newly calculated zoom factor
                                        currentZoomFactor = zoomFactor
                                        //  Sets the zoom factor to the capture device session
                                        viewModel.zoom(with: zoomFactor)
                                    }
                                })
                            )
                        Spacer()
                    }
                    .zIndex(zIndexPriority.middle.rawValue)
                    
                    // 카메라 미리보기 ~ 아래버튼
                    ZStack {
                        let screenSizes = viewModel.screenSize.getSize(geometry: geometry)
                        let width = screenSizes[0]
                        let height = screenSizes[1]
                        
                        CameraPreview(session: viewModel.session)
                            .onAppear {
                                viewModel.configure()
                            }
                            .ignoresSafeArea()
                            .position(x: viewModel.screenSize == .Fullscreen ? width / 2 : width + 50,
                                      y: viewModel.screenSize == .Fullscreen ? height / 2 : height+30)
                            .frame(width: width, height: height)
                        
                        // Footer Buttons
                        VStack {
                            Spacer()
                            Footer
                        }
                        .padding()
                    }
                }
                .blur(radius: viewModel.notYetPermitted ? 5 : 0)
            }
            .fullScreenCover(isPresented: $showImagePicker) {
                AlbumView(showAlbum: $showImagePicker)
                    .environmentObject(viewModel)
            }
            .opacity(viewModel.isTaken ? 0 : 1)
            .animation(.easeInOut(duration: 0.3))
            .navigationBarHidden(true)
        }
        .accentColor(.black)

    }
    
    var Header: some View {
        HStack {
            Button(action: {viewModel.switchSetting(); collapseAll()}, label: {Image(systemName: "ellipsis.circle")})
            
            Spacer()
            Button(action: {viewModel.switchScreenSize(); collapseAll()}, label: {Image(systemName: "squareshape.controlhandles.on.squareshape.controlhandles")})
            
            Spacer()
            ConditionalButton(action: { viewModel.switchFlashMode(); collapseAll() }, longPressAction: {}, condition: viewModel.flashMode == .off ? true : false, imageName: ["bolt.fill", "bolt.slash"], trainPadding: 0)
        }
        .font(.system(size: 25))
        .foregroundColor(.white)
    }
    
    var Lefter: some View {
        VStack(alignment: .leading) {
            SoundButtonView()
                .environmentObject(viewModel)
            
            ConditionalButton(action: { viewModel.switchSilent(); collapseAll() }, longPressAction: { viewModel.switchSilent() }, condition: viewModel.isSilent, imageName: ["speaker.fill", "speaker.slash"])
            
            HStack {
                ConditionalButton(action: { viewModel.switchShowEffect(); collapseAll() }, longPressAction: { showSlider.toggle() }, condition: !viewModel.showEffect, imageName: ["sparkles", "sparkles"])
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
                    hapticImpact.impactOccurred()
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
                        showImagePicker = true
                        viewModel.selectedPhoto = viewModel.takenPhoto
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
        VStack {
            Text("⏩ \(viewModel.animationSpeed==10 ? 10/0 : viewModel.animationSpeed, specifier: "%.1f")")
                .font(.system(size: 15))
            Slider(value: $viewModel.animationSpeed,
                   in: 0...10)
                .padding(10)
                .background(Capsule().fill(Color.black.opacity(0.3)))
                .accentColor(.catpink)
                .frame(width: 150)
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
        if let previewImage = viewModel.takenPhoto {
            Image(uiImage: previewImage)
                .resizable()
                .frame(width: 70, height: 70)
                .clipShape(RoundedRectangle(cornerRadius: 15))
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
            .foregroundColor(!condition ? .catgreen : .white)
            .padding(10)
            .padding(.trailing, trainPadding)
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
