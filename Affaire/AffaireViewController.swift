//
//  ViewController.swift
//  Affaire
//
//  Created by Gilles Poirot on 10/04/2019.
//  Copyright © 2019 iJiru. All rights reserved.
//

import UIKit

// On hérite de UITableViewController ce qui évite de
// avoir à déclarer une variable tableView
// avoir à s'enregistrer comme delegate et datasource
class AffaireViewController: UITableViewController {

    var itemArray = ["Rdv radio", "Rdv Ruma", "Buy costume"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    //MARK: - Callback pour datasource
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // "" est l'identifier que l'on a donnée à la Property cell dans le storyBoard
        // onglet "Properties" > identifier quand on clic sur
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AffaireItemCell", for: indexPath)
        
        // On crée un tableau fictif pour le moment
        cell.textLabel?.text = itemArray[indexPath.row]
        
        return cell

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    //MARK: more callback

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("select row \(itemArray[indexPath.row])")
        
        // Juste pour avoir un effet plus sympa 
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell: UITableViewCell = tableView.cellForRow(at: indexPath)!
        if cell.accessoryType == .checkmark {
            cell.accessoryType = .none
        }
        else {
            cell.accessoryType = .checkmark
        }
    }
}

