//
//  SoundSetting.swift
//  NNCK!
//
//  Created by 이영빈 on 2021/08/30.
//

import SwiftUI

struct SettingView: View {
    
    var body: some View {
        List {
            Section(header: Text("커스텀 사운드")) {
                ForEach(0..<5) { index in
                    NavigationLink(
                        destination: Text("Destination"),
                        label: { Text("\(index+1). Sound") })
                }
            }
            
            Section(header: Text("카메라 배경색")) {
                Text("석탄 블랙")
                    .foregroundColor(.white)
                    .listRowBackground(Color.flatblack)
                Text("분필 화이트")
                    .foregroundColor(.black)
                    .listRowBackground(Color.white)
                Text("유치원 옐로우")
                    .foregroundColor(.black)
                    .listRowBackground(Color.yellow)
                Text("용달 블루")
                Text("쌈무 그린")
                Text("옥상 그린")
                Text("다라이 레드")
                Text("마미손 핑크")
                Text("기타 등등")



            }
        }
        .listStyle(SidebarListStyle())
    }
}

struct SoundSetting_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
