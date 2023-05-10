//
//  ContentView.swift
//  BabyTime
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
        print(caption)
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
                    .font(.custom("Futura", size: 54))
                
                
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
                        Text("開始").font(.title)
                    }
                }
                
                if stopWatchManeger.mode == .start{
                    HStack {
                        Spacer()
                        Button(action: {self.stopWatchManeger.lap()}){
                            Text("ラップ").font(.title)
                        }
                        Spacer()
                        Button(action: {self.stopWatchManeger.stop()}){
                            Text("終了").font(.title)
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
            }.toolbar
            {
                ToolbarItem(placement: .navigationBarTrailing){
                    Button(action: {
                        //
                        isAlertShown=true
                    }) {
                        Image(systemName: "trash").disabled(stopWatchManeger.mode != .stop)
                    }
                }
            }
        }
        
        .alert(isPresented: $isAlertShown)
        {
            Alert(title: Text("計測履歴の削除"),
                  message: Text("計測履歴が完全に削除されます。"),
                  primaryButton: .cancel(Text("キャンセル"),action: {
                isAlertShown=false
                
            }),    // キャンセル用
                  secondaryButton: .destructive(Text("削除"),action: {
                isAlertShown=false
                stopWatchManeger.resetLog()
            }))   // 破壊的変更用
        }
        
        .sheet(isPresented: $isSheetShown)
        {
            
            EditorView(text:getCaptionByID(id: uuid), isShown: $isSheetShown,uuid:$uuid, manager:stopWatchManeger)
        }.edgesIgnoringSafeArea(.all)
    }
}

struct EditorView:View
{
    
    @State var text:String = ""
    
    @Binding var isShown:Bool
    @Binding var uuid:UUID
    
    @ObservedObject var manager:StopWatchManeger
    
    
    func dataByID(id:UUID)->String
    {
        var result = ""
        
        if let data = manager.durationDataByID(id: id)
        {
            result = data.data.description
        }
        return result
    }
    
    
    
    var body: some View
    {
        Text(dataByID(id:uuid) + "秒")
            .font(.custom("Futura", size: 40))
        
        
        TextField("", text: $text, prompt: Text("タイトル"))
            .textFieldStyle(.roundedBorder)
            .padding()
            .onSubmit {
                
                isShown.toggle()
                manager.editCaption(id: uuid, text: text)
            }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


