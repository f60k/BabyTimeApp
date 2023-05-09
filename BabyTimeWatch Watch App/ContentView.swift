//
//  ContentView.swift
//  BabyTimeWatch Watch App
//
//  Created by Daisuke Yanagi on 2023/05/07.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var stopWatchManeger = StopWatchManeger()
    
    var body: some View {
        VStack {
                    Text(String(format:"%.1f",stopWatchManeger.secondsElapsed))
                        .font(.custom("Futura", size: 60))
                    
                    if stopWatchManeger.mode == .stop{
                        Button(action: {self.stopWatchManeger.start()}){
                        Text("スタート").font(.title)
                        }
                    }
                    
                    if stopWatchManeger.mode == .start{
                        Button(action: {self.stopWatchManeger.pause()}){
                            Text("停止").font(.title)
                        }
                        
                    }
                        
                    if stopWatchManeger.mode == .pause{
                        VStack{
                            Button(action: {self.stopWatchManeger.start()}){
                            Text("再スタート").font(.title)
                                   }
                            Button(action: {self.stopWatchManeger.stop()}){
                            Text("終了").font(.title)
                                   }
                        }
                    }
                }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

