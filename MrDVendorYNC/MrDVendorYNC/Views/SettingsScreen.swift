//
//  SettingsScreen.swift
//  MrDVendorYNC
//
//  Created by Yi-Nain Chen on 2026/09/09.
//

import SwiftUI

struct SettingsScreen: View {
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if let token = viewModel.storedToken {
                        LabeledContent("Current token") {
                            Text(maskedToken(token))
                                .foregroundStyle(.secondary)
                        }
                        Button("Clear Token", role: .destructive) {
                            viewModel.clear()
                        }
                    } else {
                        Text("No session token stored.")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Session Token")
                } footer: {
                    Text("Stored securely in the iOS Keychain and attached as a Bearer token on outgoing requests.")
                }

                Section {
                    SecureField("Paste session token", text: $viewModel.tokenInput)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    Button("Save Token") {
                        viewModel.save()
                    }
                    .disabled(viewModel.tokenInput.trimmingCharacters(in: .whitespaces).isEmpty)
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    Toggle("Simulate vendor load failure", isOn: Binding(
                        get: { viewModel.simulateVendorFetchFailure },
                        set: { viewModel.toggleSimulateFailure($0) }
                    ))
                } header: {
                    Text("Demo")
                } footer: {
                    Text("Forces the next vendor reload to fail, to preview the error state without a real backend.")
                }
            }
            .navigationTitle("Settings")
        }
    }

    private func maskedToken(_ token: String) -> String {
        guard token.count > 4 else { return "••••" }
        let suffix = token.suffix(4)
        return "••••••••\(suffix)"
    }
}

#Preview {
    SettingsScreen()
}
