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
    
    @Namespace var namespace
    
    @State var show = false
    @State var selected: Int = 0
    
    
    var test: some View {
        LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
            ForEach(1..<20) { index in
                Image(systemName: "person")
                    .frame(width: 100, height: 100)
                    .background(
                        Rectangle().matchedGeometryEffect(id: index, in: namespace)
                    )
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            show.toggle()
                            selected = index
                        }
                    }
            }
        }
    }
    
    var AlbumGrid: some View {
        let spacing: CGFloat = viewModel.isSelectionMode ? 6 : 2
        
        return LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: spacing)], spacing: spacing) {
            ForEach(viewModel.allPhotos.indices, id: \.self) { index in
                let photo = viewModel.allPhotos[index]
                let elem = albumElement(selectedPhotoIndex: $selectedPhotoIndex, show: $show, namespace: namespace, index: index)
                elem.environmentObject(viewModel)
                    .clipped()
                    .aspectRatio(1, contentMode: .fit)
            }
        }
    }
    
    var body: some View {
        ZStack {
            if show == false {
                ScrollView {
                    AlbumGrid
//                    (namespace: namespace, show: $show, selected: $selected)
                }
            } else { imageBody }
        }
    }
    
//    var body: some View {
//        ZStack {
//            if show == false {
//                ScrollView {
//                    test
////                    (namespace: namespace, show: $show, selected: $selected)
//                }
//            } else { imageBody }
//        }
//    }
    
    var imageBody: some View {
        let differenceParameter = abs(draggedOffset.height/2000)

        return Image("pawpaw")
            .resizable()
            .scaledToFit()
            .foregroundColor(.white)
            .frame(maxWidth: 500, maxHeight: 500)
            .background(Rectangle().fill(Color.gray))
            .scaleEffect(1 - differenceParameter)
            .matchedGeometryEffect(id: selected, in: namespace)
            .opacity(1 - Double(differenceParameter) * 3)
            .offset(y: draggedOffset.height)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    show.toggle()
                }
            }
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged { value in
                            draggedOffset = value.translation
                        }
                        .onEnded({ value in
                            if draggedOffset.height > 50 {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    show = false
                                }
                            }
                            draggedOffset = CGSize.zero
                        }))
    }
    
    //    var body: some View {
    //        ZStack {
    //            // 셀렉션모드에 따라 배경색 변화
    //            if viewModel.isSelectionMode {
    //                Color.white.ignoresSafeArea()
    //            } else {
    //                Color.black.ignoresSafeArea()
    //            }
    //
    //            if viewModel.showLargeImage && viewModel.selectedPhoto != nil {
    //                Group {
    //                    // 헤더버튼 종류변화
    //                    if viewModel.showFullScreen == false {
    //                        VStack() {
    //                            Header
    //                            Spacer()
    //                        }
    //                        .zIndex(1.0)
    ////                        .transition(.asymmetric(insertion: .move(edge: .top), removal: .opacity))
    //                    }
    //
    //                    TabView(selection: $selectedPhotoIndex) {
    //                        ForEach(0..<viewModel.allPhotos.count) { index in
    //                            let photo = viewModel.allPhotos[index]
    //                            LargeImageView(photo: photo)
    //                                .environmentObject(viewModel)
    //                                .tag(index)
    //                                .matchedGeometryEffect(id: photo, in: nspace)
    //                        }
    //                    }
    ////                    .onAppear {
    ////                        UIScrollView.appearance().bounces = false
    ////                    }
    ////                    .onDisappear {
    ////                        UIScrollView.appearance().bounces = true
    ////                    }
    //                    .tabViewStyle(PageTabViewStyle())
    //                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
    //                }
    ////                .offset(y: draggedOffset.height / 1.5)
    ////                .contentShape(Rectangle())
    ////                .gesture(DragGesture(minimumDistance: 10, coordinateSpace: .local)
    ////                            .onChanged { value in
    ////                                draggedOffset = value.translation
    ////                                print(draggedOffset)
    ////                            }
    ////                            .onEnded({ value in
    ////                                if draggedOffset.height > 0 {
    ////                                    viewModel.showLargeImage = false
    ////                                }
    ////                                draggedOffset = CGSize.zero
    ////                            }))
    //            } else {
    //                VStack {
    //                    Header
    //                    ScrollView {
    //                        AlbumGrid
    //                            .zIndex(0)
    ////                            .onAppear {
    ////                                UIScrollView.appearance().bounces = true
    ////                            }
    //                    }
    //                }
    //            }
    //        }
    //        .animation(.easeInOut(duration: 0.2))
    //    }
    
    var Header: some View {
        HStack {
            if viewModel.showLargeImage && viewModel.selectedPhoto != nil {
                Button(action: {viewModel.showLargeImage = false; viewModel.showFullScreen = true}, label: {
                    HStack{
                        Image(systemName: "chevron.down")
                        Text("앨범")
                    }
                })
                
                Spacer()
                if let selectedPhoto = viewModel.selectedPhoto {
                    Button(action: { viewModel.deletePhoto(images: [selectedPhoto]); viewModel.showLargeImage = false },
                           label: {
                            HStack{
                                Image(systemName: "trash")
                            }
                           })
                }
            } else {
                if viewModel.isSelectionMode == false {
                    Button(action: { viewModel.setSelectionModeDefault() }) {
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
    
}

struct albumElement: View {
    @EnvironmentObject var viewModel: CameraViewModel
    @State var checkMark = false
    @Binding var selectedPhotoIndex: Int
    @Binding var show: Bool
    
    let namespace: Namespace.ID
    var index: Int
    
    var body: some View {
        let photo = viewModel.allPhotos[index]

        GeometryReader { geometry in
            Image(uiImage: photo)
                .resizable()
                .scaledToFill()
                .frame(height: geometry.size.width)
                .contentShape(Rectangle())
                .matchedGeometryEffect(id: photo, in: namespace)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedPhotoIndex = index
                        show.toggle()
                    }
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
        let photo = viewModel.allPhotos[index]

        viewModel.selectedPhoto = photo
        selectedPhotoIndex = viewModel.allPhotos.firstIndex(of: photo) ?? 0
        viewModel.showLargeImage = true
        viewModel.showFullScreen = false
    }
    
    private func selectionModeSetting() {
        let photo = viewModel.allPhotos[index]

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
                //                .transition(.move(edge: .bottom))
                .zIndex(0.9)
                .contentShape(Rectangle())
                .onTapGesture {
                    if viewModel.isSelectionMode != true {
                        viewModel.showFullScreen.toggle()
                        print(viewModel.showFullScreen)
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
