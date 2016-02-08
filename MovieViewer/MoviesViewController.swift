//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Zubair Khan on 2/1/16.
//  Copyright © 2016 zapps. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkErrorLabel: UILabel!

    var movies: [NSDictionary] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)

        tableView.dataSource = self
        tableView.delegate = self

        refreshControlAction(refreshControl)
    }

    func refreshControlAction(refreshControl: UIRefreshControl) {
        // Display HUD right before the request is made
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)

        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"http://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")!
        let request = NSURLRequest(URL: url)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )

        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                // Hide HUD once the network request comes back (must be done on main UI thread)
                MBProgressHUD.hideHUDForView(self.view, animated: true)

                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options:[]) as? NSDictionary {
                        if let movies = responseDictionary["results"] as? [NSDictionary] {
                            self.movies = movies
                            self.networkErrorLabel.hidden = true
                        }
                    }
                } else {
                    self.networkErrorLabel.hidden = false
                }
                self.tableView.reloadData()
                refreshControl.endRefreshing()
            }
        )
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell

        let movie = movies[indexPath.row]
        let title = getMovieTitle(movie)
        let overview = getMovieOverview(movie)

        if let url = getImageURL(movie) {
            fetchAndDisplayImage(cell.posterView, url: url)
        }

        cell.titleLabel.text = title
        cell.overviewLabel.text = overview

        return cell
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

    private func getMovieTitle(movie: NSDictionary) -> String {
        if let title = movie["title"] as? String {
            return title
        }
        return ""
    }

    private func getMovieOverview(movie: NSDictionary) -> String {
        if let overview = movie["overview"] as? String {
            return overview
        }
        return ""
    }

    private func getImageURL(movie: NSDictionary) -> NSURL? {
        var url: NSURL? = nil
        if let posterpath = movie["poster_path"] as? String {
            let baseurl = "http://image.tmdb.org/t/p/w500"
            url = NSURL(string: baseurl + posterpath)
        }
        return url
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let viewController = segue.destinationViewController as! MovieDetailsViewController
        let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)!
        let movie = movies[indexPath.row]

        if let posterUrl = getImageURL(movie) {
            viewController.posterURL = posterUrl
        }
        viewController.detailsText = getMovieOverview(movie)
        viewController.titleText = getMovieTitle(movie)
    }

}
