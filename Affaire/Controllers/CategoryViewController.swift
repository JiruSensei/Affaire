//
//  CategoryViewController.swift
//  Affaire
//
//  Created by Gilles Poirot on 25/04/2019.
//  Copyright © 2019 iJiru. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {
    
    // Initialisation de Realm
    let realm = try! Realm()
    
    // L'Array dans lequel se trouve toutes les Category
    var categories: Results<Category>?


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // On recharge les Cateories
        loadCategories()

    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        // Pour sauvegarder le tetfield venant du popup
        var popupTextField = UITextField()
        
        // Un popup est fait avec une UIAlert
        let popUp = UIAlertController(title: "Add new Category'", message: "What catégorie à faire😊", preferredStyle: .alert)
        
        // L'action que réalisera la Popup est une UIAlertAction
        let action = UIAlertAction(title: "Add your new Category", style: .default) { (action) in
            
            // Maintenant avec CoreData il faut indiquer le context (membre de la class)
            // quand on crée une entity
            let newCategory = Category()
            newCategory.name = popupTextField.text!
            
            // Ce n'est plus nécessaire car notre "tableau" categories est directement lié
            // La mise à jour est automatique quand on sauve une nouvelle instance.
//            self.categories.append(newCategory)
            
            // On sauvegarde dans UserDefault
            self.save(category: newCategory)
            
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
    
    //MARK: - TableView Datasource methods
    
    // Pour l'affichage, retourne une cell avec les informations renseignées pour un rang donnée
    // est utilisée par l'OS pour faire le display
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // "AffaireItemCell" est l'identifier que l'on a donnée à la Property cell dans le storyBoard
        // onglet "Properties" > identifier quand on clic sur
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        // On crée un tableau fictif pour le moment
        let category = categories?[indexPath.row]
        cell.textLabel?.text = category?.name ?? "No category added yet"
        
        // et on retourne la cell
        return cell
        
    }
    
    // Retourne le nombre d'élément Category actuel
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    
    //MARK: - TableView Delegates
    
    // La méthode qui sera appelée quand on sélectionnera une catégorie
    // et qui donc doit afficher les liste des items à faire pour cette catégorie
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Il faut activer le segue que l'on a nommé "gotoItems"
        // La méthode prepare() sera appelée avant pour justement
        // prendre en compte la catégorie sélectionnée et configurer le VC
        performSegue(withIdentifier: "gotoItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // On récupère d'abord le VC destination
        let destinationVC = segue.destination as! AffaireViewController
        
        // On récupère le indexPath sélectionné
        // Dans notre cas on pourrait se passer du if let car on sait qu'une row a été sélectionnée
        // mais comme c'est un Optional c'est plus propre de faire comme celà
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    //MARK: - Data manipulation
    
    // Pour sauvegarder les catégories
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print (error)
        }
    }
    
    // Pour recharger dans le context les catégories
    // On fait également un rafraichissement de l'écran
    func loadCategories() {
        
        // Attention la méthode retourne un Result<Element>
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
}
