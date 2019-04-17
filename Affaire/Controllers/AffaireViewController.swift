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

    var itemArray = [AffaireItem]()
    // Le chemin et fichier où l'on va sauvegarder
    let dataFilePath = FileManager.default.urls(for: .documentDirectory,
                                                in: .userDomainMask)
                        .first?.appendingPathComponent("afaire.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        print(dataFilePath)
        // Do any additional setup after loading the view.
//        itemArray.append(AffaireItem(with: "eat at lunch"))
//        itemArray.append(AffaireItem(with: "iOS"))
//        itemArray.append(AffaireItem(with: "DDD"))
        loadItems()
        // On recharge le tableau d'Item à partir de UserFaults
        loadItems()
    }

    //MARK: - Callback pour datasource
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // "AffaireItemCell" est l'identifier que l'on a donnée à la Property cell dans le storyBoard
        // onglet "Properties" > identifier quand on clic sur
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AffaireItemCell", for: indexPath)
        
        // On crée un tableau fictif pour le moment
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.label
        cell.accessoryType = item.checked ? .checkmark : .none
        
        // et on retourne la cell
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
        
        // Il suffit d'inverser le booleen
        itemArray[indexPath.row].checked = !itemArray[indexPath.row].checked
        
        // Le array a changé, il faut donc le sauvegarder
        saveItems()
        
        tableView.reloadData()
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
            self.itemArray.append(AffaireItem(with: popupTextField.text!))
            
            // On sauvegarde dans UserDefault
            self.saveItems()
            
            // pour l'affiche prenne en compte le nouvel item.
            print("reload")
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
    
    //MARK: Sauvegarde des données
    func saveItems() {
        // En premier on crée un encoder spécifique pour les fichiers Property
        let encoder = PropertyListEncoder()
        do {
            // On récupère une structure Data qui encapsule nos données
            let data = try encoder.encode(itemArray)
            // et on l'écrit dans le fichier que l'on à indiqué
            try data.write(to: dataFilePath!)
        } catch {
            print (error)
        }
    }
    
    func loadItems() {
        // On lit les données au format Data
        guard let data = try? Data(contentsOf: dataFilePath!) else { return }
        // On crée le decoder
        let decoder = PropertyListDecoder()
        // et on convertie dans notre Array
        // le premier paramètre indique le type de notre array
        // qui doit être conform au protocol Decodable
        itemArray = try! decoder.decode([AffaireItem].self, from: data)
    }
}

