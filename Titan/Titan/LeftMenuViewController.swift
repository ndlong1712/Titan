//
//  LeftMenuViewController.swift
//  Titan
//
//  Created by LongND9 on 6/29/16.
//  Copyright © 2016 LongND9. All rights reserved.
//

import UIKit

class LeftMenuViewController: UIViewController {
    
    @IBOutlet weak var btnFilter: UIButton!
    @IBOutlet weak var tableView: UITableView!
    let CellIdentifier = "CustomCellOne"
    
    var mainViewController: UIViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        btnFilter.layer.borderWidth = 0.5
        btnFilter.layer.cornerRadius = 5.0
        btnFilter.layer.borderColor = UIColor.whiteColor().CGColor
        
        btnFilter.layer.shadowColor = UIColor.whiteColor().CGColor
        btnFilter.layer.shadowOffset = CGSizeMake(5, 5)
        btnFilter.layer.shadowRadius = 5
        btnFilter.layer.shadowOpacity = 1.0
        
        tableView.registerNib(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: CellIdentifier)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func filterAction(sender: AnyObject) {
        
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}

extension LeftMenuViewController: UITableViewDelegate{
    
}

extension LeftMenuViewController: UITableViewDataSource{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath) as! CustomCell
        
        return cell
    }
}
