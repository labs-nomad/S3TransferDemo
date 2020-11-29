//
//  TransferListViewModel.swift
//  S3TransferDemo
//
//  Created by Nomad Company on 11/28/20.
//

import SwiftUI
import Combine
import UIKit

class TransferListViewModel: ObservableObject {
    
    @Published var transferedObjects: [S3Transferable] = []
    
    let controller: S3TransferController
    
    var uploadSubscriptions: [UUID: AnyCancellable] = [:]
    
    enum TransferEvent {
        case UPLOAD
    }
    
    var transferEvents: PassthroughSubject<TransferEvent, Never> = PassthroughSubject<TransferEvent, Never>()
    
    var eventSubscription: AnyCancellable?
    
    let formatter = DateFormatter()
    
    init() {
        self.formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"
        self.formatter.timeZone = TimeZone(identifier: "UTC")
        self.controller = try! S3TransferController(s3Credentials: S3Credentials(), bucketName: "device-metadata-edge-development")
        self.eventSubscription = self.transferEvents.receive(on: DispatchQueue.global(qos: .background)).flatMap { [weak self] (event) -> AnyPublisher<S3Transferable, Never> in
            guard let self = self else {
                fatalError("No Strong Self")
            }
            let width: CGFloat = 150
            let height: CGFloat = 150
            let randomImage: UIImage = SabilandTB(width: width, height: height).SabilandTrippyBackground
            let data = randomImage.jpegData(compressionQuality: 1)!
            let date = self.formatter.string(from: Date())
            let key: String = "photos/testUploads/\(date).jpeg"
            let jpegUpload = JPEGUpload(location: S3UploadLocation.DATA_OBJECT(data), key: key)
            return Just(jpegUpload).eraseToAnyPublisher()
            
        }.receive(on: RunLoop.main).flatMap({ [weak self] (object) -> AnyPublisher<S3Transferable?, Never> in
            self?.transferedObjects.append(object)
            return Just(object).eraseToAnyPublisher()
        }).flatMap({ [weak self] (object) -> AnyPublisher<S3Transferable?, Never> in
            let publisher = self?.controller.upload(objectToUpload: object as! S3Uploadable).map{ (uploadable) -> S3Transferable in
                return uploadable
            }.catch({ (error) -> AnyPublisher<S3Transferable?, Never> in
                return Just(nil).eraseToAnyPublisher()
            }).eraseToAnyPublisher()
            return publisher ?? Just(nil).eraseToAnyPublisher()
        }).delay(for: 5, scheduler: RunLoop.main).sink { [weak self] (p_object) in
            guard let object = p_object else {
                return
            }
            guard let index = self?.transferedObjects.firstIndex(where: { (o) -> Bool in
                return o.id == object.id
            }) else {
                return
            }
            self?.transferedObjects.remove(at: index)
        }
        
        
    }
    
    //MARK: Functions
    func uploadRandomJPEGS() {
        let numberOfObjects = 5
        for _ in 0..<numberOfObjects {
            self.transferEvents.send(TransferEvent.UPLOAD)
        }
    }
    
    deinit {
        self.eventSubscription?.cancel()
        self.eventSubscription = nil
    }
    
}
