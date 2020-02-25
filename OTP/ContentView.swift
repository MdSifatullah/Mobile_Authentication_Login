//
//  ContentView.swift
//  OTP
//
//  Created by Md Sifat on 2/25/20.
//  Copyright © 2020 Md Sifat. All rights reserved.
//

import SwiftUI
import Firebase

struct ContentView: View {
    @State var status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
    var body: some View {
        VStack{
            if status {
                HomeView()
            }else {
                NavigationView{
                    
                    FirstPage()
                }
            }
        }.onAppear{
            NotificationCenter.default.addObserver(forName: NSNotification.Name("statusChange"), object: nil, queue: .main) { (_) in
                let status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
                
                self.status = status
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct FirstPage: View{
    @State var mobileNumber = ""
    @State var countryCode = ""
    @State var show = false
    @State var msg = ""
    @State var alert = false
    @State var ID = ""
    var body: some View{
        VStack (spacing: 23){
            Image("pic").resizable().frame(width: 130, height: 130)
            Text("Verify Your Account").font(.title).fontWeight(.heavy)
            Text("Enter your Mobile Number to verify your Account")
                .font(.system(size: 13))
                .foregroundColor(.gray)
                .padding(.top, 15)
            HStack{
                TextField("+88", text: $countryCode).padding()
                    .keyboardType(.numberPad)
                    .frame(width: 75)
                    .background(Color("Color"))
                    .clipShape(RoundedRectangle(cornerRadius: 13))
                
                TextField("Enter Mobile Number", text: $mobileNumber).padding()
                    .keyboardType(.numberPad)
                    .background(Color("Color"))
                    .clipShape(RoundedRectangle(cornerRadius: 13))
            }.padding(.top, 13)
            
            NavigationLink(destination: SecondPage(show: $show, ID: $ID), isActive: $show) {
                Button(action: {
                    PhoneAuthProvider.provider().verifyPhoneNumber("+"+self.countryCode + self.mobileNumber, uiDelegate: nil) { (ID, err) in
                        
                        if err != nil{
                            self.msg = (err?.localizedDescription)!
                            self.alert.toggle()
                            return
                        }
                        self.ID = ID!
                        self.show.toggle()
                    }
                }) {
                    Text("Confirm").frame(width: UIScreen.main.bounds.width - 30, height: 50)
                }.foregroundColor(.white)
                    .background(Color.orange)
                    .cornerRadius(13)
            }
                
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
        }.padding()
            .alert(isPresented: $alert) {
                Alert(title: Text("Error"), message: Text(self.msg), dismissButton: .default(Text("Ok")))
        }
    }
}

struct SecondPage: View{
    @State var varificationCode = ""
    @Binding var show: Bool
    @Binding var ID: String
    @State var msg = ""
    @State var alert = false
    var body: some View{
        
        ZStack (alignment: .topLeading){
            
            GeometryReader{_ in
                VStack (spacing: 23){
                    Image("pic").resizable().frame(width: 130, height: 130)
                    Text("Verification Code").font(.title).fontWeight(.heavy)
                    Text("Enter Your Verification Code")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .padding(.top, 15)
                    
                    TextField("Code", text: self.$varificationCode).padding()
                        .keyboardType(.numberPad)
                        .background(Color("Color"))
                        .clipShape(RoundedRectangle(cornerRadius: 13))
                    
                    
                    Button(action: {
                        
                        let credential = PhoneAuthProvider.provider().credential(withVerificationID: self.ID, verificationCode: self.varificationCode)
                        Auth.auth().signIn(with: credential) { (res, err) in
                            
                            if err != nil{
                                self.msg = (err?.localizedDescription)!
                                self.alert.toggle()
                                return
                            }
                            UserDefaults.standard.set(true, forKey: "status")
                            NotificationCenter.default.post(name: NSNotification.Name("statusChange"), object: nil)
                            
                        }
                    }) {
                        Text("Confirm").frame(width: UIScreen.main.bounds.width - 30, height: 50)
                    }.foregroundColor(.white)
                        .background(Color.orange)
                        .cornerRadius(13)
                        .navigationBarTitle("")
                        .navigationBarHidden(true)
                        .navigationBarBackButtonHidden(true)
                }
                
            }
            Button(action: {
                self.show.toggle()
            }) {
                Image(systemName: "chevron.left").font(.title)
            }.foregroundColor(.orange)
            
        }.padding()
            .alert(isPresented: $alert) {
                Alert(title: Text("Error"), message: Text(self.msg), dismissButton: .default(Text("Ok")))
        }
    }
}

struct HomeView: View {
    var body: some View {
        VStack (spacing: 30){
            HStack{
                Text("< Home")
                Spacer()
                Button(action: {
                    try! Auth.auth().signOut()
                    UserDefaults.standard.set(false, forKey: "status")
                    NotificationCenter.default.post(name: NSNotification.Name("statusChange"), object: nil)
                    
                }, label: {
                    Text("Logout")
                })
            };Spacer()
            Text("Welcome").font(.largeTitle).fontWeight(.heavy).foregroundColor(.green)
            Image("pic")
            Text("Here We Are...").font(.title).fontWeight(.heavy).foregroundColor(.gray)
        }
    }
}
