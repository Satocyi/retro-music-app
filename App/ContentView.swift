// ContentView.swift
// WheelView を表示するだけのルートビュー。
// ナビゲーション・タブ・モーダル等は追加しない。

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WheelViewModel()

    var body: some View {
        WheelView(viewModel: viewModel)
    }
}
