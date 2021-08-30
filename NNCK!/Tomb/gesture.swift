//
//                    .gesture(
//                        DragGesture(minimumDistance: 0, coordinateSpace: .local)
//                            .onChanged { value in
//                                drag = value.translation
//                                hidePreviewHeader = true
//                            }
//                            .onEnded { value in
//                                if drag.height > 100 {
//                                    viewModel.showImageViewer = false
//                                }
//                                hidePreviewHeader = false
//                                drag = CGSize.zero
//                            }
//                    )
