//
//  TransferListView.swift
//  S3TransferDemo
//
//  Created by Nomad Company on 11/28/20.
//

import SwiftUI


public struct TransferListView: View {
    //MARK: State and binding properties
    @ObservedObject var viewModel: TransferListViewModel = TransferListViewModel()
    
    //MARK: Computed Properties
    
    //MARK: View conformance
    public var body: some View {
        ZStack {
            VStack {
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(self.viewModel.transferedObjects, id: \.id) { object in
                            let viewModel = TransferableObjectCellViewModel(transferableObject: object)
                            TransferableObjectCellView(viewModel: viewModel)
                        }
                    }
                }
                Button(action: { self.viewModel.uploadRandomJPEGS() }) {
                    Text("Upload Random JPEG's").foregroundColor(Color.white).font(.headline).frame(maxWidth: .infinity).frame(height: 55).background(Color.green).cornerRadius(4).shadow(radius: 5).padding()
                }
            }
        }
    }
    
    //MARK: Init
    
    //MARK: Functions
}

struct TransferListView_Previews: PreviewProvider {
    static var previews: some View {
        let view = TransferListView()
        return view
    }
}
