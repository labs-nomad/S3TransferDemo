//
//  AWSS3TransferUtilityTransferStatusType_Extension.swift
//  S3TransferDemo
//
//  Created by Nomad Company on 11/28/20.
//

import AWSS3

extension AWSS3TransferUtilityTransferStatusType {
    func toString() -> String {
        switch self {
        case .cancelled:
            return "Cancelled"
        case .completed:
            return "Completed"
        case .error:
            return "Error"
        case .inProgress:
            return "In Progress"
        case .paused:
            return "Paused"
        case .unknown:
            return "Unknown"
        case .waiting:
            return "Waiting"
        @unknown default:
            return "Not Implemented"
        }
    }
}
