import 'package:flutter/material.dart';

enum MedKitIcon {
  houseRounded,
  houseOutlined,
  directionsCar,
  plane,
  countryHouse,
  beach,
  child,
  elderlyWoman,
  elderlyMan,
  hiking,
  apartment,
  firstAid,
}

extension MedKitIconExtension on MedKitIcon {
  IconData getIconData() {
    switch (this) {
      case MedKitIcon.houseRounded:
        return Icons.house_rounded;
      case MedKitIcon.houseOutlined:
        return Icons.house_outlined;
      case MedKitIcon.directionsCar:
        return Icons.directions_car;
      case MedKitIcon.plane:
        return Icons.airplanemode_on;
      case MedKitIcon.countryHouse:
        return Icons.cottage_rounded;
      case MedKitIcon.beach:
        return Icons.beach_access;
      case MedKitIcon.child:
        return Icons.child_friendly;
      case MedKitIcon.elderlyWoman:
        return Icons.elderly_woman;
      case MedKitIcon.elderlyMan:
        return Icons.elderly;
      case MedKitIcon.hiking:
        return Icons.hiking;
      case MedKitIcon.apartment:
        return Icons.apartment;
      case MedKitIcon.firstAid:
        return Icons.medical_services;
      default:
        return Icons.medical_services;
    }
  }
}
