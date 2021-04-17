//
//  Task.swift
//  ToDoRxSwift
//
//  Created by Ignatio Julian on 17/04/21.
//

import Foundation

enum Priority: Int {
    case low
    case medium
    case high
}

struct Task {
    let title: String
    let priority: Priority
}
