//
//  Components.swift
//  todoTask
//
//  Created by شهد عبدالله القحطاني on 22/08/1447 AH.
//


import SwiftUI

// MARK: - Shared Background Component
struct AppBackground: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.color, .dark],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .ignoresSafeArea()
            
            Image("Gliter")
                .resizable()
                .scaledToFit()
                .scaleEffect(1.2)
                .contrast(1.9)
                .ignoresSafeArea()
        }
    }
}

// MARK: - Navigation Bar Component
struct AppNavigationBar: View {
    let title: String
    let onBack: () -> Void
    let onNext: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.clear)
                    .glassEffect(.clear.tint(Color.black.opacity(0.4)), in: .rect(cornerRadius: 24))
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            }
            
            Spacer()
            
            Text(title)
                .font(.system(size: 25, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: onNext) {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color.clear)
                    .glassEffect(.clear.tint(Color.black.opacity(0.4)), in: .rect(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            }
        }
        .padding()
    }
}

// MARK: - Glass Card Container
struct GlassCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 16) {
            content
        }
        .padding(9)
        .padding(.vertical, 33)
        .frame(maxWidth: .infinity)
        .glassEffect(.clear.tint(Color.black.opacity(0.4)), in: .rect(cornerRadius: 24))
        
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 20, weight: .medium))
            .foregroundColor(.white.opacity(0.9))
//            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Text Field with Glass Effect
struct GlassTextField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .foregroundColor(.white)
            .padding()
            .background(Color.clear)
            .glassEffect(.clear.tint(Color.black.opacity(0.4)), in: .rect(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.9), lineWidth: 1)
            )
    }
}


// MARK: - Number Stepper Component
struct NumberStepper: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let suffix: String
    
    var body: some View {
        HStack {
            // زر الناقص
            Button(action: {
                if value > range.lowerBound {
                    value -= 1
                }
            }) {
                Image(systemName: "minus")
                    .font(.system(size: 22, weight: .bold))  // 🔄 كبّرنا الخط من 20 إلى 22
                    .foregroundColor(.white)
                    .frame(width: 15, height: 15)  // 🔄 كبّرنا الإطار من 44 إلى
            }
            
            Spacer()
            
            // الرقم
            Text("\(value) \(suffix)")
                .font(.system(size: 22, weight: .medium))  // 🔄 كبّرنا من 20 إلى 22
                .foregroundColor(.white.opacity(1))  // 🔄 خففنا اللون من 1.0 إلى 0.6
            
            Spacer()
            
            // زر الزائد
            Button(action: {
                if value < range.upperBound {
                    value += 1
                }
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))  // 🔄 كبّرنا من 16 إلى 22
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)  // 🔄 كبّرنا من 44 إلى 50
                    // ❌ شلنا .background و .glassEffect
            }
        }
        .padding(.horizontal, 20)  // ✅ أضفنا مسافة داخلية أفقية
        .padding(.vertical, 1)    // ✅ أضفنا مسافة داخلية رأسية
        .background(
            RoundedRectangle(cornerRadius: 18)  // ✅ خلفية مستديرة
                .fill(Color.black.opacity(0.45))  // ✅ لون داكن شفاف
        )
    }
}

// MARK: - Week Days Selector
struct WeekDaysSelector: View {
    @Binding var selectedDays: Set<Int>
    let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        HStack(spacing: 2) {  // 🔄 زودنا المسافة من 8 إلى 12
            ForEach(0..<7, id: \.self) { index in
                Button(action: {
                    if selectedDays.contains(index) {
                        selectedDays.remove(index)
                    } else {
                        selectedDays.insert(index)
                    }
                }) {
                    Text(days[index])
                        .font(.system(size: 15, weight: .medium))  // 🔄 كبّرنا من 13 إلى 15
                        .foregroundColor(.white)
                        .frame(width: 48, height: 48)  // 🔄 كبّرنا من 44 إلى 48
                        .background(
                            selectedDays.contains(index)
                            ? Color.white.opacity(0.15)  // 🔄 خففنا من 0.3 إلى 0.15
                            : Color.clear
                        )
                        .clipShape(Circle())
                       
                }
            }
        }
    }
}
            

// MARK: - Time Picker Row

struct TimePickerRow: View {
    @Binding var startTime: Date
    @Binding var endTime: Date
    
    var body: some View {
        HStack(spacing: 12) {
            // أول DatePicker
            DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .colorScheme(.dark)
                .padding(.horizontal, 15)  // 🔄 غيرنا من .padding(8) إلى horizontal
                .padding(.vertical, 18)    // ✅ أضفنا vertical padding
                .background(
                    RoundedRectangle(cornerRadius: 12)  // 🔄 غيرنا من 10 إلى 12
                        .fill(Color.black.opacity(0.8))  // ✅ بدلنا glassEffect بخلفية داكنة
                )
                // ❌ شلنا .background(Color.clear) و .glassEffect
            
            Text("to")
                .font(.system(size: 15, weight: .medium))  // ✅ أضفنا .medium
                .foregroundColor(.white.opacity(0.6))  // 🔄 خففنا من 0.7 إلى 0.6
            
            // ثاني DatePicker
            DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .colorScheme(.dark)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.4))
                )
            
            Button(action: {}) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.white.opacity(0.5))
                    .font(.system(size: 24))  // 🔄 كبّرنا من 20 إلى 24
            }
        }
    }
}


// MARK: - Date Picker Component
struct GlassDatePicker: View {
    let title: String
    @Binding var date: Date
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 20, weight: .medium))  // 🔄 كبّرنا من 15 إلى 20
                .foregroundColor(.white)
            
            Spacer()
            
            DatePicker("", selection: $date, displayedComponents: .date)
                .labelsHidden()
                .colorScheme(.dark)
                .padding(.horizontal, 45)  // ✅ أضفنا padding أفقي
                .padding(.vertical, 16)    // ✅ أضفنا padding رأسي
               
        }
    }
}


// MARK: - Toggle Switch Component
struct GlassToggle: View {
    let option1: String
    let option2: String
    @Binding var isOption1: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            // الخيار الأول
            Button(action: { isOption1 = true }) {
                Text(option1)
                    .font(.system(size: 15, weight: .medium))  // 🔄 كبّرنا من 14 إلى 15
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)  // 🔄 زودنا من 20 إلى 24
                    .padding(.vertical, 10)    // 🔄 زودنا من 8 إلى 10
                    .background(
                        RoundedRectangle(cornerRadius: 16)  // 🔄 غيرنا من 15 إلى 16
                            .fill(isOption1 ? Color.white.opacity(0.2) : Color.black.opacity(0.3))
                            // 🔄 بدلنا: لما مختار = أبيض 0.2، لما مو مختار = أسود 0.3
                    )
                    // ❌ شلنا .glassEffect و .overlay
            }
            
            // الخيار الثاني
            Button(action: { isOption1 = false }) {
                Text(option2)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(!isOption1 ? Color.white.opacity(0.2) : Color.black.opacity(0.3))
                    )
            }
        }
    }
}

// MARK: - Custom Text Field
struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .foregroundColor(.white)
            .font(.system(size: 17))
            .padding(.horizontal, 24)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.black.opacity(0.45))
            )
    }
}
// MARK: - Slider Component
struct GlassSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    
    var body: some View {
        Slider(value: $value, in: range)
            .accentColor(.white)
            .tint(.white)         // ✅ أضفنا .tint للتوافق
    }
}
#Preview {
    FinishTotalView()
}
