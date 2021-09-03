//
//  CustomPager.swift
//  NNCK!
//
//  Created by 이영빈 on 2021/08/28.
//

import SwiftUI

struct CustomPager<Content: View>: View {
    let pageCount: Int
    @State var ignore: Bool = false
    @Binding var currentIndex: Int {
        didSet {
            if (!ignore) {
                currentFloatIndex = CGFloat(currentIndex)
            }
        }
    }
    
    @State var currentFloatIndex: CGFloat = 0 {
        didSet {
            ignore = true
            currentIndex = min(max(Int(currentFloatIndex.rounded()), 0), self.pageCount - 1)
            ignore = false
        }
    }
    let content: Content

    @GestureState private var offsetX: CGFloat = 0
    
    init(pageCount: Int, currentIndex: Binding<Int>, @ViewBuilder content: () -> Content) {
        self.pageCount = pageCount
        self._currentIndex = currentIndex
        self.content = content()
    }

    var body: some View {
        GeometryReader { geometry in
            LazyHStack(spacing: 0) {
                self.content
                    .frame(width: geometry.size.width)
            }
            .frame(width: geometry.size.width, alignment: .leading)
            .offset(x: -CGFloat(self.currentFloatIndex) * geometry.size.width)
            .offset(x: self.offsetX)
            .highPriorityGesture(
                DragGesture().updating(self.$offsetX) { value, state, _ in
                    state = value.translation.width
                }
                .onEnded({ (value) in
                    let offset = value.translation.width / geometry.size.width
                    let offsetPredicted = value.predictedEndTranslation.width / geometry.size.width
                    let newIndex = CGFloat(self.currentFloatIndex) - offset
                    
                    self.currentFloatIndex = newIndex
                    
                    withAnimation(.easeOut) {
                        if(offsetPredicted < -0.5 && offset > -0.5) {
                            self.currentFloatIndex = CGFloat(min(max(Int(newIndex.rounded() + 1), 0), self.pageCount - 1))
                        } else if (offsetPredicted > 0.5 && offset < 0.5) {
                            self.currentFloatIndex = CGFloat(min(max(Int(newIndex.rounded() - 1), 0), self.pageCount - 1))
                        } else {
                            self.currentFloatIndex = CGFloat(min(max(Int(newIndex.rounded()), 0), self.pageCount - 1))
                        }
                    }
                })
            )
        }
        .onChange(of: currentIndex, perform: { value in
            print("index changed")
            
            // this is probably animated twice, if the tab change occurs because of the drag gesture
            withAnimation(.easeOut) {
                currentFloatIndex = CGFloat(value)
            }
        })
    }
}
