import 'package:template/shared/domain/entities/item_entity.dart';

/// Shared state shape reused by [DeclareLostCubit] and [DeclareFoundCubit].
sealed class DeclareItemState {
  const DeclareItemState();
}

class DeclareItemInitial extends DeclareItemState {
  const DeclareItemInitial();
}

class DeclareItemLoading extends DeclareItemState {
  const DeclareItemLoading();
}

class DeclareItemSuccess extends DeclareItemState {
  const DeclareItemSuccess(this.item);
  final ItemEntity item;
}

class DeclareItemFailure extends DeclareItemState {
  const DeclareItemFailure(this.message);
  final String message;
}
