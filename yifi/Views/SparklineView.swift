//
//  SparklineView.swift
//  yifi
//
//  Created by Nauman Ahmad on 2/3/26.
//

import SwiftUI

/// A compact line graph showing historical data points
struct SparklineView: View {
    let data: [Double]
    let color: Color
    let isHigherBetter: Bool
    
    /// Maximum number of points to display
    private let maxPoints = 30
    
    var body: some View {
        GeometryReader { geometry in
            if data.isEmpty {
                emptyState(in: geometry)
            } else {
                sparklinePath(in: geometry)
            }
        }
    }
    
    // MARK: - Private Views
    
    private func emptyState(in geometry: GeometryProxy) -> some View {
        // Show a flat line when there's no data
        Path { path in
            let y = geometry.size.height / 2
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: geometry.size.width, y: y))
        }
        .stroke(color.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [2, 2]))
    }
    
    private func sparklinePath(in geometry: GeometryProxy) -> some View {
        let width = geometry.size.width
        let height = geometry.size.height
        
        // Get the data points to display (up to maxPoints)
        let points = Array(data.suffix(maxPoints))
        guard points.count >= 2 else {
            return AnyView(emptyState(in: geometry))
        }
        
        // Calculate min and max for scaling
        let minValue = points.min() ?? 0
        let maxValue = points.max() ?? 1
        let range = maxValue - minValue
        
        // Ensure we have some range to avoid division by zero
        let effectiveRange = range > 0 ? range : 1
        
        // Calculate x spacing
        let spacing = width / CGFloat(maxPoints - 1)
        
        // Build the path
        return AnyView(
            Path { path in
                for (index, value) in points.enumerated() {
                    // Normalize value to 0-1 range
                    var normalizedValue = (value - minValue) / effectiveRange
                    
                    // If higher is better, keep as is (higher values at top)
                    // If lower is better, invert (lower values at top)
                    if !isHigherBetter {
                        normalizedValue = 1 - normalizedValue
                    }
                    
                    // Calculate position
                    // Start from the right side if we have fewer points than max
                    let xOffset = CGFloat(maxPoints - points.count) * spacing
                    let x = xOffset + CGFloat(index) * spacing
                    
                    // Y is inverted in screen coordinates (0 at top)
                    // Add padding to avoid clipping at edges
                    let padding: CGFloat = 2
                    let y = padding + (1 - normalizedValue) * (height - 2 * padding)
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(color, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
        )
    }
}

// MARK: - Preview

#Preview("Sparkline with data") {
    VStack(spacing: 20) {
        // Good status (green)
        SparklineView(
            data: [10, 12, 8, 15, 11, 9, 14, 12, 10, 13, 11, 12, 10, 11, 12],
            color: .green,
            isHigherBetter: true
        )
        .frame(width: 80, height: 20)
        .padding()
        .background(Color.black.opacity(0.1))
        
        // Warning status (yellow)
        SparklineView(
            data: [50, 55, 48, 60, 52, 58, 45, 62, 55, 50],
            color: .yellow,
            isHigherBetter: false
        )
        .frame(width: 80, height: 20)
        .padding()
        .background(Color.black.opacity(0.1))
        
        // Bad status (red)
        SparklineView(
            data: [100, 120, 95, 150, 110, 130, 140, 125],
            color: .red,
            isHigherBetter: false
        )
        .frame(width: 80, height: 20)
        .padding()
        .background(Color.black.opacity(0.1))
        
        // Empty state
        SparklineView(
            data: [],
            color: .gray,
            isHigherBetter: true
        )
        .frame(width: 80, height: 20)
        .padding()
        .background(Color.black.opacity(0.1))
    }
    .padding()
}
