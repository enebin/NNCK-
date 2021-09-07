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
        VStack {
            let product = storeManager.myProducts[0]
            
            VStack(alignment: .center) {
                Text(product.localizedTitle)
                    .font(.headline)
                    .padding(5)
                Text(product.localizedDescription)
                    .font(.caption2)
            }
            .padding()
            Details
            Spacer()
            PriceInformation
            Spacer()
            PurchaseButton
            Spacer()
        }
    }
    
    var Details: some View {
        GroupBox {
            HStack {
                VStack(alignment: .leading) {
                    Text("개인 별로 커스텀 가능한 모양들")
                        .font(.headline)
                    Text("이것저것")
                        .font(.caption2)
                }
                Spacer()
                Text("🧶")
                    .font(.title)
            }
            .padding()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("개인 별로 커스텀 가능한 사운드")
                        .font(.headline)
                    Text("이것저것")
                        .font(.caption2)
                }
                Spacer()
                Text("🎺")
                    .font(.title)
            }
            .padding()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("개인 별로 커스텀 가능한 배경색")
                        .font(.headline)
                    Text("이것저것")
                        .font(.caption2)
                }
                Spacer()
                Text("🪣")
                    .font(.title)
            }
            .padding()
        }
        .padding(.horizontal, 30)
    }
    
    var PriceInformation: some View {
        let product = storeManager.myProducts[0]
        return Group {
            if UserDefaults.standard.bool(forKey: product.productIdentifier) {
                Text ("구매 완료")
                    .foregroundColor(.green)
            } else {
                Text("단돈 ￦\(product.price)")
                    .foregroundColor(.blue)
            }
        }
        
    }
    
    var PurchaseButton: some View {
        let product = storeManager.myProducts[0]
        return Group {
            if UserDefaults.standard.bool(forKey: product.productIdentifier) {
                Text("구매 완료..")
                    .padding()
                    .padding(.horizontal)
                    .foregroundColor(.white)
                    .background(Capsule().fill(Color.gray.opacity(0.5)))
            } else {
                Button(action: {
                    storeManager.purchaseProduct(product: product)
                }) {
                    Text("구매하기..!")
                        .padding()
                        .padding(.horizontal)
                        .foregroundColor(.white)
                        .background(Capsule().fill(Color.blue))
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
