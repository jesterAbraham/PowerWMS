// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) {
  return Product(
    uid: json['uid'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    ean: json['ean'] as String,
    productGroupName: json['productGroupName'] as String,
    productGroupBatchField: json['productGroupBatchField'] as int,
    productGroupProductionDateField:
        json['productGroupProductionDateField'] as int,
    productGroupExpirationDateField:
        json['productGroupExpirationDateField'] as int,
    unit: json['unit'] as String,
    status: json['status'] as int,
    stock: json['stock'] as num,
    hasImage: json['hasImage'] as bool,
    packagings: (json['packagings'] as List<dynamic>)
        .map((e) => Packaging.fromJson(e as Map<String, dynamic>))
        .toList(),
    id: json['id'] as int,
    isNew: json['isNew'] as bool,
  );
}

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'description': instance.description,
      'ean': instance.ean,
      'productGroupName': instance.productGroupName,
      'productGroupBatchField': instance.productGroupBatchField,
      'productGroupProductionDateField':
          instance.productGroupProductionDateField,
      'productGroupExpirationDateField':
          instance.productGroupExpirationDateField,
      'unit': instance.unit,
      'status': instance.status,
      'stock': instance.stock,
      'hasImage': instance.hasImage,
      'packagings': instance.packagings,
      'id': instance.id,
      'isNew': instance.isNew,
    };