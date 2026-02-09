//
//  PlanetDesignViewModel.swift
//  todoTask
//
//  Created by شهد عبدالله القحطاني on 20/08/1447 AH.
//


import Foundation
import SwiftUI
import Combine

// MARK: - 🪐 Planet Design ViewModel (صفحة 8)

class PlanetDesignViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var planetDesign: PlanetDesign
    @Published var selectedTheme: PlanetTheme = .rainbowCustom
    @Published var trackingMode: TrackingMode = .reduceBy
    @Published var metricType: MetricType = .screenTime
    
    // MARK: - Initialization
    init() {
        // تصميم افتراضي
        self.planetDesign = PlanetDesign(
            colors: PlanetTheme.rainbowCustom.defaultColors,
            glowIntensity: 50,
            ringCount: 1,
            ringThickness: 50,
            textureIntensity: 50,
            baselineNumber: nil,
            targetNumber: nil
        )
    }
    
    // MARK: - Color Functions
    
    /// إضافة لون
    func addColor(_ color: PlanetColor) {
        if planetDesign.colors.count < 4 {
            planetDesign.colors.append(color)
        }
    }
    
    /// حذف لون
    func removeColor(at index: Int) {
        guard planetDesign.colors.count > 1 else { return }
        planetDesign.colors.remove(at: index)
    }
    
    /// تحديث لون
    func updateColor(at index: Int, to color: PlanetColor) {
        guard index < planetDesign.colors.count else { return }
        planetDesign.colors[index] = color
    }
    
    // MARK: - Design Functions
    
    /// تحديث شدة التوهج
    func updateGlowIntensity(_ value: Double) {
        planetDesign.glowIntensity = max(0, min(100, value))
    }
    
    /// تحديث عدد الحلقات
    func updateRingCount(_ count: Int) {
        planetDesign.ringCount = max(0, min(3, count))
    }
    
    /// تحديث سمك الحلقات
    func updateRingThickness(_ value: Double) {
        planetDesign.ringThickness = max(0, min(100, value))
    }
    
    /// تحديث شدة النسيج
    func updateTextureIntensity(_ value: Double) {
        planetDesign.textureIntensity = max(0, min(100, value))
    }
    
    // MARK: - Theme Functions
    
    /// تطبيق ثيم جاهز
    func applyTheme(_ theme: PlanetTheme) {
        selectedTheme = theme
        planetDesign.colors = theme.defaultColors
    }
    
    /// الحصول على ثيم بناءً على الفئة
    func getThemeForCategory(_ category: GoalCategory) -> PlanetTheme {
        switch category {
        case .habit: return .greenNature
        case .project: return .blueTech
        case .learning: return .purpleWisdom
        case .fitness: return .redEnergy
        case .finance: return .goldWealth
        case .custom: return .rainbowCustom
        }
    }
    
    // MARK: - Number Functions (للـ Reduce Something)
    
    /// تحديث الرقم الأساسي
    func updateBaselineNumber(_ number: Int) {
        planetDesign.baselineNumber = number
    }
    
    /// تحديث رقم الهدف
    func updateTargetNumber(_ number: Int) {
        planetDesign.targetNumber = number
    }
    
    /// زيادة الرقم
    func incrementNumber(isBaseline: Bool) {
        if isBaseline {
            planetDesign.baselineNumber = (planetDesign.baselineNumber ?? 0) + 1
        } else {
            planetDesign.targetNumber = (planetDesign.targetNumber ?? 0) + 1
        }
    }
    
    /// تقليل الرقم
    func decrementNumber(isBaseline: Bool) {
        if isBaseline {
            if let current = planetDesign.baselineNumber, current > 0 {
                planetDesign.baselineNumber = current - 1
            }
        } else {
            if let current = planetDesign.targetNumber, current > 0 {
                planetDesign.targetNumber = current - 1
            }
        }
    }
    
    // MARK: - Tracking Mode
    
    /// تغيير وضع التتبع
    func updateTrackingMode(_ mode: TrackingMode) {
        trackingMode = mode
    }
    
    /// تحديث نوع المقياس
    func updateMetricType(_ type: MetricType) {
        metricType = type
    }
    
    // MARK: - Reset
    
    /// إعادة تعيين التصميم
    func resetDesign() {
        planetDesign = PlanetDesign(
            colors: selectedTheme.defaultColors,
            glowIntensity: 50,
            ringCount: 1,
            ringThickness: 50,
            textureIntensity: 50,
            baselineNumber: nil,
            targetNumber: nil
        )
    }
}
