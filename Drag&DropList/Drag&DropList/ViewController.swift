//
//  ViewController.swift
//  Drag&DropList
//
//  Created by Sachin on 07/12/17.
//  Copyright © 2017 Pixelpoint. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate {

    
    var tableview : UITableView!
    var gridView: UICollectionView!
    var list_Arr: NSMutableArray!
    var isGridView = true
    @IBOutlet var gridButton : UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        ////// set list data ///
        list_Arr = NSMutableArray()
        list_Arr = ["Item 0","Item 1","Item 2","Item 3","Item 4","Item 5","Item 6"]
        
        self.navigationItem.title = "Grid"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height-64
        
        /////// add table view ///
        tableview = UITableView(frame: CGRect(x: 0, y: 64, width: width, height: height))
        self.view.addSubview(tableview)
        tableview.register(UINib(nibName: "ListCell", bundle: nil), forCellReuseIdentifier: "Tablecell")
        tableview.delegate = self
        tableview.dataSource = self
        
        /////// add collection view //
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        gridView = UICollectionView(frame: tableview.frame, collectionViewLayout: layout)
        gridView.backgroundColor = UIColor.clear
        self.view.addSubview(gridView)
        gridView!.register(UINib(nibName: "GridCell", bundle: nil), forCellWithReuseIdentifier: "Gridcell")
        gridView.delegate = self
        gridView.dataSource = self

        tableview.isHidden = true
        gridView.isHidden = false
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture))
        gridView.addGestureRecognizer(longPressGesture)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressGestureRecognized))
        longPress.minimumPressDuration = 0.5
        tableview.addGestureRecognizer(longPress)
    }
    
    
    @IBAction func gridviewButton_tap() {
        
        if isGridView {
            self.navigationItem.title = "List"
            isGridView = false
            gridButton.image = UIImage(named: "grid_icon")
            tableview.reloadData()
            gridView.isHidden = true
            tableview.isHidden = false
        }
        else{
            self.navigationItem.title = "Grid"
            isGridView = true
            gridButton.image = UIImage(named: "table_icon")
            gridView.reloadData()
            tableview.isHidden = true
            gridView.isHidden = false
        }
    }
    
    
    ////////////////////////////////////////////////////////////
    ////////// Table view delegate and datasource methods ///////
    ////////////////////////////////////////////////////////////
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list_Arr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Tablecell") as! ListCell
        cell.selectionStyle = .none
        cell.textLabel?.text = list_Arr.object(at: indexPath.row) as? String

        return cell
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //////////////////// Gesture method for updating the cell in table view//////////
    ////////////////////////////////////////////////////////////////////////////////
    
    @objc func longPressGestureRecognized(_ gesture: UIGestureRecognizer) {
        
        let longPress = gesture as! UILongPressGestureRecognizer
        let state = longPress.state
        let locationInView = longPress.location(in: tableview)
        let indexPath = tableview.indexPathForRow(at: locationInView)
        
        struct My {
            static var cellSnapshot : UIView? = nil
            static var cellIsAnimating : Bool = false
            static var cellNeedToShow : Bool = false
        }
        struct Path {
            static var initialIndexPath : IndexPath? = nil
        }
        
        switch state {
        case .began:
            if indexPath != nil {
                Path.initialIndexPath = indexPath! as IndexPath
                let cell = tableview.cellForRow(at: indexPath!) as UITableViewCell!
                My.cellSnapshot  = customSnapshoFromView(inputView: cell!)
                
                var center = cell?.center
                My.cellSnapshot!.center = center!
                My.cellSnapshot!.alpha = 0.0
                tableview.addSubview(My.cellSnapshot!)
                
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    center?.y = locationInView.y
                    My.cellIsAnimating = true
                    My.cellSnapshot!.center = center!
                    My.cellSnapshot!.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    My.cellSnapshot!.alpha = 0.98
                    cell?.alpha = 0.0
                }, completion: { (finished) -> Void in
                    if finished {
                        My.cellIsAnimating = false
                        if My.cellNeedToShow {
                            My.cellNeedToShow = false
                            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                                cell?.alpha = 1
                            })
                        } else {
                            cell?.isHidden = true
                        }
                    }
                })
            }
            
        case UIGestureRecognizerState.changed:
            if My.cellSnapshot != nil {
                var center = My.cellSnapshot!.center
                center.y = locationInView.y
                My.cellSnapshot!.center = center
                
                if ((indexPath != nil) && (Path.initialIndexPath != nil) && (indexPath != Path.initialIndexPath)) {
                    
                    // ... update data source.
                    
                    list_Arr.exchangeObject(at: (indexPath?.row)!, withObjectAt: (Path.initialIndexPath!.row))
                    
                    // ... move the rows.
                    
                    tableview.moveRow(at: Path.initialIndexPath! as IndexPath, to: indexPath!)
                    Path.initialIndexPath = indexPath
                    tableview.scrollToRow(at: Path.initialIndexPath!, at: .middle, animated: true)
                }
            }
        default:
            if Path.initialIndexPath != nil {
                let cell = tableview.cellForRow(at: Path.initialIndexPath!) as UITableViewCell!
                if My.cellIsAnimating {
                    My.cellNeedToShow = true
                } else {
                    cell?.isHidden = false
                    cell?.alpha = 0.0
                }
                
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    My.cellSnapshot!.center = (cell?.center)!
                    My.cellSnapshot!.transform = .identity
                    My.cellSnapshot!.alpha = 0.0
                    cell?.alpha = 1.0
                    
                }, completion: { (finished) -> Void in
                    if finished {
                        Path.initialIndexPath = nil
                        My.cellSnapshot!.removeFromSuperview()
                        My.cellSnapshot = nil
                    }
                })
            }
        }
    }
    
    /** @brief Returns a customized snapshot of a given view. */
    func customSnapshoFromView(inputView: UIView) -> UIView {
        // Make an image from the input view.
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        // Create an image view.
        let snapshot: UIView? = UIImageView(image: image)
        snapshot?.layer.masksToBounds = false
        snapshot?.layer.cornerRadius = 0.0
        snapshot?.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        snapshot?.layer.shadowRadius = 5.0
        snapshot?.layer.shadowOpacity = 0.4
        return snapshot!
    }
 
    ////////////////////////////////////////////////////////////////////////////////
    ////////////////  Collection veiw delegate and datasource methods ///////
    ////////////////////////////////////////////////////////////////////////////////
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list_Arr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Gridcell", for:indexPath) as! GridCell
        cell.itemLbl.text = list_Arr.object(at: indexPath.row) as? String
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (self.view.frame.size.width-20)/2
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let tempvalue1 = list_Arr.object(at: sourceIndexPath.row)
        list_Arr.removeObject(at: sourceIndexPath.row)
        list_Arr.insert(tempvalue1, at: destinationIndexPath.row)
        
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    //////////////////// Gesture method for updating the cell in collection view//////////
    ////////////////////////////////////////////////////////////////////////////////
    
    @objc func handleLongGesture(_ gesture: UILongPressGestureRecognizer) {
        
        switch(gesture.state) {
            
        case UIGestureRecognizerState.began:
            guard let selectedIndexPath = gridView.indexPathForItem(at: gesture.location(in: gridView)) else {
                break
            }
            gridView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case UIGestureRecognizerState.changed:
            gridView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
            
        case UIGestureRecognizerState.ended:
            gridView.endInteractiveMovement()
            
        default:
            gridView.cancelInteractiveMovement()
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

