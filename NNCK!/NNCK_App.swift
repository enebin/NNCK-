//
//  NNCK_App.swift
//  NNCK!
//
//  Created by 이영빈 on 2021/08/23.
// https://medium.com/@michaelbarneyjr/how-to-integrate-admob-ads-in-swiftui-fbfd3d774c50
// https://medium.com/geekculture/adding-google-mobile-ads-admob-to-your-swiftui-app-in-ios-14-5-5073a2b99cf9

import SwiftUI
import Firebase
import GoogleMobileAds

@main
struct NNCK_App: App {
    init() {
        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}




