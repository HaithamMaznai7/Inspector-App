/// Strips query string so rotating SAS tokens map to one stable cache key.
String stableCacheKey(String url) {
  final u = Uri.tryParse(url);
  if (u == null) return url;
  return u.replace(query: '').toString();
}
