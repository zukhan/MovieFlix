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
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var runtimeLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!

    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var detailsScrollView: UIScrollView!

    var posterURL: NSURL?
    var titleText: String = ""
    var releaseDateText: String = ""
    var ratingText: String = ""
    var runtimeText: String = ""
    var overviewText: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        detailsScrollView.contentInset = UIEdgeInsets.init()
        detailsScrollView.contentInset.top = 500
    }

    override func viewDidAppear(animated: Bool) {
        if let posterURL = posterURL {
            fetchAndDisplayImage(posterView, url: posterURL)
        }
        titleLabel.text = titleText
        ratingLabel.text = ratingText
        releaseDateLabel.text = releaseDateText
        runtimeLabel.text = runtimeText
        overviewLabel.text = overviewText

        overviewLabel.sizeToFit()

        let contentWidth = detailsScrollView.bounds.width
        let contentHeight = overviewLabel.frame.height + 85

        var newFrame = detailsView.frame
        newFrame.size.height = contentHeight
        detailsView.frame = newFrame
        detailsScrollView.contentSize = CGSizeMake(contentWidth, contentHeight)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func fetchAndDisplayImage(imageView: UIImageView, url: NSURL) {
        let imageRequest = NSURLRequest(URL: url)
        imageView.setImageWithURLRequest(
            imageRequest,
            placeholderImage: nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
                    imageView.alpha = 0.0
                    imageView.image = image
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        imageView.alpha = 1.0
                    })
                } else {
                    imageView.image = image
                }
            },
            failure: { (imageRequest, imageResponse, error) -> Void in
                // do something for the failure condition
            }
        )
    }

}
