//
//  EditorView.swift
//  BabyTime
//
//  Created by Daisuke Yanagi on 2023/05/10.
//

import SwiftUI

struct EditorView:View
{
    
    @State var text:String = ""
    @State var category:Int = 1
    
    @Binding var isShown:Bool
    @Binding var uuid:UUID
    
    @ObservedObject var manager:StopWatchManeger
    
    @FocusState var focus:Bool
    
    
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
        Spacer()
        Text(dataByID(id:uuid) + "秒")
            .font(.custom("Futura", size: 40))
        
        Picker("カテゴリを選択", selection: $category) {
            Text("昼寝").tag(1)
            Text("夜寝").tag(2)
            Text("睡眠以外").tag(3)
        } .pickerStyle(InlinePickerStyle())
        
        TextField("", text: $text, prompt: Text("タイトル"))
            .textFieldStyle(.roundedBorder)
            .padding()
            .focused(self.$focus)
            .onSubmit {
                
                isShown.toggle()
                manager.editCaption(id: uuid, text: text)
                manager.editSleepCategory(id: uuid, cat: SleepCategory(rawValue: category)!)
            }
            .onAppear{
                self.focus = true
            }
        Spacer()
        Button(action: {
            isShown.toggle()
            manager.editCaption(id: uuid, text: text)
            manager.editSleepCategory(id: uuid, cat: SleepCategory(rawValue: category)!)
        }){
            Text("決定")
        }
        Spacer()
    }
}

