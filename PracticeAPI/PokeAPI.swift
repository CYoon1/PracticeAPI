//
//  PokeAPI.swift
//  PracticeAPI
//
//  Created by Christopher Yoon on 3/22/23.
//

import Foundation
import SwiftUI

@MainActor
class PageOfPokemon: ObservableObject {
    struct Returned: Codable, Identifiable {
        var id = UUID()
        var count: Int
        var next: String?
        var results: [Pokemon]
        
        enum CodingKeys: CodingKey {
            case count
            case next
            case results
        }
    }
    
    @Published var urlString: String? = "https://pokeapi.co/api/v2/pokemon"
    
    @Published var count = 0
    @Published var next: String? = ""
    @Published var results: [Pokemon] = []
    @Published var displayPokemon: [Pokemon] = []
    
    func getData() async {
        print("getData()")
        guard let urlString else {
            print("No more data to call")
            return
        }
        guard let url = URL(string: urlString) else {
            print("Error in getData() converting URL string")
            return
        }
        guard let (data, _) = try? await URLSession.shared.data(from: url) else {
            print("Error in retrieving data from url")
            return
        }
        guard let returned = try?
                JSONDecoder().decode(Returned.self, from: data) else {
            print("Error: could not convert JSON to returned struct")
            return
        }
        count = returned.count
        next = returned.next
        results = results + returned.results
        
        self.urlString = next
        
        filter(with: "")
    }
    func getAll() async {
        while(next != nil) {
            await getData()
        }
        print("End getAll()")
        return
    }
    func filter(with searchText: String) {
        if searchText.isEmpty {
            displayPokemon = results
        } else {
            displayPokemon = results.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

struct PokemonView: View {
    @StateObject var vm = PageOfPokemon()
    @State private var searchText = ""
    var body: some View {
        NavigationStack {
            List {
                ForEach(vm.displayPokemon) { pokemon in
                    HStack {
                        NavigationLink {
                            PokemonDetailView(pokemon: pokemon)
                        } label: {
                            Text(pokemon.name)
                        }

                    }
                }
            }
            .searchable(text: $searchText)
            .disableAutocorrection(true)
            .refreshable {
                print("refresh")
                await vm.getAll()
            }
            .onChange(of: searchText, perform: { newValue in
                vm.filter(with: searchText)
            })
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await vm.getData()
                        }
                    } label: {
                        Text("Get Next")
                    }
                }
                ToolbarItem(placement: .status) {
                    Text("\(vm.results.count) / \(vm.count)")
                }
            }
            .task {
                if vm.results.isEmpty {
                    await vm.getAll()
                }
            }
        }
    }
}


struct PokeAPI_Previews: PreviewProvider {
    static var previews: some View {
        PokemonView()
    }
}


