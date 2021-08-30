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
            
            Section(header: Text("사운드 슬롯")) {
                Text("Sound")
                Text("Sound")
                Text("Sound")
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

struct SoundSetting_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
