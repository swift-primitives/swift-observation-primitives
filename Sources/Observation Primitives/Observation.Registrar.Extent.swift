// Observation.Registrar.Extent.swift

extension Observation.Registrar {
    /// Heap-allocated state holder for the registrar — the class behind
    /// the struct's CoW shape. Holds the lock and the mutable observer
    /// state.
    ///
    /// `@unchecked Sendable` because all access to `state` flows through
    /// `lock`; the unchecked annotation captures the discipline that the
    /// compiler cannot verify but the implementation enforces.
    final class Extent: @unchecked Sendable {
        var lock: Observation.Lock
        var state: State

        init() {
            self.lock = Observation.Lock()
            self.state = State()
        }

        deinit {
            // No additional cleanup required: observers are stored
            // by-value in `state`. The lock is destroyed by the
            // wrapping Lock's deinit.
        }
    }
}
