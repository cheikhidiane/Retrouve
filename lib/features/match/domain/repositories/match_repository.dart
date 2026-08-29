import 'package:template/shared/domain/entities/match_entity.dart';

abstract class MatchRepository {
  Future<List<MatchEntity>> getAll();

  Future<MatchEntity?> getById(String id);

  /// Scans all unmatched lost/found items and creates new potential
  /// [MatchEntity] records for pairs whose score passes the threshold.
  /// Returns the list of newly created matches.
  Future<List<MatchEntity>> generateMatches();

  Future<MatchEntity> confirm(String id);

  Future<MatchEntity> reject(String id);
}
