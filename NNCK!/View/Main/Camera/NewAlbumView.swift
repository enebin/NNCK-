//
//  NewAlbumView.swift
//  NNCK!
//
//  Created by 이영빈 on 2021/08/23.
//

import SwiftUI

struct NewAlbumView: View {
    @EnvironmentObject var viewModel: CameraViewModel
    @Binding var showAlbum: Bool
    
    @State var show = false
    @State var selected: Int = 0
    
    @Namespace var namespace
    
    var body: some View {
        ZStack {
            ScrollView { test }
        }
    }
    
    var test: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 4)], spacing: 4) {
            ForEach(1..<20) { index in
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 100, height: 100)
                    .matchedGeometryEffect(id: index, in: namespace)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 2)) {
                            show.toggle()
                            selected = index
                        }
                    }

//                    .background(
//                        Image(uiImage: viewModel.allPhotos[index])
//                            .resizable()
//                            .aspectRatio(1, contentMode: .fill)
//                    )
            }
        }
        .overlay(imageBody(show: $show, selected: $selected, namespace: namespace))
    }
    
    struct imageBody:  View {
        @State var draggedOffset = CGSize.zero
        @Binding var show: Bool
        @Binding var selected: Int
        var namespace: Namespace.ID

        var body: some View {
            let differenceParameter = abs(draggedOffset.height/2000)
            
            ZStack {
                if show {
                    
                    Color.black
                        .opacity(0)
                        .ignoresSafeArea()
                    
                    Image("pawpaw")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white)
                        .frame(maxWidth: 500, maxHeight: 500)
                        .background(Rectangle().fill(Color.gray))
                        .scaleEffect(1 - differenceParameter)
                        .matchedGeometryEffect(id: selected, in: namespace)
                        .opacity(1 - Double(differenceParameter) * 3)
                        .offset(y: draggedOffset.height / 3)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 2)) {
                                show = false
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

            }
            .frame(width: .infinity, height: .infinity, alignment: .center)
            
        }
        
    }
    
}
