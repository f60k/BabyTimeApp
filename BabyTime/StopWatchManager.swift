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



class Time: Comparable, Equatable {
init(_ date: Date) {
    //get the current calender
    let calendar = Calendar.current

    //get just the minute and the hour of the day passed to it
    let dateComponents = calendar.dateComponents([.hour, .minute], from: date)

        //calculate the seconds since the beggining of the day for comparisions
        let dateSeconds = dateComponents.hour! * 3600 + dateComponents.minute! * 60

        //set the varibles
        secondsSinceBeginningOfDay = dateSeconds
        hour = dateComponents.hour!
        minute = dateComponents.minute!
    }

    init(_ hour: Int, _ minute: Int) {
        //calculate the seconds since the beggining of the day for comparisions
        let dateSeconds = hour * 3600 + minute * 60

        //set the varibles
        secondsSinceBeginningOfDay = dateSeconds
        self.hour = hour
        self.minute = minute
    }

    var hour : Int
    var minute: Int

    var date: Date {
        //get the current calender
        let calendar = Calendar.current

        //create a new date components.
        var dateComponents = DateComponents()

        dateComponents.hour = hour
        dateComponents.minute = minute

        return calendar.date(byAdding: dateComponents, to: Date())!
    }

    /// the number or seconds since the beggining of the day, this is used for comparisions
    private let secondsSinceBeginningOfDay: Int

    //comparisions so you can compare times
    static func == (lhs: Time, rhs: Time) -> Bool {
        return lhs.secondsSinceBeginningOfDay == rhs.secondsSinceBeginningOfDay
    }

    static func < (lhs: Time, rhs: Time) -> Bool {
        return lhs.secondsSinceBeginningOfDay < rhs.secondsSinceBeginningOfDay
    }

    static func <= (lhs: Time, rhs: Time) -> Bool {
        return lhs.secondsSinceBeginningOfDay <= rhs.secondsSinceBeginningOfDay
    }


    static func >= (lhs: Time, rhs: Time) -> Bool {
        return lhs.secondsSinceBeginningOfDay >= rhs.secondsSinceBeginningOfDay
    }


    static func > (lhs: Time, rhs: Time) -> Bool {
        return lhs.secondsSinceBeginningOfDay > rhs.secondsSinceBeginningOfDay
    }
}

extension Date {
    var time: Time {
        return Time(self)
    }
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
    
    private func appendDurationLog(start:Date, end:Date)
    {
        let calender = Calendar(identifier: .gregorian)
        let elapsedTime = calender.dateComponents([.second], from: start, to: end).second!
//        self.durationLog.forEach{ item in
////            if Calendar.current.isDate(item.start, equalTo: start, toGranularity: .nanosecond)
////            {
////                if Calendar.current.isDate(item.end, equalTo: end, toGranularity: .nanosecond)
////                {
////                    print("SKIP")
////                    return
////                }
////            }
//            if item.start.time == start.time && item.end.time == end.time
//            {
//
//            }
//        }
        var skip = false
        
        for item in self.durationLog
        {
            if item.start.time == start.time && item.end.time == end.time
            {
                skip = true
                break
            }
        }
        
        if !skip
        {
            let dLog = DurationData(data: Double(elapsedTime), start: start, end:end)
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
    
    
    
    func upload()
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
    
    func download()
    {
        let myHealthStore = HKHealthStore()
        let sleepSampleType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!
        
        let endDate = NSSortDescriptor(key: HKSampleSortIdentifierEndDate,
                                       ascending: false)
        let q = HKSampleQuery(sampleType: sleepSampleType,
                              predicate: nil,
                              limit: 0,
                              sortDescriptors: [endDate]) {
            (query, results, error) in
            
            if let samples = results
            {
                samples.forEach{ sample in
                    let start = sample.startDate
                    let end = sample.endDate
                    DispatchQueue.main.async {
                        self.appendDurationLog(start: start, end: end)
                    }
                }
            }
        }
        myHealthStore.execute(q)
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
