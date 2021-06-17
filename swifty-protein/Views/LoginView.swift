//
//  LoginView.swift
//  swifty-protein
//
//  Created by Colin Schmitt on 28/02/2021.
//

import LocalAuthentication
import SwiftUI


struct LoginView : View {
    
    @State  var context: LAContext!
    @State var biometricType: LABiometryType = .none
    @State var unlocked: Bool = false
    
    var body: some View{
        ZStack {
            
            VStack {
                HStack{
                    Text("Swifty")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(Color("bg"))
                    
                    Spacer(minLength: 0)
                }.padding()
                .padding(.top,UIApplication.shared.windows.first?.safeAreaInsets.top)
                .background(Color.white)
                Spacer()
                if biometricType != .none {
                    Button(action:{ authenticate(context: self.context!){result in
                        if result {
                            self.unlocked = result
                        }
                    }}, label: {
                        Image(self.biometricType == .faceID ? "faceid" : "touchid").resizable().renderingMode(.template).foregroundColor(Color("bg")).frame(width: 80, height: 80, alignment: .center).padding(.bottom,40)
                        
                    })
                    NavigationLink(
                        destination: ProteinListView(),
                        isActive: $unlocked,
                        label: {
                            EmptyView()
                        })
                    Spacer()
                }
                
                
            }.ignoresSafeArea(.all,edges: .top)
            .background(Color.black.opacity(0.06).ignoresSafeArea(.all,edges: .all))
            
            
            SplashView()
            
            
        }.onAppear(perform: {
            self.context = checkBiometricType { (biometric) in
                self.biometricType = biometric
            }
            
        })
    }
    
    func checkBiometricType(completion: (LABiometryType)->()) -> LAContext{
        let context = LAContext()
        
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            completion(context.biometryType)
            
        }
        else {
            
        }
        return context
    }
    
    func authenticate(context: LAContext, completion: @escaping (Bool)->()){
        let context = LAContext()
        
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            
            let reason = "We need to unlock your data."
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (success, authenticationError) in
                DispatchQueue.main.async {
                    if success{
                        completion(true)
                    }else {
                        completion(false)
                    }
                }
            }
        }else {
            print("we can't")
            // no biometric
        }
    }
    
    
}


struct SplashView: View {
    @State var animate = false
    var body: some View {
        ZStack {
            Color("bg")
            
            Image("logolarge").resizable().renderingMode(.original).aspectRatio(contentMode: animate ? .fill : .fit)
                .frame(width: animate ? nil :  80,height: animate ? nil : 80)
                .scaleEffect(animate ? 6 : 1)
                .frame(width: UIScreen.main.bounds.width)
        }.ignoresSafeArea(.all,edges: .all)
        .onAppear(perform: animateSplash).opacity(animate ? 0 : 1)
    }
    func animateSplash(){
        if !animate {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            withAnimation(Animation.easeOut(duration: 0.4)) {
                animate.toggle()
            }
            
            
        }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
