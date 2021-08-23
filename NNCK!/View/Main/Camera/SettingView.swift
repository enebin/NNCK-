//
//  SettingView.swift
//  NNCK
//
//  Created by 이영빈 on 2021/08/18.
//

import SwiftUI

struct SettingView: View {
    var body: some View {
            HStack {
                NavigationLink(
                    destination: Text("Destination"),
                    label: {
                        VStack {
                            Image(systemName: "music.note.list")
                                .font(.system(size: 35))
                                .padding()
                            Text("사운드 설정")
                                .bold()
                        }
                    })
                    .navigationBarTitle("사운드 설정")
                
                Divider()
                    .background(Color.white)
                    .padding()
                
                NavigationLink(
                    destination: Text("Destination"),
                    label: {
                        VStack {
                            Image(systemName: "text.below.photo")
                                .font(.system(size: 35))
                                .padding()
                            Text("이미지 설정")
                                .bold()
                        }
                    })
                    .navigationBarTitle("이미지 설정")
                
                Divider()
                    .background(Color.white)
                    .padding()
                
                NavigationLink(
                    destination: Text("Destination"),
                    label: {
                        VStack {
                            Image(systemName: "gear")
                                .font(.system(size: 35))
                                .padding()
                            Text("개인 설정")
                                .bold()
                        }
                    })
                    .navigationBarTitle("개인 설정")
            }
            .foregroundColor(.white)
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
