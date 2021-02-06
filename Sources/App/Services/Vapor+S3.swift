import Vapor

extension Application {
    var s3: S3 {
        .init(application: self)
    }

    struct S3 {
        struct ClientKey: StorageKey {
            typealias Value = S3Manager
        }

        var manager: S3Manager {
            get {
                guard let client = self.application.storage[ClientKey.self] else {
                    fatalError("S3Manager not setup. Use application.aws.client = ...")
                }
                return client
            }
            nonmutating set {
                self.application.storage.set(ClientKey.self, to: newValue) {
                    try $0.prepareForDeallocation()
                }
            }
        }

        let application: Application
    }
}

extension Request {
    var s3: S3 {
        .init(request: self)
    }

    struct S3 {
        var manager: S3Manager {
            return request.application.s3.manager
        }

        let request: Request
    }
}
