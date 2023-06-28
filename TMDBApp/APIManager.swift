//
//  APIManager.swift
//  TMDBApp
//
//  Created by Rahul Bawane on 21/06/23.
//


//
//  NetworkHelper.swift
//  ListedApp
//
//  Created by Rahul Bawane on 18/06/23.
//

import Foundation

let baseUrl = "https://api.themoviedb.org/3/"//dashboardNew
let accesssToken = "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI5NjI1ZTRlMGZiYTE2MjljNWZiYTI1Y2NjNjY0ZDk5YyIsInN1YiI6IjY0OTJlNzdjNjVlMGEyMDEyNWZhMDZhMSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.SwjmhBz1VTgTpw7986lApRVyRJm87wGtpXRNU_uVuTM"

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

class NetworkHelper {
    static let shared = NetworkHelper()
    private init(){}
    
    func dataTask<T:Codable>(baseUrl: String = baseUrl, apiUrl: String, httpMethod: HTTPMethod, params: [String: String]?, modelType: T.Type, completion: @escaping (_ success: Bool, _ response: Any?) -> Void) {
        var urlComponents: URLComponents? {
            var urlComponents = URLComponents(string: baseUrl + apiUrl)
            if let params = params {
                for (key, value) in params {
                    urlComponents?.queryItems?.append(URLQueryItem(name: key, value: value))
                }
            }
            return urlComponents
        }

        guard let urlComponents = urlComponents, let url = urlComponents.url?.absoluteURL else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.setValue(accesssToken, forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let movie = try JSONDecoder().decode(modelType.self, from: data)
                    completion(true, movie)
                } catch let DecodingError.dataCorrupted(context) {
                    print(context)
                } catch let DecodingError.keyNotFound(key, context) {
                    print("Key '\(key)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch let DecodingError.valueNotFound(value, context) {
                    print("Value '\(value)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch let DecodingError.typeMismatch(type, context)  {
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch {
                    print("error: ", error)
                }
            } else {
                completion(false, nil)
            }
        }.resume()
    }
}
