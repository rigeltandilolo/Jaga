//
//  FormZonaView.swift
//  Jaga
//
//  Created by Rigel Sundun Tandilolo on 12/04/26.
//

import SwiftUI

struct FormZonaView: View {
    @Binding var namaZona: String
    @Binding var selectedZona: JenisZona
    @Binding var showZonaInfo: Bool
    @Binding var showPilihZona: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Nama Zona
            HStack {
                Text("Nama Zona")
                    .font(.body)
                Spacer()
                TextField("Zona Oma Apa", text: $namaZona)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(.secondary)
                    .submitLabel(.done)
                    .onSubmit {
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil, from: nil, for: nil
                        )
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.secondarySystemGroupedBackground))
            
            Divider()
                .padding(.leading, 16)
            
            // Pilih Jenis Zona
            HStack {
                HStack(spacing: 6) {
                    Text("Pilih Jenis Zona")
                        .font(.body)
                    Button {
                        showZonaInfo = true
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                    .sheet(isPresented: $showZonaInfo) {
                        ZonaInfoSheet(isPresented: $showZonaInfo)
                    }
                }
                Spacer()
                Button {
                    showPilihZona = true
                } label: {
                    HStack(spacing: 4) {
                        Text(selectedZona.label)
                            .foregroundColor(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .sheet(isPresented: $showPilihZona) {
                    PilihJenisZonaSheet(
                        isPresented: $showPilihZona,
                        selectedZona: $selectedZona
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.secondarySystemGroupedBackground))
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
}

#Preview {
    FormZonaView(
        namaZona: .constant(""),
        selectedZona: .constant(.ketat),
        showZonaInfo: .constant(false),
        showPilihZona: .constant(false)
    )
}
