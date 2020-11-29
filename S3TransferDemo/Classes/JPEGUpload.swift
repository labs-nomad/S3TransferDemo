//
//  JPEGUpload.swift
//  S3TransferDemo
//
//  Created by Nomad Company on 11/28/20.
//

import Foundation
import AWSS3
import Combine

public class JPEGUpload: S3Uploadable {
    
    
    public var id: UUID = UUID()
    
    public var uploadableObjectLocation: S3UploadLocation
    
    public var contentType: S3ContentType
    
    public var objectCloudKey: String
    
    public var progress: CurrentValueSubject<Double, Never>
    
    public var task: AWSS3TransferUtilityTask?
    
    public var taskStatusKVOSubscription: AnyCancellable?
    
    public var taskStatusSubscription: AnyCancellable?
    
    public var status: CurrentValueSubject<AWSS3TransferUtilityTransferStatusType, Never>
    
    public init(location: S3UploadLocation, key: String) {
        self.uploadableObjectLocation = location
        self.contentType = S3ContentType.JPEG
        self.objectCloudKey = key
        self.progress = CurrentValueSubject<Double, Never>(0)
        self.status = CurrentValueSubject<AWSS3TransferUtilityTransferStatusType, Never>(.unknown)
    }
    
    public func removeFromDisk() {
        let fileManager: FileManager = FileManager.default
        guard case S3UploadLocation.LOCAL_FILE(let fileURL) = self.uploadableObjectLocation else {
            return
        }
        try? fileManager.removeItem(at: fileURL)
    }
}
