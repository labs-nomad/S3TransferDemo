//
//  S3UploadLocation.swift
//  S3TransferDemo
//
//  Created by Nomad Company on 11/27/20.
//

import Foundation

public enum S3UploadLocation {
    case LOCAL_FILE(URL)
    case DATA_OBJECT(Data)
}
