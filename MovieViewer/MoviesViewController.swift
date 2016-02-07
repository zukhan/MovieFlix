//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Zubair Khan on 2/1/16.
//  Copyright © 2016 zapps. All rights reserved.
//

import UIKit
import AFNetworking

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    var movies: [NSDictionary]?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self


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
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options:[]) as? NSDictionary {
                        self.movies = responseDictionary["results"] as? [NSDictionary]
                    }
                }
                self.tableView.reloadData()
            }
        )
        task.resume()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell

        let movie = movies![indexPath.row]
        if let title = movie["title"] as? String {
            if let overview = movie["overview"] as? String {
                cell.titleLabel.text = title
                cell.overviewLabel.text = overview
                if let url = getImageURL(movie) {
                    cell.posterView.setImageWithURL(url)
                }
            }
        }

        return cell
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

        if let posterUrl = getImageURL(movies![indexPath.row]) {
            viewController.posterURL = posterUrl
        }
    }

}
