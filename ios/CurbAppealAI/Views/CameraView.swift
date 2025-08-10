import SwiftUI
import AVFoundation

struct CameraView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var cameraManager = CameraManager()
    @State private var showingImagePicker = false
    @State private var showingPhotoLibrary = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    // Camera Preview or Analysis State
                    switch appViewModel.analysisState {
                    case .idle:
                        cameraPreviewSection
                    case .analyzing:
                        analyzingSection
                    case .completed(let analysis):
                        analysisResultSection(analysis)
                    case .error(let message):
                        errorSection(message)
                    case .uploading:
                        uploadingSection
                    }
                    
                    Spacer()
                    
                    // Controls
                    if case .idle = appViewModel.analysisState {
                        controlsSection
                    } else if case .error = appViewModel.analysisState {
                        retrySection
                    }
                }
            }
            .navigationTitle("Analyze Your Home")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if case .completed = appViewModel.analysisState {
                        Button("Done") {
                            appViewModel.resetAnalysis()
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(sourceType: .camera) { image in
                Task {
                    await appViewModel.analyzeImage(image)
                }
            }
        }
        .sheet(isPresented: $showingPhotoLibrary) {
            ImagePicker(sourceType: .photoLibrary) { image in
                Task {
                    await appViewModel.analyzeImage(image)
                }
            }
        }
        .onAppear {
            cameraManager.checkPermissions()
        }
    }
    
    private var cameraPreviewSection: some View {
        VStack {
            // Instructions
            VStack(spacing: 12) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                
                Text("Capture Your Home's Exterior")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("Position your home's front view in the frame for the best analysis")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 40)
            
            Spacer()
            
            // Tips
            VStack(alignment: .leading, spacing: 8) {
                Text("📸 Photography Tips:")
                    .font(.headline)
                    .foregroundColor(.white)
                
                tipRow(icon: "sun.max", text: "Use natural daylight for best results")
                tipRow(icon: "viewfinder", text: "Include the entire front facade")
                tipRow(icon: "perspective", text: "Stand straight across from your home")
                tipRow(icon: "square.grid.3x3", text: "Keep the horizon level")
            }
            .padding()
            .background(Color.black.opacity(0.3))
            .cornerRadius(16)
            .padding(.horizontal)
        }
    }
    
    private func tipRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
        }
    }
    
    private var controlsSection: some View {
        VStack(spacing: 20) {
            // Main capture button
            Button(action: {
                showingImagePicker = true
            }) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "camera.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
            .disabled(cameraManager.cameraState == .notAuthorized)
            
            // Secondary options
            HStack(spacing: 40) {
                Button(action: {
                    showingPhotoLibrary = true
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title3)
                        Text("Library")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                }
                
                Button(action: {
                    // Toggle flash
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "bolt.slash")
                            .font(.title3)
                        Text("Flash")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                }
            }
            
            if cameraManager.cameraState == .notAuthorized {
                Text("Camera access required for photo capture")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.bottom, 40)
    }
    
    private var analyzingSection: some View {
        VStack(spacing: 24) {
            // Progress indicator
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 4)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.blue, lineWidth: 4)
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: true)
                
                Image(systemName: "brain")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 8) {
                Text("Analyzing Your Home")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("Our AI is evaluating your home across 10 key criteria...")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Analysis steps
            VStack(alignment: .leading, spacing: 12) {
                analysisStep("🏡", "Analyzing exterior condition", true)
                analysisStep("🌿", "Evaluating landscaping", true)
                analysisStep("🎨", "Assessing paint & siding", true)
                analysisStep("📊", "Calculating scores", false)
            }
            .padding()
            .background(Color.black.opacity(0.3))
            .cornerRadius(16)
            .padding(.horizontal)
        }
    }
    
    private func analysisStep(_ icon: String, _ text: String, _ completed: Bool) -> some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.headline)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white.opacity(completed ? 1.0 : 0.6))
            
            Spacer()
            
            if completed {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
    }
    
    private func analysisResultSection(_ analysis: QuickAnalysis) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Success header
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                    
                    Text("Analysis Complete!")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                // Score display
                ScoreDisplayView(
                    score: analysis.overallScore,
                    percentage: analysis.percentage
                )
                
                // Summary
                Text(analysis.summary)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Top recommendations
                VStack(alignment: .leading, spacing: 12) {
                    Text("Priority Areas")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ForEach(analysis.criteria.filter { $0.score <= 3 }.prefix(3)) { criterion in
                        PriorityCriterionRow(criterion: criterion)
                    }
                }
                .padding()
                .background(Color.black.opacity(0.3))
                .cornerRadius(16)
                .padding(.horizontal)
                
                // Action buttons
                VStack(spacing: 12) {
                    Button(action: {
                        // Navigate to detailed view
                    }) {
                        Text("View Detailed Results")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        // Get detailed report
                    }) {
                        Text("Get Professional Report ($9.99)")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
    
    private func errorSection(_ message: String) -> some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Analysis Failed")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    private var uploadingSection: some View {
        VStack(spacing: 24) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
            
            Text("Uploading Image...")
                .font(.title2)
                .foregroundColor(.white)
        }
    }
    
    private var retrySection: some View {
        VStack(spacing: 16) {
            Button("Try Again") {
                appViewModel.resetAnalysis()
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(12)
            .padding(.horizontal)
            
            Button("Choose Different Photo") {
                appViewModel.resetAnalysis()
                showingPhotoLibrary = true
            }
            .font(.subheadline)
            .foregroundColor(.white.opacity(0.8))
            .padding(.horizontal)
        }
        .padding(.bottom, 40)
    }
}

struct PriorityCriterionRow: View {
    let criterion: CurbAppealCriteria
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(criterion.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text("Score: \(criterion.score)/5")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Text("$\(criterion.costEstimate.low)-\(criterion.costEstimate.high)")
                .font(.caption)
                .foregroundColor(.green)
        }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
            .environmentObject(AppViewModel())
    }
}