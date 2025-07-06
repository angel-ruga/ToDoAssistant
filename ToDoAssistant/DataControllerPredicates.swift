//
//  DataControllerPredicates.swift
//  ToDoAssistant
//
//  Created by Angel Efrain Ruiz Garcia on 05/07/25.
//

import Foundation

extension DataController {

    func matchesTagPredicate() -> Predicate<ToDo> {
        let filter = selectedFilter ?? .all
        var enableMatchesTag: Bool
        let tagID: UUID // SwiftData predicates do not let us use another model (in this case, Tag), apparently.
        
        if let tag = filter.tag {
            enableMatchesTag = true
            tagID = tag.tagID
        } else {
            enableMatchesTag = false
            tagID = UUID()
        }
        
        let matchesTag = #Predicate<ToDo> { toDo in
            if enableMatchesTag == true {
                if let tags = toDo.tags {
                    return tags.contains(where: {
                        if let toDoTagID = $0.id {
                            return toDoTagID == tagID
                        } else {
                            return false
                        }
                    })
                } else {
                    return false
                }
            } else {
                return true
            }
        }
        
        return matchesTag
    }
    
    func hasMaxDueDatePredicate() -> Predicate<ToDo> {
        let filter = selectedFilter ?? .all
        let filterDate = filter.maxDueDate
        
        let hasMaxDueDate = #Predicate<ToDo> { toDo in
            if let dueDate = toDo.dueDate {
                return (dueDate <= filterDate)
            } else {
                return false
            }
        }
        
        return hasMaxDueDate
    }
    
    func matchesSearchPredicate() -> Predicate<ToDo> {
        let trimmedFilterText = self.filterText.trimmingCharacters(in: .whitespaces)
        let constantFilterText = self.filterText
        
        let matchesSearch = #Predicate<ToDo> { toDo in
            if trimmedFilterText.isEmpty == false {
                if let title = toDo.title {
                    if let content = toDo.content {
                        return title.localizedStandardContains(constantFilterText)
                        || content.localizedStandardContains(constantFilterText)
                    } else {
                        return title.localizedStandardContains(constantFilterText)
                    }
                } else {
                    return false
                }
            } else {
                return true
            }
        }
        
        return matchesSearch
    }
    
    func hasPriorityPredicate() -> Predicate<ToDo> {
        let selfFilterPriority = self.filterPriority // Predicates do not like external objects that are not constant
        
        let hasPriority = #Predicate<ToDo> { toDo in
            if let priority = toDo.priority {
                if selfFilterPriority == -1 {
                    return true
                } else {
                    return (priority == selfFilterPriority)
                }
            } else {
                return false
            }
        }
        
        return hasPriority
    }
    
    func hasStatusPredicate() -> Predicate<ToDo> {
        let selfFilterStatus = self.filterStatus // Predicates do not like external objects that are not constant
        let selfFilterStatusDone = selfFilterStatus == Status.done
        let selfFilterStatusNotDone = selfFilterStatus == Status.notDone
        
        let hasStatus = #Predicate<ToDo> { toDo in
            if let completed = toDo.completed {
                if selfFilterStatusDone == true { // Predicates might not like single Bool objects as expressions.
                    return completed == true
                } else if selfFilterStatusNotDone == true {
                    return completed == false
                } else {
                    return true
                }
            } else {
                return false
            }
        }
        
        return hasStatus
    }
    
    func predicateForSelectedFilter() -> Predicate<ToDo> {
        let matchesTag = matchesTagPredicate()
        let hasMaxDueDate = hasMaxDueDatePredicate()
        let matchesSearch = matchesSearchPredicate()
        let hasPriority = hasPriorityPredicate()
        let hasStatus = hasStatusPredicate()
        
        // Need to split final predicate in parts because the compiler does not like large expressions
        let selfFilterEnabled = self.filterEnabled // Predicates do not like external objects that are not constant
        let finalPredicate1 = #Predicate<ToDo> { toDo in
            hasMaxDueDate.evaluate(toDo)
            && matchesSearch.evaluate(toDo)
            && matchesTag.evaluate(toDo)
        }
        let finalPredicate2 = #Predicate<ToDo> { toDo in
            (selfFilterEnabled ? hasPriority.evaluate(toDo) : true)
            && (selfFilterEnabled ? hasStatus.evaluate(toDo) : true)
        }
        let finalPredicate = #Predicate<ToDo> { toDo in
            finalPredicate1.evaluate(toDo)
            && finalPredicate2.evaluate(toDo)
        }
        
        return finalPredicate
    }
    
}
