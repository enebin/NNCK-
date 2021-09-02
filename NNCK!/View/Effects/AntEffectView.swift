//
//  AntEffectView.swift
//  NNCK!
//
//  Created by 이영빈 on 2021/09/02.
//

import SwiftUI

struct Airview: View {
    @ObservedObject var model = HuntingEffectModel(object: "🐞")
    
    @State var localTimer = Timer()
    
    var body: some View {
        VStack {
            ZStack {
                model.path.stroke(style: StrokeStyle(lineWidth: 0.0))
                model.aircraft
            }
            
            HStack{
                Button("Fly!", action: {
                    model.play()
                })
                .padding()
                
                Button(action: { self.model.stop() }) {
                    Text("stop")
                }
                .padding()
            }
            
        }
    }
    
    func playing() {
        self.model.play()
    }
}


struct Airview_Previews: PreviewProvider {
    static var previews: some View {
        Airview()
    }
}
