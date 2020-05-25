//
//  NotesController.swift
//  VK-total
//
//  Created by Сергей Никитин on 15.04.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class NotesController: InnerViewController, UITableViewDelegate, UITableViewDataSource {

    var userID = ""
    var offset = 0
    var count = 100
    var isRefresh = false
    
    var notes: [Notes] = []
    
    var tableView: UITableView!
    
    var navHeight: CGFloat {
           if #available(iOS 13.0, *) {
               return (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) +
                   (self.navigationController?.navigationBar.frame.height ?? 0.0)
           } else {
               return UIApplication.shared.statusBarFrame.size.height +
                   (self.navigationController?.navigationBar.frame.height ?? 0.0)
           }
       }
    var tabHeight: CGFloat = 49
    var firstAppear = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        OperationQueue.main.addOperation {
            self.createTableView()
            
            if self.userID == vkSingleton.shared.userID {
                let barButton = UIBarButtonItem(image: UIImage(named: "three-dots"), style: .plain, target: self, action: #selector(self.tapBarButtonItem(sender:)))
                self.navigationItem.rightBarButtonItem = barButton
            }
        }
        
        getNotes()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if firstAppear {
            firstAppear = false
            tabHeight = self.tabBarController?.tabBar.frame.height ?? 49.0
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func getNotes() {
        let opq = OperationQueue()
        isRefresh = true
        
        OperationQueue.main.addOperation {
            self.tableView.reloadData()
            ViewControllerUtils().showActivityIndicator(uiView: self.tableView)
        }
        
        let url = "/method/notes.get"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "user_id": userID,
            "offset": "\(offset)",
            "count": "\(count)",
            "sort": "0",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        opq.addOperation(getServerDataOperation)
        
        let parseNotes = ParseNotes()
        parseNotes.addDependency(getServerDataOperation)
        opq.addOperation(parseNotes)
        
        let reloadController = ReloadNotesController(controller: self)
        reloadController.addDependency(parseNotes)
        OperationQueue.main.addOperation(reloadController)
    }
    
    func createTableView() {
        tableView = UITableView()
        tableView.frame = CGRect(x: 0, y: navHeight, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - navHeight - tabHeight)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(NotesCell.self, forCellReuseIdentifier: "notesCell")
        tableView.separatorStyle = .none
        
        self.view.addSubview(tableView)
    }
    
    @objc func tapBackButtonItem(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func tapBarButtonItem(sender: UIBarButtonItem) {
        playSoundEffect(vkSingleton.shared.buttonSound)
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            alertController.addAction(cancelAction)
            
        let action1 = UIAlertAction(title: "Создать новую заметку", style: .default) { action in
                    
        }
        alertController.addAction(action1)
        
        present(alertController, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "notesCell") as! NotesCell
        
        return cell.getRowHeight(note: notes[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewFooter = UIView()
        viewFooter.backgroundColor = UIColor(displayP3Red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        
        return viewFooter
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "notesCell") as! NotesCell
        
        cell.configureCell(note: notes[indexPath.row])
        
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        cell.separatorInset = UIEdgeInsets(top: 0, left: cell.leftInsets, bottom: 0, right: 3 * cell.leftInsets)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let note = notes[indexPath.row]
        openBrowserController(url: note.viewURL)
    }
}
