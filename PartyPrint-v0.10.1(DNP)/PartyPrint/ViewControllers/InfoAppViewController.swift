//
//  InfoAppViewController.swift
//  PartyPrint
//
//  Created by KhoaND12 on 10/22/16.
//  Copyright © 2016 DNP. All rights reserved.
//

import UIKit

class InfoAppViewController: UIViewController {
    
    struct LocalizationKey {
        static let VERSION = "VERSION"
        static let Information = "Information"
        static let OpenSource = "OpenSource"
        static let Menu = "Menu"
    }

    @IBOutlet var btnBack: UIButton!
    @IBOutlet weak var btnBackNavigation: UIButton!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbCopyright: UILabel!
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var lbVersion: UILabel!
    @IBOutlet weak var informationTitle: UILabel!
    
    var version = ""
    var menuArrayText = [String]()
    let cellIdentifier = "InfoCell"
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        lbTitle.text = Bundle.main.infoDictionary![kCFBundleNameKey as String] as? String
        setTextForAllSubView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func setTextForAllSubView() {
        version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let format = LocalizationKey.VERSION.localized
        let ver = String.init(format: format, version)
        lbVersion.text = ver
        
        menuArrayText = [LocalizationKey.OpenSource.localized]
        informationTitle.text = LocalizationKey.Information.localized
        btnBack.setTitle(LocalizationKey.Menu.localized, for: .normal)
    }
    

    @IBAction func backNavigationButtonClicked(_ sender: AnyObject) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func handleCellTapAction(index: Int) {
        let storyBoard = Constant.StoryBoard.main
        let licenseViewController = storyBoard.instantiateViewController(withIdentifier: Constant.ViewControllerIdentifier.license)
        navigationController?.pushViewController(licenseViewController, animated: true)
    }

}

extension InfoAppViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let row = indexPath.row
        cell.textLabel?.text = menuArrayText[row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}

extension InfoAppViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return menuTableView.frame.size.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        menuTableView.deselectRow(at: indexPath, animated: false)
        handleCellTapAction(index: indexPath.row)
    }
}
