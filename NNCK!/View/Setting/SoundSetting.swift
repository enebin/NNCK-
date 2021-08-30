//
//  SoundSetting.swift
//  NNCK!
//
//  Created by 이영빈 on 2021/08/30.
//

import SwiftUI

struct SoundSetting: View {
    
    var body: some View {
        List {
            Section(header: Text("사운드 슬롯")) {
                NavigationLink(
                    destination: Text("Destination"),
                    label: {
                        Text("Sound")
                    })
                    .foregroundColor(.black)
                Text("Sound")
                Text("Sound")
            }
            .foregroundColor(.black)

            
            Section(header: Text("사운드 슬롯")) {
                Text("Sound")
                Text("Sound")
                Text("Sound")
            }
            .listRowBackground(Color.black)

        }
        .listStyle(InsetGroupedListStyle())
        .background(Color.black)
    }
}

struct SoundSetting_Previews: PreviewProvider {
    static var previews: some View {
        SoundSetting()
    }
}
