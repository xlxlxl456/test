//
//  NewDrawing.swift
//  JointUseManagementAppProto
//
//  Created by Core System Japan on 2020/03/24.
//  Copyright © 2020 Furukawa Electric Co., Ltd. All rights reserved.
//

import SwiftUI

struct namelist{
    var mapname:String = ""
    var ssmhname:String = ""
    var drawingname:String = ""
    var partname:String = ""
}


struct NewDrawing: View {
    
    //Names to name image when pictures are taken thru sticker function
    @State private var names:namelist = namelist(mapname:"",ssmhname:"",drawingname:"",partname:"")
    //View model to show path drawed by usr
    @State private var viewModel: DrawViewModel = DrawViewModel(drawData: DrawData(dragPoints: []))
    @State private var selectedColor: DrawType = .clear
    @State private var selectedwidth:CGFloat = 10
    //Switch from drawing mode on to off
    @State private var drawing_on: Bool = false
    //For opening/closing camera
    @State private var showImagePicker: Bool = false
    @State private var showImagePicker_cancel:Bool = false
    @State private var image: Image? = nil
    @State private var mapname:String = ""
    @State private var textview: TextView = TextView(textdata:[])

    var body: some View {
        GeometryReader { geometry in
            ZStack{
                Canvas(selectedColor: self.selectedColor, drawing_on: self.drawing_on,selectedwidth: self.selectedwidth,viewModel:self.$viewModel,textview:self.$textview)
                
                DrawingTools(drawing_on:self.$drawing_on,selectedColor:self.$selectedColor,image: self.$image,selectedwidth: self.$selectedwidth,viewModel:self.$viewModel)
                .offset(x: 10, y: -geometry.size.height/2 + 35)
                
                Button(action: {
                    UIApplication.shared.windows[0].rootViewController?.dismiss(animated: true, completion: {})
                    print("DELETED")
                }) { HStack {
                    Text("破棄")
                }
                .frame(width: 60.0, height: 30.0,alignment: .center).padding()
                .foregroundColor(.white)
                .background(Color.red)
                .cornerRadius(40)
                }
                .offset(x:180, y:-geometry.size.height/2 + 35)
                
                Button(action: {
                    self.takeScreenshot(origin: CGPoint(x:0, y:-35), size: CGSize(width: 1112.0, height: 712.0), current_view:self.getMyself())
                    UIApplication.shared.windows[0].rootViewController?.dismiss(animated: true, completion: {})
                    print("SAVED")
                }) { HStack {
                    Text("保存")
                }
                .frame(width: 60.0, height: 30.0,alignment: .center).padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(40)
                }
                .offset(x:300, y:-geometry.size.height/2 + 35)
            }
        }
    }
}

//Extend UIView to take a screenshot
extension UIView {
    //Create image that user want
    var getImage: UIImage {
        // rect of capure
        let rect = self.bounds
        // create the context of bitmap
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
                   print("Failed to get context")
                   return UIImage()
               }
        self.layer.render(in: context)
        // get a image from current context bitmap
        let capturedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return capturedImage
    }
}

//Extenf View to enable function to take screenshot inside of struct that adapts View protocol
extension View {
    //For specifying which view to capture
    func getMyself()->Body{
        return self.body
    }
    //Viewプロトコルに適合した構造体内でよびだせる関数で、関数呼び出し元の構造体が表示する画像を指定のサイズで保存する
    func takeScreenshot(origin: CGPoint, size: CGSize, current_view:Body){
        //Setting to capture image showing on app
        let window = UIWindow(frame: CGRect(origin: origin, size: size))
        let hosting = UIHostingController(rootView:current_view)
        hosting.view.frame = window.frame
        window.addSubview(hosting.view)
        window.makeKeyAndVisible()
        //get captured image that is showing on the app
        let capturedImage = hosting.view.getImage
        if let data = capturedImage.jpegData(compressionQuality: 0.8) {
            let filedir = NSHomeDirectory() + "/Documents/\(currentDir)/DeviceData/Images/\(poleNum)/"
            createDir(dirPath: filedir)
            
            // get date
            let f = DateFormatter()
            f.dateFormat = "yyyyMMddHHmmss"
            let now = Date()
            
            // set file path with name
            let unique_1 = completionModel.JointUseModels[poleNum - 1].PoleNumber!
            let unique_2 = unique_1 + "_"
            let unique_3 = unique_2 + f.string(from: now) + ".jpg"
            let filename = filedir + unique_3
            let imageURL: URL = URL(fileURLWithPath: filename)
            try? data.write(to: imageURL)
        }
    }
}

//Fucntion to craete dir specified by dirPath
func createDir(dirPath: String){
    let fileManager = FileManager.default
    do {
        try fileManager.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
    } catch {
        print("ERROR")
        print(error)
    }
}
