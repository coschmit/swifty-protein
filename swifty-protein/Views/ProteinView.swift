//
//  ProteinView.swift
//  swifty-protein
//
//  Created by Colin Schmitt on 02/03/2021.
//

import SwiftUI
import SceneKit

struct ProteinView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.scenePhase) var scenePhase
    
    var name : String?
    var pdbFile: String?
    
    @State var dataInfo: AtomInfo!
    @State var show : Bool = false
    
    
    @State var proteinVC : ProteinVC!
    
    var body: some View {
        
        ZStack{
            
           proteinVC.edgesIgnoringSafeArea(.all)

            VStack{
                if self.show{
                    
                    VStack{
                        ScrollView {
                            Text(self.dataInfo.summary!).foregroundColor(.white).font(.caption)
                        }.frame(height: 100)
                        
                        
                        Spacer()
                        
                        Text("\(self.dataInfo.name!) (\(self.dataInfo.symbol!))").foregroundColor(.white).font(.title).padding(.bottom,10)
                        
                        HStack{
                            Text("Phase:  \(self.dataInfo.phase!)").foregroundColor(.white).padding(.all,5)
                            Spacer()
                            Text("Density: \(self.dataInfo.density!)").foregroundColor(.white).padding(.all,5)
                        }
                        
                        HStack{
                            Text("Atomic mass: \(self.dataInfo.atomic_mass!)").foregroundColor(.white).padding(.all,5)
                            Spacer()
                            Text("Number: \(self.dataInfo.number!)").foregroundColor(.white).padding(.all,5)
                        }
                        
                        HStack{
                            Text("Boil temp: \(self.dataInfo.boil != nil ? String(self.dataInfo.boil!) : "No Info")").foregroundColor(.white).padding(.all,5)
                            Spacer()
                            Text("Molar heat: \(self.dataInfo.molar_heat != nil ? String(self.dataInfo.molar_heat!) : "No Info")").foregroundColor(.white).padding(.all,5)
                        }
                    }
                    
                }
                    
            }
            
            
        }.onAppear(perform: {
            proteinVC =  ProteinVC( pdbFile: self.pdbFile, completion: { (show,data) in
                withAnimation{
                    if (data != nil) {
                        self.dataInfo = data
                    }
                    self.show = show
                }
            })
        }).onChange(of: scenePhase, perform: { value in
            if value == .background {
                self.presentationMode.wrappedValue.dismiss()
            }
        }).navigationBarItems(trailing: Button(action: {
            let controller = UIHostingController(rootView: self)
            let view = controller.view
            proteinVC.takeScreenShot(view: view!)
        }, label: {
            Text("Share")
        })).navigationBarTitle(self.name!)
            
    }
    
}

