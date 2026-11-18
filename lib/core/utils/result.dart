import 'package:melocue/core/utils/failure.dart';

sealed class Result<S, F extends Failure> {
  const Result();

  T fold<T>(
    T Function(S data) onSuccess,
    T Function(F failure) onFailure,
  ) {
    return switch (this) {
      Success(data: final d) => onSuccess(d),
      Error(failure: final f) => onFailure(f),
    };
  }
}

class Success<S, F extends Failure> extends Result<S, F> {
  final S data;
  const Success(this.data);
}

class Error<S, F extends Failure> extends Result<S, F> {
  final F failure;
  const Error(this.failure);
}
