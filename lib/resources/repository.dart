abstract class BaseRepository<T> {
  Future<T?> fetchFromApi();
  T? fetchFromCache();
  Future<void> saveToCache();
  void listenToBroadcast();
}

abstract class ListRepository<T> {
  Future<List<T>> fetchFromApi();
  List<T> fetchFromCache();
  Future<void> saveToCache();
  void listenToBroadcast();
}
