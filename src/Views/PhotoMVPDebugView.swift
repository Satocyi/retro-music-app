import PhotosUI
import SwiftUI

/// Gate 1: PhotosPicker → UIImage ロード → 表示のみ（フィルター・ホイール未接続）
struct PhotoMVPDebugView: View {
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var loadedImage: UIImage?
    @State private var statusMessage = "写真を選んでください"

    var body: some View {
        VStack(spacing: 20) {
            Text("Photo MVP Debug — Gate 1")
                .font(.headline)

            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                Label("写真を選ぶ", systemImage: "photo.on.rectangle.angled")
            }
            .buttonStyle(.borderedProminent)

            Group {
                if let loadedImage {
                    Image(uiImage: loadedImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                } else {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.secondary.opacity(0.12))
                        .overlay {
                            VStack(spacing: 8) {
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundStyle(.secondary)
                                Text("プレビューなし")
                                    .foregroundStyle(.secondary)
                            }
                        }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 240, maxHeight: 420)

            Text(statusMessage)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .onChange(of: selectedPhotoItem) { newItem in
            Task { await loadSelectedPhoto(from: newItem) }
        }
    }

    private func loadSelectedPhoto(from item: PhotosPickerItem?) async {
        guard let item else {
            await MainActor.run {
                loadedImage = nil
                statusMessage = "写真を選んでください"
            }
            return
        }

        await MainActor.run { statusMessage = "読み込み中…" }

        guard let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else {
            await MainActor.run {
                loadedImage = nil
                statusMessage = "読み込みに失敗しました"
            }
            return
        }

        await MainActor.run {
            loadedImage = image
            let w = Int(image.size.width)
            let h = Int(image.size.height)
            statusMessage = "読み込み完了（\(w)×\(h) pt）"
        }
    }
}

#if DEBUG
#Preview {
    PhotoMVPDebugView()
}
#endif
