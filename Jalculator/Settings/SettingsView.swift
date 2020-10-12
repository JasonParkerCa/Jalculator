//
//  SettingsView.swift
//  Jalculator
//
//  Created by Jason Parker on 2019-09-02.
//  Copyright © 2019 Jason Parker. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject private var settings: Settings
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        Form {
            Section(header: Text("Settings")) {
                Stepper(value: $settings.numberOfDecimalSpacesRoundTo, in: 0...9) {
                    Text("Round to \(Int(settings.numberOfDecimalSpacesRoundTo)) decimal spaces")
                }
            }
            .padding(.top)
        }
    }
    
}
