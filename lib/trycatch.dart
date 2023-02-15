/// A utility class that provides helper methods for performing error handling
/// and exception handling in synchronous and asynchronous operations.
library trycatch;

import 'dart:async';

typedef OnTimeout = void Function()?;
typedef OnError = void Function(Object error, StackTrace stackTrace)?;
typedef OnThrottle = void Function()?;
typedef OnWaiting = void Function()?;
typedef OnSuccess = void Function<T>(T data)?;
typedef OnNull = void Function()?;
typedef OnEmpty = void Function()?;

/// A utility class that provides helper methods for performing error handling
/// and exception handling in synchronous and asynchronous operations.
///
/// Use the `async` method to wrap a `Future` operation and handle errors and
/// exceptions that may occur during the operation's execution. You can set
/// callbacks to handle different types of outcomes, such as `onSuccess` for
/// successful operations, `onError` for unhandled exceptions, `onTimeout` for
/// operations that exceed a given timeout, and others.
///
/// Use the `sync` method to wrap a synchronous operation and handle errors and
/// exceptions that may occur during its execution. You can set callbacks to
/// handle different types of outcomes, such as `onSuccess` for successful
/// operations, `onError` for unhandled exceptions, and others.
class TryCatch {
  /// Wraps a `Future` operation and handles errors and exceptions that may
  /// occur during its execution.
  ///
  /// The `async` method takes the following parameters:
  ///
  /// - `future`: The `Future` operation to wrap.
  /// - `onTimeout`: A callback to execute when the operation exceeds a given
  /// timeout.
  /// - `onError`: A callback to execute when the operation throws an unhandled
  /// exception.
  /// - `onWaiting`: A callback to execute when the operation starts waiting.
  /// - `onNull`: A callback to execute when the operation returns `null`.
  /// - `onEmpty`: A callback to execute when the operation returns an empty
  /// `List` or `Map`.
  /// - `onSuccess`: A callback to execute when the operation completes
  /// successfully. The callback takes the operation's result as a parameter.
  /// - `timeout`: The maximum amount of time to wait for the operation to
  /// complete. If the operation takes longer than this amount of time, the
  /// `onTimeout` callback is executed.
  static Future<void> async<T>({
    /// The asynchronous operation to be executed.
    required Future<T> future,

    /// Callback function to be executed when the operation times out.
    OnTimeout onTimeout,

    /// Callback function to be executed when an error occurs during the execution of the operation.
    OnError onError,

    /// Callback function to be executed while the operation is waiting to complete.
    OnWaiting onWaiting,

    /// Callback function to be executed when the operation returns null.
    OnNull onNull,

    /// Callback function to be executed when the operation returns an empty list or map.
    OnEmpty onEmpty,

    /// Callback function to be executed when the operation is successful.
    void Function(T data)? onSuccess,

    /// The amount of time to wait before timing out the operation.
    Duration timeout = const Duration(milliseconds: 10000),
  }) async {
    try {
      onWaiting?.call();

      final result = await future.timeout(timeout);

      if (result is List) {
        onEmpty?.call();
      } else if (result is Map) {
        onEmpty?.call();
      } else if (result == null) {
        onNull?.call();
      } else {
        return onSuccess?.call(result);
      }
    } catch (e, s) {
      if (e is TimeoutException) {
        onTimeout?.call();
      } else {
        onError?.call(e, s);
      }
    }
  }

  /// Synchronously executes an operation and handles various types of responses and errors.
  ///
  /// The `sync` method takes the following parameters:
  ///
  /// - `operation`: The synchronous operation to execute.
  /// - `onError`: A callback to execute when the operation throws an unhandled exception.
  /// - `onNull`: A callback to execute when the operation returns `null`.
  /// - `onEmpty`: A callback to execute when the operation returns an empty `List` or `Map`.
  /// - `onSuccess`: A callback to execute when the operation completes successfully. The callback
  /// takes the operation's result as a parameter.
  ///
  /// If the `operation` returns a null or empty response, the corresponding callback functions are
  /// executed. If the `operation` completes successfully, the `onSuccess` callback function is
  /// executed. If an error occurs during the execution of the operation, the `onError` callback
  /// function is executed.
  static void sync<T>({
    /// The synchronous operation to be executed.
    required T Function() operation,

    /// Callback function to be executed when an error occurs during the execution of the operation.
    OnError onError,

    /// Callback function to be executed when the operation returns null.
    OnNull onNull,

    /// Callback function to be executed when the operation returns an empty list or map.
    OnEmpty onEmpty,

    /// Callback function to be executed when the operation is successful.
    void Function(T data)? onSuccess,
  }) {
    /// Synchronously executes an operation and handles various types of responses and errors.
    ///
    /// This method executes the `operation` argument and waits for the operation to complete. If the operation returns
    /// a null or empty response, the corresponding callback functions are executed. If the operation completes successfully,
    /// the `onSuccess` callback function is executed.
    ///
    /// If an error occurs during the execution of the operation, the `onError` callback function is executed.

    try {
      final result = operation.call();

      if (result is List) {
        onEmpty?.call();
      } else if (result is Map) {
        onEmpty?.call();
      } else if (result == null) {
        onNull?.call();
      } else {
        return onSuccess?.call(result);
      }
    } catch (e, s) {
      onError?.call(e, s);
    }
  }
}
