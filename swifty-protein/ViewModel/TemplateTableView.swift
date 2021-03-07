//
//  TemplateTableRow.swift
//  Swifty-Companion
//
//  Created by Colin Schmitt on 31/01/2021.
//

import SwiftUI

struct TemplateTableView: View {
    
    var title : String
    var data: [String]
    @Binding var searchText: String
    
    var completion: (String)->()
    
    var body: some View {
                List {
                    ForEach(data.filter({ searchText.isEmpty ? true : $0.contains(searchText) }), id: \.self){
                        elem in
                        Button(action: {
                        completion(elem)
                        }, label: {
                            Text(elem).font(.headline).padding()
                        })
                       
                        }
                        
                }
    }
}

//struct TemplateTableView_Previews: PreviewProvider {
//    static var previews: some View {
//        TemplateTableView(title: "Projects", data: ["E12","6AA","BDI"] , searchText: .constant(""),)
//            //.preferredColorScheme(.dark)
//            
//            
//    }
//}
