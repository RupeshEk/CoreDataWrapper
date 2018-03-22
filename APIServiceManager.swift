//
//  APIServiceManager.swift
//  GO
//
//  Created by Rupesh on 10/25/17.
//  Copyright © 2017 Ileaf Solutions. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Extension to append the datas together
extension NSMutableData
{
    func appendStrings(string: String)
    {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}


class APIServiceManager
{
    /// session manager
    private let manager = URLSession.shared
    
    /// singleton intializer
    static var sharedManager = APIServiceManager()
    
    
    
    
    //MARK: Get Method
    
    /// Get Method with Token
    
    ///   - servicename: sevicename is the endpoint that will attach with the baseurl to complete the API call
    ///   - token: is used to validate the user session
    ///   - completion: will return the internet connect status:bool,Data:Anyobject,error:nserror
    func getDataWithToken(serviceName : String,token:String,completion:@escaping(Bool?,NSDictionary?,Data?,NSError?)->Void)
    {
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: NSURL(string:serviceName)! as URL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            if error == nil
            {
                let result : AnyObject?
                do
                {
//                     let  responseString:String = String(data: data!, encoding: .utf8)!
//                    print(responseString)
                    result = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
                    completion(true, result as? NSDictionary, data, nil)
                }
                catch let catchError as NSError
                {
                    completion(true, nil,nil,catchError)
                }
            }
            else
            {
                completion(false, nil,nil, error as NSError?)
            }
        })
        task.resume()
        
    }
    
    func getDataWithNoToken(serviceName : String,completion:@escaping(Bool?,AnyObject?,NSError?)->Void)
    {
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: NSURL(string:serviceName)! as URL)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            if error == nil
            {
                let result : AnyObject?
                do
                {
                    result = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
                    completion(true, result, nil)
                }
                catch let catchError as NSError
                {
                    completion(true, nil, catchError)
                }
            }
            else
            {
                completion(false, nil, error as NSError?)
            }
        })
        task.resume()
        
    }
    
    
    //MARK: Post Method with x-www-form-urlencoded
    
    /// Post Method with no token
    ///
    /// - Parameters:
    ///   - servicename: sevicename is the endpoint that will attach with the baseurl to complete the API call
    ///   - parameters: which contains the dictionary of request variables to comple the API call
    ///   - completion: will return the internet connect status:bool,Data:Anyobject,error:nserror
    
    func postMethodformurlEncoded(serviceName : String,parameters : NSDictionary,completion:@escaping(Bool?,AnyObject?,NSError?)->Void)
    {
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: NSURL(string:serviceName)! as URL)
        request.httpMethod = "POST"
        var stngObj = String()
        for obj in parameters.enumerated()
        {
            if stngObj == ""
            {
                stngObj = "\(obj.element.key)=\(obj.element.value)"
            }
            else
            {
                stngObj = "\(stngObj)&\(obj.element.key)=\(obj.element.value)"
            }
        }
        request.httpBody = stngObj.data(using: String.Encoding.utf8, allowLossyConversion: false)
        
        
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            if error == nil
            {
                let result : AnyObject?
                do
                {
                    result = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
                    completion(true, result, nil)
                }
                catch let catchError as NSError
                {
                    completion(true, nil, catchError)
                }
            }
            else
            {
                completion(false, nil, error as NSError?)
            }
        })
        task.resume()
    }
    
    
    //MARK: Form Data Multipart
    
    
    func postWithToken(serviceName : String,parameters : NSDictionary?,token:String,completion:@escaping (Bool?,AnyObject?,NSError?)-> Void)
    {
        let boundary = generateBoundaryString()
        let contentType = "multipart/form-data; boundary=\(boundary)"
        let urlRequest = NSMutableURLRequest(url: NSURL(string:serviceName)! as URL)
        urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let body = NSMutableData()
        
        if parameters != nil
        {
            for (key, value) in parameters!
            {
                body.appendStrings(string: "\r\n--\(boundary)\r\n")
                body.appendStrings(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)")
                
            }
            body.appendStrings(string: "\r\n--\(boundary)--\r\n")
            
        }
        urlRequest.httpBody = body as Data
        
        urlRequest.httpMethod = "POST"
        let task = manager.dataTask(with: urlRequest as URLRequest) { (data, response, error) in
            if error == nil
            {
                let result : AnyObject?
                do
                {
                    result = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
                    completion(true, result, nil)
                }
                catch let catchError as NSError
                {
                    completion(true, nil, catchError)
                }
            }
            else
            {
                completion(false, nil, error as NSError?)
            }
        }
        task.resume()
    }
    
    /// Post Method with no token
    ///
    /// - Parameters:
    ///   - servicename: sevicename is the endpoint that will attach with the baseurl to complete the API call
    ///   - parameters: which contains the dictionary of request variables to comple the API call
    ///   - completion: will return the internet connect status:bool,Data:Anyobject,error:nserror
    
    func postWithNoTokenWithNoData(serviceName : String,parameters : NSDictionary?,completion:@escaping (Bool?,NSDictionary?,Data?,NSError?)-> Void)
    {
        let boundary = generateBoundaryString()
        let contentType = "multipart/form-data; boundary=\(boundary)"
        
        let urlRequest = NSMutableURLRequest(url: URL(string:serviceName)!)
        urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        let body = NSMutableData()
        
        if parameters != nil
        {
            for (key, value) in parameters!
            {
                body.appendStrings(string: "\r\n--\(boundary)\r\n")
                body.appendStrings(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)")
            }
            body.appendStrings(string: "\r\n--\(boundary)--\r\n")
            
        }
        urlRequest.httpBody = body as Data
        
        urlRequest.httpMethod = "POST"
        let task = manager.dataTask(with: urlRequest as URLRequest) { (data, response, error) in
            if error == nil
            {
                let result : AnyObject?
                do
                {
                    //let  responseString:String = String(data: data!, encoding: .utf8)!
                    result = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
                    completion(true, result as? NSDictionary,data, nil)
                }
                catch let catchError as NSError
                {
                    completion(true, nil,nil, catchError)
                }
            }
            else
            {
                completion(false, nil,nil, error as NSError?)
            }
        }
        task.resume()
    }
    
    
    /// Post Method with file upload
    ///
    /// - Parameters:
    ///   - servicename: sevicename is the endpoint that will attach with the baseurl to complete the API call
    ///   - parameters: which contains the dictionary of request variables to comple the API call
    ///   - dataKey: is the imagefile key to upload
    ///   - dataArray: is the array of datas to upload if any
    ///   - dataType: is to determine which data type "image" or "video"
    ///   - token: is used to validate the user session
    ///   - completion: will return the internet connect status:bool,Data:Anyobject,error:nserror
    
    func postWithTokenAndData(serviceName : String,parameters : NSDictionary?,dataKey : String?,dataArray : [Data]?,dataType : String?,token:String,completion:@escaping (Bool?,AnyObject?,NSError?)-> Void)
    {
        let bounday = generateBoundaryString()
        let urlRequest = NSMutableURLRequest(url: NSURL(string:serviceName)! as URL)
        urlRequest.setValue("multipart/form-data; boundary=\(bounday)", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = createBodyWithParametersandData(parameters: parameters, filePathKey: dataKey, DataArray: dataArray as [NSData]?, datType: dataType, boundary: bounday) as Data
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.httpMethod = "POST"
        let task = manager.dataTask(with: urlRequest as URLRequest) { (data, response, error) in
            if error == nil
            {
                let result : AnyObject?
                do
                {
                    result = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
                    completion(true, result, nil)
                }
                catch let catchError as NSError
                {
                    completion(true, nil, catchError)
                }
            }
            else
            {
                completion(false, nil, error as NSError?)
            }
        }
        task.resume()
    }
    
    
    /// To Generate a Boundary String for Multipart Formdata
    ///
    /// - Returns: Boundary string unique one for URLSession
    private func generateBoundaryString() -> String
    {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    /// Datatype Determines the file datatype to upload to server
    ///
    /// - Parameter dataType: "image" or "video" will give file name for respective datatypes
    /// - Returns: filename for respective datatype
    private func dataType(dataType : String) -> String
    {
        var fileName : String!
        switch dataType {
        case "image":
            fileName =  self.makeFileNameforimage()
        default:
            fileName = self.makeFileNameforvideo()
        }
        return fileName
    }
    
    /// File name for image
    ///
    /// - Returns: file name for image to upload
    private func makeFileNameforimage()->String
    {
        let dateFormatter : DateFormatter = DateFormatter()
        
        dateFormatter.dateFormat =  "yyMMddHHmmssSSS"
        
        let dateString : NSString = dateFormatter.string(from: Date()) as NSString
        
        let randomValue : Int = Int(arc4random_uniform(3))
        let returnString : String = String(format: "\(dateString)\(randomValue).jpg")
        
        return returnString
    }
    
    /// File name for video
    ///
    /// - Returns: file name for video to upload
    private func makeFileNameforvideo()->String
    {
        let dateFormatter : DateFormatter = DateFormatter()
        
        dateFormatter.dateFormat =  "yyMMddHHmmssSSS"
        
        let dateString : NSString = dateFormatter.string(from: Date()) as NSString
        
        let randomValue : Int = Int(arc4random_uniform(3))
        let returnString : String = String(format: "\(dateString)\(randomValue).mov")
        
        return returnString
    }
    
    /// Helps to create the body for Multipart Formdata
    ///
    /// - Parameters:
    ///   - parameters: which contains the dictionary of request variables to comple the API call
    ///   - filePathKey: is the imagefile key to upload
    ///   - DataArray: is the array of datas to upload if any
    ///   - datType: is to determine which data type "image" or "video"
    ///   - boundary: Boundary string unique one for URLSession
    /// - Returns: Data for the HTTPBody
    private func createBodyWithParametersandData(parameters: NSDictionary?, filePathKey: String?, DataArray: [NSData]?,datType: String?, boundary: String) -> NSData
    {
        let body = NSMutableData()
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendStrings(string: "\r\n--\(boundary)\r\n")
                body.appendStrings(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)")
                
            }
        }
        
        if DataArray != nil {
            
            for (_,Data) in (DataArray?.enumerated())!
            {
                
                body.appendStrings(string: "\r\n--\(boundary)\r\n")
                body.appendStrings(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(self.dataType(dataType: datType!))\"\r\n")
                body.appendStrings(string: "Content-Type: application/octet-stream\r\n\r\n")
                body.append(Data as Data)
                
                
            }
            
        }
        body.appendStrings(string: "\r\n--\(boundary)--\r\n")
        return body
    }
    
}
