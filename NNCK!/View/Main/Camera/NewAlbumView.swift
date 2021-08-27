//
//  NewAlbumView.swift
//  NNCK!
//
//  Created by 이영빈 on 2021/08/23.
//

import SwiftUI
import PhotosUI
import SwiftUIPager

struct NewAlbumView: View {
    @StateObject var viewModel = AlbumViewModel()
    @Binding var showAlbum: Bool
    
    var body: some View {
        VStack {
            Group {
                if viewModel.isSelectionMode {
                    SelectionHeader
                } else {
                    MainHeader
                }
            }
            .padding(15)
            ScrollView {
                AlbumGrid
            }
        }
        .overlay(ImagePreview(selection: $viewModel.selection)
                    .environmentObject(viewModel))
        .background(viewModel.isSelectionMode ? Color.white.opacity(0.3) : Color.black)
        .background(Share(isPresented: $viewModel.showShare,
                          data: viewModel.chosenMultipleAssets.map({
            $0.originalImage(targetSize: viewModel.originalSize)
        })))
        .animation(.easeInOut(duration: 0.35))
    }

//    var PageView: some View {
//        Pager(page: <#T##Page#>, data: <#T##RandomAccessCollection#>, id: <#T##KeyPath<_, _>#>, content: <#T##(_) -> _#>)
//    }
    
    var AlbumGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(minimum: 80), spacing: viewModel.gridSpacing),
                            GridItem(.flexible(minimum: 80), spacing: viewModel.gridSpacing),
                            GridItem(.flexible(minimum: 80), spacing: viewModel.gridSpacing)],
                  spacing: viewModel.gridSpacing) {
            ForEach(0..<viewModel.photoAssets.count, id: \.self) { index in
                let asset = viewModel.photoAssets[index]
                AlbumElement(selection: $viewModel.selection, asset: asset, index: index)
                    .environmentObject(viewModel)
            }
        }
        .transition(.opacity)
    }
    
    var MainHeader: some View {
        HStack {
            Button(action: {showAlbum = false}) {
                Image(systemName: "xmark")
                    .foregroundColor(.yellow)
            }
            Spacer()
            Button(action: {viewModel.switchSelectionMode(to: true)}) {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.yellow)
            }
        }
        .font(.system(size: 20))
    }
    
    var SelectionHeader: some View {
        HStack {
            Button(action: { viewModel.showShare = true }) {
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(.yellow)
            }
            Spacer()
            Button(action: { viewModel.deletePhoto(assets: viewModel.chosenMultipleAssets) }) {
                Image(systemName: "trash")
                    .foregroundColor(.yellow)
            }
            Spacer()
            Button(action: {viewModel.switchSelectionMode(to: false)}) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.yellow)
            }
        }
        .font(.system(size: 20))
    }
        
    struct AlbumElement: View {
        @EnvironmentObject var viewModel: AlbumViewModel
        @Binding var selection: Int
        let asset: PHAsset
        let index: Int
        
        var body: some View {
            ZStack {
                if (viewModel.chosenMultipleAssets.firstIndex(of: asset) != nil) {
                    checkMark.zIndex(1.0)
                }
                thumbnailImage
            }
            .clipped()
            .aspectRatio(1, contentMode: .fit)
        }
        
        var checkMark: some View {
            VStack {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .background(Circle().fill(Color.white))
                        .padding(3)
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                    Spacer()
                }
                Spacer()
            }
            .transition(.identity)
        }
        
        var thumbnailImage: some View {
            GeometryReader { geometry in
//                CustomContextMenu {
//                    Image(uiImage: asset.thumbnailImage)
//                        .resizable()
//                        .scaledToFill()
//                        .frame(height: geometry.size.width)
//                        .contentShape(Rectangle())
//                        .onTapGesture {
//                            if viewModel.isSelectionMode == false {
//                                viewModel.showImageViewer = true
//                                selection = index
//                            } else {
//                                if let index = viewModel.chosenMultipleAssets.firstIndex(of: asset) { // 셀렉션이 이미 되었다면
//                                    viewModel.chosenMultipleAssets.remove(at: index)
//                                } else {
//                                    viewModel.chosenMultipleAssets.append(asset)
//                                }
//                            }
//                        }
//                } preview: {
//                    Image(uiImage: asset.originalImage(targetSize: viewModel.originalSize))
//                } actions: {
//
//                    let multiSelection = UIAction(title: "다중선택",image: UIImage(systemName: "checkmark.circle")) { _ in
//                        viewModel.isSelectionMode = true
//                        viewModel.chosenMultipleAssets.append(asset)
//                    }
//
//                    let share = UIAction(title: "공유",image: UIImage(systemName: "square.and.arrow.up")) { _ in
//                        viewModel.isSelectionMode = true
//                        viewModel.chosenMultipleAssets.append(asset)
//                        viewModel.showShare = true;
//                    }
//
//                    let delete = UIAction(title: "삭제", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
//                        viewModel.deletePhoto(assets: [asset])
//                    }
//
//                    return UIMenu(title: "",children: [multiSelection, share, delete])
//                } onEnd: {
//                    viewModel.showImageViewer = true
//                }
                
                Image(uiImage: asset.thumbnailImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: geometry.size.width)
                    .contentShape(Rectangle())
                    .contextMenu {
                        Button(action: {
                            viewModel.isSelectionMode = true
                            viewModel.chosenMultipleAssets.append(asset)
                        }) {
                            Label("다중선택", systemImage: "checkmark.circle")
                        }
                        Button(action: {
                            viewModel.isSelectionMode = true
                            viewModel.chosenMultipleAssets.append(asset)
                            viewModel.showShare = true;
                        }) {
                            Label("공유", systemImage: "square.and.arrow.up")
                        }
                        Divider()
                        Button(action: {viewModel.deletePhoto(assets: [asset])}) {
                            Label("삭제", systemImage: "trash").foregroundColor(.red)
                        }
                    }
                    .onTapGesture {
                        if viewModel.isSelectionMode == false {
                            viewModel.showImageViewer = true
                            selection = index
                        } else {
                            if let index = viewModel.chosenMultipleAssets.firstIndex(of: asset) { // 셀렉션이 이미 되었다면
                                viewModel.chosenMultipleAssets.remove(at: index)
                            } else {
                                viewModel.chosenMultipleAssets.append(asset)
                            }
                        }
                    }
            }
        }
    }
    
    struct ImagePreview: View {
        @EnvironmentObject var viewModel: AlbumViewModel
        @Binding var selection: Int
        @State var hidePreviewHeader = false
        
        var body: some View {
            if viewModel.showImageViewer {
                ZStack {
                    VStack {
                        if hidePreviewHeader == false {
                            PreviewHeader
                                .padding(15)
                                .background(Color.black.opacity(0.5))
//                                .transition(.move(edge: .top))
                        }
                        Spacer()
                    }
                    .zIndex(1.0)
                    TabPage
//                        .opacity(1 - Double(drag.height)/500)
                }
                .transition(.asymmetric(insertion: .scale, removal: .opacity))
            }
        }

        var TabPage: some View {
            return TabView(selection: $viewModel.selection) {
                ForEach(0..<viewModel.photoAssets.count, id: \.self) { index in
                    VStack {
                        Spacer()
                        ChildImageView(hidePreviewHeader: $hidePreviewHeader, index: index)
                        Spacer()
                    }
                    
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
            .onAppear {  UIScrollView.appearance().bounces = false }
            .onDisappear { UIScrollView.appearance().bounces = true }
            .background(Color.black.ignoresSafeArea(.all))


        }
        
        var PreviewHeader: some View {
            HStack {
                Button(action: {viewModel.showImageViewer = false; viewModel.switchSelectionMode(to: false)}) {
                    Image(systemName: "chevron.down")
                        .foregroundColor(.yellow)
                }
                Spacer()
                Button(action: { viewModel.deletePhoto(assets: [viewModel.photoAssets[selection]]) }) {
                    Image(systemName: "trash")
                        .foregroundColor(.yellow)
                }
                Spacer()
                Button(action: { viewModel.showShare = true; viewModel.chosenMultipleAssets.append(viewModel.photoAssets[selection]) }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.yellow)
                }
            }
            .font(.system(size: 20))
        }
        
    }
    
    struct ChildImageView : View {
        @EnvironmentObject var viewModel: AlbumViewModel
        @Binding var hidePreviewHeader: Bool
        
        let index: Int
        @State var imageScale: CGFloat = 1
        @State var drag = CGSize.zero
        
        var body: some View {
            let image = viewModel.photoAssets[index].originalImage(targetSize: viewModel.originalSize)
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .offset(y: drag.height / 2.5)
                .scaleEffect(imageScale > 1 ? imageScale : 1)
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged { value in
                            drag = value.translation
                            hidePreviewHeader = true
                        }
                        .onEnded { value in
                            if drag.height > 100 {
                                viewModel.showImageViewer = false
                            }
                            hidePreviewHeader = false
                            drag = CGSize.zero
                        }
                        .simultaneously(with:
                                            // Magnifying Gesture...
                                            MagnificationGesture()
                                            .onChanged({ (value) in
                                                imageScale = value
                                            }).onEnded({ (_) in
                                                withAnimation(.spring()){
                                                    imageScale = 1
                                                }
                                            }))
                        // Double To Zoom...
                        
                        .simultaneously(with:
                                            TapGesture(count: 2).onEnded({
                                                withAnimation{
                                                    imageScale = imageScale > 1 ? 1 : 4
                                                }
                                            }))
                )
                .onTapGesture {
                    viewModel.showImageViewer = false
                }
        }
    }
}
