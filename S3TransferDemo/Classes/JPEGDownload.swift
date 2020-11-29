//
//  JPEGDownload.swift
//  S3TransferDemo
//
//  Created by Nomad Company on 11/28/20.
//

import Foundation
import AWSS3
import Combine

public class JPEGDownload: S3Downloadable {
    
    public var downloadedData: Data?
    
    public var id: UUID = UUID()
    
    public var objectCloudKey: String
    
    public var progress: CurrentValueSubject<Double, Never>
    
    public var task: AWSS3TransferUtilityMultiPartUploadTask?
    
    public var taskStatusKVOSubscription: AnyCancellable?
    
    public var taskStatusSubscription: AnyCancellable?
    
    public var status: CurrentValueSubject<AWSS3TransferUtilityTransferStatusType, Never>
    
    
    public init(key: String) {
        self.objectCloudKey = key
        self.progress = CurrentValueSubject<Double, Never>(0)
        self.status = CurrentValueSubject<AWSS3TransferUtilityTransferStatusType, Never>(.unknown)
    }
    
    
}
