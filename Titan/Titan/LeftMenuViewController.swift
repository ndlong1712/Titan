//
//  LeftMenuViewController.swift
//  Titan
//
//  Created by LongND9 on 6/29/16.
//  Copyright © 2016 LongND9. All rights reserved.
//

import UIKit
import MapKit

class LeftMenuViewController: UIViewController {
    
    @IBOutlet weak var btnFilter: UIButton!
    @IBOutlet weak var tableView: UITableView!
    let CellIdentifier = "CustomCellOne"
    var businesses: [Business]!
    var indicator:CustomInfiniteIndicator!
    var isLoadMore = true
    
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
        
        
        Business.searchWithTerm("Thai", completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
        })
        isLoadMore = true
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func filterAction(sender: AnyObject) {
        
    }
    
    func fetchData() -> Void {
        var indexPaths = [NSIndexPath]()
        var indexPathRow = self.businesses.count
        
        
        Business.searchWithTerm("Thai", completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.indicator.stopAnimationg()
            for i in businesses {
                guard let model:Business = i else {
                    continue
                }
                
                self.businesses.append(model)
                
                indexPaths.append(NSIndexPath(forRow: indexPathRow, inSection: 0))
                
                indexPathRow += 1
            }
            self.isLoadMore = true
            self.indicator.removeFromSuperview()
            self.tableView.beginUpdates()
            self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
            self.tableView.endUpdates()
            
        })
        
        
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

extension LeftMenuViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        
        
    }
}

extension LeftMenuViewController: UITableViewDelegate{
    
}

extension LeftMenuViewController: UITableViewDataSource{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.businesses == nil) {
            return 0
        }
        return self.businesses.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath) as! CustomCell
        guard let busi = self.businesses else {return cell}
        let business = busi[indexPath.row]
        let urlRequestAvatar = NSURLRequest(URL: business.imageURL!)
        let urlRequestRating = NSURLRequest(URL: business.ratingImageURL!)
        cell.imgAvatar.setImageWithURLRequest(urlRequestAvatar, placeholderImage: UIImage(named: "placeHolder"), success: { (request: NSURLRequest, response:NSHTTPURLResponse?, image:UIImage) in
            cell.imgAvatar.image = image
            cell.lbName.text = business.name
            cell.lbCountViews.text = (business.reviewCount?.stringValue)! + " Reviews"
            cell.lbAdress.text = business.address
            cell.lbCategories.text = business.categories
            cell.lbDistance.text = business.distance
        }) { (request:NSURLRequest, response:NSHTTPURLResponse?, error:NSError) in
            
        }
        
        cell.imgRate.setImageWithURLRequest(urlRequestRating, placeholderImage: UIImage(named: "placeHolder"), success: { (request: NSURLRequest, response:NSHTTPURLResponse?, image:UIImage) in
            cell.imgRate.image = image
        }) { (request:NSURLRequest, response:NSHTTPURLResponse?, error:NSError) in
            
        }
        
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.closeLeft()
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let lastRow = tableView.numberOfRowsInSection(0) - 1
        
        if (indexPath.row == lastRow) {
            if isLoadMore {
                let bounds = UIScreen.mainScreen().bounds
                let height = bounds.size.height
                self.indicator = CustomInfiniteIndicator(frame: CGRectMake(tableView.frame.width/2 - 20, tableView.contentOffset.y + height + 40, 24, 24))
                tableView.addSubview(self.indicator)
                var contentRect = CGRectZero
                for view in tableView.subviews {
                    contentRect = CGRectUnion(contentRect, view.frame)
                }
                contentRect = CGRectUnion(contentRect, CGRectMake(tableView.frame.width/2 - 20, tableView.contentOffset.y + height + 40, 200, 200))
                tableView.contentSize = contentRect.size;
                self.indicator.startAnimating()
                isLoadMore = false
                fetchData()
            }
            
        }
    }
    
    
}

extension LeftMenuViewController: MKMapViewDelegate{
    
}

extension LeftMenuViewController: CLLocationManagerDelegate{
    
}


