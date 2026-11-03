import SwiftUI

// MARK: - Quote View

struct QuoteView: View {
    let quote: Quote
    let opacity: Double

    var body: some View {
        VStack(spacing: 10) {
            // Quote marks decoration
            Text("\u{201C}")
                .font(.system(size: 48, weight: .bold, design: .serif))
                .foregroundColor(.white.opacity(0.12))
                .offset(y: 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 32)

            // Quote text
            Text(quote.text)
                .font(.system(size: 15, weight: .light, design: .serif))
                .italic()
                .foregroundColor(.white.opacity(0.75))
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .padding(.horizontal, 48)
                .fixedSize(horizontal: false, vertical: true)

            // Author
            HStack(spacing: 6) {
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 20, height: 0.5)

                Text(quote.author)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.35))
                    .tracking(0.5)

                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 20, height: 0.5)
            }
            .padding(.top, 4)
        }
        .opacity(opacity)
        .animation(.easeInOut(duration: 0.6), value: opacity)
    }
}

