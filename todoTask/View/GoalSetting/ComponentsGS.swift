import SwiftUI

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
            }
        }
        .padding()
    }
}

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

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 20, weight: .medium))
            .foregroundColor(.white.opacity(0.9))
    }
}

struct GlassTextField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .foregroundColor(.white)
            .padding()
            .background(Color.clear)
            .glassEffect(.clear.tint(Color.black.opacity(0.4)), in: .rect(cornerRadius: 24))
    }
}

struct NumberStepper: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let suffix: String
    
    var body: some View {
        HStack {
            Button(action: {
                if value > range.lowerBound {
                    value -= 1
                }
            }) {
                Image(systemName: "minus")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
            }
            
            Spacer()
            
            Text("\(value) \(suffix)")
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: {
                if value < range.upperBound {
                    value += 1
                }
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
            }
        }
        .padding(.horizontal, 44)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.black.opacity(0.4))
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
        )
    }
}

struct WeekDaysSelector: View {
    @Binding var selectedDays: Set<Int>
    let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<7, id: \.self) { index in
                Button(action: {
                    if selectedDays.contains(index) {
                        selectedDays.remove(index)
                    } else {
                        selectedDays.insert(index)
                    }
                }) {
                    Text(days[index])
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 48, height: 48)
                        .background(
                            selectedDays.contains(index)
                            ? Color.white.opacity(0.15)
                            : Color.clear
                        )
                        .clipShape(Circle())
                }
            }
        }
    }
}

struct TimePickerRow: View {
    @Binding var startTime: Date
    @Binding var endTime: Date
    
    var body: some View {
        HStack(spacing: 12) {
            DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .colorScheme(.dark)
            
            Text("to")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
            
            DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .colorScheme(.dark)
            
            Button(action: {}) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.white.opacity(0.6))
                    .font(.system(size: 20))
            }
        }
    }
}

struct GlassDatePicker: View {
    let title: String
    @Binding var date: Date
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
            
            DatePicker("", selection: $date, displayedComponents: .date)
                .labelsHidden()
                .colorScheme(.dark)
                .padding(.horizontal, 45)
                .padding(.vertical, 16)
        }
    }
}

struct GlassToggle: View {
    let option1: String
    let option2: String
    @Binding var isOption1: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Button(action: { isOption1 = true }) {
                Text(option1)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isOption1 ? Color.white.opacity(0.2) : Color.black.opacity(0.3))
                    )
            }
            
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

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .foregroundColor(.white)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.black.opacity(0.4))
            )
    }
}

struct GlassSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    
    var body: some View {
        Slider(value: $value, in: range)
            .accentColor(.white)
            .tint(.white)
    }
}
