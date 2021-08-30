//        
//        var TempPager: some View {
//            let page: Page = .withIndex(viewModel.selection)
//            return Pager(page: page, data: (0..<viewModel.photoAssets.count), id: \.self) { index in
//                VStack {
//                    Spacer()
//                    ChildImageView(hidePreviewHeader: $hidePreviewHeader, index: index)
//                    Spacer()
//                }
//            }
////            .onPageChanged { index in
////                viewModel.selection = index
////            }
////            .pagingPriority(.simultaneous)
////            .sensitivity(.high)
////            .draggingAnimation(.standard(duration: 0.2))
//            //            .offset(CGSize(width: 0, height: drag.height / 2))
//            //            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
//            //            .onChanged { value in
//            //            drag = value.translation
////            hidePreviewHeader = true
////            print(drag)
////            }
////            .onEnded { value in
////            if drag.height > 50 {
////            viewModel.showImageViewer = false
////            }
////            hidePreviewHeader = false
////            drag = CGSize.zero
////            })
//
//        }
//        
//        var TempTabPage: some View {
//            let interval = 3
//            return CustomPager(pageCount: viewModel.photoAssets.count, currentIndex: $viewModel.selection) {
//                let startPoint =  viewModel.selection
//                ForEach(0..<viewModel.photoAssets.count, id: \.self) { index in
//                    VStack {
//                        Spacer()
//                        ChildImageView(hidePreviewHeader: $hidePreviewHeader, index: index)
//                        Spacer()
//                    }
//                }
//            }
//        }
