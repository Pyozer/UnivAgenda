class Licence {
  final String library;
  final String author;
  final String license;
  final String? url;

  const Licence(
    this.library,
    this.author, {
    this.license = "",
    this.url,
  });
}
