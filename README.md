# Drag-Drop-list
It's show how to drag and drop the table view and collection view cell and replace it.

# Requirements

 - IOS 8.0+
 - XCode 9.0+
 - Swift 4.0 +
 
# Quick Guide

  This is the simplest example to implement the drag and drop cell for both Collection View and Table View.
  
  In this example we have use the simple Longpress gesture to drag and select the cell from source index and after drop the cell will be exchange with the destination index cell.
  
  // This Method is used for table view longpress gesture.
  
  func longPressGestureRecognized(_ gesture: UIGestureRecognizer) {
        
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
    
    In Collection view drag and drop we also use the Longpress gesture for selecting the cell from source index and we have also use the InteractiveMovement function of UICollectionView class.
    
    func handleLongGesture(_ gesture: UILongPressGestureRecognizer) {
        
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
    
    
