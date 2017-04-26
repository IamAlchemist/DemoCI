//
//  MenuViewController.swift
//  DemoCI
//
//  Created by wizard lee on 7/23/16.
//  Copyright © 2016 cc.kauhaus. All rights reserved.
//

import UIKit

class MenuViewController: UITableViewController {
    
    var datasource = MenuDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = datasource
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

}

extension MenuViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: targetSegueAtIndexPath(indexPath), sender: self)
    }
    
    func targetSegueAtIndexPath(_ indexPath : IndexPath) -> String {
        return datasource.titles[indexPath.row] + "Segue"
    }
}


class MenuDataSource : NSObject, UITableViewDataSource {
    let titles = ["Camera",
                  "CIFilters"];
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath)
        cell.textLabel?.text = titles[indexPath.item]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
}



