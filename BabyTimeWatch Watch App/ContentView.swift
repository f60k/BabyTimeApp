//
//  ContentView.swift
//  BabyTimeWatch Watch App
//
//  Created by Daisuke Yanagi on 2023/05/07.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var stopWatchManeger = StopWatchManeger()
    @Environment(\.scenePhase) private var scenePhase
    
    @State var isSheetShown = false
    @State var isAlertShown = false
    
    @State var uuid:UUID = UUID()
    
    
    func getCaptionByID(id:UUID)->String
    {
        var caption = ""
        if let data = stopWatchManeger.durationDataByID(id: uuid)
        {
            caption = data.caption
        }
//        print(caption)
        return caption
    }
    
    func formatSec(sec:Double)->String
    {
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.unitsStyle = .abbreviated
        dateFormatter.allowedUnits = [.hour, .minute, .second]
        //        dateFormatter.zeroFormattingBehavior = .pad
        
        var calender = Calendar.current
        calender.locale = Locale(identifier: "ja_JP")
        dateFormatter.calendar = calender
        
        return dateFormatter.string(from: sec)!
    }
    
    var body: some View {
        
        NavigationStack
        {
            VStack {
                Spacer()
                    .padding(.top)
                Text(formatSec(sec:self.stopWatchManeger.secondsElapsed))
                    .font(.custom("Futura", size: 28))
                
                
                    .onChange(of:scenePhase){phase in
                        switch phase {
                        case .active:
                            print("active")
                            self.stopWatchManeger.systemResumed()
                        case .inactive:
                            print("inactive")
                        case .background:
                            print("background")
                            self.stopWatchManeger.systemSuspended()
                        @unknown default:
                            print("@unknown")
                        }
                    }
                
                if stopWatchManeger.mode == .stop{
                    Button(action: {self.stopWatchManeger.start()}){
                        Text("開始").font(.headline)
                    }
                }
                
                if stopWatchManeger.mode == .start{
                    HStack {
                        Spacer()
                        Button(action: {self.stopWatchManeger.lap()}){
                            Text("ラップ").font(.headline)
                        }
                        Spacer()
                        Button(action: {self.stopWatchManeger.stop()}){
                            Text("終了").font(.headline)
                        }
                        Spacer()
                    }
                }
                
                //            if stopWatchManeger.mode == .pause{
                //                VStack{
                //                    Button(action: {self.stopWatchManeger.start()}){
                //                        Text("再開").font(.title)
                //                    }
                //
                //                    Button(action: {self.stopWatchManeger.stop()}){
                //                        Text("終了").font(.title)
                //                    }
                //                }
                //            }
                
                List
                {
                    ForEach(stopWatchManeger.durationLog.reversed()){log in
                        
                        
                        
                        
                        Button(action: {
                            isSheetShown.toggle()
                            uuid = log.id
                            //                        print(log.id)
                            //                        stopWatchManeger.editCaption(id: log.id, text: "aaaa")
                            //                        stopWatchManeger.durationLog[0].caption = "aaaa"
                            
                            
                        }){
                            HStack {
                                Text(log.caption)
                                Spacer()
                                Text(formatSec(sec:log.data))
                                    .multilineTextAlignment(.trailing)
                            }
                        }
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

