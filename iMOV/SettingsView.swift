import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("isDarkMode") private var isDarkMode: Bool = true

    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("مظهر التطبيق والموقع")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Toggle(isOn: $isDarkMode) {
                            HStack {
                                Image(systemName: isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                                    .foregroundColor(isDarkMode ? .purple : .orange)
                                Text("الوضع الداكن (Dark Mode)")
                                    .font(.system(size: 16, weight: .medium))
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding(.top, 20)
            }
            .navigationTitle("الإعدادات")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("إغلاق") { dismiss() }
                }
            }
        }
    }
}
