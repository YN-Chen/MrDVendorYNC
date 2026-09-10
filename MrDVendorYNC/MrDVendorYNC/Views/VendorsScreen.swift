//
//  VendorsScreen.swift
//  MrDVendorYNC
//
//  Created by Yi-Nain Chen on 2026/09/09.
//

import SwiftUI

struct VendorsScreen: View {
    @StateObject private var viewModel = VendorListViewModel()
    @State private var isShowingPlaceSearch = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                GoogleMapView(vendors: viewModel.vendors, selectedVendorID: $viewModel.selectedVendorID)
                    .frame(height: 260)

                Divider()

                if viewModel.isLoading && viewModel.vendors.isEmpty {
                    VStack {
                        Spacer()
                        ProgressView("Loading vendors\u{2026}")
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else if let errorMessage = viewModel.errorMessage, viewModel.vendors.isEmpty {
                    VStack {
                        Spacer()
                        ErrorStateView(message: errorMessage, retryTitle: "Try Again") {
                            Task { await viewModel.load() }
                        }
                        Spacer()
                    }
                } else {
                    List(viewModel.vendors) { vendor in
                        VendorRowView(vendor: vendor,
                                      isSelected: vendor.id == viewModel.selectedVendorID,
                                      onToggleFavorite: { viewModel.toggleFavorite(vendor) })
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.select(vendor)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Nearby Vendors")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingPlaceSearch = true
                    } label: {
                        Image(systemName: "plus.magnifyingglass")
                    }
                    .accessibilityLabel("Add vendor from place search")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task { await viewModel.load() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                    .accessibilityLabel("Reload vendors")
                }
            }
            .sheet(isPresented: $isShowingPlaceSearch) {
                PlaceSearchSheet { place in
                    viewModel.addVendor(from: place)
                }
            }
            .task {
                await viewModel.loadIfNeeded()
            }
            .alert("Couldn't Reload",
                   isPresented: Binding(get: { viewModel.errorMessage != nil && !viewModel.vendors.isEmpty },
                                        set: { isPresented in if !isPresented { viewModel.errorMessage = nil } }),
                   presenting: viewModel.errorMessage) { _ in
                Button("OK") { viewModel.errorMessage = nil }
            } message: { message in
                Text(message)
            }
        }
    }
}

private struct VendorRowView: View {
    let vendor: Vendor
    let isSelected: Bool
    let onToggleFavorite: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(vendor.name)
                    .font(.headline)
                Text(vendor.address)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if vendor.coordinate == nil {
                    Text("No coordinates yet")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
            Spacer()
            Button(action: onToggleFavorite) {
                Image(systemName: vendor.isFavorite ? "star.fill" : "star")
                    .foregroundStyle(vendor.isFavorite ? .yellow : .secondary)
                    .imageScale(.large)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
        .listRowBackground(isSelected ? Color.accentColor.opacity(0.12) : Color.clear)
    }
}

#Preview {
    VendorsScreen()
}
