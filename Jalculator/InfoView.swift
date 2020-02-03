//
//  InfoView.swift
//  Jalculator
//
//  Created by Jason Parker on 2019-09-01.
//  Copyright © 2019 Jason Parker. All rights reserved.
//

import SwiftUI

struct InfoView: View {
    
    @State var isPresented: Bool = false
    @Environment(\.presentationMode) private var presentationMode
    
    struct InfoTextView: View {
        var content: String
        var body: some View {
            Text(content)
                .font(.title)
                .bold()
                .foregroundColor(Color(UIColor.label))
                .multilineTextAlignment(.center)
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            InfoTextView(content: "A calculator developed by")
            InfoTextView(content: "Jason Parker")
            Spacer()
        }
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
    }
}
