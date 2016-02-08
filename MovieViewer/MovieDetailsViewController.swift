//
//  MovieDetailsViewController.swift
//  MovieViewer
//
//  Created by Zubair Khan on 2/6/16.
//  Copyright © 2016 zapps. All rights reserved.
//

import UIKit
import AFNetworking

class MovieDetailsViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsScrollView: UIScrollView!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var detailsView: UIView!

    var posterURL: NSURL?
    var detailsText: String = ""
    var titleText: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        detailsScrollView.contentInset = UIEdgeInsets.init()
        detailsScrollView.contentInset.top = 500
    }

    override func viewDidAppear(animated: Bool) {
        if let posterURL = posterURL {
            posterView.setImageWithURL(posterURL)
        }
        titleLabel.text = titleText
        overviewLabel.text = detailsText
        overviewLabel.sizeToFit()

        let contentWidth = detailsScrollView.bounds.width
        let contentHeight = overviewLabel.frame.height + 50

        var newFrame = detailsView.frame
        newFrame.size.height = contentHeight
        detailsView.frame = newFrame
        detailsScrollView.contentSize = CGSizeMake(contentWidth, contentHeight)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
