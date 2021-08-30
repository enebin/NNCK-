//
//  ContentView.swift
//  NNCK!
//
//  Created by 이영빈 on 2021/08/23.
//

import SwiftUI

struct ContentView: View {
    let alwaysFirstLaunch = FirstLaunch.alwaysFirst()
    
    var body: some View {
        if alwaysFirstLaunch.isFirstLaunch { // will always execute
            
        } else {
            CameraView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
