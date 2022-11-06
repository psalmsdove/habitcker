//
//  AddNewHabit.swift
//  habit tracker
//
//  Created by Ali Erdem Kökcik on 6.11.2022.
//

import SwiftUI

struct AddNewHabit: View {
    @EnvironmentObject var habitModel: HabitViewModel
    @Environment(\.self) var env
    // MARK: environment values
    var body: some View {
        NavigationView{
            VStack(spacing: 15){
                TextField("title", text: $habitModel.title)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color(.white).opacity(0.4), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                
                // MARK: habit color picker
                HStack(spacing: 0){
                    ForEach(1...7, id: \.self){ index in
                        let color = "Card-\(index)"
                        Circle()
                            .fill(Color(color))
                            .frame(width: 30, height: 30)
                            .overlay(content: {
                                if color == habitModel.habitColor{
                                    Image(systemName: "checkmark")
                                        .font(.caption.bold())
                                }
                            })
                            .onTapGesture {
                                withAnimation{
                                    habitModel.habitColor = color
                                }
                            }
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical)
                Divider()
                // MARK: frequency selection
                VStack(alignment: .leading, spacing: 6){
                    Text("frequency")
                        .font(.callout.bold())
                    let weekDays = Calendar.current.weekdaySymbols
                    HStack(spacing: 10){
                        ForEach(weekDays, id: \.self){day in
                            let index = habitModel.weekDays.firstIndex{value in
                                return value == day
                            } ?? -1
                            Text(day.prefix(2))
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background{
                                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                                        .fill(index != -1  ? Color(habitModel.habitColor) : Color("TFBG").opacity(0.3 ))
                                }
                                .onTapGesture{
                                    withAnimation{
                                        if index != -1 {
                                            habitModel.weekDays.remove(at: index)
                                        } else {
                                            habitModel.weekDays.append(day)
                                        }
                                    }
                                }
                        }
                    }
                    .padding(.top, 15)
                }
                Divider()
                    .padding(.vertical, 10)
                // hiding if notification access denied
                HStack{
                    VStack(alignment: .leading, spacing: 6){
                        Text("reminder")
                            .fontWeight(.semibold)
                        Text("just notification")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Toggle(isOn: $habitModel.isRemainderOn){}
                        .labelsHidden()
                }
                .opacity(habitModel.notificationAccess ? 1 : 0)
                HStack(spacing: 12){
                    Label {
                        Text(habitModel.remainderDate.formatted(date: .omitted, time: .shortened))
                    } icon: {
                        Image(systemName: "clock")
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(Color(.white).opacity(0.4), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .onTapGesture{
                        withAnimation{
                            habitModel.showTimePicker.toggle()
                        }
                    }
                    
                    TextField("remainder text", text: $habitModel.remainderText)
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(Color(.white).opacity(0.4), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                    
                }
                .frame(height: habitModel.isRemainderOn ? nil : 0)
                .opacity(habitModel.isRemainderOn ? 1 : 0)
                .opacity(habitModel.notificationAccess ? 1 : 0)
            }
            .animation(.easeInOut, value: habitModel.isRemainderOn)
            .frame(maxHeight: .infinity, alignment: .top)
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(habitModel.editHabit != nil ? "edit habit"  : "add habit")
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading){
                    Button {
                        env.dismiss()
                    } label: {
                        Image(systemName: "xmark.circle")
                    }
                    .tint(.white)
                }
                // MARK: delete button
                ToolbarItem(placement: .navigationBarLeading){
                    Button {
                        if habitModel.deleteHabit(context: env.managedObjectContext){
                            env.dismiss()
                        }
                    } label: {
                        Image(systemName: "trash")
                    }
                    .tint(.red)
                    .opacity(habitModel.editHabit == nil ? 0 : 1)
                }
                
                ToolbarItem(placement: .navigationBarTrailing){
                    Button("done"){
                        Task{
                            if await habitModel.addHabit(context: env.managedObjectContext){
                                env.dismiss()
                            }
                        }
                    }
                    .tint(.white)
                    .disabled(!habitModel.doneStatus())
                    .opacity(habitModel.doneStatus() ? 1 : 0.6 )
                }
            }
        }
        .overlay{
            if habitModel.showTimePicker{
                ZStack{
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea()
                        .onTapGesture{
                            withAnimation{
                                habitModel.showTimePicker.toggle()
                            }
                        }
                    DatePicker.init("", selection: $habitModel.remainderDate, displayedComponents: [.hourAndMinute])
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .background{
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color("TFBG"))
                        }
                }
            }
        }
    }
}

struct AddNewHabit_Previews: PreviewProvider {
    static var previews: some View {
        AddNewHabit()
            .environmentObject(HabitViewModel())
            .preferredColorScheme(.dark)
    }
}
