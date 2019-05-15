//
//  ViewController.swift
//  Affaire
//
//  Created by Gilles Poirot on 10/04/2019.
//  Copyright © 2019 iJiru. All rights reserved.
//

import UIKit
import RealmSwift

// On hérite de UITableViewController ce qui évite de
// avoir à déclarer une variable tableView
// avoir à s'enregistrer comme delegate et datasource
class AffaireViewController: UITableViewController {

    // récupère une instance de realm
    let realm = try! Realm()
    
    // Notre tableau d'Item contenu dans la liste
    var items: Results<AFaireItem>?
    
    // La catégorie de ce VC (celle qui sera sélectionnée)
    var selectedCategory: Category? {
        // On fait le load dans didSet ce qui permet de le retirer de viewDidLoad()
        // Et on charge les donnée de la catégori spécifiée.s
        didSet {
            loadItems()
        }
    }
    
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Il peut être intéressant d'imprimer le chemin afin d'aller expoler
        // avec l'appli datum
//        print (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))

    }

    //MARK: - Callback pour datasource
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // "AffaireItemCell" est l'identifier que l'on a donnée à la Property cell dans le storyBoard
        // onglet "Properties" > identifier quand on clic sur
        let cell = tableView.dequeueReusableCell(withIdentifier: "AffaireItemCell", for: indexPath)
        
        // On positionne les attributs de la cell sélectionnée
        if let item = items?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
        }
        else { // au cas où
            cell.textLabel?.text = "No item yet"
        }
        // et on retourne la cell
        return cell

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let itemsCount = items?.count ?? 1
        return itemsCount
    }
    
    //MARK: more callback

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("select row \(items?[indexPath.row])")
        
        // On met à jour l'item
        // Ce qui est intéressant est qu'on récupère l'élément de la liste
        // Il n'y a pas besoin de save explicite le fait de faure es changements
        // dans le write() suffi
        if let item = items?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            }
            catch {
                print("Update error \(error)")
            }
        }
        
        tableView.reloadData()
        
        // Juste pour avoir un effet plus sympa
        tableView.deselectRow(at: indexPath, animated: true)
        
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
            
            // Maintenant avec Realm on ne gère plus le tableau d'Item
            // on ajoute donc à celui pointé par la catégorie courrante
            if let currentCategory = self.selectedCategory {

                do {
                    try self.realm.write {
                        let newItem = AFaireItem()
                        newItem.title = popupTextField.text!
                        newItem.dateCreated = Date()
                        // on ajoute le newItem dans la liste des items de la catégorie
                        // Attention, ça doit être fait dans une transaction write()
                        print("on ajoute l'item maintenant \(newItem)")
                        currentCategory.items.append(newItem)
                        self.realm.add(newItem)
                        print("on sauvegarde")
                    }
                }
                catch {
                    print("Error while saving new item \(error)")
                }
                
            }

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
    
    //MARK: Sauvegarde des données
    
    // Il suffit d'appelé save() sur le context qui est un attribut
    // de notre controller
    func save(item: AFaireItem) {
        do {
            try realm.write {
                realm.add(item)
            }
        } catch {
            print (error)
        }
    }
    
    // La méthode pour recharger les items à partir de la base.
    func loadItems() {
        // Pour le moment recharge l'ensemble des AFaireItem
        print("Category is \(selectedCategory?.name)")
//        items = realm.objects(AFaireItem.self)
        items = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
}

//MARK: - SearchBar méthodes
extension AffaireViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("Filter la liste maintenant avec \(searchBar.text!)")
        items = items?.filter("title CONTAINS[cd] %@", searchBar.text!)
            .sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
               searchBar.resignFirstResponder()
            }
            
        }
    }
}
