
fileprivate var globalContainer: Container?

public protocol Resolver {
    func resolve<ServiceType>(_ type: ServiceType.Type) -> ServiceType
}

struct Container: Resolver {

    let factories: [AnyServiceFactory]

    init() {
        self.factories = []
    }

    private init(factories: [AnyServiceFactory]) {
        self.factories = factories
    }

    func register(_ factory: [AnyServiceFactory]) -> Container {
        return .init(factories: factory)
    }

    // MARK: Resolver
    func resolve<ServiceType>(_ type: ServiceType.Type) -> ServiceType {
        guard let factory = factories.first(where: { $0.supports(type) }) else {
            fatalError("No suitable factory found")
        }
        return factory.resolve(self)
    }

    func factory<ServiceType>(for type: ServiceType.Type) -> () -> ServiceType {
        guard let factory = factories.first(where: { $0.supports(type) }) else {
            fatalError("No suitable factory found")
        }

        return { factory.resolve(self) }
    }
}
protocol ServiceFactory {
    associatedtype ServiceType

    func resolve(_ resolver: Resolver) -> ServiceType
}

extension ServiceFactory {
    func supports<T>(_ type: T.Type) -> Bool {
        return type == ServiceType.self
    }
}

extension Resolver {
    func factory<ServiceType>(for type: ServiceType.Type) -> () -> ServiceType {
        return { self.resolve(type) }
    }
}

struct BasicServiceFactory<ServiceType>: ServiceFactory {
    private let factory: (Resolver) -> ServiceType

    init(_ type: ServiceType.Type, factory: @escaping (Resolver) -> ServiceType) {
        self.factory = factory
    }

    func resolve(_ resolver: Resolver) -> ServiceType {
        return factory(resolver)
    }
}

class BasicServiceSingleton<ServiceType>: ServiceFactory {
    private let factory: (Resolver) -> ServiceType

    private var resolved: ServiceType? = nil

    init(_ type: ServiceType.Type, factory: @escaping (Resolver) -> ServiceType) {
        self.factory = factory
    }

    func resolve(_ resolver: Resolver) -> ServiceType {
        if let resolved = resolved {
            return resolved
        }

        self.resolved = factory(resolver)

        return resolved!
    }
}

public final class AnyServiceFactory: Resolver {
    public func resolve<ServiceType>(_ type: ServiceType.Type) -> ServiceType {
        assert(_supports(type))

        return _resolve(self) as! ServiceType
    }

    private let _resolve: (Resolver) -> Any
    private let _supports: (Any.Type) -> Bool


    init<T: ServiceFactory>(_ serviceFactory: T) {
        self._resolve = { resolver -> Any in
            serviceFactory.resolve(resolver)
        }
        self._supports = { $0 == T.ServiceType.self }
    }

    func resolve<ServiceType>(_ resolver: Resolver) -> ServiceType {
        return _resolve(resolver) as! ServiceType
    }

    func supports<ServiceType>(_ type: ServiceType.Type) -> Bool {
        return _supports(type)
    }
}

@_functionBuilder
public struct ContainerBuilder {

    typealias Component = [AnyServiceFactory]

    typealias Expression = AnyServiceFactory

    public static func buildBlock(_ children: Component...) -> Component {
        return children.flatMap { $0 }
    }

    static func buildExpression(_ expression: Expression) -> Component {
        return [expression]
    }
}

public func single<ServiceType>(_ type: ServiceType.Type, _ factory: @autoclosure @escaping (Resolver) -> ServiceType) -> [AnyServiceFactory] {
    let newFactory = BasicServiceSingleton<ServiceType>(type, factory: { resolver in
        factory(resolver)
    })
    return [AnyServiceFactory(newFactory)]
}

public func factory<ServiceType>(_ type: ServiceType.Type, _ factory: @autoclosure @escaping (Resolver) -> ServiceType) -> [AnyServiceFactory] {
    let newFactory = BasicServiceFactory<ServiceType>(type, factory: { resolver in        factory(resolver)
    })
    return [AnyServiceFactory(newFactory)]
}


public func start(@ContainerBuilder makeFactories: () -> [AnyServiceFactory]) {
    globalContainer = Container().register(makeFactories())
}


@propertyWrapper
public class Inject<ServiceType> {
    var service: ServiceType?
    public init() {

    }
    public var wrappedValue: ServiceType {
        get {
            if let service = service {
                return service
            }
            service = globalContainer!.resolve(ServiceType.self)
            return service!
        }
        set { service = newValue }
    }
}

