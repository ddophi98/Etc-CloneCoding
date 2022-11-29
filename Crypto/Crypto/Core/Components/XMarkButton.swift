//
//  XMarkButton.swift
//  Crypto
//
//  Created by 김동락 on 2022/11/29.
//

import SwiftUI

struct XMarkButton: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
            print("aaa")
        }, label: {
            Image(systemName: "xmark")
                .font(Font.headline)
        })
    }
}

struct XMarkButton_Previews: PreviewProvider {
    static var previews: some View {
        XMarkButton()
    }
}
