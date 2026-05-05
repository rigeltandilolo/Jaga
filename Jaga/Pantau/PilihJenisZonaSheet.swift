//
//  PilihJenisZonaSheet.swift
//  Jaga
//
//  Created by Rigel Sundun Tandilolo on 11/04/26.
//

import SwiftUI

struct PilihJenisZonaSheet: View {
    @Binding var isPresented: Bool
    @Binding var selectedZona: JenisZona
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(JenisZona.allCases, id: \.self) { zona in
                    Button {
                        selectedZona = zona
                        isPresented = false
                    } label: {
                        HStack(spacing: 14) {
                            Circle()
                                .fill(Color(hex: zona.warnaDot))
                                .frame(width: zona.ukuranDot,
                                       height: zona.ukuranDot)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Zona \(zona.rawValue)")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                Text("Radius ~\(Int(zona.radius)) meter")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if selectedZona == zona {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Color(hex: "#185FA5"))
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Pilih Jenis Zona")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Selesai") {
                        isPresented = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.height(280)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(50)
    }
}
