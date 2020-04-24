class Tag {

  String tid; // tag id - autogenerated
  String name;
  String color; // hex (to be turned into instance of color later)

  Tag({this.tid, this.name, this.color}) : assert(tid != null);

  @override
  bool operator ==(other) {
    return other is Tag ? tid == other.tid : false;
  }

}