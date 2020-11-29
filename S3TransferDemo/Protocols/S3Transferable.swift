//
//  S3Transferable.swift
//  S3TransferDemo
//
//  Created by Nomad Company on 11/27/20.
//

import Foundation
import AWSS3
import Combine

//https://swiftsenpai.com/swift/define-protocol-with-published-property-wrapper/
public protocol S3Transferable: class {
    var id: UUID { get }
    var objectCloudKey: String { get }
    var progress: CurrentValueSubject<Double, Never> { get }
    var task: AWSS3TransferUtilityMultiPartUploadTask? { get set }
    var status: CurrentValueSubject<AWSS3TransferUtilityTransferStatusType, Never> { get }
    var taskStatusKVOSubscription: AnyCancellable? { get set}
    var taskStatusSubscription: AnyCancellable? { get set}
    func add(task: AWSS3TransferUtilityMultiPartUploadTask)
}

extension S3Transferable {
    public func add(task: AWSS3TransferUtilityMultiPartUploadTask) {
        self.task = task
        self.taskStatusKVOSubscription = task.publisher(for: \.status).sink(receiveValue: { [weak self] (newStatus) in
            self?.status.send(newStatus)
        })
        self.taskStatusSubscription = self.status.sink(receiveValue: { [weak self] (newStatus) in
            switch newStatus {
            case .cancelled, .error, .completed:
                self?.taskStatusKVOSubscription?.cancel()
                self?.taskStatusKVOSubscription = nil
                self?.taskStatusSubscription?.cancel()
                self?.taskStatusSubscription = nil
                self?.task = nil
            default:
                break
            }
        })
    }
}
