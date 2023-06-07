//
//  APIClient.swift
//  AleloTeste
//
//  Created by Erick Sens on 06/06/23.
//

import Foundation

class APIClient {
    typealias CompletionHandler<T> = (Result<T,Error>) -> Void
    
    func request<T: Decodable> (endpoint: String, completion: @escaping CompletionHandler<T>) {
        guard let url =  URL(string: endpoint) else {
            completion(.failure(APIError.invalidUrl))
            return
        }
        let task =  URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data =  data else {
                completion(.failure(APIError.requestFailed))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(T.self, from: data)
                completion(.success(result))
            }
            
            catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
