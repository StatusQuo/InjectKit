import XCTest
@testable import InjectKit


class Dog {
    var name = "Ena"
}

class Human {
    @Inject var dog: Dog

}

//Legacy Factory
class Database {
    static func database() -> Database {
        return Database()
    }

    private init(){

    }
}

final class InjectKitTests: XCTestCase {
    func testFactoryBehavior() {
        start {
            factory(Dog.self) { _ in Dog()}
        }

        let human1 = Human()
        let human2 = Human()

        human1.dog.name = "1"
        human2.dog.name = "2"

        XCTAssertEqual(human1.dog.name, "1")
        XCTAssertEqual(human2.dog.name, "2")

    }

    func testSingletonBehaviour() {
        start {
            single(Dog.self) { _ in Dog()}
        }

        let human1 = Human()
        let human2 = Human()

        human1.dog.name = "1"

        XCTAssertEqual(human1.dog.name, "1")
        XCTAssertEqual(human2.dog.name, "1")

    }



    static var allTests = [
        ("testSingle", testSingletonBehaviour),
        ("testExample", testFactoryBehavior)
    ]
}
