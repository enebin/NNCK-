//
//  IAPView.swift
//  NNCK!
//
//  Created by 이영빈 on 2021/09/07.
//

import SwiftUI

struct IAPView: View {
    @StateObject var storeManager: StoreManager
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                let product = storeManager.myProducts[0]
                
                VStack(alignment: .center) {
                    Text("무한으로 즐겨요")
                        .font(.largeTitle)
                        .bold()
                    HStack {
                        Text("냥냥찰칵! " + product.localizedTitle)
                            .font(.headline)
                        Full
                    }
                    .padding(.top, 5)
                    
                    Text(product.localizedDescription)
                        .font(.caption2)
                }
                .padding()
                Details
                Spacer()
                PurchaseButton
                    .padding()
                Spacer()
            }
        }
    }
    
    var Details: some View {
        GroupBox {
            HStack {
                VStack(alignment: .leading) {
                    Text("더 다양한 재미")
                        .font(.headline)
                    Text("+35종의 설정 가능한 모양들")
                        .font(.caption2)
                }
                Spacer()
                Text("🧶")
                    .font(.title)
            }
            .padding()
            
            Divider()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("더 주의를 끄는 사운드")
                        .font(.headline)
                    Text("+5종의 엄선된 사운드들")
                        .font(.caption2)
                }
                Spacer()
                Text("🎺")
                    .font(.title)
            }
            .padding()
            
//            Divider()
//            HStack {
//                VStack(alignment: .leading) {
//                    Text("더 편안한 배경")
//                        .font(.headline)
//                    Text("취향껏 자유롭게 커스텀 가능한 배경색")
//                        .font(.caption2)
//                }
//                Spacer()
//                Text("🪣")
//                    .font(.title)
//            }
//            .padding()
            
            Divider()
            HStack {
                VStack(alignment: .leading) {
                    Text("워터마크 온오프 & 광고 제거")
                        .font(.headline)
                    Text("보기 싫은 곁다리들. 치워버리세요.")
                        .font(.caption2)
                }
                Spacer()
                Text("🚫")
                    .font(.title)
            }
            .padding()
        }
        .padding(.horizontal, 30)
    }
    
    var PurchaseButton: some View {
        let product = storeManager.myProducts[0]
        return Group {
            if storeManager.isPurchased(0) {
                Text("구매 완료")
                    .frame(width: 150, height: 50)
                    .foregroundColor(.white)
                    .background(Capsule().fill(Color.gray.opacity(0.5)))
                    .onAppear {
                        print(UserDefaults.standard.bool(forKey: product.productIdentifier))
                    }
            } else {
                if storeManager.transactionState == .purchasing {
                    ProgressView().progressViewStyle(CircularProgressViewStyle())
                        .frame(width: 100, height: 50)
                } else {
                    Button(action: {
                        storeManager.purchaseProduct(product: product)
                    }) {
                        Text("￦\(Int(truncating: product.price).withCommas())에 구매")
                            .frame(width: 150, height: 50)
                            .foregroundColor(.white)
                            .background(Capsule().fill(Color.blue))
                    }
                }
            }
            
        }
    }
}

struct IAPView_Previews: PreviewProvider {
    static var previews: some View {
        IAPView(storeManager: StoreManager())
    }
}
