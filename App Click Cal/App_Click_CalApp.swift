//
//  App_Click_CalApp.swift
//  App Click Cal
//
//  Created by Pushpendra on 24/05/25.
//

import SwiftUI

@main
struct App_Click_CalApp: App {
    private let openAIService: OpenAIService
    private let foodHistoryService: FoodHistoryService
    
    init() {
        // Temporarily hardcode the API key for testing
        let apiKey = "Attached-In-Email"
        
        // Initialize services
        self.openAIService = OpenAIService(apiKey: apiKey)
        self.foodHistoryService = FoodHistoryService()
        
        // Print API key status for debugging (don't print the actual key)
        if apiKey.isEmpty {
            print("Warning: OpenAI API key is not configured")
        } else {
            print("OpenAI API key is configured")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            TabView {
                FoodAnalysisView(
                    openAIService: openAIService,
                    foodHistoryService: foodHistoryService
                )
                .tabItem {
                    Label("Analyze", systemImage: "camera.fill")
                }
                
                FoodHistoryView(
                    openAIService: openAIService,
                    foodHistoryService: foodHistoryService
                )
                .tabItem {
                    Label("History", systemImage: "calendar")
                }
            }
        }
    }
}
