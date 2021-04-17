//
//  TaskListViewController.swift
//  ToDoRxSwift
//
//  Created by Ignatio Julian on 17/04/21.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class TaskListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var prioritySegmentedControl: UISegmentedControl!
    
    private var tasks = BehaviorRelay<[Task]>(value: [])
    private var filteredTask = [Task]()
    
    let disposedBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredTask.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell", for: indexPath)
        cell.textLabel?.text = self.filteredTask[indexPath.row].title
        
        return cell
    }
    
    private func updateTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let navigationController = segue.destination as? UINavigationController,
              let addTitleNavigationController = navigationController.viewControllers.first as? AddTaskViewController else {
            fatalError("Controller not found...")
        }
        
        addTitleNavigationController.taskSubjectObservable
            .subscribe(onNext: { task in
                
                let priority = Priority(rawValue: self.prioritySegmentedControl.selectedSegmentIndex - 1)
                
                var existingTasks = self.tasks.value
                existingTasks.append(task)
                self.tasks.accept(existingTasks)
                
                self.filterTask(by: priority)
                
            }).disposed(by: disposedBag)
    }
    
    @IBAction func priorityValueChanged(segmentedControl: UISegmentedControl) {
        let priority = Priority(rawValue: segmentedControl.selectedSegmentIndex - 1)
        filterTask(by: priority)
    }
    
    private func filterTask(by priority: Priority?) {
        
        if priority == nil {
            self.filteredTask = self.tasks.value
        } else {
            
            self.tasks.map { tasks in
                return tasks.filter { $0.priority == priority! }
            }.subscribe(onNext: { [weak self] tasks in
                self?.filteredTask = tasks
                self?.updateTableView()
            }).disposed(by: disposedBag)
            
        }
    }
    
}
