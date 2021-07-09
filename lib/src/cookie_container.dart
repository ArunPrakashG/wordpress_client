class CookieContainer {
  List<Cookie> _container;

  CookieContainer() {
    _container = [];
  }

  void addCookies(Cookie cookie) {
    _container.add(cookie);
  }

  void removeCookies(String key) {
    if (_container.isEmpty) {
      return;
    }

    _container.removeWhere((element) => element.key == key);
  }
}

class Cookie {
  String value;
  String key;

  Cookie(this.key, this.value);
}
