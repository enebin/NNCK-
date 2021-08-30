//
//  FirstLaunch.swift
//  NNCK!
//
//  Created by 이영빈 on 2021/08/30.
//

import SwiftUI

final class FirstLaunch {
    let wasLaunchedBefore: Bool
    var isFirstLaunch: Bool { return !wasLaunchedBefore }
    
    init(getWasLaunchedBefore: () -> Bool, setWasLaunchedBefore: (Bool) -> ()) {
        let wasLaunchedBefore = getWasLaunchedBefore()
        self.wasLaunchedBefore = wasLaunchedBefore
        if !wasLaunchedBefore { setWasLaunchedBefore(true) }
    }
    
    convenience init(userDefaults: UserDefaults, key: String) {
        self.init(getWasLaunchedBefore: { userDefaults.bool(forKey: key) },
                  setWasLaunchedBefore: { userDefaults.set($0, forKey: key) })
    }
}

extension FirstLaunch {
    static func alwaysFirst() -> FirstLaunch {
        return FirstLaunch(getWasLaunchedBefore: { return false }, setWasLaunchedBefore: { _ in })
    }
}

struct FirstView: View {
    var body: some View {
        TabView {
//            TutorialView(emoji: "🎫", title: "")

        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .interactive))
    }
    
    struct TutorialView: View {
        let emoji: String
        let title: String
        let text: String
        
        var body: some View {
            VStack {
                Text(emoji).font(.system(size: 60))
                Text(text).font(.system(size: 30))
                Text(text).font(.system(size: 30))

            }
        }
    }
}

struct FirstView_Previews: PreviewProvider {
    static var previews: some View {
        FirstView()
    }
}
