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
        VStack {
            // 헤더 부분
            ZStack {
                HStack {
                    Spacer()
                    Text("설정").bold()
                    Spacer()
                }
                HStack {
                    Spacer()
                    Text("완료").foregroundColor(.blue)
                        .padding(.horizontal)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            cameraSetting.showSetting = false
                        }
                }
            }
            .padding(.top)
            
            // 세팅 바디 부분
            settingBody
        }
    }
    
    var settingBody: some View {
        List {
            Section(header: Text("카메라 기능")) {
                Toggle("무음 모드(셔터소리 X)",
                       isOn:.init(
                        get: { cameraSetting.isSilent },
                        set: { status in
                            cameraSetting.switchSilent()
                            print("changed")
                        }
                       ))
            }
            
            Section(header: Text("애니메이션 개수")) {
                HStack {
                    Text("-")
                        .foregroundColor(.blue)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            cameraSetting.numOfEffect -= 1
                        }
                    Spacer()
                    Text("\(cameraSetting.numOfEffect)")
                    Spacer()
                    Text("+")
                        .foregroundColor(.blue)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            cameraSetting.numOfEffect += 1
                        }
                }
            }
            
            Section(header: Text("애니메이션 종류")) {
                ForEach(Effects.allCases, id: \.self) { effect in
                    let description = effect.rawValue
                    let shape = effect.getShape()
                    
                    ZStack {
                        HStack {
                            Text(description)
                            Spacer()
                            Text(shape)
                                .padding(.trailing, 15)
                        }
                        
                        if viewModel.pickedAnimationIndex == effect {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                                    .background(Circle().fill(Color.white))
                                    .padding(3)
                                    .transition(.scale)
                            }
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring()){
                            viewModel.pickedAnimationIndex = effect
                            cameraSetting.effectType = effect
                        }
                    }
                    
                }
            }
            
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
                                    .transition(.scale)
                            }
                        }
                    }
                    .listRowBackground(colorStruct.backgroundColor)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring()){
                            viewModel.pickedColorIndex = index
                            cameraSetting.backgroundColor = colorStruct.backgroundColor
                        }
                    }
                }
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
