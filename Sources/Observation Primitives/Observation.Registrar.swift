// Observation.Registrar.swift

public import Ownership_Shared_Primitives
import Synchronization
public import Tagged_Primitives

extension Observation {

    /// Lock-protected registrar of (PropertyID -> SubscriptionID) bindings.
    ///
    /// The struct holds a heap-allocated extent
    /// (`Ownership.Shared<Mutex<State>>`) so that copies share state —
    /// but copies of the Subject that owns the registrar are themselves
    /// prevented when the Subject is `~Copyable`, sidestepping the
    /// copy-on-write ambiguity that motivated Apple's class-only
    /// restriction (per SE-0395 second-review thread #119).
    ///
    /// ## Internal shape
    ///
    /// Mirrors Apple's `ObservationRegistrar` design but uses stdlib
    /// `Synchronization.Mutex<State>` for thread-safe access — no
    /// platform imports, no platform C types per [PLAT-ARCH-008c]:
    /// - struct → `Ownership.Shared<Mutex<State>>` heap-allocated extent
    ///   (CoW shape; ARC-shared across struct copies)
    /// - bidirectional index in ``Observation/Registrar/State``,
    ///   protected by `Mutex<State>`:
    ///   `[Property.ID: Set<Subscription.ID>]` lookups +
    ///   `[Subscription.ID: Observer]` observers
    /// - monotonic ``Observation/Subscription/ID`` allocator (UInt64)
    ///
    /// Replaces Apple's `(ObjectIdentifier(subject), AnyKeyPath)`
    /// keying with ``Observation/Property/ID`` keying — the
    /// registrar's heap-extent IS the Subject's stable identity (each
    /// Subject owns one).
    public struct Registrar: Sendable {
        let _extent: Ownership.Shared<Mutex<State>>

        /// Creates an empty registrar with a fresh heap-allocated state extent.
        public init() {
            self._extent = Ownership.Shared(Mutex(State()))
        }
    }
}

// MARK: - Read & write notification

extension Observation.Registrar {
    /// Records a property access.
    ///
    /// Currently a no-op — no thread-local tracking context is
    /// established yet at L1. Callers may invoke it for forward-
    /// compatibility with a future `withObservationTracking` primitive
    /// (planned for L3 `swift-observations`); the same call site will
    /// then register the property access with the active tracking
    /// context.
    public func access(_ propertyID: Observation.Property.ID) {
        // No-op today. L3 tracking primitive will inspect the
        // thread-local tracking context and append
        // (registrar-extent, propertyID) to its access list.
        _ = propertyID
    }

    /// Notifies all observers registered for `propertyID` that a
    /// mutation is about to occur.
    public func willSet(_ propertyID: Observation.Property.ID) {
        let callbacks: [@Sendable (Observation.Property.ID) -> Void] =
            _extent.value.withLock { state in
                guard let subscriptionIDs = state.lookups[propertyID] else {
                    return []
                }
                return subscriptionIDs.compactMap { id in
                    state.observers[id]?.willSet
                }
            }
        for callback in callbacks {
            callback(propertyID)
        }
    }

    /// Notifies all observers registered for `propertyID` that a
    /// mutation has just occurred.
    public func didSet(_ propertyID: Observation.Property.ID) {
        let callbacks: [@Sendable (Observation.Property.ID) -> Void] =
            _extent.value.withLock { state in
                guard let subscriptionIDs = state.lookups[propertyID] else {
                    return []
                }
                return subscriptionIDs.compactMap { id in
                    state.observers[id]?.didSet
                }
            }
        for callback in callbacks {
            callback(propertyID)
        }
    }

    /// Wraps a mutation in willSet/didSet bookkeeping.
    ///
    /// Fires `willSet(propertyID)` before `body` runs and `didSet(propertyID)`
    /// after `body` returns or throws, matching Apple's
    /// `ObservationRegistrar.withMutation` semantics.
    ///
    /// - Parameters:
    ///   - propertyID: The property being mutated.
    ///   - body: The mutation closure to run between the notifications.
    /// - Returns: The value produced by `body`.
    /// - Throws: The typed error `E` if `body` throws; `didSet` still fires.
    public func withMutation<R: ~Copyable, E: Swift.Error>(
        of propertyID: Observation.Property.ID,
        _ body: () throws(E) -> R
    ) throws(E) -> R {
        willSet(propertyID)
        defer { didSet(propertyID) }
        return try body()
    }
}

// MARK: - Subscription

extension Observation.Registrar {
    /// Registers an observer for the given properties.
    ///
    /// Returns an opaque ``Observation/Subscription/ID`` that the
    /// caller MUST retain to unregister later. A future addition
    /// (planned for L3 `swift-observations`) will accompany this with
    /// a `~Copyable` `Subscription.Token` that auto-unregisters on
    /// `consume`.
    ///
    /// - Parameters:
    ///   - properties: The set of PropertyIDs to watch.
    ///   - willSet: Optional callback for pre-mutation notification.
    ///   - didSet: Optional callback for post-mutation notification.
    /// - Returns: Opaque subscription ID for later unregistration.
    public func subscribe(
        to properties: Set<Observation.Property.ID>,
        willSet: (@Sendable (Observation.Property.ID) -> Void)? = nil,
        didSet: (@Sendable (Observation.Property.ID) -> Void)? = nil
    ) -> Observation.Subscription.ID {
        _extent.value.withLock { state in
            let id = Observation.Subscription.ID(state.nextSubscriptionID)
            state.nextSubscriptionID &+= 1

            state.observers[id] = Observer(
                properties: properties,
                willSet: willSet,
                didSet: didSet
            )

            for propertyID in properties {
                state.lookups[propertyID, default: []].insert(id)
            }

            return id
        }
    }

    /// Unregisters the subscription with the given ID.
    public func unsubscribe(_ subscriptionID: Observation.Subscription.ID) {
        _extent.value.withLock { state in
            guard let observer = state.observers.removeValue(forKey: subscriptionID) else {
                return
            }
            for propertyID in observer.properties {
                state.lookups[propertyID]?.remove(subscriptionID)
                if state.lookups[propertyID]?.isEmpty == true {
                    state.lookups[propertyID] = nil
                }
            }
        }
    }
}
