//
//  ContentView.swift
//  BetterRest
//
//  Created by Shihab Chowdhury on 4/11/23.
//

import CoreML
import SwiftUI

struct Title: View {
    var text: String
    
    var body: some View {
        Text(text)
            .font(.headline)
    }
    
    init(_ text: String) {
        self.text = text
    }
}

struct ContentView: View {
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    @State private var sleepAmount = 8.0
    @State private var wakeUp = defaultWakeTime
    @State private var coffeeCups = 1
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                VStack(alignment: .leading, spacing: 0) {
                    Title("When do you want to wake up?")
                        .padding(.bottom, 5)

                    DatePicker("Please please select a time", selection: $wakeUp, in: ContentView.defaultWakeTime..., displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Title("Desired amount of sleep")
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                .padding(.vertical, 5)
                
                VStack(alignment: .leading, spacing: 0) {
                    Title("Daily coffee intake")
                    
                    Stepper(coffeeCups == 1 ? "1 cup" : "\(coffeeCups) cups", value: $coffeeCups, in: 1...20)
                }
                .padding(.vertical, 5)
            }
            .navigationTitle("BetterRest")
            .toolbar {
                Button("Calculate", action: calculateBedtime)
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("Close", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    func calculateBedtime() {
        // Logic for calculating when they should sleep
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let dateComp = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (dateComp.hour ?? 0) * 60 * 60
            let minute = (dateComp.minute ?? 0) * 60
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeCups))
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Calculated Bedtime"
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            // Error
            alertTitle = "Error"
            alertMessage = "Sorry, something went wrong processing your request."
        }
        
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
