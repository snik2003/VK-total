//
//  ReloadNotesController.swift
//  VK-total
//
//  Created by Сергей Никитин on 15.04.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation

class ReloadNotesController: Operation {
    var controller: NotesController
    
    init(controller: NotesController) {
        self.controller = controller
    }
    
    override func main() {
        guard let parseNotes = dependencies[0] as? ParseNotes else { return }
        
        if controller.offset == 0 {
            controller.notes = parseNotes.outputData
        } else {
            for note in parseNotes.outputData {
                controller.notes.append(note)
            }
        }
        
        controller.offset += controller.count
        controller.tableView.separatorStyle = .singleLine
        controller.tableView.reloadData()
        ViewControllerUtils().hideActivityIndicator()
    }
}
