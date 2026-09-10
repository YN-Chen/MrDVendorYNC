//
//  PlaceSearchSheet.swift
//  MrDVendorYNC
//
//  Created by Yi-Nain Chen on 2026/09/09.
//

import SwiftUI

struct PlaceSearchSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = PlaceSearchViewModel()
    let onAdd: (PlaceResult) -> Void

    var body: some View {
        NavigationStack {
            List {
                if let errorMessage = viewModel.errorMessage {
                    ErrorStateView(message: errorMessage)
                } else if viewModel.isSearching {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else if viewModel.results.isEmpty && !viewModel.query.isEmpty {
                    ContentUnavailableFallback(text: "No places found for \u{201C}\(viewModel.query)\u{201D}")
                } else {
                    ForEach(viewModel.results) { place in
                        Button {
                            onAdd(place)
                            dismiss()
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(place.name)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text(place.address)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add a Vendor")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.query, prompt: "Search by name or address")
            .onChange(of: viewModel.query) { _ in
                viewModel.queryChanged()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

private struct ContentUnavailableFallback: View {
    let text: String
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "mappin.slash")
                .font(.title)
                .foregroundStyle(.secondary)
            Text(text)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .listRowSeparator(.hidden)
    }
}
