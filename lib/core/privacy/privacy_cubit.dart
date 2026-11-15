import 'package:flutter_bloc/flutter_bloc.dart';

import 'privacy_state.dart';

class PrivacyCubit extends Cubit<PrivacyState> {
  PrivacyCubit() : super(const PrivacyState());

  void toggle() {
    emit(state.copyWith(isHidden: !state.isHidden));
  }

  void hide() {
    emit(state.copyWith(isHidden: true));
  }

  void show() {
    emit(state.copyWith(isHidden: false));
  }
}
