//
//  RemoteDataProvider.swift
//  
//
//  Created by Daru Bagus Dananjaya on 02/07/23.
//

import Foundation

internal protocol RemoteDataProvider: AnyObject {
    func fetchFingerprints(request: RemoteDataRequest, completion: @escaping (RemoteDateResponse) -> Void) -> Void
}

internal struct RemoteDataRequest {
    let requestHeader: [String:String]
}

struct RemoteDateResponse {
    let responseHeader: [String:String]
    let results: Result<Data, Error>
}
