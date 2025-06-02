# Hayvan Takip Uygulaması

Bu uygulama, evcil hayvanlarınızın bilgilerini, fotoğraflarını ve sağlık durumlarını takip etmenizi sağlayan bir Flutter uygulamasıdır.

##  Teknolojiler

- **Flutter SDK**: >=3.2.3
- **Dart SDK**: >=3.2.3 <4.0.0
- **Provider**: ^6.1.1 (State Management)
- **SQLite**: ^2.3.0 (Yerel Veritabanı)
- **Image Picker**: ^1.0.7 (Fotoğraf Seçici)
- **Path Provider**: ^2.1.2 (Dosya Yolu Yönetimi)
- **UUID**: ^4.2.1 (Benzersiz Kimlik Oluşturucu)
- **Intl**: ^0.18.1 (Uluslararasılaştırma)

##  Proje Yapısı

Proje, MVVM (Model-View-ViewModel) mimari desenini kullanmaktadır:

```
lib/
├── models/         # Veri modelleri
├── views/          # UI bileşenleri
├── viewmodels/     # İş mantığı ve durum yönetimi
├── services/       # Servis katmanı (veritabanı, depolama vb.)
└── utils/          # Yardımcı fonksiyonlar ve sabitler
```

###  Ana Bileşenler

1. **Models**
   - Veri modelleri (Pet, PetPhoto vb.)
   - Veritabanı şemaları

2. **Views**
   - Ekranlar ve widget'lar
   - Kullanıcı arayüzü bileşenleri
   - Galeri, detay sayfaları vb.

3. **ViewModels**
   - İş mantığı yönetimi
   - Provider ile durum yönetimi
   - Veri işleme ve dönüştürme

4. **Services**
   - Yerel depolama servisi
   - Veritabanı işlemleri
   - Dosya sistemi işlemleri

##  Özellikler

- Evcil hayvan profil yönetimi
- Fotoğraf galerisi
- Sağlık takibi
- Yerel veritabanı desteği
- Fotoğraf ekleme ve silme
- Detaylı hayvan bilgileri

##  Kurulum

1. Flutter SDK'yı yükleyin
2. Projeyi klonlayın
3. Bağımlılıkları yükleyin:
   ```bash
   flutter pub get
   ```
4. Uygulamayı çalıştırın:
   ```bash
   flutter run
   ```

   ###  Ekran Görüntüleri
https://github.com/user-attachments/assets/871d9e31-560c-49f7-9d3a-8218ad2780a6


   
