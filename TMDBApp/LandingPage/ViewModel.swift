//
//  ViewModel.swift
//  TMDBApp
//
//  Created by Rahul Bawane on 21/06/23.
//

import Foundation

protocol ViewModelToViewProtocol {
    func reloadUI()
}

enum MovieType: String {
    case popular = "movie/popular"
    case discover = "discover/movie"
    case topRated = "movie/top_rated"
}

class ViewModel {
    var popularMovieData: Movie?
    var discoverMovieData: Movie?
    var topRatedMovieData: Movie?
    var movieType = MovieType.popular
    var delegate: ViewModelToViewProtocol!
    
    func increasePageCount() {
        switch movieType {
        case .popular:
            if popularMovieData != nil {
                popularMovieData?.page += 1
            }
        case .discover:
            if discoverMovieData != nil {
                discoverMovieData?.page += 1
            }
        case .topRated:
            if topRatedMovieData != nil {
                topRatedMovieData?.page += 1
            }
        }
    }
    
    func getPageCount() -> Int {
        switch movieType {
        case .popular:
            return popularMovieData?.page ?? 1
        case .discover:
            return discoverMovieData?.page ?? 1
        case .topRated:
            return topRatedMovieData?.page ?? 1
        }
    }
    
    func shouldCallMovies() -> Bool {
        switch movieType {
        case .popular:
            return (popularMovieData?.totalPages ?? 1) > (popularMovieData?.page ?? 0)
        case .discover:
            return (discoverMovieData?.totalPages ?? 1) > (discoverMovieData?.page ?? 0)
        case .topRated:
            return (topRatedMovieData?.totalPages ?? 1) > (topRatedMovieData?.page ?? 0)
        }
    }
    
    func getQueryParams(page: Int) -> [String: String] {
        var params = ["language": "en-US",
                      "page": "\(page)"]
        if movieType == .discover {
            params["sort_by"] = "vote_count.desc"
        }
        return params
    }
    
    func getMovies() {
        if shouldCallMovies() {
            self.increasePageCount()
            let pagesVisited = self.getPageCount()
            let params = getQueryParams(page: pagesVisited)
            
            print("===>> \(pagesVisited)")
            NetworkHelper.shared.dataTask(apiUrl: movieType.rawValue, httpMethod: .get, params: params, modelType: Movie.self) { [self] success, movie in
                print(success)
                print(movie)
                if success {
                    guard let movie = movie as? Movie else {
                        return
                    }
                    switch movieType {
                    case .popular:
                        if popularMovieData == nil {
                            popularMovieData = movie
                            popularMovieData?.results.removeAll()
                        }
                        popularMovieData?.page = movie.page
                        popularMovieData?.results += movie.results
                    case .discover:
                        if discoverMovieData == nil {
                            discoverMovieData = movie
                            discoverMovieData?.results.removeAll()
                        }
                        discoverMovieData?.page = movie.page
                        discoverMovieData?.results += movie.results
                    case .topRated:
                        if topRatedMovieData == nil {
                            topRatedMovieData = movie
                            topRatedMovieData?.results.removeAll()
                        }
                        topRatedMovieData?.page = movie.page
                        topRatedMovieData?.results += movie.results
                    }
                    delegate.reloadUI()
                } else {
                    print("Something went wrong")
                }
            }
        }
    }
}
