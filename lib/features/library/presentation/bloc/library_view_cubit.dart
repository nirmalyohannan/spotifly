import 'package:flutter_bloc/flutter_bloc.dart';

enum LibraryViewMode { list, grid }

class LibraryViewCubit extends Cubit<LibraryViewMode> {
  LibraryViewCubit() : super(LibraryViewMode.list);

  void toggleViewMode() {
    emit(
      state == LibraryViewMode.list
          ? LibraryViewMode.grid
          : LibraryViewMode.list,
    );
  }
}
