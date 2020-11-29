//
//  S3Downloadable.swift
//  S3TransferDemo
//
//  Created by Nomad Company on 11/27/20.
//

import Foundation

public protocol S3Downloadable: S3Transferable {
    var downloadedData: Data? { get set }
    
}
