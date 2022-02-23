//
//  Task.swift
//  To-Do Manager
//
//  Created by Admin on 21.12.2021.
//

import Foundation

enum TaskPriority {
    case normal
    case important
}

enum TaskStatus: Int {
    case planned
    case completed
}

protocol TaskProtocol {
    var name: String {get set}
    var type: TaskPriority {get set}
    var staus: TaskStatus {get set}
}

struct Task: TaskProtocol {
    var name: String
    var type: TaskPriority
    var staus: TaskStatus
}

protocol TaskStorageProtocol {
    func loadTask() -> [TaskProtocol]
    func saveTasks(_ tasks: [TaskProtocol])
}

class TaskStorage: TaskStorageProtocol {
    
    private var storage = UserDefaults.standard
    let storageKey = "tasks"
    
    private enum TaskKey: String {
        case title
        case type
        case status
    }
    
    func saveTasks(_ tasks: [TaskProtocol]) {
        var arrayForStorage: [[String: String]] = [[:]]
        tasks.forEach { task in
            var newElementForStorage: [String: String] = [:]
            newElementForStorage[TaskKey.title.rawValue] = task.name
            newElementForStorage[TaskKey.type.rawValue] = task.type == .important ? "important" : "normal"
            newElementForStorage[TaskKey.status.rawValue] = task.staus == .completed ? "completed" : "normal"
            arrayForStorage.append(newElementForStorage)
        }
        storage.set(arrayForStorage, forKey: "tasks")
    }
    
    
    
    func loadTask() -> [TaskProtocol] {
        var resultTasks: [TaskProtocol] = []
        let tasksFromStorage = storage.object(forKey: storageKey) as? [[String:String]] ?? []
            
        for task in tasksFromStorage {
            guard let title = task[TaskKey.title.rawValue],
                    let taskType = task[TaskKey.type.rawValue],
                    let taskStatus = task[TaskKey.status.rawValue] else {
            continue
            }
                
            let type: TaskPriority = taskType == "important" ? .important : .normal
            let status: TaskStatus = taskStatus == "completed" ? .completed : .planned
                
            resultTasks.append(Task(name: title, type: type, staus: status))
        }
        return resultTasks
    }
}
