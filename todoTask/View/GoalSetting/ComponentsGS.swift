import SwiftUI
import UIKit

struct AppBackground: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(LinearGradient(colors: [.darkBlu, .dark], startPoint: .bottom, endPoint: .top))
                .ignoresSafeArea()
            Image("Star")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.85)

            Image("Gliter")
                .resizable()
                .ignoresSafeArea()
        }
    }
}

// MARK: - Goal flow layout (shared metrics for every add-goal screen)

enum GoalFlowLayout {
    static let buttonSize: CGFloat = 50
    static let topBarHeight: CGFloat = 50
    static let topBarBottomGap: CGFloat = 8
    static let horizontalPadding: CGFloat = 16
    static let contentTopGap: CGFloat = 8
    static let referenceWidth: CGFloat = 390

    /// Scales a layout value for the current device width (clamped so iPad does not blow up).
    static func scaled(_ value: CGFloat, width: CGFloat) -> CGFloat {
        let factor = min(max(width / referenceWidth, 0.85), 1.12)
        return value * factor
    }

    static var topSafeArea: CGFloat {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap(\.windows)
            .first(where: \.isKeyWindow) else {
            return 54
        }
        return max(window.safeAreaInsets.top, 47)
    }

    /// Distance from physical top of screen to where page content begins (same on every step).
    static var contentTopOffset: CGFloat {
        topSafeArea + topBarHeight + topBarBottomGap + contentTopGap
    }
}

struct GoalFlowBackButton: View {
    let action: () -> Void
    @EnvironmentObject private var lang: LanguageManager

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.backward")
                .font(.title2.weight(.semibold))
                .foregroundColor(.white)
                .frame(width: GoalFlowLayout.buttonSize, height: GoalFlowLayout.buttonSize)
                .glassEffect(.clear.tint(Color.black.opacity(0.4)), in: .rect(cornerRadius: 24))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Back")
    }
}

/// Back + trailing action; respects app `layoutDirection` (RTL in Arabic).
struct GoalFlowNavigationRow<Trailing: View>: View {
    let onBack: () -> Void
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            GoalFlowBackButton(action: onBack)
            Spacer(minLength: 0)
            trailing()
        }
    }
}

struct GoalFlowNextButton: View {
    let action: () -> Void
    @EnvironmentObject private var lang: LanguageManager

    var body: some View {
        Button(action: action) {
            Text(lang.t(.next))
                .font(.headline)
                .foregroundColor(.white)
                .frame(minWidth: 96)
                .frame(height: GoalFlowLayout.buttonSize)
                .glassEffect(.clear.tint(Color.black.opacity(0.4)), in: .rect(cornerRadius: 24))
        }
        .buttonStyle(.plain)
    }
}

struct GoalFlowCheckButton: View {
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "checkmark")
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: GoalFlowLayout.buttonSize, height: GoalFlowLayout.buttonSize)
                .glassEffect(.clear.tint(Color.black.opacity(0.4)), in: .rect(cornerRadius: 24))
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.5)
    }
}

struct GoalFlowTitleBar: View {
    let title: String
    let onBack: () -> Void
    let onNext: () -> Void
    @EnvironmentObject private var lang: LanguageManager

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            GoalFlowBackButton(action: onBack)
            Spacer(minLength: 8)
            Text(title)
                .font(.system(size: 25, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
            Spacer(minLength: 8)
            GoalFlowNextButton(action: onNext)
        }
        .frame(height: GoalFlowLayout.topBarHeight)
    }
}

struct AppNavigationBar: View {
    let title: String
    let onBack: () -> Void
    let onNext: () -> Void

    var body: some View {
        GoalFlowTitleBar(title: title, onBack: onBack, onNext: onNext)
    }
}

struct GoalFlowScreen<Background: View, TopBar: View, Content: View>: View {
    @EnvironmentObject private var lang: LanguageManager
    @ViewBuilder var background: () -> Background
    @ViewBuilder var topBar: () -> TopBar
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack {
            background()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar()
                    .frame(maxWidth: .infinity)
                    .frame(height: GoalFlowLayout.topBarHeight)
                    .padding(.horizontal, GoalFlowLayout.horizontalPadding)
                    .padding(.top, GoalFlowLayout.topSafeArea)
                    .padding(.bottom, GoalFlowLayout.topBarBottomGap)

                content()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, GoalFlowLayout.contentTopGap)
            }
        }
        .environment(\.layoutDirection, lang.language.layoutDirection)
        .environment(\.locale, lang.language.locale)
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden(true)
    }
}

struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            content
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.clear.tint(Color.black.opacity(0.4)), in: .rect(cornerRadius: 24))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

// MARK: - Progress (card only — not around the orb)

struct GoalProgressBar: View {
    var progress: Double
    var tint: Color = .cyan
    var trackOpacity: Double = 0.15
    var height: CGFloat = 6

    var body: some View {
        let p = max(0, min(progress, 1))
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.white.opacity(trackOpacity))
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(tint)
                    .frame(width: geo.size.width * p)
                    .animation(.easeInOut(duration: 0.35), value: p)
            }
        }
        .frame(height: height)
    }
}

struct GoalChallengeProgressBars: View {
    var myProgress: Double
    var friendProgress: Double
    var friendName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("You")
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(.cyan)
                Spacer()
                Text("\(Int(myProgress * 100))%")
                    .font(.caption2.monospacedDigit())
                    .foregroundColor(.white.opacity(0.7))
            }
            GoalProgressBar(progress: myProgress, tint: .cyan)
            HStack {
                Text(friendName)
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(.orange)
                Spacer()
                Text("\(Int(friendProgress * 100))%")
                    .font(.caption2.monospacedDigit())
                    .foregroundColor(.white.opacity(0.7))
            }
            GoalProgressBar(progress: friendProgress, tint: .orange)
        }
    }
}

// MARK: - Tap-to-type numeric amount (0…max)

struct EditableAmountCounter: View {
    let completed: Int
    let target: Int
    let onSet: (Int) -> Void

    @EnvironmentObject private var lang: LanguageManager
    @State private var showEditor = false
    @State private var draftText  = ""

    var body: some View {
        Button {
            draftText = "\(completed)"
            showEditor = true
        } label: {
            Text("\(completed)/\(target)")
                .font(.caption.monospacedDigit().weight(.semibold))
                .foregroundColor(.white.opacity(0.9))
                .frame(minWidth: 44)
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(Capsule().fill(.white.opacity(0.1)))
        }
        .buttonStyle(.plain)
        .alert(lang.t(.enterAmount), isPresented: $showEditor) {
            TextField("0", text: $draftText)
                .keyboardType(.numberPad)
            Button(lang.t(.save)) {
                let n = Int(draftText.trimmingCharacters(in: .whitespaces)) ?? 0
                onSet(min(max(0, n), target))
            }
            Button(lang.t(.cancel), role: .cancel) {}
        } message: {
            Text(lang.t(.enterCompletedAmount))
        }
    }
}

struct EditableQuantityField: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let suffix: String
    var embedded: Bool = false

    @State private var text: String = ""

    var body: some View {
        HStack(spacing: 8) {
            TextField("1", text: $text)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .font(.system(size: 20, weight: .semibold))
                .onChange(of: text) { _, new in
                    let filtered = new.filter(\.isNumber)
                    if filtered != new { text = filtered }
                    if let n = Int(filtered), range.contains(n) {
                        value = n
                    }
                }
                .onAppear { text = "\(value)" }
                .onChange(of: value) { _, v in
                    if text != "\(v)" { text = "\(v)" }
                }

            if !suffix.isEmpty {
                Text(suffix)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.65))
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, embedded ? 4 : 16)
        .padding(.vertical, embedded ? 4 : 14)
        .modifier(EmbeddedSurface(embedded: embedded))
    }
}

private struct EmbeddedSurface: ViewModifier {
    let embedded: Bool
    func body(content: Content) -> some View {
        if embedded { content } else { content.goalFormSurface() }
    }
}

/// Same glass + icon style as goal-creation screens (FAB / add task).
struct GoalFlowAddButton: View {
    var size: CGFloat = 50
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: size * 0.42, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: size, height: size)
                .glassEffect(.clear.tint(Color.accent.opacity(0.55)), in: .circle)
        }
        .buttonStyle(.plain)
    }
}

struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.white.opacity(0.9))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Label + field block — same alignment for stepper, date, time, etc.
struct GoalFormField<Content: View>: View {
    let title: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: title)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

enum GoalFormStyle {
    static let fieldRadius: CGFloat = 15
    static let fieldFill = Color.black.opacity(0.4)
}

extension View {
    func goalFormSurface() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: GoalFormStyle.fieldRadius)
                    .fill(GoalFormStyle.fieldFill)
            )
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
            .glassEffect(.clear.tint(Color.black.opacity(0.4)), in: .rect(cornerRadius: 20))
    }
}

struct NumberStepper: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let suffix: String
    /// Goal setup only: tap center to type a large number.
    var allowsTyping: Bool = false

    var body: some View {
        HStack {
            stepButton(systemName: "minus") {
                if value > range.lowerBound { value -= 1 }
            }
            Spacer()
            if allowsTyping {
                EditableQuantityField(
                    title: title,
                    value: $value,
                    range: range,
                    suffix: suffix
                )
                .frame(maxWidth: 200)
            } else {
                Text("\(value) \(suffix)")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.white)
            }
            Spacer()
            stepButton(systemName: "plus") {
                if value < range.upperBound { value += 1 }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, allowsTyping ? 8 : 4)
        .goalFormSurface()
    }

    private func stepButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
        }
        .buttonStyle(.plain)
    }
}

//struct WeekDaysSelector: View {
//    @Binding var selectedDays: Set<Int>
//    let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
//    
//    var body: some View {
//        HStack(spacing: 2) {
//            ForEach(0..<7, id: \.self) { index in
//                Button(action: {
//                    if selectedDays.contains(index) {
//                        selectedDays.remove(index)
//                    } else {
//                        selectedDays.insert(index)
//                    }
//                }) {
//                    Text(days[index])
//                        .font(.system(size: 15, weight: .medium))
//                        .foregroundColor(.white)
//                        .frame(width: 48, height: 48)
//                        .background(
//                            selectedDays.contains(index)
//                            ? Color.white.opacity(0.15)
//                            : Color.clear
//                        )
//                        .clipShape(Circle())
//                }
//            }
//        }
//    }
//}
//struct WeekDaysSelector: View {
//    @Binding var selectedDays: Set<Int>
//
//    let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
//
//    var body: some View {
//        HStack(spacing: 2) {
//
//            ForEach(1...7, id: \.self) { calendarIndex in
//
//                let displayIndex = calendarIndex - 1
//
//                Button {
//                    if selectedDays.contains(calendarIndex) {
//                        selectedDays.remove(calendarIndex)
//                    } else {
//                        selectedDays.insert(calendarIndex)
//                    }
//                } label: {
//
//                    Text(days[displayIndex])
//                        .font(.system(size: 15, weight: .medium))
//                        .foregroundColor(.white)
//                        .frame(width: 48, height: 48)
//                        .background(
//                            selectedDays.contains(calendarIndex)
//                            ? Color.white.opacity(0.15)
//                            : Color.clear
//                        )
//                        .clipShape(Circle())
//                }
//            }
//        }
//    }
//}
struct WeekDaysSelector: View {
    @Binding var selectedDays: Set<Int>
    @EnvironmentObject private var lang: LanguageManager

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...7, id: \.self) { calendarIndex in
                Button {
                    if selectedDays.contains(calendarIndex) {
                        selectedDays.remove(calendarIndex)
                    } else {
                        selectedDays.insert(calendarIndex)
                    }
                } label: {
                    Text(lang.weekdayShort(calendarIndex: calendarIndex))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    selectedDays.contains(calendarIndex)
                                    ? Color.white.opacity(0.18)
                                    : Color.black.opacity(0.35)
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
//struct TimePickerRow: View {
//    @Binding var startTime: Date
//    @Binding var endTime: Date
//    
//    var body: some View {
//        HStack(spacing: 12) {
//            DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
//                .labelsHidden()
//                .colorScheme(.dark)
//            
//            Text("to")
//                .font(.system(size: 15, weight: .medium))
//                .foregroundColor(.white.opacity(0.6))
//            
//            DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
//                .labelsHidden()
//                .colorScheme(.dark)
//            
//            Button(action: {}) {
//                Image(systemName: "plus.circle.fill")
//                    .foregroundColor(.white.opacity(0.6))
//                    .font(.system(size: 20))
//            }
//        }
//    }
//}
struct TimePickerRow: View {
    @Binding var startTime: Date
    @Binding var endTime: Date

    var body: some View {
        HStack(spacing: 10) {
            DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .colorScheme(.dark)
                .frame(maxWidth: .infinity)

            Text("to")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.white.opacity(0.55))

            DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .colorScheme(.dark)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .goalFormSurface()
    }
}
//struct GlassDatePicker: View {
//    let title: String
//    @Binding var date: Date
//    
//    var body: some View {
//        HStack {
//            Text(title)
//                .font(.system(size: 20, weight: .medium))
//                .foregroundColor(.white)
//            
//            Spacer()
//            
//            DatePicker("", selection: $date, displayedComponents: .date)
////                .labelsHidden()
////                .colorScheme(.dark)
////                .padding(.vertical, 16)
////                .frame(maxWidth: 280)
//                .labelsHidden()
//                .datePickerStyle(.compact)
//                .colorScheme(.dark)
//                .frame(height: 160)
//        }
//    }
//}

/// Deadline optional until the user taps to choose — calendar ignores nil deadline.
struct OptionalGoalDateField: View {
    @Binding var date: Date?
    @EnvironmentObject private var lang: LanguageManager
    @State private var showPicker = false
    @State private var draft = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                if date == nil { date = draft }
                withAnimation(.spring(response: 0.3)) { showPicker.toggle() }
            } label: {
                HStack {
                    if let date {
                        Text(date.formatted(date: .abbreviated, time: .omitted))
                            .font(.system(size: 17))
                            .foregroundColor(.white.opacity(0.9))
                    } else {
                        Text(lang.t(.chooseDeadline))
                            .font(.system(size: 17))
                            .foregroundColor(.white.opacity(0.45))
                    }
                    Spacer()
                    Image(systemName: showPicker ? "chevron.up" : "calendar")
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)

            if showPicker {
                DatePicker(
                    "",
                    selection: Binding(
                        get: { date ?? draft },
                        set: { new in
                            draft = new
                            date = new
                        }
                    ),
                    in: Date()...,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .colorScheme(.dark)
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
        }
        .goalFormSurface()
        .onAppear {
            draft = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
        }
    }
}

/// Date row only — pair with `GoalFormField(title:)` for aligned setup forms.
struct GoalDateField: View {
    @Binding var date: Date
    @State private var showPicker = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3)) { showPicker.toggle() }
            } label: {
                HStack {
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 17))
                        .foregroundColor(.white.opacity(0.9))
                    Spacer()
                    Image(systemName: showPicker ? "chevron.up" : "calendar")
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)

            if showPicker {
                DatePicker("", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .colorScheme(.dark)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
            }
        }
        .goalFormSurface()
    }
}

/// Legacy wrapper — prefer `GoalFormField` + `GoalDateField`.
struct GlassDatePicker: View {
    let title: String
    @Binding var date: Date

    var body: some View {
        GoalFormField(title: title) {
            GoalDateField(date: $date)
        }
    }
}

struct GlassToggle: View {
    let option1: String
    let option2: String
    @Binding var isOption1: Bool

    var body: some View {
        HStack(spacing: 8) {
            toggleButton(option1, selected: isOption1) { isOption1 = true }
            toggleButton(option2, selected: !isOption1) { isOption1 = false }
        }
        .frame(maxWidth: .infinity)
    }

    private func toggleButton(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(selected ? Color.white.opacity(0.2) : Color.black.opacity(0.3))
                )
        }
        .buttonStyle(.plain)
    }
}


struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .colorScheme(.dark)
            .padding(14)

            .frame(maxWidth: .infinity)
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
//
