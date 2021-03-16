//
//  InitialView.swift
//  JointUseManagementAppProto
//
//  Created by Core System Japan on 2019/12/31.
//  Copyright © 2019 Furukawa Electric Co., Ltd. All rights reserved.
//

import SwiftUI

struct InitialView: View {
    var body: some View {
        VStack{
            Spacer()
            Text("Files内の当アプリフォルダ内に、DeviceDataが見当たりません。")
            Text("当アプリフォルダ内に、DeviceDataを格納してから、")
            Text("再度アプリを起動してください。")
            Spacer()
            Text("今回が初めての起動の場合、")
            Text("Files内に当アプリフォルダを作成いたしましたので、ご確認ください。")
            Text("万が一、当アプリフォルダが見当たらない場合は、")
            Text("iOSを再起動してからFilesをご確認ください。")
            Spacer()
        }
        .font(.largeTitle)
    }
}

struct InitialView_Previews: PreviewProvider {
    static var previews: some View {
        InitialView()
    }
}
