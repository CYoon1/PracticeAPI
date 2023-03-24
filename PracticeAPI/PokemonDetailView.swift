//
//  PokemonDetailView.swift
//  PracticeAPI
//
//  Created by Christopher Yoon on 3/23/23.
//

import SwiftUI

struct PokemonDetailView: View {
    var pokemon: Pokemon
    @StateObject var vm = PokemonDetailVM()
    
    var body: some View {
        VStack {
            Text("\(pokemon.name)")
            AsyncImage(url: URL(string: vm.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 300)
            } placeholder: {
                ProgressView()
            }
        }
        .task {
            vm.urlString = pokemon.url
            await vm.getData()
        }
    }
}
struct PokemonDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonDetailView(pokemon: Pokemon(name: "bulbasaur", url:    "https://pokeapi.co/api/v2/pokemon/1/"))
    }
}

class PokemonDetailVM: ObservableObject {
    struct Returned: Codable, Identifiable {
        var id = UUID()
        var sprites: Sprites
        
        enum CodingKeys: CodingKey {
            case sprites
        }
    }
    struct Sprites: Codable {
        var front_default: String
    }
    
    @Published var urlString = ""
    
    @Published var imageURL = ""
    @MainActor
    func getData() async {
        guard let url = URL(string: urlString) else {
            print("Error")
            return
        }
        guard let (data, _) = try? await URLSession.shared.data(from: url) else {
            print("Error")
            return
        }
        guard let returned = try?
                JSONDecoder().decode(Returned.self, from: data) else {
            print("Error: could not convert JSON to returned struct")
            return
        }
        imageURL = returned.sprites.front_default
    }
}
