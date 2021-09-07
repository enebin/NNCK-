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
//            List(storeManager.myProducts, id: \.self) { product in
//                        HStack {
//                            VStack(alignment: .leading) {
//                                Text(product.localizedTitle)
//                                    .font(.headline)
//                                Text(product.localizedDescription)
//                                    .font(.caption2)
//                            }
//                            Spacer()
//                            if UserDefaults.standard.bool(forKey: product.productIdentifier) {
//                                Text ("Purchased")
//                                    .foregroundColor(.green)
//                            } else {
//                                Button(action: {
//                                    //Purchase particular ILO product
//                                }) {
//                                    Text("단돈 ￦\(product.price)")
//                                }
//                                    .foregroundColor(.blue)
//                            }
//                        }
//                    }
            let product = storeManager.myProducts[0]
            
            VStack(alignment: .center) {
                Text(product.localizedTitle)
                    .font(.headline)
                    .padding()
                Text(product.localizedDescription)
                    .font(.caption2)
            }
            .padding()
            
            if UserDefaults.standard.bool(forKey: product.productIdentifier) {
                Text ("구매 완료")
                    .foregroundColor(.green)
            } else {
                Text("단돈 ￦\(product.price)")
                    .foregroundColor(.blue)
            }
            Spacer()
            
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
            Spacer()
        }
        
    }
}

struct IAPView_Previews: PreviewProvider {
    static var previews: some View {
        IAPView(storeManager: StoreManager())
    }
}
