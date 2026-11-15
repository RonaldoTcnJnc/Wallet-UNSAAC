import 'package:equatable/equatable.dart';

class PrivacyState extends Equatable {
  const PrivacyState({this.isHidden = false});

  final bool isHidden;

  PrivacyState copyWith({bool? isHidden}) {
    return PrivacyState(isHidden: isHidden ?? this.isHidden);
  }

  @override
  List<Object?> get props => [isHidden];
}
