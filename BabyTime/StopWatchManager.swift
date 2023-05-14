//
//  StopWatchManager.swift
//  BabyTime
//
//  Created by Daisuke Yanagi on 2023/05/07.
//

import UIKit
import HealthKit


enum LogDataPhase
{
    case start
    case finish
}

enum SleepCategory:Int
{
    case hirune = 1
    case yorune = 2
    case sonota = 3
}

struct LogData:Identifiable
{
    var id = UUID()
    var data:Date
    var phase:LogDataPhase
}

struct DurationData:Identifiable
{
    var id = UUID()
    var data:Double
    var start:Date
    var end:Date
    var caption:String = ""
    var category:SleepCategory = .hirune
}

class StopWatchManeger:ObservableObject{
    
    enum stopWatchMode{
        case start
        case stop
        case pause
    }
    
    
    @Published var mode:stopWatchMode = .stop
    @Published var secondsElapsed = 0.0
    @Published var log:[LogData] = []
    @Published var durationLog:[DurationData] = []
    
    let ud = UserDefaults.standard
    
    
    var timer:Timer!
    
    func durationDataByID(id:UUID)->DurationData?
    {
        for (data) in durationLog
        {
            if data.id == id
            {
                return data
            }
        }
        return nil
    }
    
    func editCaption(id:UUID, text:String)
    {
        var targetIndex:Int?
        
        for (index, data) in durationLog.enumerated()
        {
            if data.id == id
            {
                //                data.caption = text
                //                durationLog[0].caption = text
                targetIndex = index
                //                print(index)
            }
        }
        
        if let i = targetIndex
        {
            durationLog[i].caption = text
        }
    }
    
    func editSleepCategory(id:UUID, cat:SleepCategory)
    {
        var targetIndex:Int?
        
        for (index, data) in durationLog.enumerated()
        {
            if data.id == id
            {
                //                data.caption = text
                //                durationLog[0].caption = text
                targetIndex = index
                //                print(index)
            }
        }
        
        if let i = targetIndex
        {
            durationLog[i].category = cat
            print(durationLog[i])
        }
    }
    
    func resetLog()
    {
        log = []
        durationLog = []
    }
    
    func start(){
        mode = .start
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true){ timer in
            
            self.secondsElapsed += 0.1
        }
        log.append(LogData(data:Date(), phase:LogDataPhase.start))
    }
    
    private func appendDurationLog()
    {
        let calender = Calendar(identifier: .gregorian)
        let lastLog = log[log.count - 1]
        if lastLog.phase == LogDataPhase.start
        {
            let lastDate = lastLog.data
            let elapsedTime = calender.dateComponents([.second], from: lastDate, to: Date()).second!
            let dLog = DurationData(data: Double(elapsedTime), start: lastDate, end:Date())
            durationLog.append(dLog)
        }
    }
    
    func stop(){
        if let _ = timer
        {
            timer.invalidate()
        }
        
        secondsElapsed = 0
        mode = .stop
        
        appendDurationLog()
        
        log.append(LogData(data:Date(), phase:LogDataPhase.finish))
    }
    
    
    
    
    func lap(){
        
        appendDurationLog()
        
        log.append(LogData(data:Date(), phase:LogDataPhase.finish))
        
        log.append(LogData(data:Date(), phase:LogDataPhase.start))
    }
    
    
    
    func save()
    {
        let myHealthStore = HKHealthStore()
        
        self.durationLog.forEach{log in

            let sleepSampleType = HKCategoryType(.sleepAnalysis)
            let sleepCategory = log.category == SleepCategory.sonota ? HKCategoryValueSleepAnalysis.awake.rawValue : HKCategoryValueSleepAnalysis.asleepDeep.rawValue
//            print(sleepCategory.description)
            let deepSleepSample  = HKCategorySample(type: sleepSampleType,
                                                    value:sleepCategory,
                                                    start: log.start,
                                                    end: log.end)
            myHealthStore.save(deepSleepSample){
                success, error in
                if success
                {
                    print("Save:Success")
                }else{
                    print("Save:Failure")
                }
            }
        }
    }
    
    
    
    func pause(){
        if let _ = timer
        {
            timer.invalidate()
        }
        mode = .pause
    }
    
    func systemSuspended()
    {
        if mode == .start{
            ud.set(Date(), forKey: "date1")
        }
        else
        {
            ud.removeObject(forKey: "date1")
        }
        //        mode = .pause
    }
    
    func systemResumed()
    {
        
        
        //        mode = .start
        
        guard let date1 = ud.value(forKey: "date1") else
        {
            return
        }
        
        let calender = Calendar(identifier: .gregorian)
        let date2 = Date()
        let elapsedTime = calender.dateComponents([.second], from: date1 as! Date, to: date2).second!
        self.secondsElapsed += Double(elapsedTime)
        
        
        ud.removeObject(forKey: "date1")
        
    }
}
