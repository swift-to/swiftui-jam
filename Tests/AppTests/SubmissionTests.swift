@testable import App
import XCTVapor
import Fluent

final class SubmissionTests: XCTestCase {

    static var allTests = [
        ("testCreateSubmission", testCreateSubmission),
        ("testCreateSubmission_duplicateFails", testCreateSubmission_duplicateFails),
        ("testSubmissionUpdate", testSubmissionUpdate)
    ]

    var app: Application = {
        let app = Application(.testing)
        try! configure(app)
        return app
    }()
    var unauthedContext: UnauthorizedRoutingContext!
    var authedContext: AuthorizedRoutingContext!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        try app.autoMigrate().wait()
        
        unauthedContext = UnauthorizedRoutingContext(
            eventLoop: app.eventLoopGroup.next(),
            db: app.db
        )
        
        _ = try RegisterCaptainEndpoint.run(
            context: unauthedContext,
            parameters: (),
            query: (),
            body: .init(
                email: "test@t.com",
                name: "captain1",
                newTeamName: "team1",
                requiresFloater: false
            )
        )
        .wait()
        
        let user = try User.query(on: app.db)
            .filter(\.$email == "test@t.com")
            .first().unwrap(or: Abort(.notFound)).wait()
        
        authedContext = AuthorizedRoutingContext(
            eventLoop: app.eventLoopGroup.next(),
            db: app.db,
            auth: try user.generateAuthPayload(),
            s3: app.s3.manager)
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        try app.autoRevert().wait()
        app.shutdown()
    }
    
    func testCreateSubmission() throws {
        // Given
        let team = try Team.query(on: app.db)
            .with(\.$captain)
            .with(\.$members)
            .filter(\.$name == "team1")
            .first().unwrap(or: Abort(.notFound)).wait()
        
        // When
        let response = try CreateSubmissionEndpoint.run(
            context: authedContext,
            parameters: (),
            query: (),
            body: .init(
                name: "mysub",
                description: "asub",
                repoUrl: "abc123",
                downloadUrl: "321cba",
                blogUrl: "blogabba",
                tags: "1,2,3",
                credits: "credited"
            )
        ).wait()
        
        // Expect
        let submission = try Submission.query(on: app.db)
            .filter(\.$team.$id == team.requireID())
            .first()
            .unwrap(or: Abort(.notFound))
            .wait()
        
        XCTAssertEqual(response, SubmissionViewModel(
            id: try submission.requireID(),
            name: "mysub",
            description: "asub",
            repoUrl: "abc123",
            latestRepoUrl: nil,
            downloadUrl: "321cba",
            blogUrl: "blogabba",
            tags: "1,2,3",
            credits: "credited",
            team: try TeamDetailsViewModel(team),
            images: []
        ))
    }
    
    func testCreateSubmission_duplicateFails() throws {
        // When
        _ = try CreateSubmissionEndpoint.run(
            context: authedContext,
            parameters: (),
            query: (),
            body: .init(
                name: "mysub",
                description: "asub",
                repoUrl: "abc123",
                downloadUrl: "321cba"
            )
        ).wait()
        
        // Expect
        XCTAssertThrowsError(try CreateSubmissionEndpoint.run(
            context: authedContext,
            parameters: (),
            query: (),
            body: .init(
                name: "myssdfsub",
                description: "assdfub",
                repoUrl: "abc1sf23",
                downloadUrl: "321sdfcba"
            )
        ).wait()) { error in
            XCTAssertEqual(error as?  CreateSubmissionEndpoint.CreateSubmissionError, .submissionAlreadyExists)
        }
    }
    
    func testSubmissionUpdate() throws {
        // Given
        let team = try Team.query(on: app.db)
            .with(\.$captain)
            .with(\.$members)
            .filter(\.$name == "team1")
            .first().unwrap(or: Abort(.notFound)).wait()
        
        // When
        let submissionResponse = try CreateSubmissionEndpoint.run(
            context: authedContext,
            parameters: (),
            query: (),
            body: .init(
                name: "mysub",
                description: "asub",
                repoUrl: "abc123",
                downloadUrl: "321cba"
            )
        ).wait()
        
        // When
        let updateResponse = try UpdateSubmissionEndpoint.run(
            context: authedContext,
            parameters: .init(id: submissionResponse.id.uuidString),
            query: (),
            body: .init(
                name: "thes ub",
                description: "blashsh",
                repoUrl: "repostuff",
                latestRepoUrl: "4565",
                downloadUrl: "downloado",
                blogUrl: "blag",
                tags: "3,2,1",
                credits: "acred"
            )
        ).wait()
        
        XCTAssertEqual(updateResponse, .ok)
        
        // Expect
        let sub = try Submission.deepFindById(submissionResponse.id, on: app.db).wait()
        
        XCTAssertEqual(try SubmissionViewModel(sub), SubmissionViewModel(
            id: submissionResponse.id,
            name: "thes ub",
            description: "blashsh",
            repoUrl: "repostuff",
            latestRepoUrl: "4565",
            downloadUrl: "downloado",
            blogUrl: "blag",
            tags: "3,2,1",
            credits: "acred",
            team: try TeamDetailsViewModel(team),
            images: []
        ))
    }
    
    func testGetSubmissions_withHiddenSubmission() throws {
        // Given
        let team = try Team.query(on: app.db)
            .with(\.$captain)
            .with(\.$members)
            .filter(\.$name == "team1")
            .first().unwrap(or: Abort(.notFound)).wait()
        
        let submissionResponse = try CreateSubmissionEndpoint.run(
            context: authedContext,
            parameters: (),
            query: (),
            body: .init(
                name: "mysub",
                description: "asub",
                repoUrl: "abc123",
                downloadUrl: "321cba"
            )
        ).wait()
        
        let initialResults = try GetSubmissionsEndpoint.run(
            context: unauthedContext,
            parameters: (),
            query: (),
            body: ()
        ).wait()
        
        // When
        
        let sub = try Submission.deepFindById(submissionResponse.id, on: app.db).wait()
        sub.isHidden = true
        try sub.save(on: app.db).wait()
        
        let postHidingResults = try GetSubmissionsEndpoint.run(
            context: unauthedContext,
            parameters: (),
            query: (),
            body: ()
        ).wait()
        
        // Expect
        
        XCTAssertEqual(initialResults.count, 1)
        XCTAssertEqual(postHidingResults.count, 0)
    }
    
    
}
