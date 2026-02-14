//
//  GoalTasksModel.swift
//  todoTask
//
//  Created by Ruba Alghamdi on 25/08/1447 AH.
//

import Foundation

struct TaskSpec: Hashable {
    var action: String
    var quantity: Int
    var unit: String

    var title: String {
        "\(action) \(quantity) \(unit)"
    }
}

struct GoalTask: Identifiable, Hashable {
    let id = UUID()
    var spec: TaskSpec
    var isDone: Bool = false

    var title: String { spec.title }
}
