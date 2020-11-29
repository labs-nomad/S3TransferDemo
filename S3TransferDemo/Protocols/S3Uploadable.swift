//
//  S3Uploadable.swift
//  S3TransferDemo
//
//  Created by Nomad Company on 11/27/20.
//

import Foundation

public protocol S3Uploadable: S3Transferable {
    var uploadableObjectLocation: S3UploadLocation { get }
    var contentType: S3ContentType { get }
    func removeFromDisk()
}
