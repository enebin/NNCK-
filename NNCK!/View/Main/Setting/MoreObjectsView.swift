//
//  MoreObjectsView.swift
//  NNCK!
//
//  Created by 이영빈 on 2021/09/10.
//

import SwiftUI

struct MoreObjectsView: View {
    @EnvironmentObject var cameraSetting: CameraViewModel
    @State var selected: Int?
    
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 20) {
                ForEach(cameraSetting.objectSet.indices, id: \.self) { index in
                    ZStack {
                        if cameraSetting.effectObjectIndex == index {
                            Color.blue.opacity(0.5).zIndex(0)
                                .transition(.opacity)
                        }
                        Text(cameraSetting.objectSet[index])
                            .font(index == 0 ? .body : .title)
                            .frame(width: 75, height: 75)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.1)){
                                    if index == 0 {
                                        cameraSetting.effectObjectIndex = 0
                                        cameraSetting.effectObject = nil
                                    } else {
                                        cameraSetting.effectObjectIndex = index
                                        cameraSetting.effectObject = cameraSetting.objectSet[index]
                                    }
                                }
                            }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct MoreObjectsView_Previews: PreviewProvider {
    static var previews: some View {
        MoreObjectsView()
    }
}
