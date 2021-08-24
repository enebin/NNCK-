//
//  NewAlbumView.swift
//  NNCK!
//
//  Created by 이영빈 on 2021/08/23.
//

import SwiftUI
import PhotosUI

struct NewAlbumView: View {
    @ObservedObject var viewModel = AlbumViewModel()
    @Binding var showAlbum: Bool
    @State var selection = 0
    
    @Namespace var namespace
    
    
    var body: some View {
        VStack {
            Group {
                if viewModel.isSelectionMode {
                    SelectionHeader
                } else {
                    MainHeader }
            }
            .padding(15)
            
            ScrollView {
                AlbumGrid
                    .onAppear {
                        UIScrollView.appearance().alwaysBounceVertical = true
                    }
            }
        }
        .overlay(ImagePreview(selection: $selection)
                    .environmentObject(viewModel))
        .background(viewModel.isSelectionMode ? Color.white.opacity(0.3) : Color.black)
        .animation(.easeInOut)
    }
    
    var AlbumGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: viewModel.gridSpacing)],
                  spacing: viewModel.gridSpacing) {
            ForEach(0..<viewModel.photoAssets.count, id: \.self) { index in
                let asset = viewModel.photoAssets[index]
                AlbumElement(selection: $selection, asset: asset, index: index)
                    .environmentObject(viewModel)
            }
        }
        .transition(.opacity)
        .animation(.easeInOut)
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
            Button(action: {showAlbum = false}) {
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
        }
        
        var thumbnailImage: some View {
            GeometryReader { geometry in
                Image(uiImage: asset.thumbnailImage)
                    .resizable()
                    .contextMenu {
                        Button(action: {
                            viewModel.isSelectionMode = true
                            viewModel.chosenMultipleAssets.append(asset)
                        }) {
                            Label("다중선택", systemImage: "checkmark.circle")
                        }
                        
                        Button(action: {}) {
                            Label("공유", systemImage: "square.and.arrow.up")
                        }
                        Divider()
                        Button(action: {viewModel.deletePhoto(assets: [asset])}) {
                            Label("삭제", systemImage: "trash").foregroundColor(.red)
                        }
                    }
                    .scaledToFill()
                    .frame(height: geometry.size.width)
                    .onTapGesture {
                        if viewModel.isSelectionMode == false {
                            viewModel.showImageViewer = true
                            viewModel.chosenAsset = asset
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
        
        var body: some View {
            if viewModel.showImageViewer {
                ZStack {
                    VStack {
                        PreviewHeader
                            .padding(15)
                            .background(Color.black.opacity(0.5))
                        Spacer()
                    }
                    .zIndex(1.0)
                    TabPage
                }
                .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .bottom)))
                .animation(.easeInOut(duration: 0.3))
            }
        }
        
        var TabPage: some View {
            TabView(selection: $selection) {
                ForEach(0..<viewModel.photoAssets.count, id: \.self) { index in
                    let image = viewModel.photoAssets[index]
                        .originalImage(targetSize: CGSize(width: 700, height: 700))
                    VStack {
                        Spacer()
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                            .onTapGesture {
                                viewModel.showImageViewer = false
                            }
                            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                        .onChanged { value in
                                            DispatchQueue.main.async {
                                                viewModel.draggedOffset = value.translation
                                                print(viewModel.draggedOffset)
                                            }
                                        }
                                        .onEnded({ value in
                                            if viewModel.draggedOffset.height > 50 {
                                                viewModel.showImageViewer = false
                                            }
                                            viewModel.draggedOffset = CGSize.zero
                                        }))
                        Spacer()
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
            //                .onAppear {
            //                    UIScrollView.appearance().bounces = false
            //                }
            //                .onDisappear {
            //                    UIScrollView.appearance().bounces = true
            //                }
            .background(Color.black.ignoresSafeArea(.all))
            .offset(y:viewModel.draggedOffset.height)
            //                .opacity(1 - Double(differenceParameter) * 3)
        }
        
        var PreviewHeader: some View {
            HStack {
                Button(action: {viewModel.showImageViewer = false}) {
                    Image(systemName: "chevron.down")
                        .foregroundColor(.yellow)
                }
                Spacer()
                Button(action: { viewModel.deletePhoto(assets: [viewModel.photoAssets[selection]]) }) {
                    Image(systemName: "trash")
                        .foregroundColor(.yellow)
                }
                Spacer()
                Button(action: {  }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.yellow)
                }
            }
            .font(.system(size: 20))
        }
    }
}
