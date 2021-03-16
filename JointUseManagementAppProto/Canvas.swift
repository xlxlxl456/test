//
//  Canvas.swift
//  JointUseManagementAppProto
//
//  Created by Core System Japan on 2020/03/24.
//  Copyright © 2020 Furukawa Electric Co., Ltd. All rights reserved.
//

import SwiftUI

//Just to specify types of variables for TextView
struct textdataformat: Identifiable {
    var id = UUID()
    var text: String
    var position: CGPoint
}
//For holding texts data that usr craeted
final class TextView: ObservableObject {
    @Published var textdata: [textdataformat]
    
    init(textdata: [textdataformat]) {
        self.textdata = textdata
    }
}

struct TextboxView: View {
    @ObservedObject var textView: TextView
    
    var body: some View {
        ZStack{
            //Show texts saved in textview
            ForEach(self.textView.textdata){ data in
                Text(data.text)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .position(x:data.position.x, y:data.position.y)
            }
        }
    }
}


//Canvas to draw in NewDrawingView
struct Canvas: View {
    
    var selectedColor: DrawType = .red
    var drawing_on: Bool = true
    var selectedwidth:CGFloat = 10
    //ViewModel to show paths that usr drew
    @Binding var viewModel: DrawViewModel
    @Binding var textview: TextView
    //What to put in temporarily for drawing paths
    @State private var tmpDrawPoints: DrawPoints = DrawPoints(points: [], color: .red,linewidth: 10)
    @State private var canvas_coordinate:CGPoint = CGPoint(x:0,y:-35)
  
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                //Rectangle as canvas
                Rectangle()
                .offset(self.canvas_coordinate)
                .foregroundColor(Color(white:0.95))
                .frame(width: geometry.size.width,height: geometry.size.height, alignment: .center)
                .overlay(
                    //Show drewed paths and texts
                    ZStack{
                        DrawPathView(viewModel: self.viewModel)
                        TextboxView(textView: self.textview)
                    }
                )
                .gesture(
                    DragGesture(minimumDistance: 0)
                    .onChanged({ (value) in
                        if self.drawing_on == true {
                                if value.location.y > 0{
                                    self.tmpDrawPoints.points.append(value.location)
                                    self.tmpDrawPoints.color = self.selectedColor.color
                                    self.tmpDrawPoints.linewidth = self.selectedwidth
                                }
                        }
                    })
                    .onEnded { value in
                        if self.drawing_on == true{
                            //Save temporary paths data into ViewModel
                            self.viewModel.drawData.dragPoints.append(self.tmpDrawPoints)
                            self.tmpDrawPoints = DrawPoints(points: [], color: self.selectedColor.color,linewidth: self.selectedwidth)
                        }
                    }
                )
                
                //Show temporarily paths that usr is currently drawing
                Path { path in
                    path.addLines(self.tmpDrawPoints.points)
                }
                .stroke(self.tmpDrawPoints.color, lineWidth:self.selectedwidth)
            }
            .onDisappear(){
            }
        }
    }
}
