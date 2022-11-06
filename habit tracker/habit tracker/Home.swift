//
//  Home.swift
//  habit tracker
//
//  Created by Ali Erdem Kökcik on 6.11.2022.
//

import SwiftUI

struct Home: View {
    @FetchRequest(entity: Habit.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Habit.dateAdded, ascending: false)], predicate: nil, animation: .easeInOut) var habits: FetchedResults<Habit>
    @StateObject var habitModel: HabitViewModel = .init()
    var body: some View {
        VStack(spacing: 0){
            Text("habits")
                .font(.title2.bold())
                .frame(maxWidth: .infinity)
                .overlay(alignment: .trailing){
                    Button {
                        //
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 10)
            // MARK: making add button center when habits empty
            ScrollView(habits.isEmpty ? .init() : .vertical, showsIndicators: false){
                VStack(spacing: 15){
                    
                    ForEach(habits){ habit in
                        HabitCardView(habit: habit)
                    }
                    
                    // MARK: add habit
                    Button {
                        habitModel.addNewHabit.toggle()
                    } label: {
                        Label {
                            Text("new habit")
                        } icon: {
                            Image(systemName: "plus.circle")
                        }
                        .font(.callout.bold())
                        .foregroundColor(.white)
                    }
                    .padding(.top, 15)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
                .padding(.vertical)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding()
        .sheet(isPresented: $habitModel.addNewHabit){
            habitModel.resetData()
        } content: {
            AddNewHabit()
                .environmentObject(habitModel)
        }
    }
    
    // MARK: habit card view
    @ViewBuilder
    func HabitCardView(habit: Habit) -> some View{
        VStack(spacing: 6){
            HStack{
                Text(habit.title ?? "")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                Image(systemName: "bell.badge.fill")
                    .font(.callout)
                    .foregroundColor(Color(habit.color ?? "Card-1"))
                    .scaleEffect(0.9)
                    .opacity(habit.isRemainderOn ? 1 : 0)
                Spacer()
                
                let count = (habit.weekDays?.count ?? 0)
                Text(count == 7 ? "everyday" : "\(count) times a week")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 10)
            
            let calendar = Calendar.current
            let currentWeek = calendar.dateInterval(of: .weekOfMonth, for: Date())
            let symbols = calendar.weekdaySymbols
            let startDate = currentWeek?.start ?? Date()
            let activeWeekDays = habit.weekDays ?? []
            let activePlot = symbols.indices.compactMap{ index -> (String, Date) in
                let currentDate = calendar.date(byAdding: .day, value: index, to: startDate)
                return(symbols[index], currentDate!)
            }
            HStack(spacing: 0){
                ForEach(activePlot.indices, id: \.self){ index in
                    let item = activePlot[index]
                    
                    VStack(spacing: 6){
                        // MARK: limiting to first 3 letters
                        Text(item.0.prefix(3))
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        let status = activeWeekDays.contains{ day in
                            return day == item.0
                        }
                        Text(getDate(date: item.1))
                            .font(.system(size: 14))
                            .fontWeight(.semibold)
                            .padding(8)
                            .background{
                                Circle()
                                    .fill(Color(habit.color ?? "Card-1"))
                                    .opacity(status ? 1 : 0)
                            }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 15)
        }
        .padding(.vertical)
        .padding(.horizontal, 6)
        .background{
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color("TFBG").opacity(0.4))
        }
        .onTapGesture {
            // MARK: editing habit
            habitModel.editHabit = habit
            habitModel.restoreEditData()
            habitModel.addNewHabit.toggle()
        }
    }
    // MARK: formatting date
    func getDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter.string(from: date)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
