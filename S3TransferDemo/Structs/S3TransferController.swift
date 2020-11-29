//
//  S3TransferController.swift
//  S3TransferDemo
//
//  Created by Nomad Company on 11/27/20.
//

import Foundation
import Combine
import AWSS3


/// Controller that abstracts over the `AWSS3` SDK.
/// Some SWA S3 documentation
/// https://aws.amazon.com/blogs/mobile/amazon-s3-transfer-utility-for-ios/
public struct S3TransferController {
    
    //MARK: Public Properties
    
    
    //MARK: Private Properties
    let utilityKey: S3TransferUtilityKey
    
    
    //MARK: Embedded Objects
    internal struct S3TransferUtilityKey {
        let bucketName: String
        let uuid: UUID
        var key: String {
            return "\(self.bucketName)-\(self.uuid.uuidString)"
        }
        init(bucketName: String) {
            self.bucketName = bucketName
            self.uuid = UUID()
        }
    }
    
    public enum S3ControllerInitError: Error {
        case noServiceConfiguration
    }
    
    public enum S3TransferError: Error {
        case multipleErrors([Error])
        case couldNotRetrieveTransferUtility
        case failedToCompressImage
        case failedToCacheToDisk
    }
    
    //MARK: Init
    /// Initalize the `S3TransferController`
    /// - Parameters:
    ///   - s3Credentials: The `AWSCredentialsProvider` which contains the Access ID and Secret key to access the bucket
    ///   - bucketName: The name of the bucket that you will be reading and writing object to and from.
    public init(s3Credentials: AWSCredentialsProvider, bucketName: String) throws {
        //Init the utility key
        self.utilityKey = S3TransferUtilityKey(bucketName: bucketName)
        //Attempt to init the `AWSServiceConfiguration` which can return null. If it returns null then throw the `S3ControllerInitError`
        guard let serviceConfiguration = AWSServiceConfiguration(region: AWSRegionType.USWest2, credentialsProvider: s3Credentials) else {
            throw S3ControllerInitError.noServiceConfiguration
        }
        //Make a `AWSS3TransferUtilityConfiguration` option and set the bucket name. Keep all the other defaults
        let bucketConfiguration = AWSS3TransferUtilityConfiguration()
        bucketConfiguration.bucket = bucketName
        //Register the `AWSS3TransferUtility`. Later during upload and download we will need to retrieve the `AWSS3TransferUtility` by the `self.utilityKey.key`. This ensures that their is a unique utility per instance of this class.
        AWSS3TransferUtility.register(with: serviceConfiguration, transferUtilityConfiguration: bucketConfiguration, forKey: self.utilityKey.key)
    }
    
    //MARK: Functions
    
   //public func saveItemToDisk
    
    public func upload(uploadableObjects objects: [S3Uploadable]) -> AnyPublisher<[S3Uploadable], Error> {
        var futures: [Future<S3Uploadable, Error>] = []
        for object in objects {
            let future = self.upload(objectToUpload: object)
            futures.append(future)
        }
        return Publishers.MergeMany(futures).collect().eraseToAnyPublisher()
    }
    
    public func download<D: S3Downloadable>(downloadableObject objects: [D]) -> AnyPublisher<[D], Error> {
        var futures: [Future<D, Error>] = []
        for object in objects {
            let future = self.download(objectToDownload: object)
            futures.append(future)
        }
        return Publishers.MergeMany(futures).collect().eraseToAnyPublisher()
    }
    
    public func download<T: S3Downloadable>(objectToDownload object: T) -> Future<T, Error> {
        let future: Future<T, Error> = Future<T, Error> { promise in
            guard let transferUtility = AWSS3TransferUtility.s3TransferUtility(forKey: self.utilityKey.key) else {
                promise(.failure(S3TransferError.couldNotRetrieveTransferUtility))
                return
            }
            
            let expression = AWSS3TransferUtilityDownloadExpression()
            expression.progressBlock = { (_ task: AWSS3TransferUtilityTask, _ progress: Progress) in
                object.progress.value = progress.fractionCompleted
            }
            
            
            let completionHandle: AWSS3TransferUtilityDownloadCompletionHandlerBlock = { (task, p_url, p_data, p_error) -> Void in
                guard let error = p_error else {
                    object.downloadedData = p_data
                    promise(.success(object))
                    return
                }
                promise(.failure(error))
            }
            
            let key: String = object.objectCloudKey
            
            
            _ = transferUtility.downloadData(forKey: key, expression: expression, completionHandler: completionHandle).continueWith { (task) -> Any? in
                //object.task = task.result
                guard let error = task.error else {
                    return nil
                }
                promise(.failure(error))
                return nil
            } as? AWSTask<AWSS3TransferUtilityTask>
            
        }
        return future
    }
    
    public func upload(objectToUpload object: S3Uploadable) -> Future<S3Uploadable, Error> {
        let future: Future<S3Uploadable, Error> = Future<S3Uploadable, Error> { promise in
            
            guard let transferUtility = AWSS3TransferUtility.s3TransferUtility(forKey: self.utilityKey.key) else {
                promise(.failure(S3TransferError.couldNotRetrieveTransferUtility))
                return
            }

            let expression = AWSS3TransferUtilityMultiPartUploadExpression()
            expression.progressBlock = { (_ task: AWSS3TransferUtilityMultiPartUploadTask, _ progress: Progress) in
                object.progress.send(progress.fractionCompleted)
            }


            let completionHandle: AWSS3TransferUtilityMultiPartUploadCompletionHandlerBlock = { (task, p_error) -> Void in
                guard let error = p_error else {
                    promise(.success(object))
                    return
                }
                promise(.failure(error))
            }

            let key: String = object.objectCloudKey

            let contentType: String = object.contentType.rawValue

            switch object.uploadableObjectLocation {
            case .DATA_OBJECT(let data):
                _ = transferUtility.uploadUsingMultiPart(data: data, key: key, contentType: contentType, expression: expression, completionHandler: completionHandle).continueWith {  (task) -> Any? in
                    if let result = task.result {
                        object.add(task: result)
                    }
                    guard let error = task.error else {
                        return nil
                    }
                    promise(.failure(error))
                    return nil
                } as? AWSTask<AWSS3TransferUtilityTask>
            case .LOCAL_FILE(let url):
                _ = transferUtility.uploadUsingMultiPart(fileURL: url, key: key, contentType: contentType, expression: expression, completionHandler: completionHandle).continueWith(block: { (task) -> Any? in
                    if let result = task.result {
                        object.add(task: result)
                    }
                    guard let error = task.error else {
                        return nil
                    }
                    promise(.failure(error))
                    return nil
                })
            }
        }
        return future
    }
    
    
//    public func upload(objectToUpload object: S3Uploadable) -> Future<S3Uploadable, Error> {
//        let future: Future<S3Uploadable, Error> = Future<S3Uploadable, Error> { promise in
//            guard let transferUtility = AWSS3TransferUtility.s3TransferUtility(forKey: self.utilityKey.key) else {
//                promise(.failure(S3TransferError.couldNotRetrieveTransferUtility))
//                return
//            }
//
//            let expression = AWSS3TransferUtilityUploadExpression()
//            expression.progressBlock = { (_ task: AWSS3TransferUtilityTask, _ progress: Progress) in
//                object.progress.send(progress.fractionCompleted)
//            }
//
//
//            let completionHandle: AWSS3TransferUtilityUploadCompletionHandlerBlock = { (task, p_error) -> Void in
//                guard let error = p_error else {
//                    promise(.success(object))
//                    return
//                }
//                promise(.failure(error))
//            }
//
//            let key: String = object.objectCloudKey
//
//            let contentType: String = object.contentType.rawValue
//
//            switch object.uploadableObjectLocation {
//            case .DATA_OBJECT(let data):
//                _ = transferUtility.uploadData(data, key: key, contentType: contentType, expression: expression, completionHandler: completionHandle).continueWith { (task) -> Any? in
//                    if let result = task.result {
//                        object.add(task: result)
//                    }
//                    guard let error = task.error else {
//                        return nil
//                    }
//                    promise(.failure(error))
//                    return nil
//                } as? AWSTask<AWSS3TransferUtilityTask>
//            case .LOCAL_FILE(let url):
//                _ = transferUtility.uploadFile(url, key: key, contentType: contentType, expression: expression, completionHandler: completionHandle).continueWith(block: { (task) -> Any? in
//                    if let result = task.result {
//                        object.add(task: result)
//                    }
//                    guard let error = task.error else {
//                        return nil
//                    }
//                    promise(.failure(error))
//                    return nil
//                }) as? AWSTask<AWSS3TransferUtilityTask>
//            }
//        }
//        return future
//    }
    
}
