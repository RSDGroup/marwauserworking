import 'package:sixam_mart/data/model/response/zone_response_model.dart';

class AddressModel {
  int? id;
  String? addressType;
  String? contactPersonNumber;
  String? address;
  String? additionalAddress;
  String? latitude;
  String? longitude;
  int? zoneId;
  List<int>? zoneIds;
  String? method;
  String? contactPersonName;
  String? streetNumber;
  String? doorBell;
  String? house;
  String? floor;
  List<ZoneData>? zoneData;
  List<int>? areaIds;

  AddressModel(
      {this.id,
      this.addressType,
      this.contactPersonNumber,
      this.address,
      this.additionalAddress,
      this.latitude,
      this.longitude,
      this.zoneId,
      this.zoneIds,
      this.method,
      this.contactPersonName,
      this.streetNumber,
      this.doorBell,
      this.house,
      this.floor,
      this.zoneData,
      this.areaIds,
      });

  AddressModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    addressType = json['address_type'];
    contactPersonNumber = json['contact_person_number'];
    address = json['address'];
    additionalAddress = json['additional_address'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    zoneId = json['zone_id'];
    zoneIds = json['zone_ids']?.cast<int>();
    method = json['_method'];
    contactPersonName = json['contact_person_name'];
    streetNumber = json['road'];
    doorBell = json['doorBell'];
    house = json['house'];
    floor = json['floor'] ;
    if (json['zone_data'] != null) {
      zoneData = [];
      json['zone_data'].forEach((v) {
        zoneData!.add(ZoneData.fromJson(v));
      });
    }
    areaIds = json['area_ids']?.cast<int>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['address_type'] = addressType;
    data['contact_person_number'] = contactPersonNumber;
    data['address'] = address;
    data['additional_address'] = additionalAddress;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['zone_id'] = zoneId;
    data['zone_ids'] = zoneIds;
    data['_method'] = method;
    data['contact_person_name'] = contactPersonName;
    data['road'] = streetNumber;
    data['doorBell'] = doorBell;
    data['house'] = house;
    data['floor'] = floor;
    if (zoneData != null) {
      data['zone_data'] = zoneData!.map((v) => v.toJson()).toList();
    }
    data['area_ids'] = areaIds;
    return data;
  }
}
