//
//  TaskListController.swift
//  To-Do Manager
//
//  Created by Admin on 20.12.2021.
//

import UIKit

class TaskListController: UITableViewController {
    
    var taskStorage: TaskStorageProtocol = TaskStorage()
    var tasks: [TaskPriority: [TaskProtocol]] = [:] {
        didSet {
            for (tasksGroupPriority, tasksGroup) in tasks {
                tasks[tasksGroupPriority] = tasksGroup.sorted { task1, task2 in
                    
                    let task1Position = tasksStatusPosition.firstIndex(of: task1.staus) ?? 0
                    let task2Position = tasksStatusPosition.firstIndex(of: task2.staus) ?? 0
                    return task1Position < task2Position
                }
            }
            var savingArray: [TaskProtocol] = []
            tasks.forEach { _, value in
                savingArray += value
            }
            taskStorage.saveTasks(savingArray)
        }
    }
    var sectionTypesPosition: [TaskPriority] = [.important, .normal]
    var tasksStatusPosition: [TaskStatus] = [.planned, .completed]

    override func viewDidLoad() {
        super.viewDidLoad()
        loadTasks()
        navigationItem.leftBarButtonItem = getEditButtonItem()
    }
    
    override func setEditing (_ editing: Bool, animated: Bool)
    {
       super.setEditing(editing,animated:animated)
       if editing {
            self.getEditButtonItem().title = "Готово"
       } else {
            self.getEditButtonItem().title = "Изменить"
       }
     }
        
    private func getEditButtonItem() -> UIBarButtonItem {
        let editButton = editButtonItem
        editButton.title = "Изменить"
        return editButton
    }
    
    private func loadTasks() {
        sectionTypesPosition.forEach { taskType in
            tasks[taskType] = []
        }
        taskStorage.loadTask().forEach { task in
            tasks[task.type]?.append(task)
        }
    }
    
    func setTasks(_ tasksCollection: [TaskProtocol]) {
        sectionTypesPosition.forEach { taskType in
            tasks[taskType] = []
        }
        tasksCollection.forEach { task in
            tasks[task.type]?.append(task)
        }
    }
    
   

    // MARK: - Table view data source

    
    //Колличество секций в таблице
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tasks.count
    }
    
    //Колличество строк в определенной секции
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //определяем приоритет задач, соответствующий текущей секции
        let taskType = sectionTypesPosition[section]
        guard let currentTaskType = tasks[taskType] else {
            return 0
        }
        return currentTaskType.count
    }

    //Ячейка для строки таблицы
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        return getConfiguredTaskCell_constraints(for: indexPath)
        return getConfiguredTaskCell_stack(for: indexPath)
    }
        
        private func getConfiguredTaskCell_constraints(for indexPath: IndexPath) -> UITableViewCell {
        //Загружаем прототип ячейки по идентификатору
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellContraints", for: indexPath)
        //Получаем данные о задаче, которую необходимо вывести в ячейке
        let taskType = sectionTypesPosition[indexPath.section]
        guard let currentTask = tasks[taskType]?[indexPath.row] else {
            return cell
        }
        //Текстовая метка символа
        let symbolLabel = cell.viewWithTag(1) as? UILabel
        //Текстовая метка названия задачи
        let textLabel = cell.viewWithTag(2) as? UILabel
        
        //Измняем символ в ячейке
            symbolLabel?.text = getSymbolForTask(with: currentTask.staus)
        //Изменяем текст в ячейке
            textLabel?.text = currentTask.name
        
        //Изменяем цвет текста и символа
        if currentTask.staus == .planned {
            textLabel?.textColor = .black
            symbolLabel?.textColor = .black
        } else {
            textLabel?.textColor = .lightGray
            symbolLabel?.textColor = .lightGray
        }
        return cell
    }
    
    private func getConfiguredTaskCell_stack(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellStack", for: indexPath) as! TaskCell
        let taskType = sectionTypesPosition[indexPath.section]
        guard let currentTask = tasks[taskType]?[indexPath.row] else {
            return cell
        }
        
        cell.title.text = currentTask.name
        cell.symbol.text = getSymbolForTask(with: currentTask.staus)
        
        if currentTask.staus == .planned {
            cell.title.textColor = .black
            cell.symbol.textColor = .black
        } else {
            cell.title.textColor = .lightGray
            cell.symbol.textColor = .lightGray
        }
        return cell
    }
    
    //Возвращаем символ для соответсвующего типа задачи
    private func getSymbolForTask(with status: TaskStatus) -> String {
        var resultSymbol: String
        switch status {
        case .planned:
            resultSymbol = "\u{25CB}"
        case .completed:
            resultSymbol = "\u{25C9}"
        default:
            resultSymbol = ""
        }
        return resultSymbol
    }
    
    //Задаем текст в заголовок секции
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title: String?
        let taskType = sectionTypesPosition[section]
        if taskType == .important {
            title = "Важные"
        } else if taskType == .normal {
            title = "Текущие"
        }
        return title
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let taskType = sectionTypesPosition[indexPath.section]
        guard let _ = tasks[taskType]?[indexPath.row] else {
            return
        }
        
        guard tasks[taskType]?[indexPath.row].staus == .planned else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        tasks[taskType]![indexPath.row].staus = .completed
        
        tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //Получаем данные о задаче, которую необходимо перевести в статус "Запланированна"
        let taskType = sectionTypesPosition[indexPath.section]
        guard let _ = tasks[taskType]?[indexPath.row] else {
            return nil
        }
        //Проверяем, что задача в статусе "Выполненна"
//        guard tasks[taskType]?[indexPath.row].staus == .completed else {
//            return nil
//        }
        //Меняем статус, обновляем секцию
        let actionSwipeInstance = UIContextualAction(style: .normal, title: "Не выполненна") { _, _, _ in
            self.tasks[taskType]![indexPath.row].staus = .planned
            self.tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
        }
        
        let actionEditIntance = UIContextualAction(style: .normal, title: "Изменить") { _, _, _ in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let editScreen = storyboard.instantiateViewController(withIdentifier: "TaskEditController") as? TaskEditController
            
            editScreen?.taskText = self.tasks[taskType]![indexPath.row].name
            editScreen?.taskType = self.tasks[taskType]![indexPath.row].type
            editScreen?.taskStatus = self.tasks[taskType]![indexPath.row].staus
            
            editScreen?.doAfterEdit = { [unowned self] name, type, status in
                let editTask = Task(name: name, type: type, staus: status)
                tasks[taskType]![indexPath.row] = editTask
                self.tableView.reloadData()
            }
            self.navigationController?.pushViewController(editScreen!, animated: true)
        }
        
        actionEditIntance.backgroundColor = .darkGray
        
        let actionConfiguration: UISwipeActionsConfiguration
        if self.tasks[taskType]![indexPath.row].staus == .completed {
            actionConfiguration = UISwipeActionsConfiguration(actions: [actionSwipeInstance, actionEditIntance])
        } else {
            actionConfiguration = UISwipeActionsConfiguration(actions: [actionEditIntance])
        }
        
//        Возвращаем настроенный объект
        return actionConfiguration
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let taskType = sectionTypesPosition[indexPath.section]
        //удаляем задачу из словаря
        tasks[taskType]?.remove(at: indexPath.row)
        //удаляем задачу из таблицы
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        //Ссылка на секцию, из которой переносится задача
        let taskTypeFrom = sectionTypesPosition[sourceIndexPath.section]
        //Ссылка на секцию, в которую пернеосится задача
        let taskTypeTo = sectionTypesPosition[destinationIndexPath.section]
        //Проверка на существование задачи в словаре
        guard let movedTask = tasks[taskTypeFrom]?[sourceIndexPath.row] else {
            return
        }
        //Удаление задачи из словаря
        tasks[taskTypeFrom]!.remove(at: sourceIndexPath.row)
        //Добавление задачи в другое место
        tasks[taskTypeTo]!.insert(movedTask, at: destinationIndexPath.row)
        //Проверка на то изменилась ли секция. Если да, то надо поменять тип задачи
        if taskTypeFrom != taskTypeTo {
            tasks[taskTypeTo]![destinationIndexPath.row].type = taskTypeTo
        }
        //Обновляем даннные
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCreateScreen" {
            let destination = segue.destination as! TaskEditController
            destination.doAfterEdit = { [unowned self] title, type, status in
                let newTask = Task(name: title, type: type, staus: status)
                tasks[type]?.append(newTask)
                tableView.reloadData()
            }
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
