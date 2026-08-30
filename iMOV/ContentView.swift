import SwiftUI
import WebKit

struct ContentView: View {
    @StateObject private var tmdbService = TMDBService()
    @AppStorage("isDarkMode") private var isDarkMode: Bool = true
    
    // تحديد التبويب النشط في الشريط السفلي (0: الرئيسية، 1: أفلام، 2: مسلسلات، 3: المكتبة، 4: بحث)
    @State private var selectedTab = 0
    @State private var selectedMovie: Movie? = nil
    
    let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(uiColor: isDarkMode ? .black : .systemGroupedBackground)
                .ignoresSafeArea()
            
            // محتوى التبويبات بناءً على الاختيار السفلي
            Group {
                switch selectedTab {
                case 0:
                    HomeView(tmdbService: tmdbService, selectedMovie: $selectedMovie)
                case 1:
                    MoviesView(tmdbService: tmdbService, selectedMovie: $selectedMovie, columns: columns)
                case 2:
                    TVShowsView(tmdbService: tmdbService, selectedMovie: $selectedMovie, columns: columns)
                case 3:
                    LibraryView()
                case 4:
                    SearchView(tmdbService: tmdbService, selectedMovie: $selectedMovie, columns: columns)
                default:
                    HomeView(tmdbService: tmdbService, selectedMovie: $selectedMovie)
                }
            }
            .frame(maxHeight: .infinity)
            
            // شريط التنقل السفلي العائم (Floating Custom Tab Bar)
            CustomTabBar(selectedTab: $selectedTab)
                .padding(.bottom, 15)
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onAppear {
            if tmdbService.movies.isEmpty {
                tmdbService.fetchTrending()
            }
        }
        .fullScreenCover(item: $selectedMovie) { movie in
            MovieDetailView(movie: movie)
        }
    }
}

// MARK: - شريط التنقل السفلي العائم
struct CustomTabBar: View {
    @Binding var selectedTab: Int

    var body: some View {
        HStack(spacing: 20) {
            TabBarButton(icon: "magnifyingglass", title: "بحث", tag: 4, selectedTab: $selectedTab)
            TabBarButton(icon: "bookmark.fill", title: "المكتبة", tag: 3, selectedTab: $selectedTab)
            TabBarButton(icon: "tv.fill", title: "مسلسلات", tag: 2, selectedTab: $selectedTab)
            TabBarButton(icon: "film.fill", title: "أفلام", tag: 1, selectedTab: $selectedTab)
            TabBarButton(icon: "house.fill", title: "الرئيسية", tag: 0, selectedTab: $selectedTab)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.75))
        .background(.ultraThinMaterial)
        .cornerRadius(35)
        .padding(.horizontal, 24)
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let tag: Int
    @Binding var selectedTab: Int

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tag
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                Text(title)
                    .font(.system(size: 10, weight: .bold))
            }
            .foregroundColor(selectedTab == tag ? .yellow : .gray)
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - تبويب الرئيسية (Home)
struct HomeView: View {
    ObservedObject var tmdbService: TMDBService
    @Binding var selectedMovie: Movie?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // عنصر مميز في الأعلى (Banner)
                if let featured = tmdbService.movies.first {
                    ZStack(alignment: .bottomLeading) {
                        AsyncImage(url: featured.posterURL) { image in
                            image.resizable().aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle().fill(Color.gray.opacity(0.3))
                        }
                        .frame(height: 420)
                        .clipped()
                        
                        LinearGradient(colors: [.clear, .black], startPoint: .center, endPoint: .bottom)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(featured.displayTitle)
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 12) {
                                Button(action: { selectedMovie = featured }) {
                                    HStack {
                                        Image(systemName: "play.fill")
                                        Text("تشغيل")
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color.white)
                                    .foregroundColor(.black)
                                    .cornerRadius(8)
                                    .font(.subheadline.bold())
                                }
                                
                                Button(action: { selectedMovie = featured }) {
                                    HStack {
                                        Image(systemName: "info.circle")
                                        Text("المزيد")
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(Color.gray.opacity(0.5))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                    .font(.subheadline.bold())
                                }
                            }
                        }
                        .padding(16)
                    }
                }
                
                // قائمة أفقية للمحتوى الرائج
                VStack(alignment: .leading, spacing: 10) {
                    Text("المحتوى الرائج")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(tmdbService.movies) { movie in
                                MovieCardView(movie: movie)
                                    .frame(width: 130)
                                    .onTapGesture { selectedMovie = movie }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                
                Spacer().frame(height: 100) // مساحة إضافية لتجنب تداخل الشريط السفلي
            }
        }
        .ignoresSafeArea(edges: .top)
    }
}

// MARK: - تبويب الأفلام (Movies)
struct MoviesView: View {
    ObservedObject var tmdbService: TMDBService
    @Binding var selectedMovie: Movie?
    let columns: [GridItem]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("قائمة الأفلام")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.top, 50)
                
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(tmdbService.movies.filter { !$0.isTV }) { movie in
                        MovieCardView(movie: movie)
                            .onTapGesture { selectedMovie = movie }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 100)
            }
        }
    }
}

// MARK: - تبويب المسلسلات (TV Shows)
struct TVShowsView: View {
    ObservedObject var tmdbService: TMDBService
    @Binding var selectedMovie: Movie?
    let columns: [GridItem]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("قائمة المسلسلات")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.top, 50)
                
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(tmdbService.movies.filter { $0.isTV }) { movie in
                        MovieCardView(movie: movie)
                            .onTapGesture { selectedMovie = movie }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 100)
            }
        }
    }
}

// MARK: - تبويب المكتبة (Library)
struct LibraryView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "bookmark.fill")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("المكتبة فارغة")
                .font(.title3.bold())
                .foregroundColor(.white)
            Text("العناصر التي تحفظها ستظهر هنا.")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - تبويب البحث (Search) مع شريط بحث في الأسفل كما طلبت
struct SearchView: View {
    ObservedObject var tmdbService: TMDBService
    @Binding var selectedMovie: Movie?
    let columns: [GridItem]

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                Text("بحث")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.top, 60)
                
                if tmdbService.movies.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("ابحث عن فيلم أو مسلسل...")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(tmdbService.movies) { movie in
                                MovieCardView(movie: movie)
                                    .onTapGesture { selectedMovie = movie }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 120)
                    }
                }
            }
            
            // شريط البحث العائم تماماً فوق الشريط السفلي
            HStack(spacing: 10) {
                TextField("ابحث عن فيلم أو مسلسل...", text: $tmdbService.searchQuery)
                    .foregroundColor(.white)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: tmdbService.searchQuery) { newValue in
                        tmdbService.searchMovies(query: newValue)
                    }
                
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.85))
            .cornerRadius(25)
            .padding(.horizontal, 24)
            .padding(.bottom, 80) // فوق شريط التنقل السفلي مباشرة
        }
    }
}

// MARK: - بطاقة عرض العنصر (Movie Card)
struct MovieCardView: View {
    let movie: Movie

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: movie.posterURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fill)
                    default:
                        Rectangle().fill(Color.gray.opacity(0.3))
                    }
                }
                .frame(height: 200)
                .cornerRadius(12)
                .clipped()
                
                Text(movie.isTV ? "مسلسل" : "فيلم")
                    .font(.caption2.bold())
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.black.opacity(0.75))
                    .foregroundColor(.white)
                    .cornerRadius(4)
                    .padding(6)
            }
            
            Text(movie.displayTitle)
                .font(.system(size: 13, weight: .bold))
                .lineLimit(1)
                .foregroundColor(.primary)
        }
    }
}
