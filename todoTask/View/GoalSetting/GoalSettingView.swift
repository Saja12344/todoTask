import SwiftUI

struct FinishTotalContent: View {
    @State private var targetNumber: Int = 1
    @State private var unit: String = ""
    @State private var deadlineDate = Date()
    @State private var selectedDays: Set<Int> = []
    
    var body: some View {
        GlassCard {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Target Number:")
                    NumberStepper(
                        title: "",
                        value: $targetNumber,
                        range: 1...1000,
                        suffix: ""
                    )
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    SectionHeader(title: "Unit:")
                    CustomTextField(
                        placeholder: "eg. Inches, Bottles, Cats",
                        text: $unit
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 25)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    GlassDatePicker(
                        title: "Deadline Date:",
                        date: $deadlineDate
                    )
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Days a Week:")
                    WeekDaysSelector(selectedDays: $selectedDays)
                }
            }
        }
    }
}

struct RepeatScheduleContent: View {
    @State private var unit: String = ""
    @State private var selectedDays: Set<Int> = []
    @State private var timeWindows: [TimeWindowModel] = [TimeWindowModel()]
    
    var body: some View {
        GlassCard {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Unit:")
                    CustomTextField(
                        placeholder: "eg. Inches, Bottles, Cats",
                        text: $unit
                    )
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Days a Week:")
                    WeekDaysSelector(selectedDays: $selectedDays)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Time Window:")
                    
                    ForEach(timeWindows.indices, id: \.self) { index in
                        HStack(spacing: 8) {
                            DatePicker("", selection: $timeWindows[index].startTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .colorScheme(.dark)
                                .frame(width: 110)
                            
                            Text("to")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.5))
                            
                            DatePicker("", selection: $timeWindows[index].endTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .colorScheme(.dark)
                                .frame(width: 110)
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Button(action: {
                        withAnimation {
                            timeWindows.append(TimeWindowModel())
                        }
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green.opacity(0.7))
                                .font(.system(size: 20))
                            Text("Add Time")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(.top, 4)
                }
            }
        }
    }
}

struct TimeWindowModel: Identifiable {
    let id = UUID()
    var startTime = Date()
    var endTime = Date()
}

struct BuildStreakContent: View {
    @State private var targetNumber: Int = 1
    @State private var unit: String = ""
    @State private var breakDays: Int = 0
    
    var body: some View {
        GlassCard {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Target Number:")
                    NumberStepper(
                        title: "",
                        value: $targetNumber,
                        range: 1...365,
                        suffix: "days"
                    )
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    SectionHeader(title: "Unit:")
                    CustomTextField(
                        placeholder: "eg. journaling, workout",
                        text: $unit
                    )
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Break Days Allowed:")
                    NumberStepper(
                        title: "",
                        value: $breakDays,
                        range: 0...7,
                        suffix: ""
                    )
                }
            }
        }
    }
}

struct LevelUpContent: View {
    @State private var activity: String = ""
    @State private var targetLevel: Int = 1
    @State private var selectedDays: Set<Int> = []
    @State private var stepUpPace: Int = 1
    
    var body: some View {
        GlassCard {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Activity:")
                    CustomTextField(
                        placeholder: "eg. running, reading, exercise",
                        text: $activity
                    )
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Target Level:")
                    NumberStepper(
                        title: "",
                        value: $targetLevel,
                        range: 1...100,
                        suffix: ""
                    )
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Days a Week:")
                    WeekDaysSelector(selectedDays: $selectedDays)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Step-up Pace Every")
                    NumberStepper(
                        title: "",
                        value: $stepUpPace,
                        range: 1...52,
                        suffix: "Weeks"
                    )
                }
            }
        }
    }
}

struct MilestonesContent: View {
    @State private var deadlineDate = Date()
    @State private var selectedDays: Set<Int> = []
    @State private var scopeSize: Double = 0
    @State private var dailyTimePreference: Int = 5
    
    var body: some View {
        GlassCard {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    GlassDatePicker(
                        title: "Deadline Date:",
                        date: $deadlineDate
                    )
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Days a Week:")
                    WeekDaysSelector(selectedDays: $selectedDays)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Scope Size")
                    GlassSlider(
                        value: $scopeSize,
                        range: 0...100
                    )
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Daily Time Preference")
                    NumberStepper(
                        title: "",
                        value: $dailyTimePreference,
                        range: 5...180,
                        suffix: "minutes"
                    )
                }
            }
        }
    }
}

struct ReduceContent: View {
    @State private var metricType: String = ""
    @State private var isReduceBy: Bool = true
    @State private var baselineNumber: Int = 0
    @State private var targetNumber: Int = 0
    
    var body: some View {
        GlassCard {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Metric type :")
                    CustomTextField(
                        placeholder: "eg. tomato time, social",
                        text: $metricType
                    )
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Tracking mode :")
                    GlassToggle(
                        option1: "Reduce by",
                        option2: "Stay Under",
                        isOption1: $isReduceBy
                    )
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Baseline Number:")
                    NumberStepper(
                        title: "",
                        value: $baselineNumber,
                        range: 0...1000,
                        suffix: ""
                    )
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Target Number:")
                    NumberStepper(
                        title: "",
                        value: $targetNumber,
                        range: 0...1000,
                        suffix: ""
                    )
                }
            }
        }
    }
}

