//
//  ProteinListView.swift
//  swifty-protein
//
//  Created by Colin Schmitt on 01/03/2021.
//

import SwiftUI
import Foundation

struct ProteinListView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.scenePhase) var scenePhase
    
    @State var searchText: String = ""
    
    @State var listLoading : Bool = true
    
    @State var isSelected : Bool = false
    @State var selected : String = ""
    @State var isDownloading: Bool = false
    
    let data = ProteinData()
    
    var body: some View {
        
        LoadingView(isShowing: $isDownloading) {
            ZStack{
            VStack{
                
                SearchBar(text: $searchText).padding(.top,30)
                
                if (listLoading){
                  
                    ProgressView()
                  
                }else {
                    TemplateTableView(title: "data list", data: data.proteinsArr,searchText: $searchText, completion: {(name) in
                        self.downloadProtein(name: name)
                    } )
                }
              
                
                Spacer()
                
            }.onAppear(perform: {
                if data.proteinsArr.isEmpty {
                    data.parseProteins()
                }
                self.listLoading = false
            })
            .onChange(of: scenePhase, perform: { value in
                if value == .background {
                    self.presentationMode.wrappedValue.dismiss()
                }
            })
            
            if (isDownloading){
                VStack{
                    Text("Loading...")
                ProgressView()
                }.frame(width: 250, height: 250).background(Color.white).cornerRadius(10)
                
            }
            
            
            NavigationLink(
                destination: ProteinView(name: self.selected,pdbFile: self.data.pdbFile),
                isActive: $isSelected,
                label: {
                    EmptyView()
                })
            
            }.navigationBarTitle("proteins list",displayMode: .inline)
        }
    }
    
    
    func downloadProtein(name: String){
        self.selected = name
        self.isDownloading = true
        data.downloadProteins(name: name) { (response) in
            DispatchQueue.main.async {
                if let data = response {
                    self.data.pdbFile = data
                    self.isSelected = true
                    self.isDownloading = false
                    return
                }
                // need to create alert, [connection failed]
            }
        }
    }
    
    
}

struct LoadingView<Content>: View where Content: View{
    
    @Binding var isShowing: Bool
    var content: () -> Content
    var body: some View{
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                
                self.content()
                    .disabled(self.isShowing)
                    .blur(radius: self.isShowing ? 3 : 0)
                
                VStack {
                    Text("Loading...")
                    ProgressView()
                }
                .frame(width: geometry.size.width / 2,
                       height: geometry.size.height / 5)
                .background(Color.secondary.colorInvert())
                .foregroundColor(Color.primary)
                .cornerRadius(20)
                .opacity(self.isShowing ? 1 : 0)
                
            }
        }
    }
}


struct ProteinListView_Previews: PreviewProvider {
    static var previews: some View {
        ProteinListView()
    }
}

struct SearchBar: View {
    
    @Binding var text: String
    @State private var isEditing : Bool = false
    
    var body: some View {
        HStack {
            
            TextField("Search ...", text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(HStack{
                    Image(systemName: "magnifyingglass").foregroundColor(.gray).frame(minWidth:0,maxWidth: .infinity,alignment: .leading).padding(.leading,8)
                    
                    if isEditing{
                        Button(action: {self.text = ""}, label: {
                            Image(systemName: "multiply.circle.fill").foregroundColor(.gray).padding(.trailing,8)
                        })
                    }
                    
                })
                .padding(.horizontal, 10)
                .onTapGesture {
                    self.isEditing = true
                }
            
            if isEditing {
                Button(action: {
                    self.isEditing = false
                    self.text = ""
                    
                }) {
                    Text("Cancel")
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
                .animation(.easeIn)
            }
            
        }
    }
}
