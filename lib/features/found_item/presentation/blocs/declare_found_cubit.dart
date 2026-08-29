import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:template/features/auth/domain/repositories/auth_repository.dart';
import 'package:template/features/match/domain/repositories/match_repository.dart';
import 'package:template/shared/domain/entities/item_entity.dart';
import 'package:template/shared/domain/repositories/item_repository.dart';
import 'package:template/shared/presentation/blocs/declare_item_state.dart';
import 'package:uuid/uuid.dart';

@injectable
class DeclareFoundCubit extends Cubit<DeclareItemState> {
  DeclareFoundCubit(
    this._itemRepository,
    this._matchRepository,
    this._authRepository,
  ) : super(const DeclareItemInitial());

  final ItemRepository _itemRepository;
  final MatchRepository _matchRepository;
  final AuthRepository _authRepository;
  static const _uuid = Uuid();

  Future<void> submit({
    required String description,
    required String category,
    required String location,
    required String date,
    required String storageLocation,
  }) async {
    emit(const DeclareItemLoading());
    try {
      final user = await _authRepository.getCurrentUser();
      // Found items don't have a dedicated title field in the form; derive
      // a short title from the category + description for display in lists.
      final shortDescription = description.trim().split('\n').first;
      final title = shortDescription.length > 40
          ? '${shortDescription.substring(0, 40)}…'
          : shortDescription;

      final item = ItemEntity(
        id: _uuid.v4(),
        kind: ItemKind.found,
        title: title.isEmpty ? category : title,
        description: description.trim(),
        category: category,
        location: location.trim(),
        date: date,
        ownerId: user?.id ?? 'guest',
        createdAt: DateTime.now(),
        storageLocation: storageLocation.trim(),
      );
      await _itemRepository.add(item);
      await _matchRepository.generateMatches();
      emit(DeclareItemSuccess(item));
    } catch (e) {
      emit(DeclareItemFailure(e.toString()));
    }
  }
}
