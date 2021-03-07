//
//  ProteinView.swift
//  swifty-protein
//
//  Created by Colin Schmitt on 02/03/2021.
//

import SwiftUI
import SceneKit

struct ProteinView: View {
    
    var name : String?
    var pdbFile: String?
    
    @State var dataInfo: AtomInfo!
    @State var show : Bool = false
    
    @State var presentingModal: Bool = false
    @State var objectsToShare: [UIImage] = [UIImage()]
    
    @State var proteinVC : ProteinVC!
    
    var body: some View {
        GeometryReader { geometry in

        ZStack{
            
           proteinVC.edgesIgnoringSafeArea(.all)

            VStack{
                if self.show{
                    
                    VStack{
                        HStack{
                            Text("Protein name \(self.dataInfo.name!)").foregroundColor(.white).font(.body)
                            Spacer()
                            Text("Density: \(self.dataInfo.density!)")
                        }
                        
                        Spacer()
                        
                        HStack{
                            Text("Symbol: \(self.dataInfo.symbol!)")
                            Spacer()
                            Text("Molar heat: \(self.dataInfo.molar_heat != nil ? String(self.dataInfo.molar_heat!) : "No Info")")
                        }
                    }
                    
                }
                
                
            }
            
            
        }.onAppear(perform: {
            proteinVC =  ProteinVC(pdbFile: self.pdbFile,completion: { (show,data) in
                print("data",data)
                withAnimation{
                    if (data != nil) {
                        self.dataInfo = data
                    }
                    self.show = show
                }
            })
        }).navigationBarItems(trailing: Button(action: {
            
            let image = self.takeScreenshot(origin: geometry.frame(in: .global).origin, size: geometry.size)
            let objectsToShare = [image] as [UIImage]
            self.objectsToShare = objectsToShare
            
            self.presentingModal = true
          
        
        }, label: {
            Text("Share")
        })).sheet(isPresented: $presentingModal, content: {
            
            if (self.objectsToShare != nil) {
                ActivityVC(objectsToShare: self.objectsToShare)
            }
            
        })
        }
        
        
    }
    
}

struct ActivityVC : UIViewControllerRepresentable {
    var objectsToShare: [UIImage]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
        return activityVC
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        
    }
        
    
    
}


extension UIView {
    var renderedImage: UIImage {
        // rect of capure
        let rect = self.bounds
        // create the context of bitmap
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0.0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        self.layer.render(in: context)
        // get a image from current context bitmap
        let capturedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return capturedImage
    }
}

extension View {
    func takeScreenshot(origin: CGPoint, size: CGSize) -> UIImage {
        let window = UIWindow(frame: CGRect(origin: origin, size: size))
        let hosting = UIHostingController(rootView: self)
        hosting.view.frame = window.frame
        window.addSubview(hosting.view)
        window.makeKeyAndVisible()
        print("takescreenshot, timestamp: \(Date().timeIntervalSince1970)")

        return hosting.view.renderedImage
    }
}



