//
//  MovieDetailsViewModel.swift
//  TMDBApp
//
//  Created by Rahul Bawane on 21/06/23.
//

import Foundation

protocol MovieDetailsViewModelToViewProtocol {
    func updateUI()
}

class MovieDetailsViewModel {
    var movieDetails: MovieDetails?
    var delegate: MovieDetailsViewModelToViewProtocol!
    
    func getMovieDetails(id: Int) {
        NetworkHelper.shared.dataTask(apiUrl: "movie/\(id)", httpMethod: .get, params: nil, modelType: MovieDetails.self) { [self] success, movieDetails in
                print(success)
                print(movieDetails)
                if success {
                    if let movieDetails = movieDetails as? MovieDetails {
                        self.movieDetails = movieDetails
                    }
                    delegate.updateUI()
                } else {
                    print("Something went wrong")
                }
            }
        }
}
