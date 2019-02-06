//
//  JSONParsing.swift
//  DVT_WeatherApp
//
//  Created by Gontse Ranoto on 2019/02/02.
//  Copyright © 2019 Gontse Ranoto. All rights reserved.
//

import Foundation

//JSON a failable so throw
protocol JSONDecodable {
    init(_ decoder: JSONDecoder) throws
}

enum JSONParsingError: Error
{
    case missingKey(key: String)
    case typeMismatch(key: String)
}

typealias JSONObject = [String: Any]

class JSONDecoder{
    
    let jsonObject : JSONObject
    init(_ jsonObject: [String: Any]) {
        self.jsonObject = jsonObject
    }
    
    func value<T>(forKey key: String) throws -> T
    {
        guard let value = jsonObject[key] else
        {
            throw JSONParsingError.missingKey(key: key)
        }
        guard let finalValue = value as? T else {
            throw JSONParsingError.typeMismatch(key: key)
        }
        return finalValue
    }
    
    //Should always be json Decodable
    func parse<T>(_ data: Data) throws -> [T]  where T: JSONDecodable
    {
        let jsonObjects: [JSONObject] = try deserialize(data)
        //decode each
        return try jsonObjects.map(decode)
    }
    
    func deserialize(_ data: Data) throws -> [JSONObject]
    {
        let json =  try JSONSerialization.jsonObject(with: data, options: [])
        guard let objects =  json as? [JSONObject] else{ return [] }
        return objects
    }
    
    func decode<T>(_ jsonObject: JSONObject) throws -> T where T: JSONDecodable
    {
        return try T.init(JSONDecoder(jsonObject))
    }
}
