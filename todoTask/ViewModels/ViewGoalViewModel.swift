import Foundation
import SwiftUI
import Combine



class ViewGoalViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var goal: Goal?
    @Published var progressSnapshot: ProgressSnapshot?
    @Published var planetState: PlanetState = .hidden
    @Published var isLoading: Bool = false
    
    // MARK: - 1. تحميل الهدف
    
    func loadGoal(goalID: String) {
        isLoading = true
        
        // استرجاع الهدف من قاعدة البيانات
        // goal = fetchGoalFromDatabase(goalID)
        
        if let goal = goal {
            // حساب التقدم الحالي
            let snapshot = calculateProgress(for: goal)
            self.progressSnapshot = snapshot
            
            // تحديث حالة الكوكب
            let state = determinePlanetState(for: goal)
            self.planetState = state
        }
        
        isLoading = false
    }
    
    // MARK: - 2. إدارة المهام
    
    /// إكمال/إلغاء مهمة
    func toggleTask(taskID: String) {
        guard var goal = goal else { return }
        
        if let index = goal.subTasks.firstIndex(where: { $0.id == taskID }) {
            // تبديل الحالة
            goal.subTasks[index].isCompleted.toggle()
            
            if goal.subTasks[index].isCompleted {
                goal.subTasks[index].completedAt = Date()
                
                // فتح المهمة التالية (إذا كان فيه dependencies)
                unlockNextSubTask(after: taskID, in: &goal)
            } else {
                goal.subTasks[index].completedAt = nil
            }
            
            // إعادة حساب التقدم
            updateProgress(for: goal)
            
            // حفظ التغييرات
            self.goal = goal
            // saveGoalToDatabase(goal)
        }
    }
    
    /// إضافة مهمة جديدة
    func addNewTask(title: String, description: String? = nil) {
        guard var goal = goal else { return }
        guard !title.isEmpty else { return }
        
        let newTask = SubTask(
            id: UUID().uuidString,
            title: title,
            description: description,
            order: goal.subTasks.count,
            isCompleted: false,
            isLocked: false,
            dependsOn: nil,
            completedAt: nil
        )
        
        goal.subTasks.append(newTask)
        
        // إعادة حساب التقدم
        updateProgress(for: goal)
        
        self.goal = goal
        // saveGoalToDatabase(goal)
    }
    
    /// حذف مهمة
    func deleteTask(taskID: String) {
        guard var goal = goal else { return }
        
        goal.subTasks.removeAll { $0.id == taskID }
        
        // إعادة حساب التقدم
        updateProgress(for: goal)
        
        self.goal = goal
        // saveGoalToDatabase(goal)
    }
    
    /// تعديل مهمة
    func editTask(taskID: String, newTitle: String, newDescription: String?) {
        guard var goal = goal else { return }
        
        if let index = goal.subTasks.firstIndex(where: { $0.id == taskID }) {
            goal.subTasks[index].title = newTitle
            goal.subTasks[index].description = newDescription
            
            self.goal = goal
            // saveGoalToDatabase(goal)
        }
    }
    
    // MARK: - 3. حساب التقدم
    
    private func calculateProgress(for goal: Goal) -> ProgressSnapshot {
        let totalSubTasks = goal.subTasks.count
        let completedSubTasks = goal.subTasks.filter { $0.isCompleted }.count
        
        let completionPercentage = totalSubTasks > 0
            ? (Double(completedSubTasks) / Double(totalSubTasks)) * 100.0
            : 0.0
        
        let isLate = checkIfLate(goal)
        
        return ProgressSnapshot(
            goalID: goal.id,
            completedSubTasks: completedSubTasks,
            totalSubTasks: totalSubTasks,
            completionPercentage: completionPercentage,
            isLate: isLate,
            lastUpdated: Date()
        )
    }
    
    private func checkIfLate(_ goal: Goal) -> Bool {
        guard let endDate = goal.endDate else { return false }
        let now = Date()
        let isOverdue = now > endDate
        let isNotCompleted = goal.state != .completed
        return isOverdue && isNotCompleted
    }
    
    private func updateProgress(for goal: Goal) {
        let snapshot = calculateProgress(for: goal)
        self.progressSnapshot = snapshot
        
        let state = determinePlanetState(for: goal)
        self.planetState = state
    }
    
    // MARK: - 4. حالة الكوكب
    
    private func determinePlanetState(for goal: Goal) -> PlanetState {
        let progress = calculateProgress(for: goal)
        
        switch goal.state {
        case .draft:
            return .hidden
        case .active:
            if progress.completionPercentage >= 100.0 {
                return .completed
            } else if progress.isLate {
                return .damaged
            } else {
                return .active
            }
        case .locked:
            return .hidden
        case .completed:
            return .completed
        case .failed:
            return .damaged
        }
    }
    
    /// الحصول على الأنيميشنات الحالية
    func getPlanetAnimations() -> [String] {
        switch planetState {
        case .hidden: return []
        case .active: return ["pulse", "rotate"]
        case .completed: return ["explode_confetti", "glow"]
        case .damaged: return ["shake", "crack"]
        case .stolen: return ["fade_out", "disappear"]
        }
    }
    
    // MARK: - 5. فتح المهمة التالية
    
    private func unlockNextSubTask(after completedTaskID: String, in goal: inout Goal) {
        for (index, subTask) in goal.subTasks.enumerated() {
            if subTask.dependsOn == completedTaskID {
                goal.subTasks[index].isLocked = false
            }
        }
    }
    
    // MARK: - 6. الإحصائيات
    
    /// عدد المهام المكتملة
    func getCompletedTasksCount() -> Int {
        return goal?.subTasks.filter { $0.isCompleted }.count ?? 0
    }
    
    /// عدد المهام الكلي
    func getTotalTasksCount() -> Int {
        return goal?.subTasks.count ?? 0
    }
    
    /// نسبة التقدم
    func getProgressPercentage() -> Double {
        return progressSnapshot?.completionPercentage ?? 0.0
    }
    
    /// هل الهدف متأخر؟
    func isGoalLate() -> Bool {
        return progressSnapshot?.isLate ?? false
    }
    
    /// عدد الأيام المتبقية
    func getDaysRemaining() -> Int? {
        guard let endDate = goal?.endDate else { return nil }
        
        let components = Calendar.current.dateComponents(
            [.day],
            from: Date(),
            to: endDate
        )
        
        return components.day
    }
    
    // MARK: - 7. تحديث الهدف
    
    /// تحديث عنوان الهدف
    func updateGoalTitle(_ title: String) {
        guard var goal = goal else { return }
        guard !title.isEmpty else { return }
        
        goal.title = title
        goal.updatedAt = Date()
        
        self.goal = goal
        // saveGoalToDatabase(goal)
    }
    
    /// تفعيل الهدف (من draft إلى active)
    func activateGoal() {
        guard var goal = goal, goal.state == .draft else { return }
        
        goal.state = .active
        goal.updatedAt = Date()
        
        self.goal = goal
        updateProgress(for: goal)
        // saveGoalToDatabase(goal)
    }
    
    /// إغلاق الهدف (مكتمل)
    func completeGoal() {
        guard var goal = goal else { return }
        
        goal.state = .completed
        goal.planetState = .completed
        goal.completedAt = Date()
        
        self.goal = goal
        updateProgress(for: goal)
        // saveGoalToDatabase(goal)
    }
    
    /// إغلاق الهدف (فاشل)
    func failGoal() {
        guard var goal = goal else { return }
        
        goal.state = .failed
        goal.planetState = .damaged
        goal.completedAt = Date()
        
        self.goal = goal
        updateProgress(for: goal)
        // saveGoalToDatabase(goal)
    }
}
