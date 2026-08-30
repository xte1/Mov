import SwiftUI

struct ContentView: View {
    @StateObject private var tmdbService = TMDBService()
    @AppStorage("isDarkMode") private var isDarkMode: Bool = true
    
    @State private var showDeveloperPage = false
    @State private var showSettingsPage = false
    @State private var selectedMovie: Movie? = nil
    
    let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: isDarkMode ? .black : .systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // شريط البحث
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("بحث عن فيلم أو مسلسل...", text: $tmdbService.searchQuery)
                            .foregroundColor(.primary)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .onChange(of: tmdbService.searchQuery) { newValue in
                                tmdbService.searchMovies(query: newValue)
                            }
                        
                        if !tmdbService.searchQuery.isEmpty {
                            Button(action: {
                                tmdbService.searchQuery = ""
                                tmdbService.fetchTrending()
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(uiColor: isDarkMode ? .secondarySystemBackground : .white))
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                    
                    // محتوى العرض
                    if tmdbService.isLoading && tmdbService.movies.isEmpty {
                        Spacer()
                        ProgressView("جاري التحميل...")
                            .tint(.blue)
                        Spacer()
                    } else if tmdbService.movies.isEmpty {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "film")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("لا توجد نتائج للعرض")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 18) {
                                ForEach(tmdbService.movies) { movie in
                                    MovieCardView(movie: movie)
                                        .onTapGesture {
                                            selectedMovie = movie
                                        }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .navigationTitle("iMOV")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showDeveloperPage = true }) {
                            Label("معلومات المطور", systemImage: "person.circle")
                        }
                        Button(action: { showSettingsPage = true }) {
                            Label("الإعدادات", systemImage: "gearshape")
                        }
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onAppear {
            if tmdbService.movies.isEmpty {
                tmdbService.fetchTrending()
            }
        }
        .sheet(item: $selectedMovie) { movie in
            MoviePlayerSheet(movie: movie)
        }
        .sheet(isPresented: $showDeveloperPage) {
            DeveloperView()
        }
        .sheet(isPresented: $showSettingsPage) {
            SettingsView()
        }
    }
}

struct MovieCardView: View {
    let movie: Movie

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: movie.posterURL) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 240)
                .cornerRadius(12)
                .clipped()
                
                // شارة نوع المحتوى
                Text(movie.isTV ? "مسلسل" : "فيلم")
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.75))
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    .padding(8)
            }
            
            Text(movie.displayTitle)
                .font(.system(size: 14, weight: .bold))
                .lineLimit(1)
                .foregroundColor(.primary)
                .padding(.horizontal, 2)
            
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
                Text(String(format: "%.1f", movie.voteAverage ?? 0.0))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 2)
        }
    }
}

struct MoviePlayerSheet: View {
    let movie: Movie
    @Environment(\.dismiss) private var dismiss
    @State private var streamURL: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                WebView(urlString: $streamURL)
                    .ignoresSafeArea(edges: .bottom)
            }
            .navigationTitle(movie.displayTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("إغلاق") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                streamURL = movie.streamURL
            }
        }
    }
}
