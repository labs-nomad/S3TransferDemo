//
//  TransferableObjectCellView.swift
//  S3TransferDemo
//
//  Created by Nomad Company on 11/28/20.
//

import SwiftUI
import AWSS3

public struct TransferableObjectCellView: View {
    //MARK: State and binding properties
    
    @ObservedObject var viewModel: TransferableObjectCellViewModel
    
    //MARK: Computed Properties
    
    //MARK: View conformance
    public var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(self.viewModel.object.id.uuidString).font(.footnote)
                Text(self.viewModel.object.objectCloudKey).font(.footnote)
                Text(self.viewModel.state.toString())
//                if self.status == AWSS3TransferUtilityTransferStatusType.error {
//                    Text(self.transferableObject.task?.response.localizedDescription ?? "Error").foregroundColor(Color.red)
//                }
            }
            Spacer()
            switch self.viewModel.state {
            case AWSS3TransferUtilityTransferStatusType.cancelled, AWSS3TransferUtilityTransferStatusType.error:
                Image(systemName: "xmark.octagon.fill").resizable().frame(width: 55, height: 55).foregroundColor(Color.red)
            case AWSS3TransferUtilityTransferStatusType.completed:
                Image(systemName: "checkmark.circle.fill").resizable().frame(width: 55, height: 55).foregroundColor(Color.green)
            case AWSS3TransferUtilityTransferStatusType.inProgress, AWSS3TransferUtilityTransferStatusType.paused, AWSS3TransferUtilityTransferStatusType.waiting:
                ProgressBar(progress: self.$viewModel.progress).frame(width: 55, height: 55)
            case AWSS3TransferUtilityTransferStatusType.unknown:
                Image(systemName: "questionmark.circle.fill").resizable().frame(width: 55, height: 55).foregroundColor(Color.gray)
            @unknown default:
                Image(systemName: "xmark.octagon.fill").resizable().frame(width: 55, height: 55).foregroundColor(Color.red)
            }
        }.padding()
    }
    
    //MARK: Init
    
    //MARK: Functions
}

struct TransferableObjectCellView_Previews: PreviewProvider {
    static var previews: some View {
        let jpegUpload = JPEGUpload(location: S3UploadLocation.LOCAL_FILE(URL(fileURLWithPath: "")), key: "")
        let model = TransferableObjectCellViewModel(transferableObject: jpegUpload)
        let view = TransferableObjectCellView(viewModel: model)
        return view
    }
}
