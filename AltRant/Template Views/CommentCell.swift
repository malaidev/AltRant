//
//  CommentCell.swift
//  AltRant
//
//  Created by Omer Shamai on 12/7/20.
//

import UIKit
//import SwiftUI
import QuickLook
import SwiftRant
import SwiftHEXColors
import SkeletonView
//import ActiveLabel


class CommentCell: UITableViewCell, UITextViewDelegate, URLSessionDataDelegate {
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var downvoteButton: UIButton!
    
    @IBOutlet weak var textStackView: UIStackView!
    @IBOutlet weak var userProfileImageView: RoundedImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userScoreLabel: PaddingLabel!
    @IBOutlet weak var userStackView: UIStackView!
    @IBOutlet weak var actionsStackView: UIStackView!
    @IBOutlet weak var contentStackView: UIStackView!
    
    @IBOutlet weak var bodyLabel: UITextView!
    @IBOutlet weak var postTimeLabel: UILabel!
    @IBOutlet weak var supplementalImageView: UIImageView!
    @IBOutlet weak var reportModifyButton: UIButton!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    /**
     The `File` instance for a possible image.
     
     # See Also
        [File](x-source-tag://File)
     */
    var file: File?
    
    /**
     The data for the comment.
     
     # See Also
     [CommentModel](x-source-tag://CommentModel)
     */
    var commentContents: Comment!
    
    /**
     The parent view controller.
     
     - important: This technically can be any UIViewController, but it is advised to only put UITableViewControllers in this variable.
     */
    var parentTableViewController: UIViewController? = nil
    
    /**
     The parent table view.
     */
    var parentTableView: UITableView? = nil
    
    /**
     A pointer holding the data for the same comment in another table view.
     
     If the comment data was also represented somewhere else (for example, in another table view) and you want to sync the data between both instances of the same comment (for continuity's sake), set this property's value to your other instance's pointer.
     
     # See Also
     [CommentModel](x-source-tag://CommentModel)
     */
    //var commentInFeed: UnsafeMutablePointer<Comment>?
    
    var delegate: FeedDelegate?
    
    private var loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    //- commentInFeed: An [`UnsafeMutablePointer`]() pointer holding the data for the same comment in another table view. Optional.
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        supplementalImageView.image = nil
        supplementalImageView.isHidden = true
        
        userProfileImageView.image = nil
        
        imageViewHeightConstraint.constant = 0
        
        file = nil
        
        commentContents = nil
        
        scoreLabel.text = ""
        bodyLabel.text = ""
        bodyLabel.attributedText = nil
        
        NotificationCenter.default.removeObserver(self, name: windowResizeNotification, object: nil)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        layoutIfNeeded()
    }
    
    /**
     Configures the comment cell to show a loading ring.
     
     - returns: Nothing.
     */
    func configureLoading() {
        upvoteButton.isHidden = true
        scoreLabel.isHidden = true
        downvoteButton.isHidden = true
        textStackView.isHidden = true
        bodyLabel.isHidden = true
        supplementalImageView.isHidden = true
        
        contentView.addSubview(loadingIndicator)
        
        loadingIndicator.startAnimating()
        
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        //loadingIndicator.widthAnchor.constraint(equalToConstant: 20).isActive = true
        //loadingIndicator.heightAnchor.constraint(equalToConstant: 20).isActive = true
        loadingIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
        loadingIndicator.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -40).isActive = true
        loadingIndicator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 40).isActive = true
        
        layoutIfNeeded()
        //loadingIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 40).isActive = true
        
        //loadingIndicator.hidesWhenStopped = true
    }
    
    /**
     Configures the comment cell with the required data.
     
     - parameters:
        - model: The `CommentModel` full of the data given from the devRant API.
        - supplementalImage: If there is an image associated with the comment, this is the parameter that you need to set in order to give the cache URL for the image. Optional.
        - parentTableViewController: The table view controller that shows this cell. Optional.
        - parentTableView: The table view that shows this cell. Optional.
        - commentInFeed: An `UnsafeMutablePointer` that holds the address for the data for the same `CommentModel` in another table view. Optional.
        - allowedToPreview: A boolean value that tells the cell if it should allow special functionality, like previewing attached images and opening the comment's poster's profile page.
     
     - returns: Nothing.
     */
    func configure(with model: Comment, supplementalImage: File?, parentTableViewController: UIViewController?, parentTableView: UITableView?, currentDate: Date, allowedToPreview: Bool) {
        self.commentContents = model
        self.file = supplementalImage
        self.parentTableViewController = parentTableViewController
        self.parentTableView = parentTableView
        
        if loadingIndicator.isDescendant(of: contentView) {
            loadingIndicator.removeFromSuperview()
        }
        
        upvoteButton.isHidden = false
        scoreLabel.isHidden = false
        downvoteButton.isHidden = false
        textStackView.isHidden = false
        bodyLabel.isHidden = false
        supplementalImageView.isHidden = false
        
        debugPrint("==========BEGIN DEBUG COMMENT INFO==========")
        debugPrint("COMMENT ID:         \(commentContents.id)")
        debugPrint("ASSOCIATED RANT ID: \(commentContents.rantID)")
        debugPrint("BODY:               \"\(commentContents.body.count <= 30 ? commentContents.body : "\(commentContents.body.prefix(upTo: commentContents.body.index(commentContents.body.startIndex, offsetBy: 29)))...")")
        debugPrint("SCORE:              \(commentContents.score)")
        debugPrint("CREATED TIME:       \(commentContents.createdTime)")
        debugPrint("VOTE STATE:         \(commentContents.voteState)")
        debugPrint("IS EDITED:          \(commentContents.isEdited)")
        debugPrint("LINKS:              \(commentContents.links == nil ? "0 LINKS" : "\(commentContents.links!.count) LINKS")")
        debugPrint("USER ID:            \(commentContents.userID)")
        debugPrint("USERNAME:           \(commentContents.username)")
        debugPrint("USER SCORE:         \(commentContents.userScore)")
        
        upvoteButton.tintColor = (model.voteState == .upvoted ? UIColor(hexString: model.userAvatar.backgroundColor)! : UIColor.systemGray)
        //scoreLabel.text = String(commentContents!.score)
        scoreLabel.text = formatNumber(commentContents!.score)
        downvoteButton.tintColor = (model.voteState == .downvoted ? UIColor(hexString: model.userAvatar.backgroundColor)! : UIColor.systemGray)
        
        if commentContents.attachedImage == nil {
            supplementalImageView.isHidden = true
        } else {
            supplementalImageView.isHidden = false
            
            supplementalImageView.translatesAutoresizingMaskIntoConstraints = false
            
            let resizeMultiplier = supplementalImageView.frame.size.width / (CGFloat(commentContents.attachedImage!.width) / UIScreen.main.scale)
            
            let finalHeight = (CGFloat(commentContents.attachedImage!.height) / UIScreen.main.scale) * resizeMultiplier
            
            debugPrint("FINAL IMAGE HEIGHT: \(finalHeight)")
            
            imageViewHeightConstraint.constant = finalHeight
            
            NotificationCenter.default.addObserver(self, selector: #selector(windowResizeHandler), name: windowResizeNotification, object: nil)
            
            supplementalImageView.showAnimatedSkeleton()
            
            var request = URLRequest(url: URL(string: commentContents.attachedImage!.url)!)
            request.cachePolicy = .returnCacheDataElseLoad
            
            // hopefully, this is cached.
            let dataTask = URLSession.shared.dataTask(with: request) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async { [weak self] in
                        self?.supplementalImageView.image = UIImage(data: data)
                        
                        self?.supplementalImageView.hideSkeleton(transition: .crossDissolve(0.2))
                    }
                }
            }
            
            dataTask.delegate = self
            
            dataTask.resume()
            
            /*if FileManager.default.fileExists(atPath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(URL(string: commentContents.attachedImage!.url)!.lastPathComponent).relativePath) {
                let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(URL(string: commentContents.attachedImage!.url)!.lastPathComponent).relativePath
                
                debugPrint("IMAGE FOUND AT RELATIVE PATH \(path) FOR COMMENT ID \(commentContents.id)!")
                
                DispatchQueue.global().async {
                    let image = UIImage(contentsOfFile: path)
                    
                    DispatchQueue.main.async { [weak self] in
                        self?.supplementalImageView.image = image
                        
                        self?.supplementalImageView.hideSkeleton(transition: .crossDissolve(0.2))
                    }
                }
            } else {
                debugPrint("IMAGE \(URL(string: commentContents.attachedImage!.url)!.lastPathComponent) FOR COMMENT ID \(commentContents.id) NOT AVAILABLE ON DISK, FETCHING FROM WEB...")
                let session = URLSession(configuration: .default)
                let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(URL(string: commentContents.attachedImage!.url)!.lastPathComponent)
                
                session.dataTask(with: URL(string: commentContents.attachedImage!.url)!) { data, _, _ in
                    if let data = data {
                        try? data.write(to: fileURL, options: .atomic)
                        
                        DispatchQueue.main.async { [weak self] in
                            self?.supplementalImageView.image = UIImage(data: data)
                            self?.supplementalImageView.hideSkeleton(transition: .crossDissolve(0.2))
                        }
                    }
                }.resume()
            }*/
            
            /*let resizeMultiplier = supplementalImage!.size!.width / bodyLabel.frame.size.width
            
            let finalWidth = supplementalImage!.size!.width / resizeMultiplier
            let finalHeight = supplementalImage!.size!.height / resizeMultiplier
            
            UIGraphicsBeginImageContextWithOptions(CGSize(width: finalWidth, height: finalHeight), false, resizeMultiplier)
            UIImage(contentsOfFile: supplementalImage!.previewItemURL.relativePath)!.draw(in: CGRect(origin: .zero, size: CGSize(width: finalWidth, height: finalHeight)))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            supplementalImageView.image = newImage*/
        }
        
        upvoteButton.isEnabled = commentContents!.voteState != .unvotable
        downvoteButton.isEnabled = commentContents!.voteState != .unvotable
        
        bodyLabel.text = commentContents!.body
        
        /*if let parentTableViewController = parentTableViewController as? RantViewController {
            Task {
                self.userProfileImageView.image = try? await parentTableViewController.userImageLoader.loadImage(withUserID: self.commentContents.userID)
            }
        } else if let parentTableViewController = parentTableViewController as? ProfileTableViewController {
            Task {
                self.userProfileImageView.image = try? await parentTableViewController.userImageLoader.loadImage(withUserID: self.commentContents.userID)
            }
        }*/
        
        userProfileImageView.backgroundColor = UIColor(hexString: commentContents.userAvatar.backgroundColor)
        
        if let avatarImage = commentContents.userAvatar.avatarImage {
            userProfileImageView.showAnimatedSkeleton(usingColor: UIColor(hexString: commentContents.userAvatar.backgroundColor)!)
            
            var request = URLRequest(url: URL(string: "https://avatars.devrant.com/\(avatarImage)")!)
            request.cachePolicy = .returnCacheDataElseLoad
            
            // hopefully, this is cached.
            let dataTask = URLSession.shared.dataTask(with: request) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async { [weak self] in
                        self?.userProfileImageView.image = UIImage(data: data)
                        
                        self?.userProfileImageView.hideSkeleton(transition: .crossDissolve(0.2))
                    }
                }
            }
            
            dataTask.delegate = self
            
            dataTask.resume()
        }
        
        usernameLabel.text = commentContents!.username
        
        if commentContents!.score < 0 {
            userScoreLabel.text = String(commentContents!.userScore)
        } else {
            userScoreLabel.text = "+\(commentContents!.userScore)"
        }
        
        userScoreLabel.backgroundColor = UIColor(hexString: commentContents!.userAvatar.backgroundColor)
        
        scoreLabel.text = String(commentContents!.score)
        
        if allowedToPreview {
            let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleImageTap(_:)))
            supplementalImageView.addGestureRecognizer(imageGestureRecognizer)
            
            let usernameGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleUsernameTap(_:)))
            userStackView.addGestureRecognizer(usernameGestureRecognizer)
            
            if commentContents.userID == SwiftRant.shared.tokenFromKeychain!.authToken.userID && commentContents.username == SwiftRant.shared.usernameFromKeychain {
                reportModifyButton.setTitle("Modify", for: .normal)
                
                let actionsMenu = UIMenu(title: "", children: [
                    UIAction(title: "Edit", image: UIImage(systemName: "square.and.pencil")!, handler: { _ in
                        if Double(Date().timeIntervalSince1970) - Double(self.commentContents.createdTime) >= 300 {
                            let alert = UIAlertController(title: "Editing Disabled", message: "Rants and comments can only be edited for 5 mins (30 mins for devRant++ subscribers) after they are posted.", preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: nil))
                            
                            self.parentTableViewController?.present(alert, animated: true, completion: nil)
                        } else {
                            let composeVC = UIStoryboard(name: "ComposeViewController", bundle: nil).instantiateViewController(identifier: "ComposeViewController") as! UINavigationController
                            (composeVC.viewControllers.first as! ComposeViewController).commentID = self.commentContents.id
                            (composeVC.viewControllers.first as! ComposeViewController).isComment = true
                            (composeVC.viewControllers.first as! ComposeViewController).isEdit = true
                            (composeVC.viewControllers.first as! ComposeViewController).content = self.commentContents.body
                            
                            (composeVC.viewControllers.first as! ComposeViewController).viewControllerThatPresented = self.parentTableViewController
                            
                            composeVC.isModalInPresentation = true
                            
                            self.parentTableViewController!.present(composeVC, animated: true, completion: nil)
                        }
                    }),
                    
                    UIAction(title: "Delete", image: UIImage(systemName: "trash")!, handler: { _ in
                        let alert = UIAlertController(title: "Confirm Delete", message: "Are you sure you want to delete this comment?", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in self.delete() }))
                        
                        self.parentTableViewController?.present(alert, animated: true, completion: nil)
                    })
                ])
                
                reportModifyButton.showsMenuAsPrimaryAction = true
                reportModifyButton.menu = actionsMenu
            } else {
                reportModifyButton.setTitle("Report", for: .normal)
            }
            
            if commentContents.links != nil {
                debugPrint("IS ADDING LINKS:    true")
                if let parentTableViewController = parentTableViewController, let controller = parentTableViewController as? RantViewController {
                    bodyLabel.attributedText = controller.textsWithLinks[commentContents.id]
                }
                bodyLabel.isUserInteractionEnabled = true
                
                bodyLabel.delegate = self
            } else {
                debugPrint("IS ADDING LINKS:    false")
                //bodyLabel.attributedText = nil
                //bodyLabel.text = commentContents.body
                var attributedString = NSMutableAttributedString(string: commentContents.body)
                
                attributedString.addAttribute(.font, value: UIFont.preferredFont(forTextStyle: .body), range: (commentContents.body as NSString).range(of: commentContents.body))
                
                attributedString.addAttribute(.foregroundColor, value: UIColor.label, range: (commentContents.body as NSString).range(of: commentContents.body))
                
                bodyLabel.attributedText = attributedString
            }
        }
        
        if !allowedToPreview {
            actionsStackView.isHidden = true
            
            bodyLabel.isUserInteractionEnabled = false
            bodyLabel.isSelectable = false
            bodyLabel.dataDetectorTypes = UIDataDetectorTypes([])
        } else {
            if let gestureRecognizers = bodyLabel.gestureRecognizers {
                print("GESTURE RECOGNIZERS IN BODY LABEL FOUND! SEARCHING DOUBLE TAP...")
                
                for (idx, gestureRecognizer) in gestureRecognizers.enumerated() {
                    if gestureRecognizer is UITapGestureRecognizer && (gestureRecognizer as! UITapGestureRecognizer).numberOfTapsRequired > 1 {
                        print("FOUND DOUBLE+ TAP! NUMBER OF TAPS REQUIRED: \((gestureRecognizer as! UITapGestureRecognizer).numberOfTapsRequired)")
                        //bodyLabel.removeGestureRecognizer(gestureRecognizer)
                        
                        let newDoubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap))
                        newDoubleTapGesture.numberOfTapsRequired = 2
                        bodyLabel.addGestureRecognizer(newDoubleTapGesture)
                        
                        
                        gestureRecognizer.removeTarget(nil, action: nil)
                        gestureRecognizer.require(toFail: newDoubleTapGesture)
                        
                        print(gestureRecognizer.debugDescription)
                        
                        print("---------------------------")
                    }
                }
            }
        }
        
        let createdDate = Date(timeIntervalSince1970: Double(commentContents.createdTime))
        if currentDate.timeIntervalSince1970 - createdDate.timeIntervalSince1970 < 60 {
            postTimeLabel.text = "\(commentContents.isEdited ? "(Edited) " : "")\(Int((currentDate.timeIntervalSince1970 - createdDate.timeIntervalSince1970).rounded(.up)))s"
        } else if (currentDate.timeIntervalSince1970 - createdDate.timeIntervalSince1970) < 3600 {
            postTimeLabel.text = "\(commentContents.isEdited ? "(Edited) " : "")\(Int(((currentDate.timeIntervalSince1970 - createdDate.timeIntervalSince1970) / 60).rounded(.up)))m"
        } else if currentDate.timeIntervalSince1970 - createdDate.timeIntervalSince1970 < 86400 {
            postTimeLabel.text = "\(commentContents.isEdited ? "(Edited) " : "")\(Int(((currentDate.timeIntervalSince1970 - createdDate.timeIntervalSince1970) / 3600).rounded(.up)))h"
        } else if currentDate.timeIntervalSince1970 - createdDate.timeIntervalSince1970 < 2678400 {
            postTimeLabel.text = "\(commentContents.isEdited ? "(Edited) " : "")\(Int(((currentDate.timeIntervalSince1970 - createdDate.timeIntervalSince1970) / 86400).rounded(.up)))d"
        } else {
            postTimeLabel.text = "\(commentContents.isEdited ? "(Edited) " : "")\(createdDate.formatted(date: .numeric, time: .omitted))"
        }
        
        debugPrint("===========END DEBUG COMMENT INFO===========")
        
        layoutIfNeeded()
    }
    
    @objc func didDoubleTap() {
        guard commentContents.voteState != .upvoted && commentContents.voteState != .unvotable else {
            return
        }
        
        (delegate as? ProfileTableViewControllerDelegate)?.setVoteStateForComment(withID: commentContents!.id, voteState: .upvoted)
        (delegate as? RantViewControllerDelegate)?.changeCommentVoteState(commentID: commentContents!.id, voteState: .upvoted)
        
        (delegate as? ProfileTableViewControllerDelegate)?.setScoreForComment(withID: commentContents!.id, score: commentContents!.voteState == .upvoted ? commentContents!.score - 1 : commentContents!.score + VoteState.upvoted.rawValue)
        (delegate as? RantViewControllerDelegate)?.changeCommentScore(commentID: commentContents!.id, score: commentContents!.voteState == .upvoted ? commentContents!.score - 1 : commentContents!.score + VoteState.upvoted.rawValue)
        
        DispatchQueue.main.async {
            (self.delegate as? ProfileTableViewControllerDelegate)?.reloadData()
            (self.delegate as? RantViewControllerDelegate)?.reloadData()
        }
        
        delegate?.didVoteOnComment(withID: commentContents.id, vote: .upvoted, cell: self)
    }
    
    func delete() {
        self.parentTableViewController?.title = "Deleting your comment..."
        
        delegate?.didDeleteComment(withID: commentContents.id, cell: self)
    }
    
    @IBAction func handleUpvote(_ sender: UIButton) {
        var vote: VoteState {
            switch self.commentContents!.voteState {
            case .unvoted:
                return .upvoted
                
            case .upvoted:
                return .unvoted
                
            default:
                return .upvoted
            }
        }
        
        (delegate as? ProfileTableViewControllerDelegate)?.setVoteStateForComment(withID: commentContents!.id, voteState: vote)
        (delegate as? RantViewControllerDelegate)?.changeCommentVoteState(commentID: commentContents!.id, voteState: vote)
        
        (delegate as? ProfileTableViewControllerDelegate)?.setScoreForComment(withID: commentContents!.id, score: commentContents!.voteState == .upvoted ? commentContents!.score - 1 : commentContents!.score + vote.rawValue)
        (delegate as? RantViewControllerDelegate)?.changeCommentScore(commentID: commentContents!.id, score: commentContents!.voteState == .upvoted ? commentContents!.score - 1 : commentContents!.score + vote.rawValue)
        
        DispatchQueue.main.async {
            (self.delegate as? ProfileTableViewControllerDelegate)?.reloadData()
            (self.delegate as? RantViewControllerDelegate)?.reloadData()
        }
        
        delegate?.didVoteOnComment(withID: commentContents.id, vote: vote, cell: self)
    }
    
    @IBAction func handleDownvote(_ sender: UIButton) {
        var vote: VoteState {
            switch self.commentContents!.voteState {
            case .unvoted:
                return .downvoted
                
            case .downvoted:
                return .unvoted
                
            default:
                return .downvoted
            }
        }
        
        (delegate as? ProfileTableViewControllerDelegate)?.setVoteStateForComment(withID: commentContents!.id, voteState: vote)
        (delegate as? RantViewControllerDelegate)?.changeCommentVoteState(commentID: commentContents!.id, voteState: vote)
        
        (delegate as? ProfileTableViewControllerDelegate)?.setScoreForComment(withID: commentContents!.id, score: commentContents!.voteState == .downvoted ? commentContents!.score + 1 : commentContents!.score + vote.rawValue)
        (delegate as? RantViewControllerDelegate)?.changeCommentScore(commentID: commentContents!.id, score: commentContents!.voteState == .downvoted ? commentContents!.score + 1 : commentContents!.score + vote.rawValue)
        
        DispatchQueue.main.async {
            (self.delegate as? ProfileTableViewControllerDelegate)?.reloadData()
            (self.delegate as? RantViewControllerDelegate)?.reloadData()
        }
        
        delegate?.didVoteOnComment(withID: commentContents.id, vote: vote, cell: self)
    }
    
    @objc func handleImageTap(_ sender: UITapGestureRecognizer) {
        let quickLookViewController = QLPreviewController()
        quickLookViewController.modalPresentationStyle = .overFullScreen
        quickLookViewController.dataSource = (parentTableViewController as! RantViewController)
        quickLookViewController.delegate = (parentTableViewController as! RantViewController)
        (parentTableViewController as! RantViewController).tappedComment = self
        
        quickLookViewController.currentPreviewItemIndex = 0
        parentTableViewController?.present(quickLookViewController, animated: true)
    }
    
    @objc func handleUsernameTap(_ sender: UITapGestureRecognizer) {
        if let parentTableViewController = self.parentTableViewController {
            let profileVC = UIStoryboard(name: "ProfileTableViewController", bundle: nil).instantiateViewController(identifier: "ProfileTableViewController", creator: { coder in
                return ProfileTableViewController(coder: coder, userID: self.commentContents.userID)
            })
            
            print(String(describing: type(of: parentTableViewController)))
            print(String(describing: type(of: self)))
            
            parentTableViewController.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    @IBAction func reply(_ sender: Any) {
        let composeVC = UIStoryboard(name: "ComposeViewController", bundle: nil).instantiateViewController(identifier: "ComposeViewController") as! UINavigationController
        
        (composeVC.viewControllers.first! as! ComposeViewController).content = "@\(commentContents.username) "
        (composeVC.viewControllers.first! as! ComposeViewController).rantID = commentContents.rantID
        (composeVC.viewControllers.first! as! ComposeViewController).isComment = true
        (composeVC.viewControllers.first! as! ComposeViewController).isEdit = false
        (composeVC.viewControllers.first! as! ComposeViewController).viewControllerThatPresented = parentTableViewController
        
        composeVC.isModalInPresentation = true
        parentTableViewController?.present(composeVC, animated: true, completion: nil)
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        if URL.absoluteString.hasPrefix("mention://") {
            if let parentTableViewController = self.parentTableViewController {
                let profileVC = UIStoryboard(name: "ProfileTableViewController", bundle: nil).instantiateViewController(identifier: "ProfileTableViewController", creator: { coder in
                    return ProfileTableViewController(coder: coder, userID: Int(URL.absoluteString.components(separatedBy: "/").last!)!)
                })
                
                print(String(describing: type(of: parentTableViewController)))
                print(String(describing: type(of: self)))
                
                parentTableViewController.navigationController?.pushViewController(profileVC, animated: true)
            }
        } else {
            UIApplication.shared.open(URL)
        }
        return false
    }
    
    private func getImageResizeMultiplier(imageWidth: CGFloat, imageHeight: CGFloat, multiplier: Int) -> CGFloat {
        if imageWidth / CGFloat(multiplier) < 315 && imageHeight / CGFloat(multiplier) < 420 {
            return CGFloat(multiplier)
        } else {
            return getImageResizeMultiplier(imageWidth: imageWidth, imageHeight: imageHeight, multiplier: multiplier + 2)
        }
    }
    
    @objc func windowResizeHandler() {
        guard commentContents.attachedImage != nil else {
            return
        }
        
        let resizeMultiplier = supplementalImageView.frame.size.width / (CGFloat(commentContents.attachedImage!.width) / UIScreen.main.scale)
        
        let finalHeight = (CGFloat(commentContents.attachedImage!.height) / UIScreen.main.scale) * resizeMultiplier
        
        imageViewHeightConstraint.constant = finalHeight
        
        layoutIfNeeded()
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
        
        debugPrint("CACHING IMAGE FOR COMMENT ID \(commentContents.id) WITH STORAGE POLICY: \(proposedResponse.storagePolicy == .allowed ? ".allowed" : proposedResponse.storagePolicy == .allowedInMemoryOnly ? ".allowedInMemoryOnly" : ".notAllowed")")
        
        completionHandler(proposedResponse)
    }
}

func unsafeWaitFor(_ f: @escaping () async -> ()) {
    let sema = DispatchSemaphore(value: 0)
    Task {
        await f()
        sema.signal()
    }
    
    sema.wait()
}
