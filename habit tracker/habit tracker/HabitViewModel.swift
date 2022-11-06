//
//  HabitViewModel.swift
//  habit tracker
//
//  Created by Ali Erdem Kökcik on 6.11.2022.
//

import SwiftUI
import CoreData
import UserNotifications

class HabitViewModel: ObservableObject {
    // MARK: new habit properties
    @Published var addNewHabit: Bool = false
    @Published var title: String = ""
    @Published var habitColor: String = "Card-1"
    @Published var weekDays: [String] = []
    @Published var isRemainderOn: Bool = false
    @Published var remainderText: String = ""
    @Published var remainderDate: Date = Date()
    
    // MARK: remainder time picker
    @Published var showTimePicker: Bool = false
    init(){
        requestNotificationAccess()
    }
    
    // MARK: editing habits
    @Published var editHabit: Habit?
    
    // MARK: notification access
    @Published var notificationAccess: Bool = false
    func requestNotificationAccess(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert]) { status, _ in
            DispatchQueue.main.async {
                self.notificationAccess = status
            }
        }
    }
    
    // MARK: adding habit to database
    func addHabit(context: NSManagedObjectContext) async -> Bool {
        let habit = Habit(context: context)
        habit.title = title
        habit.color = habitColor
        habit.weekDays = weekDays
        habit.isRemainderOn = isRemainderOn
        habit.remainderText = remainderText
        habit.notificationDate = remainderDate
        habit.notificationIDs = []
        
        if isRemainderOn {
            // MARK: scheduling notifications
            if let ids = try? await scheduleNotification(){
                habit.notificationIDs = ids
                if let _ = try? context.save(){
                    return true
                }
            }
        }else {
            // MARK: adding data
            if let _ = try? context.save(){
                return true
            }
        }
        return false
    }
    
    // MARK: notifications
    func scheduleNotification()async throws -> [String] {
        let content = UNMutableNotificationContent()
        content.title = "habit reminder"
        content.subtitle = remainderText
        content.sound = UNNotificationSound.default
        
        // MARK: scheduled ids
        var notificationIDs: [String] = []
        let calendar = Calendar.current
        let weekdaySymbols: [String] = calendar.weekdaySymbols
        
        // MARK: scheduling notification
        for weekDay in weekDays {
            let id = UUID().uuidString
            let hour = calendar.component(.hour, from: remainderDate)
            let min = calendar.component(.minute, from: remainderDate)
            let day = weekdaySymbols.firstIndex{ currentDay in
                return currentDay == weekDay
            } ?? -1
            if day != -1{
                var components = DateComponents()
                components.hour = hour
                components.minute = min
                components.weekday = day + 1
                
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                
                // MARK: notification request
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                try await UNUserNotificationCenter.current().add(request)
                
                notificationIDs.append(id)
            }
        }
        return notificationIDs
    }
    
    // MARK: erasing content
    func resetData(){
        title = ""
        habitColor = "Card-1"
        weekDays = []
        isRemainderOn = false
        remainderDate = Date()
        remainderText = ""
        editHabit = nil
    }
    
    // MARK: deleting habit
    func deleteHabit(context: NSManagedObjectContext) -> Bool {
        if let editHabit = editHabit{
            context.delete(editHabit)
            if let _ = try? context.save(){
                return true
            }
        }
        return false
    }
    
    // MARK: restoring edit data
    func restoreEditData(){
        if let editHabit = editHabit{
            title = editHabit.title ?? ""
            habitColor = editHabit.color ?? "Card-1"
            weekDays = editHabit.weekDays ?? []
            isRemainderOn = editHabit.isRemainderOn
            remainderDate = editHabit.notificationDate ?? Date()
            remainderText = editHabit.remainderText ?? ""
        }
    }
    
    // MARK: done button
    func doneStatus() -> Bool{
        let remainderStatus = isRemainderOn ? remainderText == "" : false
        
        if title == "" || weekDays.isEmpty || remainderStatus {
            return false
        }
        return  true
    }
}
