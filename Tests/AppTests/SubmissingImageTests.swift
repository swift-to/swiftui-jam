@testable import App
import XCTVapor
import Vapor
import Fluent

final class SubmissionImageTests: XCTestCase {
    
    func getTestFile() -> Data {
        let filePath = #file
        var readUrl = URL(fileURLWithPath: filePath)
        readUrl.deleteLastPathComponent()
        readUrl.appendPathComponent("Assets")
        readUrl.appendPathComponent("test-upload.jpg")
        return FileManager.default.contents(atPath: readUrl.path)!
    }
    
    func uploadFile(
        to url: URL,
        data: Data,
        md5String: String,
        eventLoop: EventLoopGroup
    ) -> EventLoopFuture<Void> {
        let promise = eventLoop.next().makePromise(of: Void.self)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.httpBody = data
        urlRequest.allHTTPHeaderFields = [
            "Content-Length": String(data.count),
            "Content-MD5": md5String,
            "Content-Type": "image/jpeg"
        ]
        URLSession(configuration: .default)
            .dataTask(with: urlRequest) { (data, res, err) in
                if err != nil || ((res as? HTTPURLResponse)?.statusCode ?? 400) >= 400 {
                    print("err?", err as Any)
                    XCTFail()
                } else {
                    promise.completeWith(.success(()))
                }
            }.resume()

        return promise.futureResult
    }

    static var allTests = [
        ("testSubmissionImageFlow", testSubmissionImageFlow)
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
   
    func testSubmissionImageFlow() throws {
        
        // Given
        let submission = try CreateSubmissionEndpoint.run(
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
        
        let testFile = getTestFile()
        let md5Hash = Insecure.MD5.hash(data: getTestFile())
        let md5String = Data(md5Hash).base64EncodedString()

        let prepResponse = try PrepareSubmissionImageUploadEndpoint.run(
            context: authedContext,
            parameters: .init(id: submission.id.uuidString),
            query: (),
            body: .init(
                info: .init(
                    bytes: testFile.count,
                    md5Hash: md5String,
                    mimeType: "image/jpeg"
                )
            )
        ).wait()
        
        try uploadFile(
            to: prepResponse.uploadUrl,
            data: testFile,
            md5String: md5String,
            eventLoop: app.eventLoopGroup
        ).wait()
        
        // Confirm it exists in the db, but is not accessible yet
        guard let itemImageBeforeConfirm = try SubmissionImage.find(prepResponse.id, on: app.db).wait() else {
            XCTFail()
            return
        }
        let imageUrl = itemImageBeforeConfirm.url
        XCTAssertEqual(itemImageBeforeConfirm.isPending, true)
        
        let res = try app.client.get(.init(string: imageUrl)).wait()
        XCTAssertEqual(res.status, .forbidden)
        
        let confirmResponse = try ConfirmSubmissionImageUploadEndpoint.run(
            context: authedContext,
            parameters: .init(
                itemId: submission.id.uuidString,
                imageId: prepResponse.id.uuidString
            ),
            query: (),
            body: ()
        ).wait()
        
        XCTAssertEqual(confirmResponse, .ok)
        
        let itemImageAfterConfirm = try SubmissionImage.find(prepResponse.id, on: app.db).wait()
        XCTAssertEqual(itemImageAfterConfirm?.isPending, false)
        
        let res2 = try app.client.get(.init(string: imageUrl)).wait()
        XCTAssertEqual(res2.status, .ok)
                
        let submissionResponse = try GetSubmissionByIdEndpoint.run(
            context: unauthedContext,
            parameters: .init(id: submission.id.uuidString),
            query: (),
            body: ()
        ).wait()
        
        XCTAssertEqual(submissionResponse.images.count, 1)
        
        let deleteResponse = try DeleteSubmissionImageEndpoint.run(
            context: authedContext,
            parameters: .init(
                itemId: submission.id.uuidString,
                imageId: prepResponse.id.uuidString
            ),
            query: (),
            body: ()
        ).wait()
        
        XCTAssertEqual(deleteResponse, .ok)
        
        let res3 = try app.client.get(.init(string: imageUrl)).wait()
        XCTAssertEqual(res3.status, .forbidden)
        
        let submissionAfterImageDeleteResponse = try GetSubmissionByIdEndpoint.run(
            context: unauthedContext,
            parameters: .init(id: submission.id.uuidString),
            query: (),
            body: ()
        ).wait()
        
        XCTAssertEqual(submissionAfterImageDeleteResponse.images.count, 0)
        
    }
    
}
