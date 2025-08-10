import SwiftUI
import Combine

@MainActor
class AppViewModel: ObservableObject {
    @Published var analysisState: AnalysisState = .idle
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var recentAnalyses: [QuickAnalysis] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let supabaseManager = SupabaseManager.shared
    private let aiService = AIService.shared
    
    init() {
        setupSubscriptions()
        loadRecentAnalyses()
    }
    
    private func setupSubscriptions() {
        supabaseManager.$currentUser
            .receive(on: DispatchQueue.main)
            .assign(to: \.currentUser, on: self)
            .store(in: &cancellables)
        
        supabaseManager.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .assign(to: \.isAuthenticated, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Analysis Methods
    
    func analyzeImage(_ image: UIImage) async {
        analysisState = .analyzing
        
        do {
            let analysis = try await aiService.analyzeImage(image)
            analysisState = .completed(analysis)
            
            // Add to recent analyses
            recentAnalyses.insert(analysis, at: 0)
            if recentAnalyses.count > 10 {
                recentAnalyses.removeLast()
            }
            
            // Save to local storage
            saveRecentAnalyses()
            
        } catch {
            analysisState = .error(error.localizedDescription)
        }
    }
    
    func resetAnalysis() {
        analysisState = .idle
    }
    
    // MARK: - Data Persistence
    
    private func loadRecentAnalyses() {
        if let data = UserDefaults.standard.data(forKey: "recentAnalyses"),
           let analyses = try? JSONDecoder().decode([QuickAnalysis].self, from: data) {
            recentAnalyses = analyses
        }
    }
    
    private func saveRecentAnalyses() {
        if let data = try? JSONEncoder().encode(recentAnalyses) {
            UserDefaults.standard.set(data, forKey: "recentAnalyses")
        }
    }
    
    // MARK: - Authentication
    
    func signIn(email: String, password: String) async throws {
        try await supabaseManager.signIn(email: email, password: password)
    }
    
    func signUp(email: String, password: String, fullName: String?) async throws {
        try await supabaseManager.signUp(email: email, password: password, fullName: fullName)
    }
    
    func signOut() async throws {
        try await supabaseManager.signOut()
        recentAnalyses.removeAll()
        saveRecentAnalyses()
    }
}