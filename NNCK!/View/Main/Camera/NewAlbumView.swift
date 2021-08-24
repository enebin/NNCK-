//
//  NewAlbumView.swift
//  NNCK!
//
//  Created by 이영빈 on 2021/08/23.
//

//TabView(selection: $selection) {
//                    ForEach(0..<viewModel.photoAssets.count) { index in
//                        let asset = viewModel.photoAssets[index]
//                        ImageBody(show: $show, asset: asset)
//                            .tag(index)
//                            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
//                                        .onChanged { value in
//                                            draggedOffset = value.translation
//                                        }
//                                        .onEnded({ value in
//                                            if draggedOffset.height > 50 {
//                                                withAnimation(.easeInOut(duration: 0.3)) {
//                                                    show = false
//                                                }
//                                            }
//                                            draggedOffset = CGSize.zero
//                                        }))
//                            .onTapGesture {
//                                withAnimation(.easeInOut(duration: 0.3)) {
//                                    show = false
//                                }
//                            }
//                    }
//                }
//                .onAppear {
//                    UIScrollView.appearance().alwaysBounceVertical = false
//                }
//                .onDisappear {
//                    UIScrollView.appearance().alwaysBounceVertical = true
//                }
//                .tabViewStyle(PageTabViewStyle())
//                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .interactive))
//                .opacity(1 - Double(differenceParameter) * 3)
//                .offset(y: draggedOffset.height / 3)


import SwiftUI
import PhotosUI
import SwiftUIPager

struct NewAlbumView: View {
    @ObservedObject var viewModel = AlbumViewModel()
    @StateObject var page: Page = .withIndex(0)
    @State var selection = 0
    @State var show = false
    @State var currentAsset = PHAsset()
    
    @Namespace var namespace
    
    var body: some View {
        ZStack {
            ScrollView {
                AlbumGrid
                    .onAppear {
                        UIScrollView.appearance().alwaysBounceVertical = true
                    }
            }
            .overlay(ImagePreview(show: $show, selection: $selection).environmentObject(viewModel))
        }
    }
    
    struct ImagePreview: View {
        @EnvironmentObject var viewModel: AlbumViewModel
        @Binding var show: Bool
        @Binding var selection: Int
        @State var draggedOffset = CGSize.zero

        var body: some View {
            let differenceParameter = abs(draggedOffset.height/2000)
            
            if show {
                ZStack {
                    Color.black.ignoresSafeArea(.all)
                    
                    TabView(selection: $selection) {
                        ForEach(0..<viewModel.photoAssets.count) { index in
                            Image(uiImage: viewModel.photoAssets[index].originalImage(targetSize: CGSize(width: 500, height: 500)))
                        }
                    }
                    .onTapGesture {
                        show = false
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
                }
            }
        }
    }
    
    var AlbumGrid: some View {
        let assets = viewModel.photoAssets
        return LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 4)], spacing: 4) {
            ForEach(0..<assets.count) { index in
                let asset = assets[index]
                Image(uiImage: asset.thumbnailImage)
                    .onTapGesture {
                        show = true
                        selection = index
                        viewModel.chosenAsset = asset
                        print("########")
                        print(viewModel.chosenAsset)
                    }
            }
        }
    }
}
