IF DB_ID('KonceptBarDB') IS NULL
    CREATE DATABASE KonceptBarDB;


GO
USE KonceptBarDB;


GO
-- =========================
-- 1. KREIRANJE ŠEME
-- =========================
IF NOT EXISTS (SELECT *
               FROM   sys.schemas
               WHERE  name = 'KonceptBar')
    BEGIN
        EXECUTE ('CREATE SCHEMA KonceptBar AUTHORIZATION dbo');
    END


GO
-- =========================
-- BRISANJE OBJEKATA
-- =========================
IF OBJECT_ID('KonceptBar.tr_AzuriranjeCeneStavke', 'TR') IS NOT NULL
    DROP TRIGGER KonceptBar.tr_AzuriranjeCeneStavke;


GO
IF OBJECT_ID('KonceptBar.tr_ProveraDatumaIsporuke', 'TR') IS NOT NULL
    DROP TRIGGER KonceptBar.tr_ProveraDatumaIsporuke;


GO
IF OBJECT_ID('KonceptBar.usp_DodajStavkuNarudzbine', 'P') IS NOT NULL
    DROP PROCEDURE KonceptBar.usp_DodajStavkuNarudzbine;


GO
IF OBJECT_ID('KonceptBar.usp_IzvestajKeteringNarudzbine', 'P') IS NOT NULL
    DROP PROCEDURE KonceptBar.usp_IzvestajKeteringNarudzbine;


GO
IF OBJECT_ID('KonceptBar.fn_KeteringNarudzbineKlijenta', 'IF') IS NOT NULL
    DROP FUNCTION KonceptBar.fn_KeteringNarudzbineKlijenta;


GO
IF OBJECT_ID('KonceptBar.fn_UkupnaVrednostNarudzbine', 'FN') IS NOT NULL
    DROP FUNCTION KonceptBar.fn_UkupnaVrednostNarudzbine;


GO
-- =========================
-- 2. BRISANJE TABELA
-- =========================
IF OBJECT_ID('KonceptBar.Ucestvuje', 'U') IS NOT NULL
    DROP TABLE KonceptBar.Ucestvuje;

IF OBJECT_ID('KonceptBar.Stavka_Narudzbine', 'U') IS NOT NULL
    DROP TABLE KonceptBar.Stavka_Narudzbine;

IF OBJECT_ID('KonceptBar.Ketering_Narudzbina', 'U') IS NOT NULL
    DROP TABLE KonceptBar.Ketering_Narudzbina;

IF OBJECT_ID('KonceptBar.Narudzbina', 'U') IS NOT NULL
    DROP TABLE KonceptBar.Narudzbina;

IF OBJECT_ID('KonceptBar.Eksterni_Dogadjaj', 'U') IS NOT NULL
    DROP TABLE KonceptBar.Eksterni_Dogadjaj;

IF OBJECT_ID('KonceptBar.Jelo', 'U') IS NOT NULL
    DROP TABLE KonceptBar.Jelo;

IF OBJECT_ID('KonceptBar.Pice', 'U') IS NOT NULL
    DROP TABLE KonceptBar.Pice;

IF OBJECT_ID('KonceptBar.Meni_Artikal', 'U') IS NOT NULL
    DROP TABLE KonceptBar.Meni_Artikal;

IF OBJECT_ID('KonceptBar.Artikal', 'U') IS NOT NULL
    DROP TABLE KonceptBar.Artikal;

IF OBJECT_ID('KonceptBar.Meni', 'U') IS NOT NULL
    DROP TABLE KonceptBar.Meni;

IF OBJECT_ID('KonceptBar.Dogadjaj', 'U') IS NOT NULL
    DROP TABLE KonceptBar.Dogadjaj;

IF OBJECT_ID('KonceptBar.Klijent', 'U') IS NOT NULL
    DROP TABLE KonceptBar.Klijent;

IF OBJECT_ID('KonceptBar.Zaposleni', 'U') IS NOT NULL
    DROP TABLE KonceptBar.Zaposleni;


GO
-- =========================
-- 3. ZAPOSLENI
-- =========================
CREATE TABLE KonceptBar.Zaposleni (
    ID_zap    INT             NOT NULL,
    ime_zap   VARCHAR (20)    NOT NULL,
    prez_zap  VARCHAR (30)    NOT NULL,
    tel_zap   VARCHAR (20)    NOT NULL,
    plata_zap DECIMAL (10, 2) NOT NULL,
    datum_zap DATE            NOT NULL,
    email_zap VARCHAR (30)    NULL,
    CONSTRAINT PK_Zaposleni PRIMARY KEY (ID_zap),
    CONSTRAINT UQ_Zaposleni_Email UNIQUE (email_zap),
    CONSTRAINT CK_Zaposleni_Plata CHECK (plata_zap > 0)
);


GO
-- =========================
-- 4. KLIJENT
-- =========================
CREATE TABLE KonceptBar.Klijent (
    ID_klijent    INT          NOT NULL,
    tel_klijent   VARCHAR (20) NULL,
    email_klijent VARCHAR (30) NULL,
    CONSTRAINT PK_Klijent PRIMARY KEY (ID_klijent)
);


GO
-- =========================
-- 5. DOGADJAJ
-- =========================
CREATE TABLE KonceptBar.Dogadjaj (
    ID_dogadjaj     INT           NOT NULL,
    opis_dogadjaja  VARCHAR (100) NULL,
    vreme_pocetka   TIME          NOT NULL,
    vreme_zavrsetka TIME          NOT NULL,
    datum_dogadjaja DATE          NOT NULL,
    namena          VARCHAR (100) NULL,
    CONSTRAINT PK_Dogadjaj PRIMARY KEY (ID_dogadjaj),
    CONSTRAINT CK_Dogadjaj_Vreme CHECK (vreme_zavrsetka > vreme_pocetka)
);


GO
-- =========================
-- 6. MENI
-- =========================
CREATE TABLE KonceptBar.Meni (
    ID_meni         INT          NOT NULL,
    tip_menija      VARCHAR (20) NOT NULL,
    datum_kreiranja DATE         NOT NULL,
    vazi_od         DATE         NOT NULL,
    vazi_do         DATE         NOT NULL,
    CONSTRAINT PK_Meni PRIMARY KEY (ID_meni),
    CONSTRAINT CK_Meni_Datum CHECK (vazi_do >= vazi_od)
);


GO
-- =========================
-- 7. ARTIKAL
-- =========================
CREATE TABLE KonceptBar.Artikal (
    ID_artikal    INT            NOT NULL,
    naziv_artikal VARCHAR (40)   NOT NULL,
    cena          DECIMAL (8, 2) NOT NULL,
    CONSTRAINT PK_Artikal PRIMARY KEY (ID_artikal),
    CONSTRAINT CK_Artikal_Cena CHECK (cena > 0)
);


GO
-- =========================
-- 8. EKSTERNI DOGADJAJ
-- =========================
CREATE TABLE KonceptBar.Eksterni_Dogadjaj (
    ID_dogadjaj INT NOT NULL,
    ID_klijent  INT NOT NULL,
    CONSTRAINT PK_Eksterni_Dogadjaj PRIMARY KEY (ID_dogadjaj),
    CONSTRAINT FK_EksterniDogadjaj_Dogadjaj FOREIGN KEY (ID_dogadjaj) REFERENCES KonceptBar.Dogadjaj (ID_dogadjaj),
    CONSTRAINT FK_EksterniDogadjaj_Klijent FOREIGN KEY (ID_klijent) REFERENCES KonceptBar.Klijent (ID_klijent)
);


GO
-- =========================
-- 9. NARUDZBINA
-- =========================
CREATE TABLE KonceptBar.Narudzbina (
    ID_nar      INT          NOT NULL,
    datum_nar   DATE         NOT NULL,
    status_nar  VARCHAR (20) NOT NULL,
    ID_zap      INT          NOT NULL,
    ID_dogadjaj INT          NULL,
    CONSTRAINT PK_Narudzbina PRIMARY KEY (ID_nar),
    CONSTRAINT FK_Narudzbina_Zaposleni FOREIGN KEY (ID_zap) REFERENCES KonceptBar.Zaposleni (ID_zap),
    CONSTRAINT FK_Narudzbina_Dogadjaj FOREIGN KEY (ID_dogadjaj) REFERENCES KonceptBar.Dogadjaj (ID_dogadjaj),
    CONSTRAINT CK_Narudzbina_Status CHECK (status_nar IN ('kreirana', 'u obradi', 'zavrsena', 'otkazana'))
);


GO
-- =========================
-- 10. KETERING NARUDZBINA
-- =========================
CREATE TABLE KonceptBar.Ketering_Narudzbina (
    ID_nar          INT           NOT NULL,
    adresa_isporuke VARCHAR (60)  NOT NULL,
    datum_isporuke  DATE          NOT NULL,
    vreme_isporuke  TIME          NOT NULL,
    napomena        VARCHAR (100) NULL,
    ID_meni         INT           NOT NULL,
    ID_klijent      INT           NOT NULL,
    CONSTRAINT PK_Ketering_Narudzbina PRIMARY KEY (ID_nar),
    CONSTRAINT FK_KeteringNarudzbina_Narudzbina FOREIGN KEY (ID_nar) REFERENCES KonceptBar.Narudzbina (ID_nar),
    CONSTRAINT FK_KeteringNarudzbina_Meni FOREIGN KEY (ID_meni) REFERENCES KonceptBar.Meni (ID_meni),
    CONSTRAINT FK_KeteringNarudzbina_Klijent FOREIGN KEY (ID_klijent) REFERENCES KonceptBar.Klijent (ID_klijent)
);


GO
-- =========================
-- 11. MENI ARTIKAL
-- =========================
CREATE TABLE KonceptBar.Meni_Artikal (
    ID_meni       INT            NOT NULL,
    ID_artikal    INT            NOT NULL,
    trenutna_cena DECIMAL (8, 2) NOT NULL,
    CONSTRAINT PK_Meni_Artikal PRIMARY KEY (ID_meni, ID_artikal),
    CONSTRAINT FK_MeniArtikal_Meni FOREIGN KEY (ID_meni) REFERENCES KonceptBar.Meni (ID_meni),
    CONSTRAINT FK_MeniArtikal_Artikal FOREIGN KEY (ID_artikal) REFERENCES KonceptBar.Artikal (ID_artikal),
    CONSTRAINT CK_MeniArtikal_Cena CHECK (trenutna_cena > 0)
);


GO
-- =========================
-- 12. STAVKA NARUDZBINE
-- =========================
CREATE TABLE KonceptBar.Stavka_Narudzbine (
    ID_stavka_nar INT            NOT NULL,
    ID_nar        INT            NOT NULL,
    RB_stavke     INT            NOT NULL,
    kolicina      INT            NOT NULL,
    prodajna_cena DECIMAL (8, 2) NOT NULL,
    ID_artikal    INT            NOT NULL,
    ID_meni       INT            NOT NULL,
    CONSTRAINT PK_Stavka_Narudzbine PRIMARY KEY (ID_stavka_nar),
    CONSTRAINT FK_StavkaNarudzbine_Narudzbina FOREIGN KEY (ID_nar) REFERENCES KonceptBar.Narudzbina (ID_nar),
    CONSTRAINT FK_StavkaNarudzbine_MeniArtikal FOREIGN KEY (ID_meni, ID_artikal) REFERENCES KonceptBar.Meni_Artikal (ID_meni, ID_artikal),
    CONSTRAINT CK_StavkaNarudzbine_Kolicina CHECK (kolicina > 0),
    CONSTRAINT CK_StavkaNarudzbine_Cena CHECK (prodajna_cena > 0)
);


GO
-- =========================
-- 13. JELO
-- =========================
CREATE TABLE KonceptBar.Jelo (
    ID_artikal INT          NOT NULL,
    napomena   VARCHAR (60) NULL,
    CONSTRAINT PK_Jelo PRIMARY KEY (ID_artikal),
    CONSTRAINT FK_Jelo_Artikal FOREIGN KEY (ID_artikal) REFERENCES KonceptBar.Artikal (ID_artikal)
);


GO
-- =========================
-- 14. PICE
-- =========================
CREATE TABLE KonceptBar.Pice (
    ID_artikal INT            NOT NULL,
    zapremina  DECIMAL (5, 2) NOT NULL,
    CONSTRAINT PK_Pice PRIMARY KEY (ID_artikal),
    CONSTRAINT FK_Pice_Artikal FOREIGN KEY (ID_artikal) REFERENCES KonceptBar.Artikal (ID_artikal),
    CONSTRAINT CK_Pice_Zapremina CHECK (zapremina > 0)
);


GO
-- =========================
-- 15. UCESTVUJE
-- =========================
CREATE TABLE KonceptBar.Ucestvuje (
    ID_zap      INT NOT NULL,
    ID_dogadjaj INT NOT NULL,
    CONSTRAINT PK_Ucestvuje PRIMARY KEY (ID_zap, ID_dogadjaj),
    CONSTRAINT FK_Ucestvuje_Zaposleni FOREIGN KEY (ID_zap) REFERENCES KonceptBar.Zaposleni (ID_zap),
    CONSTRAINT FK_Ucestvuje_Dogadjaj FOREIGN KEY (ID_dogadjaj) REFERENCES KonceptBar.Dogadjaj (ID_dogadjaj)
);


GO
-- =========================
-- 7. DML NAREDBE ZA UNOS PODATAKA
-- =========================
INSERT  INTO KonceptBar.Zaposleni
VALUES (1, 'Marko', 'Markovic', '060111111', 65000, '2023-01-10', 'marko@mail.com'),
       (2, 'Ana', 'Jovanovic', '060222222', 70000, '2022-03-15', 'ana@mail.com'),
       (3, 'Petar', 'Petrovic', '060333333', 62000, '2024-02-20', 'petar@mail.com'),
       (4, 'Jelena', 'Nikolic', '060444444', 75000, '2021-07-01', 'jelena@mail.com'),
       (5, 'Milan', 'Ilic', '060555555', 68000, '2020-09-12', 'milan@mail.com'),
       (6, 'Sara', 'Simic', '060666666', 72000, '2023-05-18', 'sara@mail.com'),
       (7, 'Luka', 'Kostic', '060777777', 61000, '2024-04-11', 'luka@mail.com'),
       (8, 'Nina', 'Stankovic', '060888888', 69000, '2022-12-05', 'nina@mail.com'),
       (9, 'Vuk', 'Pavlovic', '060999999', 73000, '2021-11-21', 'vuk@mail.com'),
       (10, 'Maja', 'Lazic', '061000000', 66000, '2023-08-30', 'maja@mail.com');

INSERT  INTO KonceptBar.Klijent
VALUES (1, '061111111', 'klijent1@mail.com'),
       (2, '061222222', 'klijent2@mail.com'),
       (3, '061333333', 'klijent3@mail.com'),
       (4, '061444444', 'klijent4@mail.com'),
       (5, '061555555', 'klijent5@mail.com'),
       (6, '061666666', 'klijent6@mail.com'),
       (7, '061777777', 'klijent7@mail.com'),
       (8, '061888888', 'klijent8@mail.com'),
       (9, '061999999', 'klijent9@mail.com'),
       (10, '062000000', 'klijent10@mail.com');

INSERT  INTO KonceptBar.Dogadjaj
VALUES (1, 'Rodjendan', '18:00', '23:00', '2026-06-01', 'Privatna proslava'),
       (2, 'Svadba', '17:00', '23:59', '2026-06-05', 'Porodicni dogadjaj'),
       (3, 'Korporativna vecera', '19:00', '23:30', '2026-06-10', 'Poslovni dogadjaj'),
       (4, 'Seminar', '10:00', '16:00', '2026-06-12', 'Edukacija'),
       (5, 'Promocija proizvoda', '12:00', '18:00', '2026-06-15', 'Marketing'),
       (6, 'Koktel vece', '20:00', '23:00', '2026-06-18', 'Druzenje'),
       (7, 'Diplomska proslava', '18:30', '23:59', '2026-06-20', 'Proslava'),
       (8, 'Humanitarno vece', '19:00', '22:30', '2026-06-22', 'Humanitarni dogadjaj'),
       (9, 'Konferencija', '09:00', '17:00', '2026-06-25', 'Poslovni skup'),
       (10, 'Privatna vecera', '19:30', '22:30', '2026-06-28', 'Privatni dogadjaj');

INSERT  INTO KonceptBar.Meni
VALUES (1, 'Standardni', '2026-01-01', '2026-01-01', '2026-12-31'),
       (2, 'Premium', '2026-01-02', '2026-01-02', '2026-12-31'),
       (3, 'Vegetarijanski', '2026-01-03', '2026-01-03', '2026-12-31'),
       (4, 'Deciji', '2026-01-04', '2026-01-04', '2026-12-31'),
       (5, 'Svadbeni', '2026-01-05', '2026-01-05', '2026-12-31'),
       (6, 'Poslovni', '2026-01-06', '2026-01-06', '2026-12-31'),
       (7, 'Koktel', '2026-01-07', '2026-01-07', '2026-12-31'),
       (8, 'Luksuzni', '2026-01-08', '2026-01-08', '2026-12-31'),
       (9, 'Sezonski', '2026-01-09', '2026-01-09', '2026-12-31'),
       (10, 'Specijalni', '2026-01-10', '2026-01-10', '2026-12-31');

-- =========================
-- ARTIKAL
-- =========================
INSERT  INTO KonceptBar.Artikal
VALUES (1, 'Piletina sa povrcem', 950),
       (2, 'Biftek', 1800),
       (3, 'Pasta Carbonara', 850),
       (4, 'Cezar salata', 700),
       (5, 'Cheesecake', 450),
       (6, 'Coca Cola', 250),
       (7, 'Fanta', 250),
       (8, 'Sok od narandze', 300),
       (9, 'Voda', 180),
       (10, 'Crveno vino', 600),
       (11, 'Rizoto sa pecurkama', 780),
       (12, 'Losos sa povrcem', 1600),
       (13, 'Pileci medaljoni', 900),
       (14, 'Grcka salata', 650),
       (15, 'Tiramisu', 500),
       (16, 'Sprite', 250),
       (17, 'Limunada', 280),
       (18, 'Espresso', 220),
       (19, 'Mineralna voda', 200),
       (20, 'Belo vino', 600);


GO
-- =========================
-- JELO
-- =========================
INSERT  INTO KonceptBar.Jelo
VALUES (1, 'Bez luka'),
       (2, 'Medium pecenje'),
       (3, 'Bez slanine'),
       (4, 'Dodatni dresing'),
       (5, 'Servirati hladno'),
       (11, 'Vegetarijansko'),
       (12, 'Servirati toplo'),
       (13, 'Bez ljutog'),
       (14, 'Dodatni sir'),
       (15, 'Desert');


GO
-- =========================
-- PICE
-- =========================
INSERT  INTO KonceptBar.Pice
VALUES (6, 330),
       (7, 330),
       (8, 250),
       (9, 500),
       (10, 150),
       (16, 330),
       (17, 300),
       (18, 40),
       (19, 500),
       (20, 150);


GO
-- =========================
-- MENI_ARTIKAL
-- =========================
INSERT  INTO KonceptBar.Meni_Artikal
VALUES (1, 1, 950),
       (1, 2, 1800),
       (1, 3, 850),
       (2, 4, 700),
       (2, 5, 450),
       (3, 6, 250),
       (3, 7, 250),
       (4, 8, 300),
       (5, 9, 180),
       (6, 10, 600),
       (7, 11, 780),
       (7, 12, 1600),
       (8, 13, 900),
       (8, 14, 650),
       (9, 15, 500),
       (9, 16, 250),
       (10, 17, 280),
       (10, 18, 220),
       (10, 19, 200),
       (10, 20, 600);


GO
-- =========================
-- EKSTERNI_DOGADJAJ
-- =========================
INSERT  INTO KonceptBar.Eksterni_dogadjaj
VALUES (1, 1),
       (2, 2),
       (3, 3),
       (4, 4),
       (5, 5),
       (6, 6),
       (7, 7),
       (8, 8),
       (9, 9),
       (10, 10);

-- =========================
-- NARUDZBINA
-- =========================
INSERT  INTO KonceptBar.Narudzbina
VALUES (1, '2026-05-20', 'kreirana', 1, 1),
       (2, '2026-05-21', 'kreirana', 2, 2),
       (3, '2026-05-22', 'u obradi', 3, 3),
       (4, '2026-05-23', 'u obradi', 4, 4),
       (5, '2026-05-24', 'zavrsena', 5, 5),
       (6, '2026-05-25', 'kreirana', 6, 6),
       (7, '2026-05-26', 'zavrsena', 7, 7),
       (8, '2026-05-27', 'u obradi', 8, 8),
       (9, '2026-05-28', 'kreirana', 9, 9),
       (10, '2026-05-29', 'kreirana', 10, 10);

-- =========================
-- KETERING_NARUDZBINA
-- =========================
INSERT  INTO KonceptBar.Ketering_narudzbina
VALUES (1, 'Bulevar Oslobodjenja 1', '2026-06-01', '18:00', 'Rodjendan', 1, 1),
       (2, 'Bulevar Cara Lazara 10', '2026-06-05', '17:00', 'Svadba', 2, 2),
       (3, 'Narodnog Fronta 15', '2026-06-10', '19:00', 'Poslovna vecera', 3, 3),
       (4, 'Mise Dimitrijevica 5', '2026-06-12', '10:00', 'Seminar', 4, 4),
       (5, 'Futoska 22', '2026-06-15', '12:00', 'Promocija', 5, 5),
       (6, 'Temerinska 100', '2026-06-18', '20:00', 'Koktel', 6, 6),
       (7, 'Cara Dusana 11', '2026-06-20', '18:30', 'Proslava', 7, 7),
       (8, 'Partizanska 7', '2026-06-22', '19:00', 'Humanitarno vece', 8, 8),
       (9, 'Jevrejska 8', '2026-06-25', '09:00', 'Konferencija', 9, 9),
       (10, 'Dunavska 30', '2026-06-28', '19:30', 'Privatna vecera', 10, 10);

-- =========================
-- STAVKA_NARUDZBINE
-- =========================
INSERT  INTO KonceptBar.Stavka_narudzbine
VALUES (1, 1, 1, 10, 950, 1, 1),
       (2, 2, 1, 15, 1800, 2, 1),
       (3, 3, 1, 20, 850, 3, 1),
       (4, 4, 1, 25, 700, 4, 2),
       (5, 5, 1, 30, 450, 5, 2),
       (6, 6, 1, 40, 250, 6, 3),
       (7, 7, 1, 40, 250, 7, 3),
       (8, 8, 1, 35, 300, 8, 4),
       (9, 9, 1, 50, 180, 9, 5),
       (10, 10, 1, 20, 600, 10, 6);

-- =========================
-- UCESTVUJE
-- =========================
INSERT  INTO KonceptBar.Ucestvuje
VALUES (1, 1),
       (2, 2),
       (3, 3),
       (4, 4),
       (5, 5),
       (6, 6),
       (7, 7),
       (8, 8),
       (9, 9),
       (10, 10);


GO
/* UPIT 1 – Pregled ketering narudžbina za eksterne događaje
Prikazuje sve ketering narudžbine sa podacima o klijentu,
eksternom događaju i odabranom meniju.
*/
SELECT   n.ID_nar,
         n.datum_nar,
         n.status_nar,
         k.ID_klijent,
         d.opis_dogadjaja,
         d.datum_dogadjaja,
         m.tip_menija
FROM     KonceptBar.Narudzbina AS n
         INNER JOIN
         KonceptBar.Ketering_Narudzbina AS kn
         ON n.ID_nar = kn.ID_nar
         INNER JOIN
         KonceptBar.Klijent AS k
         ON kn.ID_klijent = k.ID_klijent
         INNER JOIN
         KonceptBar.Eksterni_Dogadjaj AS ed
         ON n.ID_dogadjaj = ed.ID_dogadjaj
         INNER JOIN
         KonceptBar.Dogadjaj AS d
         ON ed.ID_dogadjaj = d.ID_dogadjaj
         INNER JOIN
         KonceptBar.Meni AS m
         ON kn.ID_meni = m.ID_meni
WHERE    k.ID_klijent = ed.ID_klijent
ORDER BY n.datum_nar;


GO
/* UPIT 2 – Ukupna vrednost ketering narudžbina za eksterne događaje
Za svaku ketering narudžbinu (vezanu za eksterni događaj) prikazuje 
klijenta, događaj, ukupan broj stavki i ukupnu vrednost narudžbine veću od 10000.
*/
SELECT   n.ID_nar,
         n.status_nar,
         k.ID_klijent,
         d.opis_dogadjaja,
         d.datum_dogadjaja,
         COUNT(sn.ID_stavka_nar) AS Broj_stavki,
         SUM(sn.kolicina * sn.prodajna_cena) AS Ukupna_vrednost
FROM     KonceptBar.Narudzbina AS n
         INNER JOIN
         KonceptBar.Ketering_Narudzbina AS kn
         ON n.ID_nar = kn.ID_nar
         INNER JOIN
         KonceptBar.Klijent AS k
         ON kn.ID_klijent = k.ID_klijent
         INNER JOIN
         KonceptBar.Eksterni_Dogadjaj AS ed
         ON n.ID_dogadjaj = ed.ID_dogadjaj
         INNER JOIN
         KonceptBar.Dogadjaj AS d
         ON ed.ID_dogadjaj = d.ID_dogadjaj
         INNER JOIN
         KonceptBar.Stavka_Narudzbine AS sn
         ON n.ID_nar = sn.ID_nar
WHERE    k.ID_klijent = ed.ID_klijent
GROUP BY n.ID_nar, n.status_nar, k.ID_klijent, d.opis_dogadjaja, d.datum_dogadjaja
HAVING   SUM(sn.kolicina * sn.prodajna_cena) > 10000
ORDER BY Ukupna_vrednost DESC;


GO
/* UPIT 3 – Artikli skuplji od proseka
Prikazuje artikle iz menija koji su skuplji od prosečne cene svih artikala.
*/
SELECT   a.ID_artikal,
         a.naziv_artikal,
         a.cena,
         m.tip_menija
FROM     KonceptBar.Artikal AS a
         INNER JOIN
         KonceptBar.Meni_Artikal AS ma
         ON a.ID_artikal = ma.ID_artikal
         INNER JOIN
         KonceptBar.Meni AS m
         ON ma.ID_meni = m.ID_meni
WHERE    a.cena > (SELECT AVG(cena)
                   FROM   KonceptBar.Artikal)
ORDER BY a.cena DESC;


GO
/* UPIT 4 – Zaposleni na eksternim događajima sa ketering narudžbinom
Prikazuje zaposlene koji učestvuju na eksternim događajima 
za koje postoji ketering narudžbina.
*/
SELECT   z.ID_zap,
         z.ime_zap,
         z.prez_zap,
         d.opis_dogadjaja,
         d.datum_dogadjaja,
         k.ID_klijent
FROM     KonceptBar.Zaposleni AS z
         INNER JOIN
         KonceptBar.Ucestvuje AS u
         ON z.ID_zap = u.ID_zap
         INNER JOIN
         KonceptBar.Dogadjaj AS d
         ON u.ID_dogadjaj = d.ID_dogadjaj
         INNER JOIN
         KonceptBar.Eksterni_Dogadjaj AS ed
         ON d.ID_dogadjaj = ed.ID_dogadjaj
         INNER JOIN
         KonceptBar.Klijent AS k
         ON ed.ID_klijent = k.ID_klijent
         INNER JOIN
         KonceptBar.Narudzbina AS n
         ON n.ID_dogadjaj = d.ID_dogadjaj
         INNER JOIN
         KonceptBar.Ketering_Narudzbina AS kn
         ON n.ID_nar = kn.ID_nar
ORDER BY d.datum_dogadjaja;


GO
/* UPIT 5 – Pregled menija i prosečne cene
Za svaki meni prikazuje broj artikala i prosečnu trenutnu cenu artikala.
*/
SELECT   m.ID_meni,
         m.tip_menija,
         COUNT(ma.ID_artikal) AS Broj_artikala,
         AVG(ma.trenutna_cena) AS Prosecna_cena
FROM     KonceptBar.Meni AS m
         INNER JOIN
         KonceptBar.Meni_Artikal AS ma
         ON m.ID_meni = ma.ID_meni
GROUP BY m.ID_meni, m.tip_menija
HAVING   COUNT(ma.ID_artikal) >= 1
         AND AVG(ma.trenutna_cena) > 300
ORDER BY Prosecna_cena DESC;


GO
/* SEKVENCA 1 – Automatsko generisanje ID klijenta */
IF OBJECT_ID('KonceptBar.KlijentSeq', 'SO') IS NOT NULL
    DROP SEQUENCE KonceptBar.KlijentSeq;


GO
CREATE SEQUENCE KonceptBar.KlijentSeq
    START WITH 11
    INCREMENT BY 1;


GO
INSERT  INTO KonceptBar.Klijent (
    ID_klijent,
    tel_klijent,
    email_klijent
)
VALUES                          ( NEXT VALUE FOR KonceptBar.KlijentSeq, '063111222', 'novi.klijent@mail.com');


GO
/* SEKVENCA 2 – Automatsko generisanje ID narudžbine */
IF OBJECT_ID('KonceptBar.NarudzbinaSeq', 'SO') IS NOT NULL
    DROP SEQUENCE KonceptBar.NarudzbinaSeq;


GO
CREATE SEQUENCE KonceptBar.NarudzbinaSeq
    START WITH 11
    INCREMENT BY 1;


GO
INSERT  INTO KonceptBar.Narudzbina (
    ID_nar,
    datum_nar,
    status_nar,
    ID_zap,
    ID_dogadjaj
)
VALUES                             ( NEXT VALUE FOR KonceptBar.NarudzbinaSeq, '2026-05-30', 'kreirana', 1, 1);


GO
/* INDEKS – Pretraga događaja po datumu
Indeks se kreira nad datumom događaja jer se događaji često pretražuju po datumu održavanja.
*/
IF EXISTS (SELECT 1
           FROM   sys.indexes
           WHERE  name = 'IX_Dogadjaj_Datum'
                  AND object_id = OBJECT_ID('KonceptBar.Dogadjaj'))
    DROP INDEX IX_Dogadjaj_Datum
        ON KonceptBar.Dogadjaj;


GO
CREATE INDEX IX_Dogadjaj_Datum
    ON KonceptBar.Dogadjaj(datum_dogadjaja);


GO
SELECT *
FROM   KonceptBar.Dogadjaj
WHERE  datum_dogadjaja = '2026-06-25';


GO
/* FUNKCIJA 1 – Ukupna vrednost narudžbine
Skalarna funkcija za prosleđeni ID narudžbine vraća ukupnu vrednost narudžbine.
*/
IF OBJECT_ID('KonceptBar.fn_UkupnaVrednostNarudzbine', 'FN') IS NOT NULL
    DROP FUNCTION KonceptBar.fn_UkupnaVrednostNarudzbine;


GO
CREATE FUNCTION KonceptBar.fn_UkupnaVrednostNarudzbine
(@ID_nar INT)
RETURNS DECIMAL (10, 2)
AS
BEGIN
    DECLARE @ukupno AS DECIMAL (10, 2);
    SELECT @ukupno = SUM(kolicina * prodajna_cena)
    FROM   KonceptBar.Stavka_Narudzbine
    WHERE  ID_nar = @ID_nar;
    RETURN ISNULL(@ukupno, 0);
END


GO
/* TEST */
SELECT ID_nar,
       KonceptBar.fn_UkupnaVrednostNarudzbine(ID_nar) AS UkupnaVrednost
FROM   KonceptBar.Narudzbina;


GO
/* FUNKCIJA 2 – Ketering narudžbine klijenta
Inline tabelarna funkcija za prosleđeni ID klijenta vraća njegove ketering narudžbine.
*/
IF OBJECT_ID('KonceptBar.fn_KeteringNarudzbineKlijenta', 'IF') IS NOT NULL
    DROP FUNCTION KonceptBar.fn_KeteringNarudzbineKlijenta;


GO
CREATE FUNCTION KonceptBar.fn_KeteringNarudzbineKlijenta
(@ID_klijent INT)
RETURNS TABLE 
AS
RETURN 
    (SELECT n.ID_nar,
            n.datum_nar,
            n.status_nar,
            kn.adresa_isporuke,
            kn.datum_isporuke,
            kn.vreme_isporuke,
            KonceptBar.fn_UkupnaVrednostNarudzbine(n.ID_nar) AS UkupnaVrednost
     FROM   KonceptBar.Narudzbina AS n
            INNER JOIN
            KonceptBar.Ketering_Narudzbina AS kn
            ON n.ID_nar = kn.ID_nar
     WHERE  kn.ID_klijent = @ID_klijent)



GO
/* TEST */
SELECT *
FROM   KonceptBar.fn_KeteringNarudzbineKlijenta(1);


GO
/* PROCEDURA 1 – Izveštaj o ketering narudžbini
Procedura prikazuje osnovne podatke o ketering narudžbini i pomoću kursora ispisuje sve stavke.
*/
IF OBJECT_ID('KonceptBar.usp_IzvestajKeteringNarudzbine', 'P') IS NOT NULL
    DROP PROCEDURE KonceptBar.usp_IzvestajKeteringNarudzbine;


GO
CREATE PROCEDURE KonceptBar.usp_IzvestajKeteringNarudzbine
@ID_nar INT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1
                   FROM   KonceptBar.Ketering_Narudzbina
                   WHERE  ID_nar = @ID_nar)
        BEGIN
            PRINT 'Greska: Ketering narudzbina sa prosledjenim ID-em ne postoji.';
            RETURN;
        END
    DECLARE @datum_nar AS DATE;
    DECLARE @status_nar AS VARCHAR (20);
    DECLARE @adresa AS VARCHAR (60);
    DECLARE @datum_isporuke AS DATE;
    DECLARE @vreme_isporuke AS TIME;
    DECLARE @klijent AS INT;
    DECLARE @meni AS INT;
    SELECT @datum_nar = n.datum_nar,
           @status_nar = n.status_nar,
           @adresa = kn.adresa_isporuke,
           @datum_isporuke = kn.datum_isporuke,
           @vreme_isporuke = kn.vreme_isporuke,
           @klijent = kn.ID_klijent,
           @meni = kn.ID_meni
    FROM   KonceptBar.Narudzbina AS n
           INNER JOIN
           KonceptBar.Ketering_Narudzbina AS kn
           ON n.ID_nar = kn.ID_nar
    WHERE  n.ID_nar = @ID_nar;
    PRINT 'Izvestaj za ketering narudzbinu broj: ' + CAST (@ID_nar AS VARCHAR);
    PRINT 'Datum narudzbine: ' + CONVERT (VARCHAR, @datum_nar, 104);
    PRINT 'Status narudzbine: ' + @status_nar;
    PRINT 'Adresa isporuke: ' + @adresa;
    PRINT 'Datum isporuke: ' + CONVERT (VARCHAR, @datum_isporuke, 104);
    PRINT 'ID klijenta: ' + CAST (@klijent AS VARCHAR);
    PRINT 'ID menija: ' + CAST (@meni AS VARCHAR);
    PRINT '--------------------------------------------';
    DECLARE @naziv_artikal AS VARCHAR (40);
    DECLARE @kolicina AS INT;
    DECLARE @prodajna_cena AS DECIMAL (8, 2);
    DECLARE @ukupno_stavka AS DECIMAL (10, 2);
    DECLARE stavke_cursor CURSOR
        FOR SELECT   a.naziv_artikal,
                     sn.kolicina,
                     sn.prodajna_cena,
                     sn.kolicina * sn.prodajna_cena
            FROM     KonceptBar.Stavka_Narudzbine AS sn
                     INNER JOIN
                     KonceptBar.Artikal AS a
                     ON sn.ID_artikal = a.ID_artikal
            WHERE    sn.ID_nar = @ID_nar
            ORDER BY sn.RB_stavke;
    OPEN stavke_cursor;
    FETCH NEXT FROM stavke_cursor INTO @naziv_artikal, @kolicina, @prodajna_cena, @ukupno_stavka;
    WHILE @@FETCH_STATUS = 0
        BEGIN
            PRINT @naziv_artikal + ' | Kolicina: ' + CAST (@kolicina AS VARCHAR) + ' | Cena: ' + CAST (@prodajna_cena AS VARCHAR) + ' | Ukupno: ' + CAST (@ukupno_stavka AS VARCHAR);
            FETCH NEXT FROM stavke_cursor INTO @naziv_artikal, @kolicina, @prodajna_cena, @ukupno_stavka;
        END
    CLOSE stavke_cursor;
    DEALLOCATE stavke_cursor;
    PRINT '--------------------------------------------';
    PRINT 'Ukupna vrednost narudzbine: ' + CAST (KonceptBar.fn_UkupnaVrednostNarudzbine(@ID_nar) AS VARCHAR);
END


GO
-- TEST 1 – Uspešan poziv procedure (postojeća ketering narudžbina)
EXECUTE KonceptBar.usp_IzvestajKeteringNarudzbine @ID_nar = 1;


GO
-- TEST 2 – Nepostojeća ketering narudžbina
EXECUTE KonceptBar.usp_IzvestajKeteringNarudzbine @ID_nar = 99;


GO
/* PROCEDURA 2 – Dodavanje stavke narudžbine
Procedura dodaje novu stavku u narudžbinu uz proveru poslovnih pravila i upotrebu transakcije.
*/
IF OBJECT_ID('KonceptBar.usp_DodajStavkuNarudzbine', 'P') IS NOT NULL
    DROP PROCEDURE KonceptBar.usp_DodajStavkuNarudzbine;


GO
CREATE PROCEDURE KonceptBar.usp_DodajStavkuNarudzbine
@ID_stavka_nar INT, @ID_nar INT, @RB_stavke INT, @kolicina INT, @ID_meni INT, @ID_artikal INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @prodajna_cena AS DECIMAL (8, 2);
    IF NOT EXISTS (SELECT 1
                   FROM   KonceptBar.Narudzbina
                   WHERE  ID_nar = @ID_nar)
        BEGIN
            PRINT 'Greska: Narudzbina ne postoji.';
            RETURN;
        END
    IF EXISTS (SELECT 1
               FROM   KonceptBar.Narudzbina
               WHERE  ID_nar = @ID_nar
                      AND status_nar IN ('zavrsena', 'otkazana'))
        BEGIN
            PRINT 'Greska: Nije dozvoljeno dodavanje stavki u zavrsenu ili otkazanu narudzbinu.';
            RETURN;
        END
    IF NOT EXISTS (SELECT 1
                   FROM   KonceptBar.Meni_Artikal
                   WHERE  ID_meni = @ID_meni
                          AND ID_artikal = @ID_artikal)
        BEGIN
            PRINT 'Greska: Izabrani artikal ne postoji u odabranom meniju.';
            RETURN;
        END
    SELECT @prodajna_cena = trenutna_cena
    FROM   KonceptBar.Meni_Artikal
    WHERE  ID_meni = @ID_meni
           AND ID_artikal = @ID_artikal;
    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT  INTO KonceptBar.Stavka_Narudzbine (
            ID_stavka_nar,
            ID_nar,
            RB_stavke,
            kolicina,
            prodajna_cena,
            ID_artikal,
            ID_meni
        )
        VALUES                                    (@ID_stavka_nar, @ID_nar, @RB_stavke, @kolicina, @prodajna_cena, @ID_artikal, @ID_meni);
        COMMIT TRANSACTION;
        PRINT 'Stavka narudzbine je uspesno dodata.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        PRINT 'Transakcija je ponistena: ' + ERROR_MESSAGE();
    END CATCH
END


GO
/* TEST 1 - brisanje postojeće test stavke ako postoji */
IF EXISTS (SELECT 1
           FROM   KonceptBar.Stavka_Narudzbine
           WHERE  ID_stavka_nar = 11)
    DELETE KonceptBar.Stavka_Narudzbine
    WHERE  ID_stavka_nar = 11;


GO
/* TEST 2 - uspešno dodavanje stavke */
EXECUTE KonceptBar.usp_DodajStavkuNarudzbine @ID_stavka_nar = 11, @ID_nar = 1, @RB_stavke = 2, @kolicina = 5, @ID_meni = 1, @ID_artikal = 2;


GO
SELECT *
FROM   KonceptBar.Stavka_Narudzbine
WHERE  ID_stavka_nar = 11;


GO
/* TEST 3 - pokušaj dodavanja u završenu narudžbinu */
EXECUTE KonceptBar.usp_DodajStavkuNarudzbine @ID_stavka_nar = 15, @ID_nar = 5, @RB_stavke = 2, @kolicina = 3, @ID_meni = 2, @ID_artikal = 5;


GO
/* TRIGER 1 – Provera datuma i vremena isporuke
Triger proverava pravila za unos i izmenu ketering narudžbine.
*/
IF OBJECT_ID('KonceptBar.tr_ProveraDatumaIsporuke', 'TR') IS NOT NULL
    DROP TRIGGER KonceptBar.tr_ProveraDatumaIsporuke;


GO
CREATE TRIGGER KonceptBar.tr_ProveraDatumaIsporuke
    ON KonceptBar.Ketering_Narudzbina
    AFTER INSERT, UPDATE
    AS BEGIN
           SET NOCOUNT ON;
           IF EXISTS (SELECT 1
                      FROM   inserted AS i
                             INNER JOIN
                             KonceptBar.Narudzbina AS n
                             ON i.ID_nar = n.ID_nar
                      WHERE  i.datum_isporuke < n.datum_nar)
               BEGIN
                   THROW 50001, 'Greska: Datum isporuke ne moze biti pre datuma narudzbine.', 1;
               END
           IF EXISTS (SELECT 1
                      FROM   inserted AS i
                             INNER JOIN
                             KonceptBar.Narudzbina AS n
                             ON i.ID_nar = n.ID_nar
                             INNER JOIN
                             KonceptBar.Dogadjaj AS d
                             ON n.ID_dogadjaj = d.ID_dogadjaj
                      WHERE  i.datum_isporuke > d.datum_dogadjaja)
               BEGIN
                   THROW 50002, 'Greska: Datum isporuke ne moze biti posle datuma dogadjaja.', 1;
               END
           IF EXISTS (SELECT 1
                      FROM   inserted AS i
                             INNER JOIN
                             KonceptBar.Narudzbina AS n
                             ON i.ID_nar = n.ID_nar
                             INNER JOIN
                             KonceptBar.Dogadjaj AS d
                             ON n.ID_dogadjaj = d.ID_dogadjaj
                      WHERE  i.vreme_isporuke < d.vreme_pocetka
                             OR i.vreme_isporuke > d.vreme_zavrsetka)
               BEGIN
                   THROW 50003, 'Greska: Vreme isporuke mora biti u okviru vremena trajanja dogadjaja.', 1;
               END
           IF EXISTS (SELECT 1
                      FROM   inserted AS i
                             INNER JOIN
                             KonceptBar.Narudzbina AS n
                             ON i.ID_nar = n.ID_nar
                      WHERE  n.status_nar IN ('zavrsena', 'otkazana'))
               BEGIN
                   THROW 50004, 'Greska: Nije dozvoljena izmena ketering podataka za zavrsenu ili otkazanu narudzbinu.', 1;
               END
       END


GO
-- TEST 1 – Datum isporuke pre datuma narudzbine (ocekuje se greska 50001)
BEGIN TRY
    UPDATE KonceptBar.Ketering_Narudzbina
    SET    datum_isporuke = '2020-01-01'
    WHERE  ID_nar = 1;
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH


GO
-- TEST 2 – Datum isporuke posle datuma dogadjaja (ocekuje se greska 50002)
BEGIN TRY
    UPDATE KonceptBar.Ketering_Narudzbina
    SET    datum_isporuke = '2030-01-01'
    WHERE  ID_nar = 1;
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH


GO
-- TEST 3 – Vreme isporuke van opsega trajanja dogadjaja (ocekuje se greska 50003)
BEGIN TRY
    UPDATE KonceptBar.Ketering_Narudzbina
    SET    vreme_isporuke = '03:00'
    WHERE  ID_nar = 1;
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH


GO
-- TEST 4 – Izmena zavrsene narudzbine (ocekuje se greska 50004)
-- Narudzbina sa ID_nar = 5 ima status 'zavrsena'
BEGIN TRY
    UPDATE KonceptBar.Ketering_Narudzbina
    SET    napomena = 'Nova napomena'
    WHERE  ID_nar = 5;
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH


GO
-- TEST 5 – Ispravan unos (ocekuje se uspeh)
BEGIN TRY
    UPDATE KonceptBar.Ketering_Narudzbina
    SET    napomena = 'Azurirana napomena'
    WHERE  ID_nar = 1;
    PRINT 'Izmena uspesno izvrsena.';
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH


GO
/* TRIGER 2 – Kontrolisan unos stavke narudžbine
INSTEAD OF INSERT triger proverava unos stavke i automatski postavlja prodajnu cenu iz menija.
*/
IF OBJECT_ID('KonceptBar.tr_AzuriranjeCeneStavke', 'TR') IS NOT NULL
    DROP TRIGGER KonceptBar.tr_AzuriranjeCeneStavke;


GO
CREATE TRIGGER KonceptBar.tr_AzuriranjeCeneStavke
    ON KonceptBar.Stavka_Narudzbine
    INSTEAD OF INSERT
    AS BEGIN
           SET NOCOUNT ON;
           IF EXISTS (SELECT 1
                      FROM   inserted AS i
                             INNER JOIN
                             KonceptBar.Narudzbina AS n
                             ON i.ID_nar = n.ID_nar
                      WHERE  n.status_nar IN ('zavrsena', 'otkazana'))
               BEGIN
                   THROW 50005, 'Greska: Nije dozvoljeno dodavanje stavki u zavrsenu ili otkazanu narudzbinu.', 1;
               END
           IF EXISTS (SELECT 1
                      FROM   inserted AS i
                             LEFT OUTER JOIN
                             KonceptBar.Meni_Artikal AS ma
                             ON i.ID_meni = ma.ID_meni
                                AND i.ID_artikal = ma.ID_artikal
                      WHERE  ma.ID_meni IS NULL)
               BEGIN
                   THROW 50006, 'Greska: Izabrani artikal ne postoji u odabranom meniju.', 1;
               END
           IF EXISTS (SELECT 1
                      FROM   inserted AS i
                             INNER JOIN
                             KonceptBar.Stavka_Narudzbine AS sn
                             ON i.ID_nar = sn.ID_nar
                                AND i.RB_stavke = sn.RB_stavke)
               BEGIN
                   THROW 50007, 'Greska: Redni broj stavke vec postoji za ovu narudzbinu.', 1;
               END
           INSERT INTO KonceptBar.Stavka_Narudzbine (
               ID_stavka_nar,
               ID_nar,
               RB_stavke,
               kolicina,
               prodajna_cena,
               ID_artikal,
               ID_meni
           )
           SELECT i.ID_stavka_nar,
                  i.ID_nar,
                  i.RB_stavke,
                  i.kolicina,
                  ma.trenutna_cena,
                  i.ID_artikal,
                  i.ID_meni
           FROM   inserted AS i
                  INNER JOIN
                  KonceptBar.Meni_Artikal AS ma
                  ON i.ID_meni = ma.ID_meni
                     AND i.ID_artikal = ma.ID_artikal;
           PRINT 'Stavka je uspesno dodata, a cena je automatski preuzeta iz menija.';
       END


GO
-- TEST 1 – Uspesno dodavanje stavke (cena se automatski preuzima iz menija)
BEGIN TRY
    INSERT  INTO KonceptBar.Stavka_Narudzbine (
        ID_stavka_nar,
        ID_nar,
        RB_stavke,
        kolicina,
        prodajna_cena,
        ID_artikal,
        ID_meni
    )
    VALUES                                    (12, 2, 2, 3, 1, 2, 1);
END TRY
BEGIN CATCH
    -- prodajna_cena = 1 je namerno pogresna, triger ce je zameniti tacnom cenom
    PRINT ERROR_MESSAGE();
END CATCH


GO
-- Provera da li je cena ispravno preuzeta iz menija
SELECT ID_stavka_nar,
       prodajna_cena
FROM   KonceptBar.Stavka_Narudzbine
WHERE  ID_stavka_nar = 12;


GO
-- TEST 2 – Pokusaj dodavanja u zavrsenu narudzbinu (ocekuje se greska 50005)
-- Narudzbina sa ID_nar = 5 ima status 'zavrsena'
BEGIN TRY
    INSERT  INTO KonceptBar.Stavka_Narudzbine (
        ID_stavka_nar,
        ID_nar,
        RB_stavke,
        kolicina,
        prodajna_cena,
        ID_artikal,
        ID_meni
    )
    VALUES                                    (13, 5, 2, 2, 500, 5, 2);
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH


GO
-- TEST 3 – Artikal ne postoji u odabranom meniju (ocekuje se greska 50006)
-- Artikal 20 ne postoji u meniju 1
BEGIN TRY
    INSERT  INTO KonceptBar.Stavka_Narudzbine (
        ID_stavka_nar,
        ID_nar,
        RB_stavke,
        kolicina,
        prodajna_cena,
        ID_artikal,
        ID_meni
    )
    VALUES                                    (14, 1, 3, 1, 500, 20, 1);
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH


GO
-- TEST 4 – Redni broj stavke vec postoji za tu narudzbinu (ocekuje se greska 50007)
-- Narudzbina 1 vec ima stavku sa RB_stavke = 1
BEGIN TRY
    INSERT  INTO KonceptBar.Stavka_Narudzbine (
        ID_stavka_nar,
        ID_nar,
        RB_stavke,
        kolicina,
        prodajna_cena,
        ID_artikal,
        ID_meni
    )
    VALUES                                    (15, 1, 1, 2, 950, 1, 1);
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH