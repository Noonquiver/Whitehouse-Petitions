//
//  ViewController.swift
//  Whitehouse Petitions
//
//  Created by Camilo Hernández Guerrero on 26/06/22.
//

import UIKit

class ViewController: UITableViewController {
    var petitions = Array<Petition>()
    var filteredPetitions = Array<Petition>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urlString: String
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(showCredits))
        
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                parse(json: data)
                return
            }
        }
        
        showError()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredPetitions.isEmpty {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(filterPetitions))
            return petitions.count
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(removeFilter))
        
        return filteredPetitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition: Petition
        
        if filteredPetitions.isEmpty {
            petition = petitions[indexPath.row]
        } else {
            petition = filteredPetitions[indexPath.row]
        }
        
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = DetailViewController()
        
        if filteredPetitions.isEmpty {
            viewController.detailItem = petitions[indexPath.row]
        } else {
            viewController.detailItem = filteredPetitions[indexPath.row]
        }
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func filterPetitions() {
        var filter = UIAlertAction()
        
        DispatchQueue.global(qos: .userInitiated).async {
            [weak self] in
            self?.filteredPetitions.removeAll(keepingCapacity: true)
        }
        
        DispatchQueue.main.async {
            [weak self] in
            let alertController = UIAlertController(title: "Filter by title", message: "Please type the desired article title.", preferredStyle: .alert)
            alertController.addTextField()
            
            filter = UIAlertAction(title: "Filter", style: .default) {
                [weak self, weak alertController] _ in
                guard let alertController = alertController else { return }
                guard let filterWord = alertController.textFields?[0].text else { return }
                
                self?.filtered(using: filterWord)
            }
            
            alertController.addAction(filter)
            self?.present(alertController, animated: true)
        }
    }
    
    func filtered(using filterWord: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            [weak self] in
            guard let petitions = self?.petitions else { return }
            
            for petition in petitions {
                if petition.title.lowercased().contains(filterWord.lowercased()) {
                    self?.filteredPetitions.append(petition)
                }
            }
        }

        DispatchQueue.main.async {
            [weak self] in
            guard let noArticleFound = self?.filteredPetitions.isEmpty else { return }
            
            if noArticleFound {
                let alertController = UIAlertController(title: "No article found", message: "There's no article title that includes that word.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                self?.present(alertController, animated: true)
            }

            self?.tableView.reloadData()
        }
    }
    
    @objc func removeFilter() {
        filteredPetitions.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    @objc func showCredits() {
        let alertController = UIAlertController(title: "Did you know?", message: "The data used on this application comes from the API of the White House.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Awesome!", style: .cancel))
        present(alertController, animated: true)
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            tableView.reloadData()
        }
    }
    
    func showError() {
        let alertController = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
        present(alertController, animated: true)
    }
}

