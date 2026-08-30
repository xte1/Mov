import SwiftUI

struct DeveloperView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                VStack(spacing: 25) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 90, height: 90)
                        .foregroundColor(.accentColor)
                        .padding(.top, 20)

                    VStack(spacing: 6) {
                        Text("تطبيق i MOV")
                            .font(.title2.bold())
                        Text("الإصدار 1.0.0")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    VStack(spacing: 12) {
                        Link(destination: URL(string: "https://github.com")!) {
                            HStack {
                                Image(systemName: "link")
                                Text("حساب المطور على GitHub")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .foregroundColor(.primary)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                        }
                        
                        Link(destination: URL(string: "https://t.me")!) {
                            HStack {
                                Image(systemName: "paperplane.fill")
                                Text("قناة التليجرام / الدعم")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .foregroundColor(.primary)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                }
            }
            .navigationTitle("عن المطور")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("إغلاق") { dismiss() }
                }
            }
        }
    }
}
