//
//  threedApp.swift
//  threed
//
//  Created by Sunil Munjal on 6/23/21.
//

import SwiftUI

@main
struct threedApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: RubiksCubeViewModel())
        }
    }
}
