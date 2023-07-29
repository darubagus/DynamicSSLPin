//
//  SharedInstance.swift
//  DynamicSSLPin
//
//  Created by Daru Bagus Dananjaya on 28/07/23.
//

import Foundation

extension CertStore {
    static var sharedInstance: CertStore {
        let config = CertStoreConfig(
            serviceURL: URL(string: "https://..."),
            pubKey: "MFkwE...BC9w=="
        )
        return integrateCertStore(configuration: config)
    }
}
