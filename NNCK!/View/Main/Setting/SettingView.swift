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
    
    // 헤더 정의
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
    
    // 바디
    struct SettingBody: View {
        @EnvironmentObject var soundSettting: SoundViewModel
        @EnvironmentObject var cameraSetting: CameraViewModel
        @EnvironmentObject var storeManager: StoreManager
        
        @EnvironmentObject var viewModel: SettingViewModel
        
        @Namespace var bottomID
        
        var body: some View {
            ScrollViewReader { proxy in
                Form {
                    CamFuctions
                    AniFunctions
                    AniTypes
                    SoundTypes
                    CamBackground
                    IAP
                }
            }
        }
        
        // 카메라 기능(토글)
        var CamFuctions: some View {
            let isPro = storeManager.isPurchased(0)
            return Section(header: Text("카메라 기능")) {
//                Toggle("무음 모드(셔터소리 X)",
//                       isOn:.init(
//                        get: { cameraSetting.isSilent },
//                        set: { status in
//                            cameraSetting.switchSilent()
//                        }
//                       ))
                
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
                    .opacity(0.5)
                    .alert(isPresented: $viewModel.showProAlert) {
                        ProAlert
                    }
                }
            }
        }
        
        // 애니메이션 세부설정. 속도, 개수 등
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
                    Text("\(cameraSetting.numOfEffect)개")
                    
                    Spacer()
                    Text("+")
                        .contentShape(Rectangle())
                        .onTapGesture {
                            cameraSetting.increaseEffectNo()
                            if cameraSetting.numOfEffect > 4 && isPro == false {
                                viewModel.showNumbersAlert = true
                            }
                        }
                        .padding(.leading)
                }
                .accentColor(.blue)
                .alert(isPresented: $viewModel.showNumbersAlert) {
                       Alert(title: Text("안내"),
                             message: Text("무료버전은 4개까지 지원합니다."),
                             dismissButton: .default(Text("OK"), action: {
                                cameraSetting.numOfEffect = 4
                             }))
                }
                
                // 크기
                HStack {
                    Text("-")
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if cameraSetting.sizeOfEffect >= 2 {
                                cameraSetting.sizeOfEffect -= 2
                            } else {
                                cameraSetting.sizeOfEffect = 0
                            }
                        }
                        .padding(.trailing)

                    Spacer()
                    Text("\(Int(cameraSetting.sizeOfEffect/2)) 사이즈")
                    
                    Spacer()
                    Text("+")
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if cameraSetting.sizeOfEffect < 70 {
                                cameraSetting.sizeOfEffect += 2
                            } else {
                                cameraSetting.sizeOfEffect = 70
                            }
                        }
                        .padding(.leading)
                }
                .accentColor(.blue)
                
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
                                    cameraSetting.animationSpeed = 0
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
                                if cameraSetting.animationSpeed < 9 {
                                    cameraSetting.animationSpeed += 1
                                } else {
                                    cameraSetting.animationSpeed = 10
                                }
                            }
                            .padding(.leading)
                    }
                }

                // 더 많은 모양
                ZStack {
                    if isPro {
                        NavigationLink(destination: MoreObjectsView().environmentObject(cameraSetting)) {
                                                ZStack {
                                                    HStack {
                                                        Text("모양 변경하기")
                                                        Spacer()
                                                        Text(cameraSetting.effectObject ?? "🔴")
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
        
        // 애니메이션 행동 종류
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
        
        // 사운드 효과 종류
        var SoundTypes: some View {
            return Section(header: Text("사운드"), footer: Text("⚠️ 과도한 이용은 고양이를 지치게 할 수 있음!")) {
                ForEach(soundSettting.sounds.indices, id: \.self) { index in
                    let thisSound = soundSettting.sounds[index]
                    let name = thisSound.name
                    let description = thisSound.description
                    
                    ZStack {
                        HStack {
                            Text(name)
                            Image(systemName: "info.circle").padding(.trailing)
                                .foregroundColor(.gray)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    viewModel.showSoundInfo[index] = true
                                }
                                .alert(isPresented: $viewModel.showSoundInfo[index]) {
                                    Alert(title: Text("안내"),
                                          message: Text(description),
                                          dismissButton: .default(Text("OK")))
                                }
                            Spacer()
//                            Image(systemName: "\(index + 1).circle.fill")
//                                .padding(.trailing, 15)
                        }
                        
                        if viewModel.pickedSoundIndex == index {
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
                            viewModel.pickedSoundIndex = index
                            soundSettting.chooseSound(of: index)
                            soundSettting.stopSound()
                        }
                    }
                }
            }
        }
        
        var CamBackground: some View {
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
            .id(bottomID)
        }
        
        var restore: some View {
            HStack {
                Button("구매 복구", action: { storeManager.restoreProducts() })
                
                Button(action: { viewModel.showAlert = true }) {
                    Image(systemName: "questionmark.circle")
                }
                .alert(isPresented: $viewModel.showAlert) {
                    Alert(title: Text("구매복구?"),
                          message: Text("이전에 이미 결제했다면 '구매복구'를 눌러 내역을 복구합니다."))
                }
            }
        }
        
        var ProAlert: Alert {
            Alert(title: Text("알림"), message: Text("Full 버전에서만 가능한 기능입니다."),
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

