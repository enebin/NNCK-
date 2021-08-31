//
//  SoundSetting.swift
//  NNCK!
//
//  Created by 이영빈 on 2021/08/30.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var soundSettting: SoundViewModel
    @EnvironmentObject var cameraSetting: CameraViewModel
    @EnvironmentObject var viewModel: SettingViewModel
    
    var body: some View {
        List {
            Section(header: Text("사운드")) {
                ForEach(0..<3) { index in
                    NavigationLink(
                        destination: Text("사운드 고르기"),
                        label: { Text("\(index+1). Sound") })
                }
            }
            
            Section(header: Text("카메라 배경색")) {
                ForEach(viewModel.colors.indices) { index in
                    let colorStruct = viewModel.colors[index]
                    ZStack {
                        HStack {
                            colorStruct.description
                                .foregroundColor(colorStruct.forgroundColor)
                            Spacer()
                        }

                        if viewModel.pickedColorIndex == index {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                                    .background(Circle().fill(Color.white))
                                    .padding(3)
                            }
                        }
                    }
                    .transition(.scale)
                    .listRowBackground(colorStruct.backgroundColor)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring()){
                            viewModel.pickedColorIndex = index
                            cameraSetting.backgroundColor = colorStruct.backgroundColor
                        }
                    }
                }
                
                ColorPicker("커스텀 칼-라", selection: $cameraSetting.backgroundColor)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .navigationBarHidden(true)
                    .listRowBackground(
                        LinearGradient(
                            gradient: .init(colors: [Color(red: 0.12, green: 0.08, blue: 0.22),
                                                     Color(red: 0.26, green: 0.2, blue: 0.44)]),
                            startPoint: .init(x: 0, y: 0),
                            endPoint: .init(x: 1, y: 0)
                        )
                        .opacity(0.7)
                    )
            }
        }
        .listStyle(SidebarListStyle())
        
    }
}

struct ColorPickerView: View {
    @State private var bgColor = Color.catmint
    
    var body: some View {
        ColorPicker("색상 설정", selection: $bgColor)
            .frame(width: 200, height: 200)
            .foregroundColor(.black)
            .padding(.horizontal, 30)
            .navigationBarHidden(true)
    }
}

struct SoundSetting_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
