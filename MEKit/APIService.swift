//
//  APIService.swift
//  MEKit
//
//  Created by Pablo Ezequiel Romero Giovannoni on 23/11/2019.
//  Copyright © 2019 Pablo Ezequiel Romero Giovannoni. All rights reserved.
//

import Foundation

public struct APIServiceConfiguration {
    private init() { }
    static var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .formatted(Formatter.dateFormatter)
}

enum APIServiceError: Error {
    case noData
}

protocol APIRequestProtocol {
    func cancel()
}

class APIRequest: APIRequestProtocol {
    let dataTask: URLSessionDataTask
    
    init(dataTask: URLSessionDataTask) {
        self.dataTask = dataTask
    }
    
    func cancel() {
        dataTask.cancel()
    }
}

enum APIHTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case DELETE = "DELETE"
    case PUT = "PUT"
    case PATCH = "PATCH"
}

protocol APIResponseBase {
    init(_ data: Data) throws
}

struct APIResponse<DataType: Decodable>: APIResponseBase {
    var value: DataType?
    
    init(_ data: Data) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = APIServiceConfiguration.dateDecodingStrategy
        value = try decoder.decode(DataType.self, from: data)
    }
}

struct APICollectionResponse<DataType: Decodable>: APIResponseBase {
    var values: [DataType]?
    
    init(_ data: Data) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = APIServiceConfiguration.dateDecodingStrategy
        values = try decoder.decode([DataType].self, from: data)
    }
}

protocol APIEndpoint {
    associatedtype ResultType: APIResponseBase

    func createURLRequest(baseURL: URL) -> URLRequest
    
    var path: String {get}
    var method: APIHTTPMethod {get}
    var queryParameters: [String: Any]? {get}
    var bodyData: Data? {get}
}

extension APIEndpoint {
    var queryParameters: [String: Any]? {
        return nil
    }
    
    var bodyData: Data? {
        return nil
    }
    
    func createURLRequest(baseURL: URL) -> URLRequest {
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
       
        if !path.isEmpty {
            urlComponents.path.append(path)
        }
        
        if let queryParameters = queryParameters, !queryParameters.isEmpty {
            var queryItems: [URLQueryItem] = []
            
            for (key, value) in queryParameters {
                queryItems.append(URLQueryItem(name: key, value: "\(value)"))
            }
            
            urlComponents.queryItems = queryItems
        }
                       
        let url = urlComponents.url!
        var request = URLRequest(url: url)
        
        request.httpMethod = method.rawValue
        
        if let bodyData = bodyData {
            request.httpBody = bodyData
        }
        
        return request
    }
}

protocol APIPagedEndpoint: APIEndpoint {
    var page: Int {get set}
    var pageSize: Int {get}
}

protocol APIServiceProtocol {
    @discardableResult func load<E: APIEndpoint>(endpoint: E, completion: @escaping (Result<E.ResultType, Error>)->()) -> APIRequestProtocol
}

class APIService: APIServiceProtocol {
    
    let baseURL: URL
    
    init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    @discardableResult func load<E: APIEndpoint>(endpoint: E, completion: @escaping (Result<E.ResultType, Error>)->()) -> APIRequestProtocol {
        
        let urlRequest = endpoint.createURLRequest(baseURL: baseURL)
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, URLResponse, requestError in
            var result: Result<E.ResultType, Error>!
            
            if let requestError = requestError {
                result = .failure(requestError)
            } else {
                if let data = data {
                    do {
                        let response = try E.ResultType.init(data)
                        result = .success(response)
                    } catch {
                        result = .failure(error)
                    }
                } else {
                    result = .failure(APIServiceError.noData)
                }
            }
            
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        dataTask.resume()
        
        return APIRequest(dataTask: dataTask)
    }
    
}
