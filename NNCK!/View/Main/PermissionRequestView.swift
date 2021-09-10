//
//  PermissionRequestView.swift
//  NNCK
//
//  Created by 이영빈 on 2021/08/18.
//

import SwiftUI

struct PermissionRequestView: View {
    @EnvironmentObject var viewModel: CameraViewModel
    
    let informationTitle = "권한 오류"
    let information = "어플리케이션의 원활한 사용을 위해 \n다음 권한들을 허용해주세요."
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8).ignoresSafeArea()
            VStack {
                Text(informationTitle)
                    .underline(color: Color.yellow)
                    .font(.title)
                    .fontWeight(.black)
                    .padding()
                Text(information)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .multilineTextAlignment(.center)
                    .padding()
                
                GroupBox {
                    HStack {
                        Text("카메라 권한")
                            .bold()
                        Spacer()
                        if viewModel.cameraAuth == .success {
                            Text("🟢")
                        } else {
                            Text("❌")
                        }
                    }
                    Divider()
                        .background(Color.gray)
                    HStack {
                        Text("저장 권한")
                            .bold()
                        Spacer()
                        if viewModel.albumAuth == .success {
                            Text("🟢")
                        } else {
                            Text("❌")
                        }
                    }
                    
                }
                .foregroundColor(.black)
                .padding(.horizontal, 50)

                Text("많지 않아요!")
                    .padding(.top, 30)
                    .foregroundColor(.black)
                Button(action: {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!) }, label: {
                    Text("👉 설정 👈")
                        .foregroundColor(.black)
                        .font(.subheadline)
                        .bold()
                        .padding()
                        .background(Capsule().fill(Color.white.opacity(0.8)))
                })
            }
            .foregroundColor(.white)
        }
    }
}

struct PermissionRequestView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionRequestView()
    }
}
