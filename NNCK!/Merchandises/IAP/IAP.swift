//
//  IAP.swift
//  NNCK!
//
//  Created by 이영빈 on 2021/09/07.
//

import Foundation
import StoreKit

class StoreManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    @Published var myProducts = [SKProduct]()
    @Published var transactionState: SKPaymentTransactionState?

    var request: SKProductsRequest!
    
    func showReview() {
        if let windowScene = UIApplication.shared.windows.first?.windowScene { SKStoreReviewController.requestReview(in: windowScene) }
    }
    
    func isPurchased(_ index: Int) -> Bool{
        if self.myProducts == [] {
            return false
        } else {
            return UserDefaults.standard.bool(forKey: self.myProducts[index].productIdentifier)
        }
    }
    
    func getProducts(productIDs: [String]) {
        print("Start requesting products ...")
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        request.delegate = self
        request.start()
        print("Done with requesting products. Result: \(self.myProducts)")
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Did receive response")
        
        if !response.products.isEmpty {
            for fetchedProduct in response.products {
                DispatchQueue.main.async {
                    self.myProducts.append(fetchedProduct)
                }
            }
        }
        
        for invalidIdentifier in response.invalidProductIdentifiers {
            print("Invalid identifiers found: \(invalidIdentifier)")
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                transactionState = .purchasing
            case .purchased:
                UserDefaults.standard.setValue(true, forKey: transaction.payment.productIdentifier)
                queue.finishTransaction(transaction)
                transactionState = .purchased
            case .restored:
                UserDefaults.standard.setValue(true, forKey: transaction.payment.productIdentifier)
                queue.finishTransaction(transaction)
                transactionState = .restored
            case .failed, .deferred:
                print("Payment Queue Error: \(String(describing: transaction.error))")
                queue.finishTransaction(transaction)
                transactionState = .failed
            default:
                queue.finishTransaction(transaction)
            }
        }
    }
    
    func purchaseProduct(product: SKProduct) {
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        } else {
            print("User can't make payment.")
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Request did fail: \(error)")
    }
    
    func restoreProducts() {
        print("Restoring products ...")
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}
//
//extension StoreManager: SKProductsRequestDelegate {
//    
//    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
//        print("Loaded list of products...")
//        let products = response.products
//        productsRequestCompletionHandler?(true, products)
//        clearRequestAndHandler()
//        
//        for p in products {
//            print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
//        }
//    }
//    
//    public func request(_ request: SKRequest, didFailWithError error: Error) {
//        print("Failed to load list of products.")
//        print("Error: \(error.localizedDescription)")
//        productsRequestCompletionHandler?(false, nil)
//        clearRequestAndHandler()
//    }
//    
//    private func clearRequestAndHandler() {
//        productsRequest = nil
//        productsRequestCompletionHandler = nil
//    }
//}
