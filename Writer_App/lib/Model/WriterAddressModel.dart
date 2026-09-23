class Writeraddressmodel {
  final String? fullName;
  final String? mobileNumber;
  final String? pincode;
  final String? houseNo;
  final String? locality;
  final String? city;
  final String? state;
  final String? saveAs;

  Writeraddressmodel({
    this.fullName,
    this.mobileNumber,
    this.pincode,
    this.houseNo,
    this.locality,
    this.city,
    this.state,
    this.saveAs,
  });

  factory Writeraddressmodel.fromJson(Map<String, dynamic> json) {
    return Writeraddressmodel(
      fullName: json['fullName'],
      mobileNumber: json['mobileNumber'],
      pincode: json['pincode'],
      houseNo: json['houseNo'],
      locality: json['locality'],
      city: json['city'],
      state: json['state'],
      saveAs: json['saveAs'],
    );
  }


  @override
  String toString() {
    return 'Writeraddressmodel{fullName: $fullName, mobileNumber: $mobileNumber, pincode: $pincode, houseNo: $houseNo, locality: $locality, city: $city, state: $state, saveAs: $saveAs}';
  }

  Map<String, dynamic> toJson() {
    return {
      "fullName": fullName,
      "mobileNumber": mobileNumber,
      "pincode": pincode,
      "houseNo": houseNo,
      "locality": locality,
      "city": city,
      "state": state,
      "saveAs": saveAs,
    };
  }
}
