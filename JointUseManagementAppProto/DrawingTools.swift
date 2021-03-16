//
//  DrawingTools.swift
//  JointUseManagementAppProto
//
//  Created by Core System Japan on 2020/03/24.
//  Copyright © 2020 Furukawa Electric Co., Ltd. All rights reserved.
//

import SwiftUI

//Drawing tools for usr to select what color to use, text box or clean up all paths
struct DrawingTools: View {
    @Binding var drawing_on: Bool
    @Binding var selectedColor: DrawType
    @Binding var image:Image?
    @Binding var selectedwidth:CGFloat
    @Binding var viewModel:DrawViewModel
    
    var body: some View {
        HStack{
            Button(action: {
                if self.selectedColor == .black{
                    //To hide selected sign of red circle
                    self.selectedColor = .clear
                    self.drawing_on = false
                }else{
                    self.selectedColor = .black
                    self.drawing_on = true
                }
                self.drawing_on = true
                self.selectedwidth = 3
            }) { HStack {
                if self.selectedColor == .black{
                    Image("BlackPencil")
                    .resizable()
                    .renderingMode(Image.TemplateRenderingMode?.init(Image.TemplateRenderingMode.original))
                    .frame(width: 75.0, height:60.0)
                        .border(Color.red, width: 5)
                }
                else{
                    Image("BlackPencil")
                    .resizable()
                    .renderingMode(Image.TemplateRenderingMode?.init(Image.TemplateRenderingMode.original))
                    .frame(width:75, height:60)
                }
            }}
            Button(action: {
                if self.selectedColor == .red{
                    self.selectedColor = .clear
                    self.drawing_on = false
                }else{
                 self.selectedColor = .red
                    self.drawing_on = true
                }
                self.selectedwidth = 3
            }) {
                HStack {
                    if self.selectedColor == .red{
                    Image("RedPencil")
                    .resizable()
                    .renderingMode(Image.TemplateRenderingMode?.init(Image.TemplateRenderingMode.original))
                    .frame(width: 75.0, height:60.0)
                        .border(Color.red, width: 5)
                    }
                    else{
                        Image("RedPencil")
                        .resizable()
                        .renderingMode(Image.TemplateRenderingMode?.init(Image.TemplateRenderingMode.original))
                        .frame(width:75, height:60)
                            
                    }
                }
            }
            Button(action: {
                if self.selectedColor == .white{
                    self.selectedColor = .clear
                    self.drawing_on = false
                }else{
                    self.selectedColor = .white
                    self.drawing_on = true
                }
                self.drawing_on = true
                self.selectedwidth = 50
            }) { HStack {
                if self.selectedColor == .white{
                Image("Eraser")
                .resizable()
                .renderingMode(Image.TemplateRenderingMode?.init(Image.TemplateRenderingMode.original))
                .frame(width: 75.0, height:60.0)
                    .border(Color.red, width: 5)
                }
                else{
                    Image("Eraser")
                    .resizable()
                    .renderingMode(Image.TemplateRenderingMode?.init(Image.TemplateRenderingMode.original))
                    .frame(width:75, height:60)
                        
                }
            }

            }
            Button(action: {
                self.drawing_on = false
                self.selectedColor = .clear
                self.viewModel = DrawViewModel(drawData: DrawData(dragPoints: []))
                print("DELETED")

            }) { HStack {
                Text("全消去")
            }
            .frame(width: 60.0, height: 30.0, alignment: .center).padding()
            .foregroundColor(.white)
            .background(Color.yellow)
            .cornerRadius(40)
            }
            Spacer()
        }
    }
}

enum DrawType {
    case red
    case white
    case clear
    case black

    var color: Color {
        switch self {
            case .red:
                return Color.red
            case .white:
                return Color(white: 0.95)
            case .clear:
                return Color.clear
            case .black:
                return Color.black
        }
    }
}

struct DrawData {
    var dragPoints: [DrawPoints]
}

struct DrawPoints: Identifiable {
    var id = UUID()
    var points: [CGPoint]
    var color: Color
    var linewidth:CGFloat
}

final class DrawViewModel: ObservableObject {
    @Published var drawData: DrawData
    
    init(drawData: DrawData) {
        self.drawData = drawData
    }
}

struct DrawPathView: View {

    @ObservedObject var viewModel: DrawViewModel
//    @State var width: Int = 10
    var body: some View {
        ZStack {
            ForEach(viewModel.drawData.dragPoints) { data in
                Path { path in
                    path.addLines(data.points)
                }
                .stroke(data.color, lineWidth: data.linewidth)
            }
        }
    }
}


