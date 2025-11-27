# Arşiv ve Lojistik Yönetim Sistemi (ArsivSirketi)

Bu proje, MS SQL Server kullanılarak geliştirilmiş, kurumsal bir arşiv ve lojistik şirketinin tüm operasyonel süreçlerini yöneten kapsamlı bir veri tabanı çözümüdür.

### Proje Kapsamı
Bu sistem; depo yönetiminden personel takibine, gelir-gider analizinden sipariş süreçlerine kadar geniş bir yelpazeyi kapsar.

* **Depo & Stok Yönetimi:** Hangi dosyanın hangi kolide ve hangi rafta olduğu takip edilir.
* **Finansal Analiz:** Gelir ve Gider tabloları üzerinden günlük/aylık kar-zarar analizleri (Complex Queries) yapılır.
* **Prosedürler (Stored Procedures):** Yeni çalışan ekleme, şirket güncelleme gibi işlemler otomatize edilmiştir.
* **Görünümler (Views):** Yöneticiler için özet raporlar (Sipariş Durumu, Depo Doluluğu vb.) hazırlanmıştır.

### Proje İçeriği
* **Tablolar:** Çalışanlar, Şirketler, Depolar, Koliler, Dosyalar, Siparişler, Gelirler, Giderler...
* **İleri Seviye SQL:** Trigger mantığı, Computed Columns (Otomatik Hesaplanan Sütunlar), JOIN işlemleri ve Sub-Queries.
