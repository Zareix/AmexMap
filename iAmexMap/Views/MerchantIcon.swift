import SwiftUI

struct MerchantIcon: View {
    let symbol: String
    let color: Color
    var size: CGFloat = 40

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: size * 0.44, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(
                LinearGradient(
                    colors: [color.mix(with: .white, by: 0.35), color],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                in: Circle()
            )
            .overlay(Circle().stroke(.white, lineWidth: size * 0.11))
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
    }
}

#Preview {
    HStack(spacing: 16) {
        MerchantIcon(symbol: "fork.knife", color: .orange, size: 32)
        MerchantIcon(symbol: "cup.and.saucer.fill", color: .orange)
        MerchantIcon(symbol: "bag.fill", color: .yellow, size: 48)
        MerchantIcon(symbol: "building.columns.fill", color: .green, size: 52)
        MerchantIcon(symbol: "airplane", color: .blue, size: 56)
    }
    .padding()
}
