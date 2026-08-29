import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:template/features/auth/domain/repositories/auth_repository.dart';
import 'package:template/features/match/domain/repositories/match_repository.dart';
import 'package:template/shared/domain/entities/item_entity.dart';
import 'package:template/shared/domain/repositories/item_repository.dart';
import 'package:template/shared/presentation/blocs/declare_item_state.dart';
import 'package:uuid/uuid.dart';

@injectable
class DeclareLostCubit extends Cubit<DeclareItemState> {
  DeclareLostCubit(
    this._itemRepository,
    this._matchRepository,
    this._authRepository,
  ) : super(const DeclareItemInitial());

  final ItemRepository _itemRepository;
  final MatchRepository _matchRepository;
  final AuthRepository _authRepository;
  static const _uuid = Uuid();

  Future<void> submit({
    required String title,
    required String description,
    required String category,
    required String location,
    required String date,
    required String secretQuestion,
    required String secretAnswer,
  }) async {
    emit(const DeclareItemLoading());
    try {
      final user = await _authRepository.getCurrentUser();
      final item = ItemEntity(
        id: _uuid.v4(),
        kind: ItemKind.lost,
        title: title.trim(),
        description: description.trim(),
        category: category,
        location: location.trim(),
        date: date,
        ownerId: user?.id ?? 'guest',
        createdAt: DateTime.now(),
        secretQuestion: secretQuestion.trim(),
        secretAnswer: secretAnswer.trim(),
      );
      await _itemRepository.add(item);
      await _matchRepository.generateMatches();
      emit(DeclareItemSuccess(item));
    } catch (e) {
      emit(DeclareItemFailure(e.toString()));
    }
  }
}
