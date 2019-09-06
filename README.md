# InjectKit
Proof of concept for a dependency injection framework using function builder DSL and PropertyWrappers of swift 5.1

```swift

//Init Dependency Tree
start {
    single(DogType.self) { _ in Dog() }
    factory(Cat.self) { _ in Cat() }
    factory(Cat.self) { _ in Cat() }
    factory(String.self) { _ in "123" }
    single(Database.self) { _ in Database.database() }
    single(Human.self) { Human(dog: $0.resolve(DogType.self)) }
}

// Using by Inject annotation
class Main {
    @Inject private var value: String
    @Inject private var myDog: DogType
    @Inject private var myDog2: DogType
    @Inject private var database: Database
    @Inject private var human: Human

    init() {
        print(value)

        print(myDog.name)
        myDog.run()
        print(myDog.name)
        print(myDog2.name)
        print(human.name)
    }
}


let _ = Main()


```

Special Thanks to

https://quickbirdstudios.com/blog/swift-dependency-injection-service-locators/

https://blog.vihan.org/swift-function-builders/

