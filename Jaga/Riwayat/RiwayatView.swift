//
//  RiwayatView.swift
//  Jaga
//
//  Created by Rigel Sundun Tandilolo on 12/04/26.
//

import SwiftUI
import SwiftData
 
struct RiwayatView: View {
    @Query(sort: \RiwayatSesi.waktuMulai, order: .reverse)
    private var semuaSesi: [RiwayatSesi]
 
    @State private var sesiDipilih: RiwayatSesi? = nil
 
    // MARK: - Statistik
    private var totalPantau: Int { semuaSesi.count }
    private var totalKeluarZona: Int {
        semuaSesi.filter { $0.statusAkhir == .keluarZona }.count
    }
 
    // MARK: - Pengelompokan per minggu
    private var grouped: [(label: String, sesi: [RiwayatSesi])] {
        let calendar = Calendar.current
        let now      = Date()
 
        var hariIni:    [RiwayatSesi] = []
        var mingguIni:  [RiwayatSesi] = []
        var mingguLalu: [RiwayatSesi] = []
        var lebihLama:  [RiwayatSesi] = []
 
        for sesi in semuaSesi {
            if calendar.isDateInToday(sesi.waktuMulai) {
                hariIni.append(sesi)
            } else if let weekAgo = calendar.date(byAdding: .day, value: -7, to: now),
                      sesi.waktuMulai >= weekAgo {
                mingguIni.append(sesi)
            } else if let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: now),
                      sesi.waktuMulai >= twoWeeksAgo {
                mingguLalu.append(sesi)
            } else {
                lebihLama.append(sesi)
            }
        }
 
        var hasil: [(String, [RiwayatSesi])] = []
        if !hariIni.isEmpty    { hasil.append(("Hari ini", hariIni)) }
        if !mingguIni.isEmpty  { hasil.append(("Minggu ini", mingguIni)) }
        if !mingguLalu.isEmpty { hasil.append(("Minggu lalu", mingguLalu)) }
        if !lebihLama.isEmpty  { hasil.append(("Lebih lama", lebihLama)) }
        return hasil
    }
 
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
 
                // MARK: Header
                HStack {
                    Text("Riwayat")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
 
                // MARK: Stat Cards
                HStack(spacing: 12) {
                    statCard(
                        judul: "Jumlah Pantau",
                        sub: "Total sesi pemantauan",
                        nilai: "\(totalPantau)",
                        bg: Color(.secondarySystemGroupedBackground),
                        warnaAngka: .primary
                    )
                    statCard(
                        judul: "Keluar Zona",
                        sub: "Total lansia keluar dari zona aman",
                        nilai: "\(totalKeluarZona)",
                        bg: totalKeluarZona > 0 ? Color(hex: "#FCEBEB") : Color(.secondarySystemGroupedBackground),
                        warnaAngka: totalKeluarZona > 0 ? Color(hex: "#A32D2D") : .primary
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
 
                // MARK: Daftar riwayat
                if semuaSesi.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 44))
                            .foregroundColor(.secondary)
                        Text("Belum ada riwayat")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                } else {
                    VStack(spacing: 0) {
                        ForEach(grouped, id: \.label) { grup in
                            // Section header
                            HStack {
                                Text(grup.label)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            .padding(.bottom, 10)

                            // Cards
                            VStack(spacing: 10) {
                                ForEach(grup.sesi) { sesi in
                                    Button {
                                        sesiDipilih = sesi
                                    } label: {
                                        RiwayatCardView(sesi: sesi)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)
                        }
                    }
                }
 
                Spacer(minLength: 32)
            }
        }
        .sheet(item: $sesiDipilih) { sesi in
            RiwayatDetailView(sesi: sesi)
        }
    }
 
    // MARK: - Stat Card Builder
    @ViewBuilder
    private func statCard(
        judul: String,
        sub: String,
        nilai: String,
        bg: Color,
        warnaAngka: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(judul)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(warnaAngka == .primary ? .primary : Color(hex: "#A32D2D"))
            Text(sub)
                .font(.caption2)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            Text(nilai)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(warnaAngka)
        }
        .frame(maxWidth: .infinity, minHeight: 110, alignment: .leading)
        .padding(16)
        .background(bg)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
 
// MARK: - Card item di list
struct RiwayatCardView: View {
    let sesi: RiwayatSesi
 
    private var warnaStrip: Color {
        switch sesi.statusAkhir {
        case .aman:       return Color(hex: "#1D9E75")
        case .keluarZona: return Color(hex: "#A32D2D")
        case .disconnect: return Color(hex: "#B85C00")
        }
    }
 
    private var badgeWarna: Color {
        switch sesi.statusAkhir {
        case .aman:       return Color(hex: "#1D9E75")
        case .keluarZona: return Color(hex: "#A32D2D")
        case .disconnect: return Color(hex: "#B85C00")
        }
    }
 
    private var badgeBg: Color {
        switch sesi.statusAkhir {
        case .aman:       return Color(hex: "#1D9E75").opacity(0.15)
        case .keluarZona: return Color(hex: "#A32D2D").opacity(0.15)
        case .disconnect: return Color(hex: "#B85C00").opacity(0.15)
        }
    }
 
    private var waktuFormatted: String {
        let f = DateFormatter()
        f.dateFormat = "dd/MM/yyyy, HH:mm"
        return f.string(from: sesi.waktuMulai)
    }
 
    var body: some View {
        HStack(spacing: 0) {
            // Strip warna kiri dengan corner radius kiri
            RoundedRectangle(cornerRadius: 2)
                .fill(warnaStrip)
                .frame(width: 30)
                .padding(.vertical, 0)
//                .padding(.leading, 12)

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(sesi.namaZona)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    // Badge status
                    HStack(spacing: 5) {
                        Circle()
                            .fill(badgeWarna)
                            .frame(width: 7, height: 7)
                        Text(sesi.statusAkhir.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(badgeWarna)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(badgeBg)
                    .clipShape(Capsule())
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(waktuFormatted)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 16)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}
