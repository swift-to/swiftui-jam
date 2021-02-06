import Vapor

extension Application {
    var ses: SES {
        .init(application: self)
    }

    struct SES {
        struct ClientKey: StorageKey {
            typealias Value = SESManager
        }

        var manager: SESManager {
            get {
                guard let client = self.application.storage[ClientKey.self] else {
                    fatalError("SESManager not setup. Use application.aws.client = ...")
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
    var ses: SES {
        .init(request: self)
    }

    struct SES {
        var manager: SESManager {
            return request.application.ses.manager
        }

        let request: Request
    }
}
