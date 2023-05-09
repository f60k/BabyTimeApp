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
    
    var body: some View {
        
        
        
        VStack {
            Spacer()
                .padding(.top)
            Text(String(format:"%.1f",self.stopWatchManeger.secondsElapsed))
                .font(.custom("Futura", size: 60))
            
            
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
                Button(action: {self.stopWatchManeger.stop()}){
                    Text("終了").font(.title)
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
                            Text(log.data + "秒")
                                .multilineTextAlignment(.trailing)
                        }
                        
                    }
                }
            }
            
            
            
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
            result = data.data
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


