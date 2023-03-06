class Shop {
  String id;
  String name;

  Shop({this.id, this.name});

  Shop.withId({this.id, this.name});

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    map['name'] = name;
    return map;
  }

  factory Shop.fromMap(Map<String, dynamic> map) {
    return Shop.withId(
      id: map['id'],
      name: map['name'],
    );
  }
}
