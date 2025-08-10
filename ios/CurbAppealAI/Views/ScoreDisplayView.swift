import SwiftUI

struct ScoreDisplayView: View {
    let score: Int // 1-50
    let percentage: Int // 0-100
    let size: DisplaySize
    
    enum DisplaySize {
        case small, medium, large
        
        var circleSize: CGFloat {
            switch self {
            case .small: return 60
            case .medium: return 100
            case .large: return 140
            }
        }
        
        var strokeWidth: CGFloat {
            switch self {
            case .small: return 4
            case .medium: return 6
            case .large: return 8
            }
        }
        
        var fontSize: Font {
            switch self {
            case .small: return .headline
            case .medium: return .title2
            case .large: return .largeTitle
            }
        }
        
        var subscriptFont: Font {
            switch self {
            case .small: return .caption
            case .medium: return .subheadline
            case .large: return .headline
            }
        }
    }
    
    init(score: Int, percentage: Int, size: DisplaySize = .medium) {
        self.score = score
        self.percentage = percentage
        self.size = size
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Circular progress
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: size.strokeWidth)
                    .frame(width: size.circleSize, height: size.circleSize)
                
                Circle()
                    .trim(from: 0, to: CGFloat(percentage) / 100)
                    .stroke(scoreColor, lineWidth: size.strokeWidth)
                    .frame(width: size.circleSize, height: size.circleSize)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.5), value: percentage)
                
                VStack(spacing: 2) {
                    Text("\(percentage)%")
                        .font(size.fontSize)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("\(score)/50")
                        .font(size.subscriptFont)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            // Score interpretation
            VStack(spacing: 4) {
                Text(scoreLabel)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(scoreColor)
                
                Text("Curb Appeal Score")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
    
    private var scoreColor: Color {
        switch percentage {
        case 80...: return .green
        case 60..<80: return .yellow
        case 40..<60: return .orange
        default: return .red
        }
    }
    
    private var scoreLabel: String {
        switch percentage {
        case 80...: return "Excellent"
        case 60..<80: return "Good"
        case 40..<60: return "Fair"
        default: return "Needs Improvement"
        }
    }
}

struct ScoreDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                ScoreDisplayView(score: 42, percentage: 84, size: .large)
                ScoreDisplayView(score: 35, percentage: 70, size: .medium)
                ScoreDisplayView(score: 28, percentage: 56, size: .small)
            }
        }
    }
}