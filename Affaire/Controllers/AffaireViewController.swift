//
//  ViewController.swift
//  Affaire
//
//  Created by Gilles Poirot on 10/04/2019.
//  Copyright © 2019 iJiru. All rights reserved.
//

import UIKit
import CoreData

// On hérite de UITableViewController ce qui évite de
// avoir à déclarer une variable tableView
// avoir à s'enregistrer comme delegate et datasource
class AffaireViewController: UITableViewController {
    
    // En premier on récupère le context (le stagging)
    // et pour ce faire on récupère le singleton de l'Application
    // Il sera utilisé pour sauver les données notamment
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Notre tableau d'Item contenu dans la liste
    var itemArray = [AfaireItem]()
    
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
        
        // On crée un tableau fictif pour le moment
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        
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
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        
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
            
            // Maintenant avec CoreData il faut indiquer le context (membre de la class)
            // quand on crée une entity
            let newItem = AfaireItem(context: self.context)
            newItem.title = popupTextField.text!
            newItem.parentCategory = self.selectedCategory!
            self.itemArray.append(newItem)
            
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
    
    // Il suffit d'appelé save() sur le context qui est un attribut
    // de notre controller
    func saveItems() {
        do {
            try context.save()
        } catch {
            print (error)
        }
    }
    
    // La méthode pour recharger les items à partir de la base.
    // On met un prédicat afin de ne sélectionner que ceux de la catégorie.
    func loadItems(with request: NSFetchRequest<AfaireItem> = AfaireItem.fetchRequest(), predicate: NSPredicate? = nil) {
        // Le predicat se fait sur le nom de la catégorie
        let categoryPredicat = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        // Puis on ajoute le cas échéant le prédicat déjà présent (notamment pour Search)
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicat, additionalPredicate])
        }
        else {
            request.predicate = categoryPredicat
        }
        
        request.predicate = compoundPredicate

        do {
            print("Try to fetch les affaire item")
            itemArray = try context.fetch(request)
        }
        catch {
            print("Error fetching AfaireItem \(error)")
        }
        
        tableView.reloadData()
    }
}

//MARK: - SearchBar méthodes
extension AffaireViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // On crée la requête pour l'entité AfaireItem.
        let request: NSFetchRequest<AfaireItem> = AfaireItem.fetchRequest()
        print(searchBar.text!)

        // On crée un predicat qui en gros est le code de la requête
        // dans un format proche de SQL
        let predicat = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        // On charge le prédicat dans la requête
        request.predicate = predicat
        
        // On précise l'ordre dans lequel on veut recevoir le résultat
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        
        // Attention, ce qui est attendu est un tableau de descriptor
        // On l'initialise avec un seul élément
        request.sortDescriptors = [sortDescriptor]
        
        // Finalement on exécute le requête
        loadItems(with: request)
        
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
