import SwiftUI

struct DepthProfileView: View {
    let samples: [DepthSample]

    private var maxDepth: Double {
        samples.map(\.depth).max() ?? 1.0
    }

    private var totalDuration: TimeInterval {
        samples.map(\.time).max() ?? 1.0
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                profileGradient(in: geometry)
                profileLine(in: geometry)
                depthLabels(in: geometry)
                timeLabels(in: geometry)
            }
        }
        .background(Color(.systemBackground).opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func point(for sample: DepthSample, in size: CGSize) -> CGPoint {
        let x = CGFloat(sample.time / totalDuration) * size.width
        let y = CGFloat(sample.depth / (maxDepth * 1.1)) * (size.height - 20)
        return CGPoint(x: x, y: y)
    }

    @ViewBuilder
    private func profileLine(in geometry: GeometryProxy) -> some View {
        if samples.count >= 2 {
            Path { path in
                let size = geometry.size
                path.move(to: point(for: samples[0], in: size))
                for sample in samples.dropFirst() {
                    path.addLine(to: point(for: sample, in: size))
                }
            }
            .stroke(
                LinearGradient(
                    colors: [.cyan, .blue],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
            )
        }
    }

    @ViewBuilder
    private func profileGradient(in geometry: GeometryProxy) -> some View {
        if samples.count >= 2 {
            Path { path in
                let size = geometry.size
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: point(for: samples[0], in: size))
                for sample in samples.dropFirst() {
                    path.addLine(to: point(for: sample, in: size))
                }
                path.addLine(to: CGPoint(x: size.width, y: 0))
                path.closeSubpath()
            }
            .fill(
                LinearGradient(
                    colors: [.cyan.opacity(0.3), .blue.opacity(0.05)],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
        }
    }

    private func depthLabels(in geometry: GeometryProxy) -> some View {
        VStack(alignment: .trailing) {
            Text(String(format: "%.0fm", maxDepth))
                .font(.caption2)
                .foregroundStyle(.secondary)
            Spacer()
            Text("0m")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.trailing, 4)
        .padding(.vertical, 2)
    }

    private func timeLabels(in geometry: GeometryProxy) -> some View {
        HStack {
            Text("0")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Spacer()
            Text(formatTime(totalDuration))
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .padding(.horizontal, 4)
        .padding(.bottom, 2)
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        return "\(minutes) min"
    }
}

#Preview {
    DepthProfileView(samples: DepthSample.sampleProfile(maxDepth: 18.5, duration: 3240))
        .frame(height: 160)
        .padding()
}
