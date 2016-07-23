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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

}

extension MenuViewController {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(targetSegueAtIndexPath(indexPath), sender: self)
    }
    
    func targetSegueAtIndexPath(indexPath : NSIndexPath) -> String {
        return datasource.titles[indexPath.row] + "Segue"
    }
}


class MenuDataSource : NSObject, UITableViewDataSource {
    let titles = ["Camera",
                  "CIFilters"];
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath)
        cell.textLabel?.text = titles[indexPath.item]
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
}



