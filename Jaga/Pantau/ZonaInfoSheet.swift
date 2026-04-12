//
//  ZonaInfoSheet.swift
//  Jaga
//
//  Created by Rigel Sundun Tandilolo on 11/04/26.
//

import SwiftUI

struct ZonaInfoSheet: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ForEach(JenisZona.allCases, id: \.self) { zona in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 10) {
                                Circle()
                                    .fill(Color(hex: zona.warnaDot))
                                    .frame(width: zona.ukuranDot,
                                           height: zona.ukuranDot)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Zona \(zona.rawValue)")
                                        .font(.headline)
                                    Text("Radius ~\(Int(zona.radius)) meter")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Text(zona.deskripsi)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        if zona != JenisZona.allCases.last {
                            Divider()
                        }
                    }
                    
                    Divider()
                    
                    // Catatan Akurasi
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.secondary)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Catatan Akurasi")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Simbol (~) menunjukkan bahwa radius bersifat perkiraan. Akurasi pemantauan bergantung pada kondisi sinyal GPS.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Jenis Zona")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(50)
    }
}

#Preview {
    ZonaInfoSheet(isPresented: .constant(true))
}
