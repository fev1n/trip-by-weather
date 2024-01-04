//
//  Service.swift
//  TripByWeather
//
//  Created by Fevin Patel on 2023-12-07.
//

import Foundation
import UIKit

class Service {
    
    static let shared = Service()
    private init() {}

    static let apiKey = "4f4630df97f956113585cc53d9e4f1a2"

    enum Endpoints {
        static let mainURL = "https://api.openweathermap.org/data/2.5/weather"
        static let apiKeyParam = "&appid=\(apiKey)"
        
        case getCity(String)
        case getCityWeather(String)
        
        var stringValue: String {
            switch self {
            case .getCity(let query):
                let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                return "http://gd.geobytes.com/AutoCompleteCity?callback=?&q=\(encodedQuery)"
            case .getCityWeather(let cityWeather):
                let encodedCityWeather = cityWeather.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                return Endpoints.mainURL + "?q=\(encodedCityWeather)&units=metric" + Endpoints.apiKeyParam
            }
        }
        
        var url: URL {
            guard let url = URL(string: stringValue) else {
                fatalError("Invalid URL: \(stringValue)")
            }
            return url
        }
    }
    
    class func fetchCities(from url: URL, completion: @escaping ([String]?, Error?) -> Void) -> URLSessionTask {
        let dataTask = URLSession.shared.dataTask(with: url) { (data, _, error) in
            DispatchQueue.main.async {
                guard let data = data else {
                    completion([], error)
                    return
                }
                
                if let stringData = String(data: data, encoding: .utf8) {
                    let trimmedData = stringData.dropFirst(2).dropLast(2)
                    
                    if let convertedData = trimmedData.data(using: .utf8) {
                        do {
                            let cities = try JSONSerialization.jsonObject(with: convertedData, options: []) as? [String]
                            completion(cities, nil)
                        } catch {
                            completion([], error)
                        }
                    }
                }
            }
        }
        dataTask.resume()
        return dataTask
    }
        
    
    static func fetchImage(urlstr: String, completion: @escaping (UIImage?) -> Void ) {
        guard let url = URL(string: urlstr) else {
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            let image = UIImage(data: data)
            DispatchQueue.main.async {
                completion(image)
            }
        }
        task.resume()
    }
    
    func getDataFromAPI(url: String, complition: @escaping (WeatherInfo)->Void) {
        guard let url = URL(string: url) else {  return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data{
                if let list = try? JSONDecoder().decode(WeatherInfo.self, from: data){
                    complition(list)
                }
            }
            }.resume()
    }
}




