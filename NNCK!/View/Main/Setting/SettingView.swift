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
    @EnvironmentObject var storeManager: StoreManager
    
    @EnvironmentObject var viewModel: SettingViewModel

    var body: some View {
        let isPro = storeManager.isPurchased(0)

        VStack(spacing: 0) {
            // 헤더 부분
            Header
            
            SettingBody()
                .environmentObject(soundSettting)
                .environmentObject(cameraSetting)
                .environmentObject(storeManager)
                .environmentObject(viewModel)
            
            
            // 광~고
            if isPro == false {
                Banner()
            }
        }
    }
    
    var Header: some View {
        let isPro = storeManager.isPurchased(0)
        return ZStack {
            HStack {
                if isPro {
                    Full
                } else {
                    Free
                }
                Spacer()
            }
            .padding(.leading)
            
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
    }
    
    struct SettingBody: View {
        @EnvironmentObject var soundSettting: SoundViewModel
        @EnvironmentObject var cameraSetting: CameraViewModel
        @EnvironmentObject var storeManager: StoreManager
        
        @EnvironmentObject var viewModel: SettingViewModel
        
        var body: some View {
            Form {
                CamFuctions
                AniFunctions
                AniTypes
                //            SoundTypes
                CamBackground
                IAP
            }
        }
        
        var CamFuctions: some View {
            let isPro = storeManager.isPurchased(0)
            return Section(header: Text("카메라 기능")) {
                Toggle("무음 모드(셔터소리 X)",
                       isOn:.init(
                        get: { cameraSetting.isSilent },
                        set: { status in
                            cameraSetting.switchSilent()
                        }
                       ))
                
                if isPro {
                    Toggle("워터마크",
                           isOn:.init(
                            get: { cameraSetting.isWatermark },
                            set: { status in
                                cameraSetting.switchWatermark()
                            }
                           ))
                } else {
                    Button(action: { viewModel.showProAlert = true }) {
                        Toggle("워터마크",
                               isOn:.init(
                                get: { cameraSetting.isSilent },
                                set: { status in
                                    cameraSetting.switchSilent()
                                }
                               ))
                            .disabled(true)
                    }
                    .alert(isPresented: $viewModel.showProAlert) {
                        ProAlert
                    }
                }
            }
        }
        
        var AniFunctions: some View {
            let isPro = storeManager.isPurchased(0)
            
            return Section(header: Text("애니메이션 세부설정")) {
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
                            if cameraSetting.numOfEffect > 2 {
                                viewModel.showNumbersAlert = true
                            }
                        }
                        .padding(.leading)
                }
                .accentColor(.blue)
                .alert(isPresented: $viewModel.showNumbersAlert) {
                       Alert(title: Text("안내"),
                             message: Text("무료버전은 2개까지 지원합니다."),
                             dismissButton: .default(Text("OK"), action: {
                                cameraSetting.numOfEffect = 2
                             }))
                }
                
                // 속도 바
                VStack {
                    Text("\(cameraSetting.animationSpeed==10 ? 10/0 : cameraSetting.animationSpeed, specifier: "%.1f")")
                        .font(.system(size: 8))
                    
                    HStack {
                        Text("-")
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if cameraSetting.animationSpeed >= 1 {
                                    cameraSetting.animationSpeed -= 1
                                } else {
                                    cameraSetting.animationSpeed -= 0
                                }
                            }
                            .padding(.trailing)
                        
                        Spacer()
                        Slider(value: $cameraSetting.animationSpeed,
                               in: 0...10)
                            .accentColor(.pink)
                        Spacer()
                        
                        Text("+")
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if cameraSetting.animationSpeed <= 9 {
                                    cameraSetting.animationSpeed += 1
                                } else {
                                    cameraSetting.animationSpeed += 0
                                }
                            }
                            .padding(.leading)
                    }
                }

                // 모양
                // (PRO) 더 많은 모양
                ZStack {
                    if isPro {
                        NavigationLink(destination: Text("여러가지 모양")) {
                                                ZStack {
                                                    HStack {
                                                        Text("모양 변경하기")
                                                        Spacer()
                                                        Text("🔴")
                                                    }
                                                }
                                            }
                    } else {
                        Button(action: { viewModel.showProAlert = true }, label: {
                            HStack {
                                Text("모양 변경하기")
                                Spacer()
                                Text("🔴")
                            }
                        })
                        .opacity(0.5)
                        .alert(isPresented: $viewModel.showProAlert, content: {
                            ProAlert
                        })
                    }
                }
            }
        }
        
        var AniTypes: some View {
            let isPro = storeManager.isPurchased(0)
            
            return Section(header: Text("애니메이션 종류")) {
                ForEach(Effects.allCases, id: \.self) { effect in
                    let description = effect.rawValue
                    let shape = effect.getShape()
                    
                    if effect == .realistic && isPro == false {
                        Button(action: {viewModel.showProAlert = true}, label: {
                            HStack {
                                Text(description)
                                Spacer()
                                Text(shape)
                                    .padding(.trailing, 15)
                            }
                        })
                        .opacity(0.5)
                        .alert(isPresented: $viewModel.showProAlert, content: {
                            ProAlert
                        })
                    } else {
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
            let isPro = storeManager.isPurchased(0)
            
            return Section(header: Text("카메라 배경색")) {
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
//                
//                if isPro {
//                    NavigationLink(destination: Text("")) {
//                        HStack {
//                            Text("커스텀 컬러")
//                            Spacer()
//                            ColorPickerView()
//                        }
//                    }
//                } else {
//                    Button(action: {viewModel.showProAlert = true}) {
//                        HStack {
//                            Text("커스텀 컬러")
//                            Spacer()
//                            ColorPickerView()
//                                .disabled(true)
//                        }
//                    }
//                    .opacity(0.5)
//                    .alert(isPresented: $viewModel.showProAlert) {
//                        ProAlert
//                    }
//                }
            }

        }
        
        var IAP: some View {
            Section(header: Text("냥냥찰칵! 풀 패키지 구매")) {
                NavigationLink(
                    destination: IAPView(storeManager: storeManager)
                        .toolbar{ restore },
                    label: {
                        Text("바로가기")
                    })
            }
        }
        
        var restore: some View {
            HStack {
                Button("구매 복구", action: {storeManager.restoreProducts()})
                Button(action: { viewModel.showAlert = true }) {
                    Image(systemName: "questionmark.circle")
                }
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("구매복구?"),
                      message: Text("이전에 이미 결제했다면 '구매복구'를 눌러 내역을 복구합니다."))
            }
        }
        
        var ProAlert: Alert {
            Alert(title: Text("알림"), message: Text("유료버전에서만 가능한 기능입니다."),
                  dismissButton: .default(Text("OK")))
        }
    }
}

struct ColorPickerView: View {
    @State private var bgColor = Color.catmint
    
    var body: some View {
        ColorPicker("커스텀 컬러", selection: $bgColor)
            .foregroundColor(.black)
            .navigationBarHidden(true)
    }
}

public var Full: some View {
    Text("FULL")
        .font(.system(size: 10))
        .frame(width: 50, height: 25)
        .foregroundColor(.white)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.lightgreen))
}

public var Free: some View {
    Text("FREE")
        .font(.system(size: 10))
        .frame(width: 50, height: 25)
        .foregroundColor(.white)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray))
}

struct SoundSetting_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}

