import Foundation

struct Movie: Identifiable, Codable {
    let id: Int
    let title: String?
    let name: String?
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double?
    let mediaType: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, name, overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
        case mediaType = "media_type"
    }
    
    var displayTitle: String {
        title ?? name ?? "بدون عنوان"
    }
    
    var posterURL: URL? {
        guard let path = posterPath, !path.isEmpty else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }
    
    var isTV: Bool {
        mediaType == "tv" || (title == nil && name != nil)
    }
    
    // رابط السيرفر المحدث لدعم الجودة العالية والترجمة العربية التلقائية
    var streamURL: String {
        if isTV {
            return "https://vidsrc.me/embed/tv?tmdb=\(id)&season=1&episode=1&ds_lang=ar"
        } else {
            return "https://vidsrc.me/embed/movie?tmdb=\(id)&ds_lang=ar"
        }
    }
}

struct TMDBResponse: Codable {
    let results: [Movie]
}

class TMDBService: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var isLoading = false
    @Published var searchQuery = ""
    
    private let apiKey = "12bae60f08973cb30c741d0844769d9d"
    private let baseURL = "https://api.themoviedb.org/3"
    private var searchWorkItem: DispatchWorkItem?
    
    func fetchTrending() {
        guard let url = URL(string: "\(baseURL)/trending/all/day?api_key=\(apiKey)&language=ar-SA") else { return }
        performRequest(with: url)
    }
    
    func searchMovies(query: String) {
        searchWorkItem?.cancel()
        
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            fetchTrending()
            return
        }
        
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            let encodedQuery = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            guard let url = URL(string: "\(self.baseURL)/search/multi?api_key=\(self.apiKey)&query=\(encodedQuery)&language=ar-SA") else { return }
            self.performRequest(with: url)
        }
        
        searchWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: workItem)
    }
    
    private func performRequest(with url: URL) {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            guard let data = data, error == nil else { return }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(TMDBResponse.self, from: data)
                DispatchQueue.main.async {
                    self.movies = response.results.filter { $0.posterPath != nil }
                }
            } catch {
                print("Error decoding TMDB data: \(error)")
            }
        }.resume()
    }
}
