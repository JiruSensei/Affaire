//
//  SwipeTableViewController.swift
//  Affaire
//
//  Created by Gilles Poirot on 24/05/2019.
//  Copyright © 2019 iJiru. All rights reserved.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 84.0

    }
    
    //TableView Datasource Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell

        // Pour SwipcellKit
        cell.delegate = self
        
        // et on retourne la cell
        return cell
    }
    
    // Cette méthode est directement collée à partir de
    // https://github.com/SwipeCellKit/SwipeCellKit
    // Elle gère le fait que l'utilisateur glisse la cellule
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        // Ici on indique le sens du glissement
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            print("delete here ----------- \(indexPath.row)")
            
            self.updateModel(at: indexPath)
            
            print("delete completed -----------")
            
        }
        
        // customize the action appearance
        // On met le nom de l'image qu'on a récupéré (je n'i pas réussi à récupéré l'image
        // du site SwipeCellKit mais j'ai pris une autre sur le net.
        deleteAction.image = UIImage(named: "trash-icon")
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    
    func updateModel(at indexPath: IndexPath) {
        
    }

}
