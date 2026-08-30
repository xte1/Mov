import SwiftUI

struct ContentView: View {
    // قائمة تجريبية للأفلام لضمان عمل الواجهة بدون أخطاء
    @State private var movies: [Movie] = [
        Movie(title: "فيلم تجريبي 1", overview: "هذه تفاصيل وقصة الفيلم التجريبي الأول."),
        Movie(title: "فيلم تجريبي 2", overview: "هذه تفاصيل وقصة الفيلم التجريبي الثاني.")
    ]
    
    var body: some View {
        NavigationView {
            List(movies) { movie in
                // السطر 49 الذي يربط القائمة بصفحة التفاصيل
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
        }
    }
}

// نموذج بيانات الفيلم البسيط لضمان توافق الكود
struct Movie: Identifiable {
    let id = UUID()
    let title: String
    let overview: String
}
