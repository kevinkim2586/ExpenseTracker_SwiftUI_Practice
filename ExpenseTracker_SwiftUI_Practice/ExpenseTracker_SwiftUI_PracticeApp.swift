//
//  ExpenseTracker_SwiftUI_PracticeApp.swift
//  ExpenseTracker_SwiftUI_Practice
//
//  Created by Kevin Kim on 2022/03/24.
//

import SwiftUI

@main
struct ExpenseTracker_SwiftUI_PracticeApp: App {
    
    @StateObject var transactionListVM = TransactionListViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(transactionListVM)
        }
    }
}
