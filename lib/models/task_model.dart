class Task {
  String id;
  String title;
  DateTime date;
  String price;
  String status; // 0 - Incomplete, 1 - Complete
  String shop;
  String tprice;
  String numberSell;
  String giamgia = "0";

  Task(
      {this.title,
      this.date,
      this.price,
      this.status,
      this.id,
      this.shop,
      this.tprice,
      this.numberSell,
      this.giamgia});

  Task.withId(
      {this.id,
      this.title,
      this.date,
      this.price,
      this.status,
      this.shop,
      this.tprice,
      this.numberSell,
      this.giamgia});

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    map['title'] = title;
    map['date'] = date.toIso8601String();
    map['price'] = price;
    map['status'] = status;
    map['shop'] = shop;
    map['tprice'] = tprice;
    map['numberSell'] = numberSell;
    map['giamgia'] = giamgia;
    return map;
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task.withId(
      id: map['id'],
      title: map['title'],
      date: DateTime.parse(map['date']),
      price: map['price'],
      status: map['status'],
      shop: map['shop'],
      tprice: map['tprice'],
      giamgia: map['giamgia'],
      numberSell: map['numberSell'],
    );
  }
}
