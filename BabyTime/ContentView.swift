//
//  ContentView.swift
//  BabyTime
//
//  Created by Daisuke Yanagi on 2023/05/07.
//

import SwiftUI
import HealthKit
import HealthKitUI

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
    
    func getCategoryByID(id:UUID)->SleepCategory
    {
        var cat = BabyTime.SleepCategory.hirune
        if let data = stopWatchManeger.durationDataByID(id: uuid)
        {
            cat = data.category
        }
        return cat
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
    
    func formatLogCategory(cat:SleepCategory)->String
    {
        let str:String
        if cat == BabyTime.SleepCategory.hirune
        {
            str = "昼寝"
        }
        else if cat == BabyTime.SleepCategory.yorune
        {
            str = "夜寝"
        }
        else
        {
            str = "覚醒"
        }
        return str
    }
    
    func uploadHealth()
    {
        if HKHealthStore.isHealthDataAvailable()
        {
            let myHealthStore = HKHealthStore()
            let typeOfWrite = Set(arrayLiteral: HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
            )
            myHealthStore.requestAuthorization(toShare: typeOfWrite, read: nil, completion: {
                (success, error) in
                if let e = error
                {
                    print("Error:\(e.localizedDescription)")
                    return
                }
                print(success ? "Success" : "Failure")
                
                stopWatchManeger.upload()

            })
        }
    }
    
    func downloadHealth()
    {
        if HKHealthStore.isHealthDataAvailable()
        {
            let myHealthStore = HKHealthStore()
            let typeOfRead = Set(arrayLiteral: HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
            )
            myHealthStore.requestAuthorization(toShare: nil, read: typeOfRead, completion: {
                (success, error) in
                if let e = error
                {
                    print("Error:\(e.localizedDescription)")
                    return
                }
                print(success ? "Success" : "Failure")
                
                stopWatchManeger.download()

            })
        }
    }
    
    var body: some View {
        
        NavigationStack
        {
            VStack {
                Spacer()
                    .padding(.top)
                Text(formatSec(sec:self.stopWatchManeger.secondsElapsed))
                    .font(.custom("Futura", size: 54))
                Text(formatSec(sec:self.stopWatchManeger.getCurrentDuration()))
                    .font(.custom("Futura", size: 24))
                Spacer()
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

                List
                {
                    ForEach(stopWatchManeger.durationLog.reversed()){log in

                        Button(action: {
                            isSheetShown.toggle()
                            uuid = log.id

                        }){
                            HStack {
                                Text(log.caption)
                                
                                Text("" + formatLogCategory(cat:log.category) + "")
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
                
                ToolbarItem(placement: .navigationBarLeading){
                    Button(action: {
                        uploadHealth()
                    }) {
                        Image(systemName: "arrow.up.heart")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading){
                    Button(action: {
                        downloadHealth()
                    }) {
                        Image(systemName: "arrow.down.heart")
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
            
            EditorView(text:getCaptionByID(id: uuid), category:getCategoryByID(id: uuid).rawValue, isShown: $isSheetShown,uuid:$uuid, manager:stopWatchManeger)
        }.edgesIgnoringSafeArea(.all)
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


