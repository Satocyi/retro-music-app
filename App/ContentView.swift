// ContentView.swift
// MVP: SwiftUI 構成 Memory Tuner UI（旧 `WheelView` / 画像シェルは未削除で保持）

import SwiftUI

struct ContentView: View {
    var body: some View {
        // TODO: Gate 1 検証後は MemoryTunerView() に戻す
        PhotoMVPDebugView()
    }
}
