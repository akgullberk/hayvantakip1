import '../../models/meal_tracking_model.dart';

String yemekTuruToString(YemekTuru tur) {
  switch (tur) {
    case YemekTuru.kuruMama:
      return 'Kuru Mama';
    case YemekTuru.yasMama:
      return 'Yaş Mama';
    case YemekTuru.evYemegi:
      return 'Ev Yemeği';
    case YemekTuru.diger:
      return 'Diğer';
  }
}

String yemekSaatiToString(YemekSaati saat) {
  switch (saat) {
    case YemekSaati.sabah:
      return 'Sabah';
    case YemekSaati.ogle:
      return 'Öğle';
    case YemekSaati.aksam:
      return 'Akşam';
  }
} 