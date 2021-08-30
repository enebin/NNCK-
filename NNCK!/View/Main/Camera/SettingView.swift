//
//  SettingView.swift
//  NNCK
//
//  Created by 이영빈 on 2021/08/18.
//

import SwiftUI

struct SettingView: View {
    let padding: CGFloat = 15
    
    var body: some View {
            HStack {
                NavigationLink(
                    destination: Text("Destination"),
                    label: {
                        VStack {
                            Image(systemName: "music.note.list")
                                .font(.system(size: 25))
                                .padding()
                            Text("사운드 설정")
                                .bold()
                        }.contentShape(Rectangle())
                    })
                    .navigationBarTitle("사운드 설정")
                    .padding(.horizontal, padding)
                
                Divider()
                    .background(Color.white)
                    .padding(.vertical, 5)
                
                NavigationLink(
                    destination: Text("Destination"),
                    label: {
                        VStack {
                            Image(systemName: "text.below.photo")
                                .font(.system(size: 25))
                                .padding()
                            Text("이미지 설정")
                                .bold()
                        }.contentShape(Rectangle())
                    })
                    .navigationBarTitle("이미지 설정")
                    .padding(.horizontal, 5)
                
                Divider()
                    .background(Color.white)
                    .padding(.vertical, padding)
                
                NavigationLink(
                    destination: Text("Destination"),
                    label: {
                        VStack {
                            Image(systemName: "gear")
                                .font(.system(size: 25))
                                .padding()
                            Text("개인 설정")
                                .bold()
                        }.contentShape(Rectangle())
                    })
                    .navigationBarTitle("개인 설정")
                    .padding(.horizontal, padding)
            }
            .foregroundColor(.white)
        
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
