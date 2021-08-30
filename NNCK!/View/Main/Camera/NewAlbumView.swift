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
    @State var selection = 0
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
        .overlay(ImagePreview(selection: $selection)
                    .environmentObject(viewModel))
        .background(viewModel.isSelectionMode ? Color.white.opacity(0.3) : Color.black)
        .background(Share(isPresented: $viewModel.showShare,
                          data: viewModel.chosenMultipleAssets.map({
            $0.originalImage(targetSize: viewModel.originalSize)
        })))
        .animation(.easeInOut(duration: 0.35))
    }
    
    var AlbumGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(minimum: 80), spacing: viewModel.gridSpacing),
                            GridItem(.flexible(minimum: 80), spacing: viewModel.gridSpacing),
                            GridItem(.flexible(minimum: 80), spacing: viewModel.gridSpacing)],
                  spacing: viewModel.gridSpacing) {
            ForEach(0..<viewModel.photoAssets.count, id: \.self) { index in
                let asset = viewModel.photoAssets[index]
                AlbumElement(selection: $selection, asset: asset, index: index)
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
                        }
                        Spacer()
                    }
                    .zIndex(1.0)
                    TabPage
                }
                .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .bottom)))
            }
        }

        var TabPage: some View {
            return TabView(selection: $selection) {
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
//            .onAppear {  UIScrollView.appearance().bounces = false }
//            .onDisappear { UIScrollView.appearance().bounces = true }
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
        @State var imageScale: CGFloat = 1
        @State var drag = CGSize.zero
        
        let haptic = UIImpactFeedbackGenerator(style: .light)

        let index: Int
        var body: some View {
            let image = viewModel.photoAssets[index].originalImage(targetSize: viewModel.originalSize)
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .scaleEffect(imageScale)
                .gesture(TapGesture(count: 2).onEnded({
                    withAnimation{
                        imageScale = imageScale > 1 ? 1 : 4
                    }
                    hidePreviewHeader = imageScale > 1 ?
                        true : false
                }))
                .simultaneousGesture(TapGesture(count: 1).onEnded({
                    hidePreviewHeader.toggle()
                }))
                .simultaneousGesture(MagnificationGesture()
                                        .onChanged({ (value) in
                                            imageScale = value
                                            hidePreviewHeader = true
                                        }).onEnded({ (_) in
                                            withAnimation(.spring()){
                                                imageScale = 1
                                            }
                                            haptic.impactOccurred()
                                            hidePreviewHeader = false
                                        }))
        }
    }
}
