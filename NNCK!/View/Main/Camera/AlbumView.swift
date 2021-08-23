//
//  AlbumView.swift
//  NNCK
//
//  Created by 이영빈 on 2021/08/19.
//

import SwiftUI

struct AlbumView: View {
    @EnvironmentObject var viewModel: CameraViewModel
    @Binding var showAlbum: Bool
    @State var selectedPhotoIndex: Int = 0
    @State var draggedOffset = CGSize.zero

    
    var body: some View {
        ZStack {
            // 셀렉션모드에 따라 배경색 변화
            if viewModel.isSelectionMode {
                Color.white.ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
            }
            
            Group {
                if viewModel.showLargeImage && viewModel.selectedPhoto != nil {
                    // 헤더버튼 종류변화
                    if viewModel.hideHeader == false {
                        VStack {
                            Header
                            Spacer()
                        }
                        .zIndex(1.0)
                        .transition(.asymmetric(insertion: .move(edge: .top), removal: .opacity))
                    }
                    
                    // 큰 미리보기
                    TabView(selection: $selectedPhotoIndex) {
                        ForEach(0..<viewModel.allPhotos.count) { index in
                            let photo = viewModel.allPhotos[index]
                            LargeImageView(photo: photo)
                                .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                            .onChanged { value in
                                                draggedOffset = value.translation
                                            }
                                            .onEnded{ value in
                                                if draggedOffset.height > 50 {
                                                    viewModel.showLargeImage = false
                                                }
                                                draggedOffset = CGSize.zero
                                            }
                                )
                                .environmentObject(viewModel)
                                .tag(index)
                        }
                    }
                    .onAppear {
                        UIScrollView.appearance().bounces = false
                    }
                    .onDisappear {
                        UIScrollView.appearance().bounces = true
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
                } else {
                    VStack {
                        Header
                        ScrollView {
                            AlbumGrid
                                .onAppear {
                                    UIScrollView.appearance().bounces = true
                                }
                        }
                    }
                }
            }
            .offset(y: draggedOffset.height/2)
        }
        .animation(.easeInOut(duration: 0.3))
    }
    
    var Header: some View {
        HStack {
            if viewModel.showLargeImage && viewModel.selectedPhoto != nil {
                Button(action: {viewModel.showLargeImage = false; viewModel.hideHeader = true}, label: {
                    HStack{
                        Image(systemName: "chevron.down")
                        Text("앨범")
                    }
                })
                
                Spacer()
                if let selectedPhoto = viewModel.selectedPhoto {
                    Button(action: {viewModel.deletePhoto(images: [selectedPhoto]); viewModel.showLargeImage = false},
                           label: {
                        HStack{
                            Image(systemName: "trash")
                        }
                    })
                }
            } else {
                if viewModel.isSelectionMode == false {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            viewModel.setSelectionModeDefault()
                        }
                    }) {
                        Text("선택")
                    }

                } else {
                    Button(action: { viewModel.setSelectionModeDefault() }) {
                        Text("취소")
                    }
                }
                
                Spacer()
                if viewModel.selectedMultiplePhotos.count > 0 {
                    Button(action: { viewModel.deletePhoto(images: viewModel.selectedMultiplePhotos) }) {
                        Image(systemName: "trash")
                    }
                }
            }
            
            Spacer()
            Button(action: {showAlbum = false; viewModel.setAlbumDefault()}, label: {
                Image(systemName: "xmark")
            })
        }
        .font(.system(size: 18))
        .padding()
        .foregroundColor(.white)
        .background(Color.black.opacity(0.6).ignoresSafeArea())
    }
    
    var AlbumGrid: some View {
        let spacing: CGFloat = viewModel.isSelectionMode ? 6 : 2
        
        return LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: spacing)], spacing: spacing) {
            ForEach(viewModel.allPhotos, id: \.self) { photo in
                let elem = albumElement(selectedPhotoIndex: $selectedPhotoIndex, photo: photo)
                elem.environmentObject(viewModel)
                    .clipped()
                    .aspectRatio(1, contentMode: .fit)
            }
        }
        .transition(.scale)
    }
}

struct albumElement: View {
    @EnvironmentObject var viewModel: CameraViewModel
    @State var checkMark = false
    @Binding var selectedPhotoIndex: Int

    let photo: UIImage
    
    var body: some View {
        GeometryReader { geometry in
            Image(uiImage: photo)
                .resizable()
                .scaledToFill()
                .frame(height: geometry.size.width)
                .contentShape(Rectangle())
                .onTapGesture {
                    if viewModel.isSelectionMode == false {
                        // 셀렉션 모드가 아닐 때 라지 뷰 세팅
                        largeImageViewSetting()
                    } else {
                        // 셀렉션모드일 때 세팅
                        selectionModeSetting()
                    }
                }
                .contextMenu {
                    Button(action: { viewModel.selectedMultiplePhotos.append(photo)
                        checkMark = true
                        viewModel.isSelectionMode = true
                    }) {
                        Label("다중선택", systemImage: "checkmark.circle")
                    }
                    Button(action: {}) {
                        Label("공유", systemImage: "square.and.arrow.up")
                    }
                    
                    Divider()
                    Button(action: {viewModel.deletePhoto(images: [photo])}) {
                        Label("삭제", systemImage: "trash").foregroundColor(.red)
                    }
                }
            if checkMark {
                Image(systemName: "checkmark.circle.fill")
                    .background(Circle().fill(Color.white))
                    .padding(3)
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
                    .zIndex(1.0)
            }
        }
    }
    
    private func largeImageViewSetting() {
        viewModel.selectedPhoto = photo
        selectedPhotoIndex = viewModel.allPhotos.firstIndex(of: photo) ?? 0
        viewModel.showLargeImage = true
        viewModel.hideHeader = false
    }
    
    private func selectionModeSetting() {
        if checkMark == false {
            viewModel.selectedMultiplePhotos.append(photo)
            checkMark = true
        } else {
            if let index = viewModel.selectedMultiplePhotos.firstIndex(of: photo) {
                viewModel.selectedMultiplePhotos.remove(at: index)
            } else {
                print(LocalizedError.self)
            }
            checkMark = false
        }
    }

}

struct LargeImageView: View {
    @EnvironmentObject var viewModel: CameraViewModel

    let photo: UIImage
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                VStack{
                    Spacer()
                    Image(uiImage: photo)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .ignoresSafeArea()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    Spacer()
                }
                .transition(.move(edge: .bottom))
                .zIndex(0.9)
                .contentShape(Rectangle())
                .onTapGesture {
                    if viewModel.isSelectionMode != true {
                        viewModel.hideHeader.toggle()
                        print(viewModel.hideHeader)
                    } else {}
                }
                
            }
        }
        
    }
}

struct AlbumView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumView(showAlbum: .constant(false))
    }
}
