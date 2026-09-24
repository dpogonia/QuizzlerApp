import CoreServices
import Foundation

public struct QuizSessionSnapshot: Codable, Sendable {
    public var mode: GameMode
    public var currentQuestionIndex: Int
    public var correctAnswers: Int
    public var maxQuestions: Int
    public var remainingTime: TimeInterval
    public var currentCorrectAnswer: Bool
    public var currentCorrectName: String
    public var questionText: String
    public var movieImageName: String?
    public var imageURL: String?
    public var movieRoundImages: [String]?
    public var engine: QuizEngineProgress

    public init(
        mode: GameMode,
        currentQuestionIndex: Int,
        correctAnswers: Int,
        maxQuestions: Int,
        remainingTime: TimeInterval,
        currentCorrectAnswer: Bool,
        currentCorrectName: String,
        questionText: String,
        movieImageName: String?,
        imageURL: String?,
        movieRoundImages: [String]?,
        engine: QuizEngineProgress
    ) {
        self.mode = mode
        self.currentQuestionIndex = currentQuestionIndex
        self.correctAnswers = correctAnswers
        self.maxQuestions = maxQuestions
        self.remainingTime = remainingTime
        self.currentCorrectAnswer = currentCorrectAnswer
        self.currentCorrectName = currentCorrectName
        self.questionText = questionText
        self.movieImageName = movieImageName
        self.imageURL = imageURL
        self.movieRoundImages = movieRoundImages
        self.engine = engine
    }
}

public protocol QuizSessionPersisting: Sendable {
    func save(_ snapshot: QuizSessionSnapshot, questionImage: Data?) async
    func load() async -> QuizSessionSnapshot?
    func loadQuestionImage() async -> Data?
    func clear() async
}

public final class QuizSessionStore: QuizSessionPersisting, @unchecked Sendable {
    private enum FileName {
        static let snapshot = "session.json"
        static let image = "session_image.jpg"
    }

    private let files: any FileStoring
    private let parser: any JSONParsing

    public init(files: any FileStoring, parser: any JSONParsing) {
        self.files = files
        self.parser = parser
    }

    public func save(_ snapshot: QuizSessionSnapshot, questionImage: Data?) async {
        guard let data = try? parser.encode(snapshot) else { return }
        try? await files.write(data, toRelativePath: FileName.snapshot)
        if let questionImage {
            try? await files.write(questionImage, toRelativePath: FileName.image)
        } else {
            await files.remove(relativePath: FileName.image)
        }
    }

    public func load() async -> QuizSessionSnapshot? {
        guard let data = await files.read(fromRelativePath: FileName.snapshot) else { return nil }
        return try? parser.decode(QuizSessionSnapshot.self, from: data)
    }

    public func loadQuestionImage() async -> Data? {
        await files.read(fromRelativePath: FileName.image)
    }

    public func clear() async {
        await files.remove(relativePath: FileName.snapshot)
        await files.remove(relativePath: FileName.image)
    }
}
