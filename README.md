# BengkelKu Mobile (Flutter)

Aplikasi mobile **bengkel motor** untuk pelanggan: beranda (banner, layanan, produk unggulan), katalog sparepart + detail, booking servis, keranjang & checkout, riwayat booking & pesanan, profil. Desain modern, tema **biru + aksen oranye**, font Poppins. Terhubung ke [api-bengkel](https://github.com/marfino3028/api-bengkel) (Laravel).

Bagian dari ekosistem **BengkelKu** (api · cms · web · mobile).

---

## 🚀 Menjalankan

```bash
flutter pub get

# Emulator Android (host loopback = 10.0.2.2) — default sudah ke sana:
flutter run

# Atau arahkan ke API mana pun via --dart-define:
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
```

> **Base URL API** diatur lewat `--dart-define=API_BASE_URL=...` (lihat `lib/config.dart`).
> - Emulator Android → `http://10.0.2.2:8000/api`
> - iOS simulator / web → `http://localhost:8000/api`
> - HP fisik → `http://<IP-komputer>:8000/api`
> - Produksi → `https://api-bengkel-production.up.railway.app/api` atau `https://api.domainmu.com/api`

**Login** memakai akun seed API: `budi@mail.com` / `password` (atau daftar akun baru di app).

---

## 📦 Build Rilis (APK / Play Store)

```bash
# APK (bagikan langsung)
flutter build apk --release --dart-define=API_BASE_URL=https://api.domainmu.com/api

# App Bundle (upload Play Store)
flutter build appbundle --release --dart-define=API_BASE_URL=https://api.domainmu.com/api
```

APK ada di `build/app/outputs/flutter-apk/app-release.apk`.

> Untuk rilis Play Store, siapkan signing key (`key.properties` + keystore) sesuai dokumentasi Flutter. Pastikan `API_BASE_URL` menunjuk ke API produksi (HTTPS).

---

## 🧱 Struktur
```
lib/
  config.dart            # base URL API (dart-define)
  theme.dart             # warna & tema (biru + oranye, Poppins)
  models.dart            # model + parsing JSON
  services/api_client.dart   # Dio + token (shared_preferences)
  providers/             # auth & cart (provider/ChangeNotifier)
  utils/formatter.dart   # rupiah & tanggal
  widgets/               # product card, service card, dll.
  screens/               # splash, auth, home, catalog, services, booking, cart, activity, profile
```

## ✅ Kualitas
`flutter analyze` → **0 issue**. `flutter test` → lulus.

## 🛠️ Stack
Flutter 3.38 · Dio · Provider · google_fonts · cached_network_image · shared_preferences.
