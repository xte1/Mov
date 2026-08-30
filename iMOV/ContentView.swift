struct DirectPlayerView: View {
    let movie: Movie
    @Environment(\.dismiss) private var dismiss
    @State private var streamURL: String = ""

    var body: some View {
        ZStack(alignment: .topTrailing) {
            WebView(urlString: $streamURL)
                .ignoresSafeArea()
            
            // أزرار التحكم العلوية
            HStack(spacing: 15) {
                // زر الفتح بالمتصفح الخارجي كحل بديل لو تعثر العرض المباشر
                if let url = URL(string: streamURL) {
                    Button(action: {
                        UIApplication.shared.open(url)
                    }) {
                        Image(systemName: "safari.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                }
                
                // زر الإغلاق
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                }
            }
            .padding(.top, 45)
            .padding(.trailing, 20)
        }
        .onAppear {
            streamURL = movie.streamURL
        }
    }
}
