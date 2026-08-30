import SwiftUI

struct MovieDetailView: View {
    let movie: Movie // افترض أن لديك نموذج (Model) يسمى Movie، أو استبدله بالنوع المستخدم لديك
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // عرض تفاصيل الفيلم
                Text(movie.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(movie.overview)
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("تفاصيل الفيلم")
        .navigationBarTitleDisplayMode(.inline)
    }
}
