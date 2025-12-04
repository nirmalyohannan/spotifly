import 'package:spotifly/features/search/domain/entities/search_results.dart';

abstract class SearchRepository {
  Future<SearchResults> search(String query);
}
