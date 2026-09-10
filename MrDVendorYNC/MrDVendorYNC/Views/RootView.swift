//
//  RootView.swift
//  MrDVendorYNC
//
//  Created by Yi-Nain Chen on 2026/09/09.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            VendorsScreen()
                .tabItem {
                    Label("Vendors", systemImage: "storefront")
                }
            SettingsScreen()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    RootView()
}
