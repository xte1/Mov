import SwiftUI

struct ContentView: View {
    @StateObject private var tmdbService = TMDBService()
    
    var body: some View {
        NavigationView {
            List(tmdbService.movies) { movie in
                NavigationLink(destination: MovieDetailView(movie: movie)) {
                    HStack(spacing: 12) {
                        if let posterPath = movie.posterPath,
                           let url = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)") {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Color.gray.opacity(0.3)
                            }
                            .frame(width: 60, height: 90)
                            .cornerRadius(8)
                        } else {
                            Color.gray.opacity(0.3)
                                .frame(width: 60, height: 90)
                                .cornerRadius(8)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(movie.title)
                                .font(.headline)
                                .lineLimit(2)
                            
                            Text(movie.overview)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(3)
                        }
                    }
                }
            }
            .navigationTitle("Movies")
            .onAppear {
                tmdbService.fetchMovies()
            }
        }
    }
}
