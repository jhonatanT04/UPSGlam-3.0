import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/gpu_process_result.dart';
import '../../core/services/api_service.dart';
import '../../core/providers/auth_provider.dart';

enum UploadStep { idle, processing, done, error }

class UploadState {
  final File? selectedImage;
  final String selectedFilter;
  final int filterSize;
  final UploadStep step;
  final GpuProcessResult? result;
  final String? errorMessage;

  const UploadState({
    this.selectedImage,
    this.selectedFilter = 'motion_blur',
    this.filterSize = 65,
    this.step = UploadStep.idle,
    this.result,
    this.errorMessage,
  });

  UploadState copyWith({
    File? selectedImage,
    String? selectedFilter,
    int? filterSize,
    UploadStep? step,
    GpuProcessResult? result,
    String? errorMessage,
  }) =>
      UploadState(
        selectedImage: selectedImage ?? this.selectedImage,
        selectedFilter: selectedFilter ?? this.selectedFilter,
        filterSize: filterSize ?? this.filterSize,
        step: step ?? this.step,
        result: result ?? this.result,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

final uploadProvider =
    StateNotifierProvider.autoDispose<UploadNotifier, UploadState>(
        (ref) => UploadNotifier(ref.read(apiServiceProvider)));

class UploadNotifier extends StateNotifier<UploadState> {
  final ApiService _api;
  UploadNotifier(this._api) : super(const UploadState());

  void setImage(File file) => state = state.copyWith(selectedImage: file);
  void setFilter(String filter) => state = state.copyWith(selectedFilter: filter);
  void setFilterSize(int size) => state = state.copyWith(filterSize: size);

  Future<void> processImage() async {
    if (state.selectedImage == null) return;
    state = state.copyWith(step: UploadStep.processing);
    try {
      final result = await _api.processImage(
        state.selectedImage!,
        filterName: state.selectedFilter,
        filterSize: state.filterSize,
      );
      state = state.copyWith(step: UploadStep.done, result: result);
    } catch (e) {
      state = state.copyWith(
          step: UploadStep.error, errorMessage: e.toString());
    }
  }

  void reset() => state = const UploadState();
}
