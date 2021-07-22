class BooksModel {
  String docId, imageURL, name, author, rating;

  BooksModel({this.docId, this.imageURL, this.name, this.author, this.rating});

  toMap() {
    Map<String, dynamic> map = Map();

    map['docId'] = docId;
    map['imageURL'] = imageURL;
    map['name'] = name;
    map['author'] = author;
    map['rating'] = rating;

    return map;
  }
}
