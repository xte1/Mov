import SwiftUI

struct ContentView: View {
    @ObservedObject var tmdbService = TMDBService()
    
    var body: some View {
        NavigationView {
            List(tmdbService.movies) { movie in
                NavigationLink(destination: MovieDetailView(movie: movie)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(movie.title)
                            .font(.headline)
                        Text(movie.overview)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            .navigationTitle("مكتبة الأفلام iMOV")
            .onAppear {
                tmdbService.fetchMovies()
            }
        }
    }
}
