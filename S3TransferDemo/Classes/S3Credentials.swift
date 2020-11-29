//
//  S3Credentials.swift
//  S3TransferDemo
//
//  Created by Nomad Company on 11/27/20.
//

import Foundation

import AWSS3


class S3Credentials: NSObject, AWSCredentialsProvider {
    
    let accessKey = ""
    
    let secretKey = ""
    
    func credentials() -> AWSTask<AWSCredentials> {
        let credentials = AWSCredentials(accessKey: accessKey, secretKey: secretKey, sessionKey: nil, expiration: nil)
        return AWSTask(result: credentials)
    }

    func invalidateCachedTemporaryCredentials() {

    }
}
