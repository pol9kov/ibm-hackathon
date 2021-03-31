
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class IOT {
  IOT(this.timestamp, this.temperature, this.oxygen);

  @JsonKey(name: 'ts')
  final int timestamp;
  @JsonKey(name: 't')
  final int temperature;
  @JsonKey(name: 'o')
  final int oxygen;

//   factory IOT.fromJson(Map<String, dynamic> json) => _$IOTFromJson(json);
//
//   Map<String, dynamic> toJson() => _$IOTToJson(this);
//
//   IOT _$IOTFromJson(Map<String, dynamic> json) {
//   return IOT(
//     json['firstName'] as String,
//     json['lastName'] as String,
//     DateTime.parse(json['timestamp'] as String),
//     middleName: json['middleName'] as String?,
//     lastOrder: json['last-order'] == null
//         ? null
//         : DateTime.parse(json['last-order'] as String),
//     orders: (json['orders'] as List<dynamic>?)
//         ?.map((e) => Order.fromJson(e as Map<String, dynamic>))
//         .toList(),
//   );
// }
//
// Map<String, dynamic> _$PersonToJson(Person instance) {
//   final val = <String, dynamic>{
//     'firstName': instance.firstName,
//   };
//
//   void writeNotNull(String key, dynamic value) {
//     if (value != null) {
//       val[key] = value;
//     }
//   }
//
//   writeNotNull('middleName', instance.middleName);
//   val['lastName'] = instance.lastName;
//   val['date-of-birth'] = instance.dateOfBirth.toIso8601String();
//   val['last-order'] = instance.lastOrder?.toIso8601String();
//   val['orders'] = instance.orders;
//   return val;
}