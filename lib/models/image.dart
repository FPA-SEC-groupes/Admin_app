class ImageModel {
  String id;
  String fileName;
  String fileType;
  String data;

  ImageModel({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.data,
  });


  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'],
      fileName: json['fileName'],
      fileType: json['fileType'],
      data: json['data'],

    );
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    'fileName': fileName,
    'fileType': fileType,
    'data': data,

  };
}



