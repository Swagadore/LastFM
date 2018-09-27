//
//  ViewController.swift
//  Last.fm
//
//  Created by Daniel Sofoluke on 27/09/2018.
//  Copyright © 2018 Daniel Sofoluke. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import ObjectMapper

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    private var searchResults = [JSON]() {
        didSet {
            tableView.reloadData()
        }
    }
    var selectedAlbum: Album?
    let apiKey = "9c09b19e10a3022946e6fba985495784"
    let albumName = ""
    @IBOutlet weak var tableView: UITableView!
    var albums = [Album]()
    var searchController: UISearchController!
    var shouldShowSearchResults = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        let params = ["album": albumName, "api_key":apiKey]
        let searchURL = "http://ws.audioscrobbler.com/2.0/?method=album.search&album=\(albumName)&api_key=\(apiKey)&format=json"
        configureSearchController()
        getMusicData(url: searchURL, params: params)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.searchController.searchBar.isHidden = true
        DispatchQueue.main.async {
            self.searchController.isActive = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        DispatchQueue.main.async {
            self.searchController.isActive = false
            self.searchController.searchBar.isHidden = true
        }
    }
    
    
    func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false;
        searchController.searchBar.isTranslucent = false
        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.placeholder = "Search Album"
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.tintColor = UIColor.lightGray
        searchController.searchBar.layer.borderColor = UIColor.lightGray.cgColor
        searchController.searchBar.barTintColor = UIColor.lightGray
        UITextField.appearance(whenContainedInInstancesOf: [type(of: searchController.searchBar)]).tintColor = UIColor.black
        tableView.tableHeaderView = searchController.searchBar
        let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.black
    }


    func getMusicData(url: String, params: [String : String])
    {
        
        Alamofire.request(url, method: .get, parameters: params).responseJSON { response in
            
            switch response.result {
            case .success:
                
                let json = JSON(response.result.value)
                let jsonResults = json["results"]
                let albumMatches = jsonResults["albummatches"]
                let albumArrayJSON = albumMatches["album"].arrayValue
                self.searchResults = albumArrayJSON
                self.tableView.reloadData()
                print(json)
            case .failure( _):
                
                var errorString = "NULL"
                
                if let data = response.data {
                    if let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String: String] {
                        errorString = json["error"]!
                    }
                }
                
            }
            
        }
    }
    
    // MARK: - Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? LastFMSearchResultCellTableViewCell
        cell?.artistLabel.text = searchResults[indexPath.row]["artist"].stringValue
        cell?.nameLabel?.text = searchResults[indexPath.row]["name"].stringValue
        if let imageUrl = searchResults[indexPath.row]["image"].arrayValue[0]["#text"].string, let url = URL(string: imageUrl) {
            print(url)
            print(imageUrl)
            cell?.logoImage.kf.setImage(with: url)
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
      selectedAlbum = Album(streamable: searchResults[indexPath.row]["streamable"].stringValue, mbid: searchResults[indexPath.row]["mbid"].stringValue, name: searchResults[indexPath.row]["name"].stringValue, url: searchResults[indexPath.row]["url"].stringValue, artist: searchResults[indexPath.row]["artist"].stringValue)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    // MARK: - Search
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchResults.removeAll()
        guard let textToSearch = searchBar.text, !textToSearch.isEmpty else {
            return
        }
        
        fetchResults(for: textToSearch)
        
    }
    
    func fetchResults(for text: String) {
        let searchURL = "http://ws.audioscrobbler.com/2.0/?method=album.search&album=\(text)&api_key=\(apiKey)&format=json"
        let params = ["album": text, "api_key":apiKey]
        getMusicData(url: searchURL, params: params)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let cancelButtonAttributes: NSDictionary = [NSForegroundColorAttributeName: UIColor.black]
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes as? [String : AnyObject], for: UIControlState.normal)
        shouldShowSearchResults = true
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchResults.removeAll()
        tableView.reloadData()
        shouldShowSearchResults = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            tableView.reloadData()
        }
        searchController.searchBar.resignFirstResponder()
    }
    
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let detailVC = segue.destination as? AlbumDetailViewController {
                detailVC.selectedAlbum = selectedAlbum
            }
        }
    }
}


class LastFMSearchResultCellTableViewCell: UITableViewCell
{
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var logoImage: UIImageView!
    
}

