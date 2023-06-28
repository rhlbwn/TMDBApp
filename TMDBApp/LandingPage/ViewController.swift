//
//  ViewController.swift
//  TMDBApp
//
//  Created by Rahul Bawane on 21/06/23.
//

import UIKit

class MovieCell: UICollectionViewCell {
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    
    func setupCell(movieTitle: String, imageUrl: String) {
        self.movieTitle.text = movieTitle
        DispatchQueue.main.async {
            self.movieImage.downloaded(from: "https://image.tmdb.org/t/p/original" + imageUrl)
        }
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var filterButton: UIButton!
    
    var viewModel = ViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.title = "Movies List"
        self.filterButton.setTitle("Popular", for: .normal)
        viewModel.delegate = self
        viewModel.getMovies()
    }

    @IBAction func filterAction(_ sender: Any) {
        let controller = UIAlertController(title: "", message: "Filter Options", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Discover", style: .default) { _ in
            self.filterButton.setTitle("Discover", for: .normal)
            self.viewModel.movieType = .discover
            self.viewModel.getMovies()
        }
        let action2 = UIAlertAction(title: "Popular", style: .default) { _ in
            self.filterButton.setTitle("Popular", for: .normal)
            self.viewModel.movieType = .popular
            self.viewModel.getMovies()
        }
        let action3 = UIAlertAction(title: "Top Rated", style: .default) { _ in
            self.filterButton.setTitle("Top Rated", for: .normal)
            self.viewModel.movieType = .topRated
            self.viewModel.getMovies()
        }
        controller.addAction(action1)
        controller.addAction(action2)
        controller.addAction(action3)
        self.present(controller, animated: true)
    }
    
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.viewModel.movieType {
        case .popular:
            return self.viewModel.popularMovieData?.results.count ?? 0
        case .discover:
            return self.viewModel.discoverMovieData?.results.count ?? 0
        case .topRated:
            return self.viewModel.topRatedMovieData?.results.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCell
        var movieData: Result?
        switch self.viewModel.movieType {
        case .popular:
            movieData = self.viewModel.popularMovieData?.results[indexPath.item]
        case .discover:
            movieData = self.viewModel.discoverMovieData?.results[indexPath.item]
        case .topRated:
            movieData = self.viewModel.topRatedMovieData?.results[indexPath.item]
        }
        let title = movieData?.originalTitle ?? ""
        let image = movieData?.posterPath ?? ""
        cell.setupCell(movieTitle: "\(indexPath.item + 1) " + title, imageUrl: image)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var id = 0
        switch self.viewModel.movieType {
        case .popular:
            id = self.viewModel.popularMovieData?.results[indexPath.item].id ?? 0
        case .discover:
            id = self.viewModel.discoverMovieData?.results[indexPath.item].id ?? 0
        case .topRated:
            id = self.viewModel.topRatedMovieData?.results[indexPath.item].id ?? 0
        }
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "MovieDetailsViewController") as? MovieDetailsViewController
        else {
            return
        }
        vc.movieId = id
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width)
        return CGSize(width: width/2, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        var count = 0
        switch self.viewModel.movieType {
        case .popular:
            count = self.viewModel.popularMovieData?.results.count ?? 0
        case .discover:
            count = self.viewModel.discoverMovieData?.results.count ?? 0
        case .topRated:
            count = self.viewModel.topRatedMovieData?.results.count ?? 0
        }
        if count != 0 && count == indexPath.item + 1 {
            self.viewModel.getMovies()
        }
    }
}

extension ViewController: ViewModelToViewProtocol {
    func reloadUI() { 
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
