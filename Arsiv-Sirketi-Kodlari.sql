CREATE DATABASE ArsivSirketi; 

USE ArsivSirketi;

-- Çalışanlar için bir tablo oluşturur. 
CREATE TABLE tCalisanlar (
    CalisanID INT IDENTITY(1,1) NOT NULL PRIMARY KEY, -- Otomatik artan benzersiz kimlik.
    AdSoyad NVARCHAR(50) NOT NULL, -- Çalışanın adı ve soyadı.
    DogumTarihi DATE NULL, -- Çalışanın doğum tarihi.
    Telefon VARCHAR(15) UNIQUE NULL, -- Benzersiz telefon numarası.
    CHECK (DogumTarihi <= GETDATE()) -- Doğum tarihi bugünden ileri olamaz.
);

-- Departman bilgilerini tutar. Her departmanın bir kimlik numarası (DepartmanID) ve adı vardır. 
-- Departmandaki çalışan sayısı varsayılan olarak 0'dır.
CREATE TABLE tDepartmanlar (
    DepartmanID INT IDENTITY(1,1) NOT NULL PRIMARY KEY, -- Otomatik artan benzersiz kimlik.
    Adi NVARCHAR(50) NOT NULL, -- Departman adı.
    CalisanSayisi INT NOT NULL DEFAULT 0 -- Varsayılan çalışan sayısı.
);

-- Şirket bilgilerini tutar. Şirket adı, adresi ve benzersiz e-posta adresi içerir. 
-- E-posta adresi doğru formatta olmalıdır.
CREATE TABLE tSirketler (
    SirketID INT IDENTITY(1,1) NOT NULL PRIMARY KEY, -- Otomatik artan benzersiz kimlik.
    Adi NVARCHAR(50) NOT NULL, -- Şirket adı.
    Adres NVARCHAR(255) NOT NULL, -- Şirket adresi.
    Email NVARCHAR(100) NOT NULL UNIQUE, -- Benzersiz e-posta adresi.
    CHECK (Email LIKE '%@%.%') -- Geçerli bir e-posta formatı kontrolü.
);

-- Depo bilgilerini tutar. Her deponun bir adı ve adresi vardır.
CREATE TABLE tDepolar (
    DepoID INT IDENTITY(1,1) NOT NULL PRIMARY KEY, -- Otomatik artan benzersiz kimlik.
    Adi NVARCHAR(50) NOT NULL, -- Depo adı.
    Adres NVARCHAR(255) NOT NULL -- Depo adresi.
);

-- Koli bilgilerini tutar. Depo numarası ve raf numarası benzersizdir.
-- Koli oluşturma tarihi otomatik olarak bugünün tarihiyle doldurulur.
CREATE TABLE tKoliler (
    KoliID INT IDENTITY(1,1) NOT NULL PRIMARY KEY, -- Otomatik artan benzersiz kimlik.
    RafNumarasi INT NOT NULL DEFAULT 0, -- Raf numarası.
    OlusturmaTarihi DATE NOT NULL DEFAULT GETDATE(), -- Koli oluşturma tarihi.
    DepoID INT NOT NULL, -- Depoya ait kimlik numarası.
    FOREIGN KEY (DepoID) REFERENCES tDepolar(DepoID), -- Depolar tablosuna yabancı anahtar bağlantısı.
    UNIQUE (DepoID, RafNumarasi) -- Aynı depoda aynı raf numarası olamaz.
);

-- Dosya bilgilerini tutar. Dosyanın oluşturma tarihi otomatik atanır.
-- Her dosya bir koliye ve bir şirkete bağlıdır.
CREATE TABLE tDosyalar (
    DosyaID INT IDENTITY(1,1) NOT NULL PRIMARY KEY, -- Otomatik artan benzersiz kimlik.
    OlusturmaTarihi DATE NOT NULL DEFAULT GETDATE(), -- Dosya oluşturma tarihi.
    SirketID INT NOT NULL, -- Dosyanın ait olduğu şirketin kimlik numarası.
    KoliID INT NOT NULL, -- Dosyanın saklandığı kolinin kimlik numarası.
    FOREIGN KEY (SirketID) REFERENCES tSirketler(SirketID), -- Şirketler tablosuna yabancı anahtar bağlantısı.
    FOREIGN KEY (KoliID) REFERENCES tKoliler(KoliID) -- Koliler tablosuna yabancı anahtar bağlantısı.
);

-- Gider bilgilerini tutar. Kategori, ürün adı, miktar ve birim fiyat gibi bilgiler içerir.
-- Toplam tutar otomatik hesaplanır.
CREATE TABLE tGiderler (
    GiderID INT IDENTITY(1,1) NOT NULL PRIMARY KEY, -- Otomatik artan benzersiz kimlik.
    GiderKategorisi NVARCHAR(63) NOT NULL, -- Gider kategorisi (ör. Dosya, Koli).
    UrunAdi NVARCHAR(63) NULL, -- Ürün adı.
    Miktar INT NULL, -- Alınan ürün miktarı.
    BirimFiyat DECIMAL(10,2) NULL, -- Ürün birim fiyatı.
    ToplamTutar AS (Miktar * BirimFiyat), -- Hesaplanan toplam tutar.
    Tarih DATE NOT NULL DEFAULT GETDATE(), -- Giderin tarihi.
    CHECK (Miktar >= 0), -- Miktar negatif olamaz.
    CHECK (BirimFiyat >= 0 OR BirimFiyat IS NULL) -- Birim fiyat negatif olamaz.
);

-- Sipariş bilgilerini tutar. Sipariş tarihi, teslim tarihi ve sipariş edilen ürün bilgilerini içerir.
-- Toplam tutar otomatik hesaplanır.
CREATE TABLE tSiparisler (
    SiparisID INT IDENTITY(1,1) NOT NULL PRIMARY KEY, -- Otomatik artan benzersiz kimlik.
    SiparisTarihi DATE NOT NULL DEFAULT GETDATE(), -- Sipariş tarihi.
    TeslimTarihi DATE NULL, -- Siparişin teslim tarihi.
    UrunTipi NVARCHAR(15) NOT NULL, -- Ürün tipi (ör. Dosya, Koli).
    Miktar INT NOT NULL DEFAULT 1, -- Sipariş miktarı.
    BirimFiyat DECIMAL(10,2) NOT NULL, -- Birim fiyat.
    ToplamTutar AS (Miktar * BirimFiyat), -- Hesaplanan toplam tutar.
    SirketID INT NOT NULL, -- Sipariş veren şirketin kimlik numarası.
    FOREIGN KEY (SirketID) REFERENCES tSirketler(SirketID), -- Şirketler tablosuna yabancı anahtar bağlantısı.
    CHECK (TeslimTarihi IS NULL OR TeslimTarihi >= SiparisTarihi) -- Teslim tarihi sipariş tarihinden önce olamaz.
);

-- Gelir bilgilerini tutar. Gelir kategorisi, ürün tipi, miktar ve birim fiyat içerir.
-- Toplam gelir otomatik hesaplanır.
CREATE TABLE tGelirler (
    GelirID INT IDENTITY(1,1) NOT NULL PRIMARY KEY, -- Otomatik artan benzersiz kimlik.
    GelirKategorisi NVARCHAR(63) NOT NULL, -- Gelir kategorisi (ör. Dosya Saklama, Koli Gönderim).
    UrunTipi NVARCHAR(15) NULL, -- Ürün tipi (Dosya veya Koli).
    Miktar INT NULL, -- İşlemde yer alan miktar.
    BirimFiyat DECIMAL(10,2) NULL, -- Ürün başına gelir.
    ToplamGelir AS (Miktar * BirimFiyat), -- Hesaplanan toplam gelir.
    Tarih DATE NOT NULL DEFAULT GETDATE(), -- Gelir tarihi.
    CHECK (Miktar >= 0), -- Miktar negatif olamaz.
    CHECK (BirimFiyat >= 0 OR BirimFiyat IS NULL) -- Birim fiyat negatif olamaz.
);

-- Araçlar için bir tablo oluşturur. Araç plakası benzersizdir ve kapasite belirtilir.
CREATE TABLE tAraclar (
    AracID INT IDENTITY(1,1) NOT NULL PRIMARY KEY, -- Otomatik artan benzersiz kimlik.
    Plaka VARCHAR(15) NOT NULL UNIQUE, -- Araç plakası.
    Kapasite INT NOT NULL DEFAULT 100, -- Araç kapasitesi.
    CHECK (Kapasite > 0) -- Kapasite 0'dan küçük olamaz.
);

-- Çalışanların sistem erişim bilgilerini tutar. Erişim durumu 'AKTIF' veya 'PASIF' olabilir.
-- Çalışan ve şirket bilgileri yabancı anahtar olarak eklenmiştir.
CREATE TABLE tSistemErisimleri (
    ErisimID INT IDENTITY(1,1) NOT NULL PRIMARY KEY, -- Otomatik artan benzersiz kimlik.
    ErisimTarihi DATE NOT NULL DEFAULT GETDATE(), -- Erişim tarihi.
    Durum VARCHAR(15) NOT NULL DEFAULT 'AKTIF', -- Erişim durumu (AKTIF veya PASIF).
    CalisanID INT NOT NULL, -- Çalışanın kimlik numarası.
    SirketID INT NOT NULL, -- Şirketin kimlik numarası.
    FOREIGN KEY (CalisanID) REFERENCES tCalisanlar(CalisanID), -- Çalışanlar tablosuna yabancı anahtar bağlantısı.
    FOREIGN KEY (SirketID) REFERENCES tSirketler(SirketID), -- Şirketler tablosuna yabancı anahtar bağlantısı.
    CHECK (Durum IN ('AKTIF', 'PASIF')) -- Erişim durumu sadece 'AKTIF' veya 'PASIF' olabilir.
);

-- VİEW

--1 Her Şirketin Sipariş Özeti: Bu view, her şirketin verdiği sipariş sayısını ve toplam sipariş tutarını özetleyecek.
CREATE VIEW vwSirketSiparisOzet AS
SELECT 
    s.Adi AS SirketAdi,
    COUNT(sp.SiparisID) AS SiparisSayisi,
    SUM(sp.ToplamTutar) AS ToplamSiparisTutari
FROM 
    tSirketler s
LEFT JOIN 
    tSiparisler sp ON s.SirketID = sp.SirketID
GROUP BY 
    s.Adi;

--2Depolardaki Kolilerin Özeti: Bu view, her depo için koli sayısını ve son koli oluşturma tarihini özetleyecek.
CREATE VIEW vwDepoKoliOzet AS
SELECT 
    d.Adi AS DepoAdi,
    COUNT(k.KoliID) AS ToplamKoliSayisi,
    MAX(k.OlusturmaTarihi) AS SonKoliTarihi
FROM 
    tDepolar d
LEFT JOIN 
    tKoliler k ON d.DepoID = k.DepoID
GROUP BY 
    d.Adi;

--3 Depolardaki Dosya Özeti Bu view, her depo için toplam dosya sayısını ve o depodaki en eski dosyanın oluşturulma tarihini gösterir.
CREATE VIEW vwDepoDosyaOzet AS
SELECT 
    d.Adi AS DepoAdi,
    COUNT(f.DosyaID) AS ToplamDosyaSayisi,
    MIN(f.OlusturmaTarihi) AS EnEskiDosyaTarihi
FROM 
    tDepolar d
LEFT JOIN 
    tKoliler k ON d.DepoID = k.DepoID
LEFT JOIN 
    tDosyalar f ON k.KoliID = f.KoliID
GROUP BY 
    d.Adi;

	SELECT * FROM vwDepoDosyaOzet;
--4 Sipariş Durumu Raporu: Bu view, her siparişin durumunu (bekliyor veya tamamlandı) gösterecek.
CREATE VIEW vwSiparisDurumu AS
SELECT 
    sp.SiparisID,
    s.Adi AS SirketAdi,
    sp.SiparisTarihi,
    sp.TeslimTarihi,
    CASE 
        WHEN sp.TeslimTarihi IS NULL THEN 'Bekliyor'
        ELSE 'Tamamlandı'
    END AS Durum
FROM 
    tSiparisler sp
INNER JOIN 
    tSirketler s ON sp.SirketID = s.SirketID;

--5 Aktif Çalışanların Listesi: Bu view, telefon numarası olan çalışanları listeleyecek.
CREATE VIEW vwAktifCalisanlar AS
SELECT 
    CalisanID, 
    AdSoyad, 
    Telefon 
FROM 
    tCalisanlar
WHERE 
    Telefon IS NOT NULL;

--İNDEXLER
CREATE UNIQUE INDEX IX_tCalisanlar_Telefon ON tCalisanlar(Telefon);


CREATE INDEX IX_tDepartmanlar_Adi ON tDepartmanlar(Adi);

CREATE UNIQUE INDEX IX_tSirketler_Email ON tSirketler(Email);
CREATE INDEX IX_tSirketler_Adi ON tSirketler(Adi);

CREATE INDEX IX_tDepolar_Adi ON tDepolar(Adi);

CREATE INDEX IX_tKoliler_RafNumarasi ON tKoliler(RafNumarasi);
CREATE INDEX IX_tKoliler_DepoID ON tKoliler(DepoID);

-- Çalışanlar tablosuna veri ekleme
INSERT INTO tCalisanlar (AdSoyad, DogumTarihi, Telefon) VALUES
('Ali Yılmaz', '1985-06-15', '05321234567'),
('Mehmet Özdemir', '1990-11-22', '05329876543'),
('Ayşe Demir', '1982-03-09', '05337654321'),
('Fatma Arslan', '1995-08-14', '05345543321'),
('Ahmet Kaya', '1988-01-25', '05351234543');

-- Departmanlar tablosuna veri ekleme
INSERT INTO tDepartmanlar (Adi, CalisanSayisi) VALUES
('Muhasebe', 3),
('IT', 2),
('Pazarlama', 4),
('İnsan Kaynakları', 1),
('Lojistik', 2);

-- Şirketler tablosuna veri ekleme
INSERT INTO tSirketler (Adi, Adres, Email) VALUES
('ABC Ltd.', 'İstanbul, Beyoğlu', 'contact@abcltd.com'),
('XYZ AŞ', 'Ankara, Çankaya', 'info@xyz.com'),
('MNO Şirketi', 'İzmir, Karşıyaka', 'sales@mno.com'),
('DEF Gıda', 'Bursa, Osmangazi', 'support@defgida.com'),
('GHI Otomotiv', 'Antalya, Konyaaltı', 'service@ghi.com');

-- Depolar tablosuna veri ekleme
INSERT INTO tDepolar (Adi, Adres) VALUES
('Depo A', 'İstanbul, Üsküdar'),
('Depo B', 'Ankara, Yenimahalle'),
('Depo C', 'İzmir, Konak'),
('Depo D', 'Bursa, Mudanya'),
('Depo E', 'Antalya, Lara');

-- Koliler tablosuna veri ekleme
INSERT INTO tKoliler (RafNumarasi, OlusturmaTarihi, DepoID) VALUES
(1, '2024-01-10', 1),
(2, '2024-01-11', 2),
(3, '2024-01-12', 3),
(4, '2024-01-13', 4),
(5, '2024-01-14', 5);

-- Dosyalar tablosuna veri ekleme
INSERT INTO tDosyalar (OlusturmaTarihi, SirketID, KoliID) VALUES
('2024-01-15', 1, 1),
('2024-02-10', 2, 2),
('2024-03-05', 3, 3),
('2024-04-18', 4, 4),
('2024-05-25', 5, 5);

-- Giderler tablosuna veri ekleme
INSERT INTO tGiderler (GiderKategorisi, UrunAdi, Miktar, BirimFiyat, Tarih) VALUES
('Koli', 'Büyük Koli', 10, 20.00, '2024-01-01'),
('Kırtasiye', 'Kağıt', 200, 0.50, '2024-02-01'),
('Depo', 'Raf', 50, 25.00, '2024-03-01'),
('Taşıma', 'Kargo', 5, 30.00, '2024-04-01'),
('Koli', 'Küçük Koli', 20, 15.00, '2024-05-01');

-- Siparişler tablosuna veri ekleme
INSERT INTO tSiparisler (SiparisTarihi, TeslimTarihi, UrunTipi, Miktar, BirimFiyat, SirketID) VALUES
('2024-01-10', '2024-01-12', 'Dosya', 100, 5.00, 1),
('2024-02-15', '2024-02-18', 'Koli', 50, 15.00, 2),
('2024-03-20', '2024-03-25', 'Dosya', 200, 3.00, 3),
('2024-04-01', '2024-04-05', 'Koli', 30, 20.00, 4),
('2024-05-10', '2024-05-12', 'Koli', 40, 10.00, 5);

-- Gelirler tablosuna veri ekleme
INSERT INTO tGelirler (GelirKategorisi, UrunTipi, Miktar, BirimFiyat, Tarih) VALUES
('Depolama', 'Koli', 50, 5.00, '2024-01-01'),
('Taşıma', 'Dosya', 100, 3.00, '2024-02-01'),
('Kiralama', 'Koli', 20, 8.00, '2024-03-01'),
('Depolama', 'Dosya', 150, 2.50, '2024-04-01'),
('Taşıma', 'Koli', 30, 6.00, '2024-05-01');

-- Araçlar tablosuna veri ekleme
INSERT INTO tAraclar (Plaka, Kapasite) VALUES
('34ABC123', 100),
('35DEF456', 80),
('36GHI789', 120),
('37JKL012', 150),
('38MNO345', 90);

-- Sistem Erişimleri tablosuna veri ekleme
INSERT INTO tSistemErisimleri (ErisimTarihi, Durum, CalisanID, SirketID) VALUES
('2024-01-01', 'AKTIF', 1, 1),
('2024-02-01', 'AKTIF', 2, 2),
('2024-03-01', 'PASIF', 3, 3),
('2024-04-01', 'AKTIF', 4, 4),
('2024-05-01', 'AKTIF', 5, 5);

-- SORU: Oluşturmuş olduğunuz veritabanında esnafın günlük karlarını nasıl listeleyeceğini gösteren sorguyu yazınız.
SELECT 
    g.Tarih AS GunTarihi,  -- Günün tarihi
    SUM(g.ToplamGelir) - SUM(d.ToplamTutar) AS GunlukKar -- Gelir ve gider farkı
FROM 
    tGelirler g
LEFT JOIN 
    tGiderler d ON g.Tarih = d.Tarih -- Aynı gün gelir ve gider eşleştirilir
GROUP BY 
    g.Tarih -- Gün bazında gruplanır
ORDER BY 
    GunTarihi DESC; -- Son gün en üstte

--SORU: Oluşturmuş olduğunuz veritabanında esnafın ortalama aylık karlarını belirleyin. Bu değerin altındaki aylara ait satışları nasıl listeleyeceğini gösteren sorguyu yazınız.
SELECT 
    YEAR(g.Tarih) AS Yil,
    MONTH(g.Tarih) AS Ay,
    SUM(g.ToplamGelir) - SUM(d.ToplamTutar) AS AylikKar
FROM 
    tGelirler g
LEFT JOIN 
    tGiderler d ON YEAR(g.Tarih) = YEAR(d.Tarih) AND MONTH(g.Tarih) = MONTH(d.Tarih)
GROUP BY 
    YEAR(g.Tarih), MONTH(g.Tarih)
HAVING 
    SUM(g.ToplamGelir) - SUM(d.ToplamTutar) < 
    ( 
        -- Ortalama karı dışarıda bir kere hesapla
        SELECT AVG(AylikKar) 
        FROM (
            SELECT 
                SUM(g2.ToplamGelir) - SUM(d2.ToplamTutar) AS AylikKar
            FROM 
                tGelirler g2
            LEFT JOIN 
                tGiderler d2 ON YEAR(g2.Tarih) = YEAR(d2.Tarih) AND MONTH(g2.Tarih) = MONTH(d2.Tarih)
            GROUP BY 
                YEAR(g2.Tarih), MONTH(g2.Tarih)
        ) AS OrtKar
    )
ORDER BY 
    Yil DESC, Ay DESC;

--SORU: . Oluşturmuş olduğunuz veritabanında esnafın zarar ettiği ürünleri nasıl listeleyeceğini gösteren sorguyu yazınız.
  SELECT 
    g.GiderKategorisi AS UrunTipi, 
    SUM(g.Miktar * g.BirimFiyat) AS GiderToplam, 
    SUM(gl.Miktar * gl.BirimFiyat) AS GelirToplam
FROM 
    tGiderler g
JOIN 
    tGelirler gl ON g.GiderKategorisi = gl.GelirKategorisi
GROUP BY 
    g.GiderKategorisi
HAVING 
    SUM(g.Miktar * g.BirimFiyat) > SUM(gl.Miktar * gl.BirimFiyat);

--SORU: . Oluşturmuş olduğunuz veritabanında esnafın en çok hangi ürünü sattığını listeleyeceğini gösteren sorguyu yazınız
SELECT TOP 1 
    UrunTipi, 
    SUM(Miktar) AS ToplamSatis
FROM 
    tGelirler
GROUP BY 
    UrunTipi
ORDER BY 
    ToplamSatis DESC;

-- PROCEDURLER

--1. Çalışan Ekleme Prosedürü Bu prosedür, yeni bir çalışanı tCalisanlar tablosuna ekler.
CREATE PROCEDURE spCalisanEkle
    @AdSoyad NVARCHAR(50),
    @DogumTarihi DATE,
    @Telefon VARCHAR(15)
AS
BEGIN
    INSERT INTO tCalisanlar (AdSoyad, DogumTarihi, Telefon)
    VALUES (@AdSoyad, @DogumTarihi, @Telefon);
END;

EXEC spCalisanEkle @AdSoyad = 'Ali Yılmaz', @DogumTarihi = '1985-03-15', @Telefon = '5551234567';

-- 2. Şirket Bilgisi Güncelleme Prosedürü Bu prosedür, bir şirketin bilgilerini günceller.
CREATE PROCEDURE spSirketGuncelle
    @SirketID INT,
    @YeniAdi NVARCHAR(50),
    @YeniAdres NVARCHAR(255),
    @YeniEmail NVARCHAR(100)
AS
BEGIN
    UPDATE tSirketler
    SET Adi = @YeniAdi, Adres = @YeniAdres, Email = @YeniEmail
    WHERE SirketID = @SirketID;
END;

EXEC spSirketGuncelle @SirketID = 1, @YeniAdi = 'Tech Solutions', @YeniAdres = 'Yeni Adres, No:2', @YeniEmail = 'tech@solutions.com';

-- 3. Depo ve Koli Ekleme Prosedürü Bu prosedür, bir depo ve koliyi aynı anda ekler.
CREATE PROCEDURE spDepoKoliEkle
    @DepoAdi NVARCHAR(50),
    @DepoAdres NVARCHAR(255),
    @RafNumarasi INT
AS
BEGIN
    -- Depo ekle
    INSERT INTO tDepolar (Adi, Adres)
    VALUES (@DepoAdi, @DepoAdres);
    -- Depo ekleme işleminden sonra DepoID'yi al
    DECLARE @DepoID INT;
    SET @DepoID = SCOPE_IDENTITY();
    -- Koli ekle
    INSERT INTO tKoliler (RafNumarasi, DepoID)
    VALUES (@RafNumarasi, @DepoID);
END;

EXEC spDepoKoliEkle @DepoAdi = 'Ana Depo', @DepoAdres = 'Ana Cadde No:1', @RafNumarasi = 5;

--4 Belirli Bir Şirketin Sipariş Geçmişini Listeleme Prosedürü Bu prosedür, bir şirketin kimliğini (SirketID) alır ve o şirkete ait tüm siparişleri sıralı bir şekilde listeler.
CREATE PROCEDURE spSirketSiparisleriListele
    @SirketID INT  -- Şirket kimliği
AS
BEGIN
    -- Şirketin siparişlerini sıralı bir şekilde getirir.
    SELECT 
        SiparisID, 
        SiparisTarihi, 
        TeslimTarihi, 
        UrunTipi, 
        Miktar, 
        BirimFiyat, 
        (Miktar * BirimFiyat) AS ToplamTutar
    FROM 
        tSiparisler
    WHERE 
        SirketID = @SirketID
    ORDER BY 
        SiparisTarihi DESC; -- En son sipariş en üstte listelenir.

    PRINT 'Şirketin siparişleri başarıyla listelendi.';
END;

EXEC spSirketSiparisleriListele @SirketID = 2;
--5. Depoya Yeni Koli Ekleme Prosedürü Amacımız, belirli bir depoya yeni bir koli eklemek. Bu prosedür, bir depo ID'si ve raf numarası parametreleri alacak ve verilen bilgilere göre yeni bir koli oluşturacak.
CREATE PROCEDURE spKoliEkle
    @DepoID INT,  -- Depo kimliği
    @RafNumarasi INT  -- Raf numarası
AS
BEGIN
    -- Aynı depo ve aynı raf numarası için koli olup olmadığını kontrol ederiz.
    IF EXISTS (SELECT 1 FROM tKoliler WHERE DepoID = @DepoID AND RafNumarasi = @RafNumarasi)
    BEGIN
        PRINT 'Bu depoda ve raf numarasında zaten bir koli bulunmaktadır.';
    END
    ELSE
    BEGIN
        -- Yeni koli oluşturulur.
        INSERT INTO tKoliler (DepoID, RafNumarasi)
        VALUES (@DepoID, @RafNumarasi);

        PRINT 'Yeni koli başarıyla eklendi.';
    END
END;

EXEC spKoliEkle @DepoID = 3, @RafNumarasi = 5;

-- tSistemErisimleri Tablosu'ndan Veri Silme
DELETE FROM tSistemErisimleri;

-- tAraclar Tablosu'ndan Veri Silme
DELETE FROM tAraclar;

-- tGelirler Tablosu'ndan Veri Silme
DELETE FROM tGelirler;

-- tSiparisler Tablosu'ndan Veri Silme
DELETE FROM tSiparisler;

-- tGiderler Tablosu'ndan Veri Silme
DELETE FROM tGiderler;

-- tDosyalar Tablosu'ndan Veri Silme
DELETE FROM tDosyalar;

-- tKoliler Tablosu'ndan Veri Silme
DELETE FROM tKoliler;

-- tDepolar Tablosu'ndan Veri Silme
DELETE FROM tDepolar;

-- tSirketler Tablosu'ndan Veri Silme
DELETE FROM tSirketler;

-- tDepartmanlar Tablosu'ndan Veri Silme
DELETE FROM tDepartmanlar;

-- tCalisanlar Tablosu'ndan Veri Silme
DELETE FROM tCalisanlar;
