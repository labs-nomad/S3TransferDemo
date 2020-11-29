//
//  ProgressBar.swift
//  S3TransferDemo
//
//  Created by Nomad Company on 11/28/20.
//

import SwiftUI

//https://www.simpleswiftguide.com/how-to-build-a-circular-progress-bar-in-swiftui/
struct ProgressBar: View {
    @Binding var progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 10.0)
                .opacity(0.3)
                .foregroundColor(Color.green)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 10.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.green)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear)
            Text(String(format: "%.0f%%", min(self.progress, 1.0)*100.0))
                .font(.footnote)
                .bold()
        }
    }
}
