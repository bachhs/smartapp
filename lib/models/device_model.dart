class Task {
  String id;
  String name;
  String shop;

  Task({
    this.name,
    this.id,
    this.shop,
  });

  Task.withId({
    this.id,
    this.name,
    this.shop,
  });

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    map['name'] = name;
    map['shop'] = shop;
    return map;
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task.withId(
      id: map['id'],
      name: map['name'],
      shop: map['shop'],
    );
  }
}
