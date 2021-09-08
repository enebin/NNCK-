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
    @EnvironmentObject var storeManager: StoreManager
    
    var body: some View {
        VStack(spacing: 0) {
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
            .padding(.vertical)
            
            // 세팅 바디 부분
            settingBody
            
            // 광~고
            Banner()
        }
    }
    
    var CamFuctions: some View {
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
    }

    var settingBody: some View {
        Form {
            CamFuctions
            AniFunctions
            AniTypes
//            SoundTypes
            CamBackground
            IAP
        }
    }
    
    var AniFunctions: some View {
        Section(header: Text("애니메이션 세부설정")) {
            // 개수
            HStack {
                Text("-")
                    .contentShape(Rectangle())
                    .onTapGesture {
                        cameraSetting.decreaseEffectNo()
                    }
                    .padding(.trailing)

                Spacer()
                Text("\(cameraSetting.numOfEffect)")
                
                Spacer()
                Text("+")
                    .contentShape(Rectangle())
                    .onTapGesture {
                        cameraSetting.increaseEffectNo()
                    }
                    .padding(.leading)
            }
            .accentColor(.blue)
            
            // 속도 바
            VStack{
                Text("\(cameraSetting.animationSpeed==10 ? 10/0 : cameraSetting.animationSpeed, specifier: "%.1f")")
                    .font(.system(size: 8))
                
                HStack {
                    Text("-")
                        .padding(.trailing)
                    Slider(value: $cameraSetting.animationSpeed,
                           in: 0...10)
                        .accentColor(.pink)
                    Text("+")
                        .padding(.leading)
                }
            }

            // 모양
            // (PRO) 더 많은 모양
            NavigationLink(destination: Text("여러가지 모양")) {
                HStack {
                    Text("모양 변경하기")
                    Spacer()
                    Text("🔴")
                }
            }
        }

    }
    
    var AniTypes: some View {
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

    }
    
    var SoundTypes: some View {
            Section(header: Text("사운드")) {
                ForEach(0..<3) { index in
                    NavigationLink(
                        destination: Text("사운드 고르기"),
                        label: { Text("\(index+1). Sound") })
                }
            }
    }
    
    var CamBackground: some View {
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
    
    var IAP: some View {
        Section(header: Text("냥냥찰칵! 풀 패키지 구매")) {
            NavigationLink(
                destination: IAPView(storeManager: storeManager),
                label: {
                    Text("바로가기")
                })
        }
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
