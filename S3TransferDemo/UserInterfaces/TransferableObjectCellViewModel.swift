//
//  TransferableObjectCellViewModel.swift
//  S3TransferDemo
//
//  Created by Nomad Company on 11/28/20.
//

import SwiftUI
import Combine
import AWSS3

class TransferableObjectCellViewModel: ObservableObject {
    
    let object: S3Transferable
    
    @Published var state: AWSS3TransferUtilityTransferStatusType
    
    @Published var progress: Double
    
    var subscriptions: Set<AnyCancellable> = []
    
    init(transferableObject object: S3Transferable) {
        self.object = object
        self.state = object.status.value
        self.progress = object.progress.value
        object.status.receive(on: RunLoop.main).assign(to: &self.$state)
        object.progress.receive(on: RunLoop.main).assign(to: &self.$progress)
    }
    
    
    deinit {
        for subscription in self.subscriptions {
            subscription.cancel()
        }
        self.subscriptions.removeAll()
    }
}
