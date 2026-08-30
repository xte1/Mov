import SwiftUI

struct MovieDetailView: View {
    let movie: Movie
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(movie.title ?? "بدون عنوان")
                    .font(.largeTitle)
                    .bold()
                Text(movie.overview ?? "لا توجد تفاصيل متاحة لهذا الفيلم.")
                    .font(.body)
                Spacer()
            }
            .padding()
        }
        .navigationTitle("تفاصيل الفيلم")
    }
}
