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
        Text(dataByID(id:uuid) + "秒")
            .font(.custom("Futura", size: 40))
        
        
        TextField("", text: $text, prompt: Text("タイトル"))
            .textFieldStyle(.roundedBorder)
            .padding()
            .focused(self.$focus)
            .onSubmit {
                
                isShown.toggle()
                manager.editCaption(id: uuid, text: text)
            }
            .onAppear{
                self.focus = true
            }
        
    }
}

