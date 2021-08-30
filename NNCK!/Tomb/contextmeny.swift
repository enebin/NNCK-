            
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
                
