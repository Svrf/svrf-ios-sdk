//
//  SvrfAPIManager.swift
//  SvrfSDK
//
//  Created by Andrei Evstratenko on 28/05/2019.
//  Copyright © 2019 Svrf, Inc. All rights reserved.
//

import Foundation
import Alamofire

class SvrfAPIManager {

    static private let baseURL = "https://api.svrf.com/v1"
    static private var xAppToken: String?

    static func setToken(_ token: String) {
        xAppToken = token
    }

    static func authenticate(
        with apiKey: String,
        onSuccess success: @escaping (_ authenticationResponse: SvrfAuthenticationResponse) -> Void,
        onFailure failure: @escaping (_ error: Error?) -> Void) {

        let path = "/app/authenticate"
        let urlString = baseURL + path

        let header = ["content-type": "application/json"]
        let parameters = ["apiKey": apiKey]

        Alamofire.request(
            urlString,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: header).responseJSON { response in

                if let jsonData = response.data {
                    do {
                        let decoder = JSONDecoder()
                        let authenticationResponse = try decoder.decode(SvrfAuthenticationResponse.self, from: jsonData)

                        success(authenticationResponse)
                    } catch let error {
                        failure(error)
                    }
                }
        }
    }

    static func getMedia(by id: String,
                         onSuccess success: @escaping (_ mediaResponse: SvrfMediaResponse) -> Void,
                         onFailure failure: @escaping (_ error: Error?) -> Void) -> DataRequest? {

        let path = "/vr/\(id)"

        if let request = getRequest(with: path, parameters: nil) {
            return request.responseJSON { response in

                if let jsonData = response.data {

                    do {
                        let decoder = JSONDecoder()
                        let mediaResponse = try decoder.decode(SvrfMediaResponse.self, from: jsonData)

                        success(mediaResponse)
                    } catch let error {
                        failure(error)
                    }
                }
            }
        } else {
            failure(SvrfError(svrfDescription: SvrfErrorDescription.noToken.rawValue))
        }

        return nil
    }

    static func getTrending(options: SvrfOptions?,
                            onSuccess success: @escaping (_ trendingResponse: SvrfTrendingResponse) -> Void,
                            onFailure failure: @escaping (_ error: Error?) -> Void) -> DataRequest? {

        let path = "/vr/trending"
        let parameters: [String: Any?] = ["type": options?.type?.map { $0.rawValue }.joined(),
                                          "stereoscopicType": options?.stereoscopicType?.rawValue,
                                          "category": options?.category?.rawValue,
                                          "size": options?.size,
                                          "minimumWidth": options?.minimumWidth,
                                          "pageNum": options?.pageNum,
                                          "isFaceFilter": options?.isFaceFilter,
                                          "hasBlendShapes": options?.hasBlendShapes,
                                          "requiresBlendShapes": options?.requiresBlendShapes]

        if let request = getRequest(with: path, parameters: parameters) {
            return request.responseJSON { response in

                if let jsonData = response.data {

                    do {
                        let decoder = JSONDecoder()
                        let trendingResponse = try decoder.decode(SvrfTrendingResponse.self, from: jsonData)

                        success(trendingResponse)
                    } catch let error {
                        failure(error)
                    }
                }
            }
        } else {
            failure(SvrfError(svrfDescription: SvrfErrorDescription.noToken.rawValue))
        }

        return nil
    }

    static func search(query: String,
                       options: SvrfOptions?,
                       onSuccess success: @escaping (_ searchResponse: SvrfSearchResponse) -> Void,
                       onFailure failure: @escaping (_ error: Error?) -> Void) -> DataRequest? {

        let path = "/vr/search"
        let parameters: [String: Any?] = ["type": options?.type?.map { $0.rawValue }.joined(),
                                          "stereoscopicType": options?.stereoscopicType?.rawValue,
                                          "category": options?.category?.rawValue,
                                          "size": options?.size,
                                          "minimumWidth": options?.minimumWidth,
                                          "pageNum": options?.pageNum,
                                          "isFaceFilter": options?.isFaceFilter,
                                          "hasBlendShapes": options?.hasBlendShapes,
                                          "requiresBlendShapes": options?.requiresBlendShapes,
                                          "q": query]

        if let request = getRequest(with: path, parameters: parameters) {
            return request.responseJSON { response in

                if let jsonData = response.data {

                    do {
                        let decoder = JSONDecoder()
                        let searchResponse = try decoder.decode(SvrfSearchResponse.self, from: jsonData)

                        success(searchResponse)
                    } catch let error {
                        failure(error)
                    }
                }
            }
        } else {
            failure(SvrfError(svrfDescription: SvrfErrorDescription.noToken.rawValue))
        }

        return nil
    }

    // MARK: private functions
    static private func getRequest(with endPoint: String,
                                   parameters: [String: Any?]?) -> DataRequest? {

        guard let xAppToken = self.xAppToken else {
            return nil
        }

        let urlString = baseURL + endPoint
        let header = ["x-app-token": xAppToken,
                      "accept": "application/json"]
        var urlComponents = URLComponents(string: urlString)

        if let parameters = parameters {
            urlComponents?.queryItems = mapValuesToQueryItems(values: parameters)
        }

        guard let url = urlComponents else {
            return nil
        }

        return Alamofire.request(url,
                                 method: .get,
                                 parameters: nil,
                                 encoding: JSONEncoding.default,
                                 headers: header)
    }

    static private func mapValuesToQueryItems(values: [String: Any?]) -> [URLQueryItem]? {
        let returnValues = values
            .filter { $0.1 != nil }
            .map { (item: (_key: String, _value: Any?)) -> URLQueryItem in
                URLQueryItem(name: item._key, value: "\(item._value!)")
        }
        if returnValues.count == 0 {
            return nil
        }
        return returnValues
    }
}
