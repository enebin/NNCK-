                            
//                            .gesture( // Zoom에 관한 함수구문
//                                DragGesture().onChanged({ (val) in
//                                    //  Only accept vertical drag
//                                    if abs(val.translation.height) > abs(val.translation.width) {
//                                        //  Get the percentage of vertical screen space covered by drag
//                                        let percentage: CGFloat = -(val.translation.height / geometry.size.height)
//                                        //  Calculate new zoom factor
//                                        let calc = currentZoomFactor + percentage
//                                        //  Limit zoom factor to a maximum of 5x and a minimum of 1x
//                                        let zoomFactor: CGFloat = min(max(calc, 1), 5)
//                                        //  Store the newly calculated zoom factor
//                                        currentZoomFactor = zoomFactor
//                                        //  Sets the zoom factor to the capture device session
//                                        viewModel.zoom(with: zoomFactor)
//                                    }
//                                })
//                            )
