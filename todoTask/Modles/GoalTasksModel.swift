//
//  GoalTasksModel.swift
//  todoTask
//
//  Created by Ruba Alghamdi on 25/08/1447 AH.
//

import Foundation

struct GoalTask: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var isDone: Bool = false
}
