//
//  MovieDetailsViewController.swift
//  TMDBApp
//
//  Created by Rahul Bawane on 21/06/23.
//

import UIKit

class MovieDetailsViewController: UIViewController, MovieDetailsViewModelToViewProtocol {

    var viewModel = MovieDetailsViewModel()
    var movieId = 0
    
    @IBOutlet weak var backdropImage: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        viewModel.delegate = self
        viewModel.getMovieDetails(id: self.movieId)
    }
    
    func updateUI() {
        DispatchQueue.main.async {
            if let movieDetails = self.viewModel.movieDetails {
                if let backdropPath = movieDetails.backdropPath {
                self.backdropImage.downloaded(from: "https://image.tmdb.org/t/p/original" + backdropPath)
                }
                self.contentLabel.text = "\(movieDetails.title ?? "")\n\(movieDetails.tagline ?? "")\n\nVotes:\(movieDetails.voteCount ?? 0)\n\nOverview:\n\(movieDetails.overview ?? "")"
            }
        }
    }
}
