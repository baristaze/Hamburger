//
//  MainViewController.swift
//  Mwitter
//
//  Created by Baris Taze on 5/30/15.
//  Copyright (c) 2015 Baris Taze. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet private weak var menuView: UIView!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var menuTable: UITableView!
    
    @IBOutlet private weak var menuWidth: NSLayoutConstraint!
    @IBOutlet private weak var menuLeft: NSLayoutConstraint!

    @IBOutlet weak var tweetBarButtonItem: UIBarButtonItem!
    
    private var menuExpanded:Bool = true
    private var animating:Bool = false
    
    var activeViewController: UIViewController? {
        didSet(oldViewControllerOrNil){
            if let oldVC = oldViewControllerOrNil {
                oldVC.willMoveToParentViewController(nil)
                oldVC.view.removeFromSuperview()
                oldVC.removeFromParentViewController()
            }
            if let newVC = activeViewController {
                self.addChildViewController(newVC)
                newVC.view.frame = self.contentView.bounds
                self.contentView.addSubview(newVC.view)
                newVC.didMoveToParentViewController(self)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.menuTable.tableFooterView = UIView(frame:CGRectZero)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if(self.menuExpanded){
            toggleMenuView(){
                var activeVC = self.storyboard!.instantiateViewControllerWithIdentifier("timelineVC") as! TimelineViewController
                self.activeViewController = activeVC
                self.navigationItem.title = "Timeline";
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onHamburgerMenu(sender: AnyObject) {
        
        toggleMenuView(){}
    }
    
    @IBAction func onTweet(sender: AnyObject) {
        
        var action:((Void)->Void) = {
            if self.activeViewController is TimelineViewController {
                var vc = self.activeViewController as! TimelineViewController
                vc.openNewTweetVC()
            }
        }
        
        if self.menuExpanded {
            toggleMenuView() {
                action()
            }
        }
        else {
            action()
        }
    }
    
    func toggleMenuView(onComplete:((Void)->Void)){
        
        if self.animating {
            return
        }
        
        self.animating = true
        UIView.animateWithDuration(
            1.0,
            animations: { () -> Void in
                var menuLeftConstant:CGFloat = 0.0;
                if(self.menuExpanded){
                    menuLeftConstant = -self.menuWidth.constant
                }
                self.menuLeft.constant = menuLeftConstant
            },
            completion:{(complete:Bool)->Void in
                self.menuExpanded = !self.menuExpanded
                self.animating = false
                onComplete();
        })
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL") as? UITableViewCell
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CELL")
        }
        
        var label = ""
        switch(indexPath.row){
            case 0: label = "Timeline"
            case 1: label = "Mentions"
            case 2: label = "Profile"
            case 3: label = "Logout"
            default: label = "..."
        }

        if (cell!.respondsToSelector(Selector("setPreservesSuperviewLayoutMargins:"))){
            cell!.preservesSuperviewLayoutMargins = false
        }
        if (cell!.respondsToSelector(Selector("setSeparatorInset:"))){
            cell!.separatorInset = UIEdgeInsetsMake(0, 4, 0, 0)
        }
        if (cell!.respondsToSelector(Selector("setLayoutMargins:"))){
            cell!.layoutMargins = UIEdgeInsetsZero
        }
        
        cell!.textLabel?.text = label
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4;
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        toggleMenuView(){
            
            var activeVC:UIViewController?
            var title:String = "Home"
            
            switch(indexPath.row){
            case 0:
                activeVC = self.storyboard!.instantiateViewControllerWithIdentifier("timelineVC") as! TimelineViewController
                title = "Timeline"
                //self.navigationItem.rightBarButtonItem = self.tweetBarButtonItem
                //self.navigationController?.navigationBar.reloadInputViews()

            case 1:
                activeVC = self.storyboard!.instantiateViewControllerWithIdentifier("mentions.vc") as! MentionsViewController
                title = "Mentions"
                
            case 2:
                activeVC = self.storyboard!.instantiateViewControllerWithIdentifier("profile.vc") as! ProfileViewController
                title = "Profile"
                
            case 3:
                self.activeViewController = nil
                TwitterClient.sharedInstance.logout()
                (UIApplication.sharedApplication().delegate as! AppDelegate).startLoginStoryBoard()
                
            default:
                self.activeViewController = nil
            }
            
            if(activeVC != nil){
                self.activeViewController = activeVC
                self.navigationItem.title = title;
                if(title == "Timeline") {
                    self.navigationItem.rightBarButtonItem?.title = "Tweet";
                }
                else {
                    self.navigationItem.rightBarButtonItem?.title = "";
                }
            }
        }
    }
}
