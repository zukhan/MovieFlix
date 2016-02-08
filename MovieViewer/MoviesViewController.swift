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

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkErrorLabel: UILabel!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var searchField: UISearchBar!

    var searchActive = false
    var movies: [NSDictionary] = []
    var movieDetails = [Int: NSDictionary]()
    var movieTitleToIdLookup = [String: Int]()
    var filtered: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.titleView = searchField

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)

        tableView.dataSource = self
        tableView.delegate = self
        searchField.delegate = self

        refreshControlAction(refreshControl)
    }

    func refreshControlAction(refreshControl: UIRefreshControl) {
        // Display HUD right before the request is made
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)

        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"http://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")!

        makeAPICall(url, completionHandler: { (dataOrNil, response, error) in
            // Hide HUD once the network request comes back (must be done on main UI thread)
            MBProgressHUD.hideHUDForView(self.view, animated: true)

            if let data = dataOrNil {
                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options:[]) as? NSDictionary {
                    if let movies = responseDictionary["results"] as? [NSDictionary] {
                        self.movies = movies
                        self.networkErrorLabel.hidden = true
                        self.fetchMovieDetails(movies)
                    }
                }
            } else {
                self.networkErrorLabel.hidden = false
            }
            self.tableView.reloadData()
            refreshControl.endRefreshing()
        })
    }

    func fetchMovieDetails(movies: [NSDictionary]) {
        let movieIds = movies.map { (let movie) -> Int in
            return movie["id"] as! Int
        }

        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"

        for movieId in movieIds {
            let url = NSURL(string:"http://api.themoviedb.org/3/movie/\(movieId)?api_key=\(apiKey)")!
            makeAPICall(url, completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let movie = try! NSJSONSerialization.JSONObjectWithData(data, options:[]) as? NSDictionary {
                        self.movieDetails[movieId] = movie
                        self.movieTitleToIdLookup[self.getTitle(movie)] = movieId
                    }
                }
            })
        }
    }

    func makeAPICall(url: NSURL, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) {
        let request = NSURLRequest(URL: url)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )

        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: completionHandler)
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }

    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let movieTitles = movies.map { (let movie) -> String in
            return movie["title"] as! String
        }
        filtered = movieTitles.filter({ (text) -> Bool in
            let tmp: NSString = text
            let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range.location != NSNotFound
        })
        if (filtered.count == 0) {
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.tableView.reloadData()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (searchActive) {
            return filtered.count
        }
        return movies.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        cell.accessoryType = UITableViewCellAccessoryType.None

        let movie = getMovieAtIndexPath(indexPath)
        let title = getTitle(movie)
        let overview = getOverview(movie)

        if let url = getImageURL(movie) {
            fetchAndDisplayImage(cell.posterView, url: url)
        }

        cell.titleLabel.text = title
        cell.overviewLabel.text = overview

        return cell
    }

    func getMovieAtIndexPath(indexPath: NSIndexPath) -> NSDictionary {
        if (searchActive) {
            let title = filtered[indexPath.row]
            return movieDetails[movieTitleToIdLookup[title]!]!
        }
        return movies[indexPath.row]
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

    private func getTitle(movie: NSDictionary) -> String {
        return getMovieField(movie, fieldName: "title")
    }

    private func getReleaseDate(movie: NSDictionary) -> String {
        if let releaseDateStr = movie["release_date"] as? String {
            let inputDateFormatter = NSDateFormatter()
            inputDateFormatter.dateFormat = "yyyy-MM-dd"

            if let date = inputDateFormatter.dateFromString(releaseDateStr) {
                let outputDateFormatter = NSDateFormatter()
                outputDateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
                return outputDateFormatter.stringFromDate(date)
            }
        }
        return ""
    }

    private func getRating(movie: NSDictionary) -> String {
        if let rating = movie["vote_average"] as? Double {
            let percentRating = Int(rating * 10)
            return "Rating: " + String(percentRating) + "%"
        }
        return ""
    }

    private func getRuntime(movie: NSDictionary) -> String {
        let id = movie["id"] as! Int
        if let details = movieDetails[id] {
            var runtime = details["runtime"] as! Int

            var hours = 0
            var mins = 0
            while runtime >= 60 {
                runtime -= 60
                hours++
            }
            mins = runtime
            return "\(hours) hr \(mins) mins"
        }
        return ""
    }

    private func getOverview(movie: NSDictionary) -> String {
        return getMovieField(movie, fieldName: "overview")
    }

    private func getMovieField(movie: NSDictionary, fieldName: String) -> String {
        if let field = movie[fieldName] as? String {
            return field
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
        viewController.titleText = getTitle(movie)
        viewController.releaseDateText = getReleaseDate(movie)
        viewController.ratingText = getRating(movie)
        viewController.runtimeText = getRuntime(movie)
        viewController.overviewText = getOverview(movie)
    }

}
