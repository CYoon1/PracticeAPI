//
//  ApiListView.swift
//  PracticeAPI
//
//  Created by Christopher Yoon on 3/22/23.
//

import SwiftUI

struct ApiListView: View {
    @StateObject var vm = MainVM()
    
    var body: some View {
        List {
            ForEach(vm.articles) { article in
                VStack {
                    Text(article.title)
                }
            }
        }
        .task {
            await vm.getData()
        }
    }
}

struct ApiListView_Previews: PreviewProvider {
    static var previews: some View {
        ApiListView()
    }
}
