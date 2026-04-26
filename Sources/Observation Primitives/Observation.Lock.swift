// Observation.Lock.swift
// Platform-specific lock primitive selection — mirrors Apple's
// `stdlib/public/Observation/Sources/Observation/Locking.swift`
// dispatch to os_unfair_lock / pthread_mutex_t / SRWLOCK.

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#elseif os(Windows)
import WinSDK
#endif

extension Observation {
    /// Platform-specific lock primitive — internal to this package.
    ///
    /// Wraps `os_unfair_lock` (Darwin), `pthread_mutex_t` (Linux/Musl),
    /// or `SRWLOCK` (Windows) with a uniform `withLock` API supporting
    /// `~Copyable` results and typed throws.
    final class Lock: @unchecked Sendable {
        #if canImport(Darwin)
        var _lock: os_unfair_lock = os_unfair_lock()
        #elseif canImport(Glibc) || canImport(Musl)
        var _lock: pthread_mutex_t = pthread_mutex_t()
        #elseif os(Windows)
        var _lock: SRWLOCK = SRWLOCK()
        #else
        // Embedded / unsupported platforms: no-op (single-threaded assumption).
        #endif

        init() {
            #if canImport(Glibc) || canImport(Musl)
            unsafe pthread_mutex_init(&_lock, nil)
            #elseif os(Windows)
            unsafe InitializeSRWLock(&_lock)
            #endif
        }

        deinit {
            #if canImport(Glibc) || canImport(Musl)
            unsafe pthread_mutex_destroy(&_lock)
            #endif
            // Darwin's os_unfair_lock and Windows' SRWLOCK have no destroy.
        }

        func lock() {
            #if canImport(Darwin)
            unsafe os_unfair_lock_lock(&_lock)
            #elseif canImport(Glibc) || canImport(Musl)
            unsafe pthread_mutex_lock(&_lock)
            #elseif os(Windows)
            unsafe AcquireSRWLockExclusive(&_lock)
            #endif
        }

        func unlock() {
            #if canImport(Darwin)
            unsafe os_unfair_lock_unlock(&_lock)
            #elseif canImport(Glibc) || canImport(Musl)
            unsafe pthread_mutex_unlock(&_lock)
            #elseif os(Windows)
            unsafe ReleaseSRWLockExclusive(&_lock)
            #endif
        }

        func withLock<R: ~Copyable, E: Error>(_ body: () throws(E) -> R) throws(E) -> R {
            lock()
            defer { unlock() }
            return try body()
        }
    }
}
