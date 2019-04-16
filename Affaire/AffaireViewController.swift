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
    var defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // On recharge le tableau d'Item à partir de UserFaults
        itemArray = defaults.array(forKey: "AffaireArray") as! [String]
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
    
    //MARK - Add Items actions
    
    // Quand on clic sur le boutton + on veut pouvoir créer un nouvel item dans la liste
    // Pour cela on va ouvrir un PopUp avec un TextField permettant d'entrer le nom
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        // Pour sauvegarder le tetfield venant du popup
        var popupTextField = UITextField()
        
        // Un popup est fait avec une UIAlert
        let popUp = UIAlertController(title: "Add new item'", message: "What à faire😊", preferredStyle: .alert)
        
        // L'action que réalisera la Popup est une UIAlertAction
        let action = UIAlertAction(title: "Add your new à faire", style: .default) { (action) in
            print(popupTextField.text)
            self.itemArray.append(popupTextField.text!)
            
            // On sauvegarde dans UserDefault
            self.defaults.set(self.itemArray, forKey: "AffaireArray")
            
            // pour l'affiche prenne en compte le nouvel item.
            self.tableView.reloadData()
        }
        
        // On ajoute aussi un TextField afin de pouvoir entrer le texte de l'action à faire
        // Ce qu'il faut bien voir c'est que le code dans cette closure  sera appelé
        // au moment du addTextField donc quand on enregistre et non pas quand on appuie
        // sur le bouton + où c'est l'autre closure qui est appelée
        popUp.addTextField {
            (alertTextField) in
            alertTextField.placeholder = "Create an à faire"
            popupTextField = alertTextField
        }
        
        // On enregistre l'action
        popUp.addAction(action)
        
        // et on affiche le Popup avec present
        present(popUp, animated: true, completion: nil)
        
    }
}

