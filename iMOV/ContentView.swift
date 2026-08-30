import SwiftUI

struct ContentView: View {
    @StateObject var tmdbService = TMDBService()
    
    var body: some View {
        NavigationView {
            List(tmdbService.movies) { movie in
                NavigationLink(destination: MovieDetailView(movie: movie)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(movie.title ?? "بدون عنوان")
                            .font(.headline)
                        Text(movie.overview ?? "لا توجد تفاصيل")
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
