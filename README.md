# Rsync Backup Helper
* BackupHelper v0.2
* Joni Kukko
* joni.kukko@outlook.com


## KUVAUS
Scriptin tarkoitus on käynnistää rsync vain jos lähdekansiorakenteessa on muutoksia.

Tällä pyritään siihen, ettei rsyncin kohteena oleva nas-palvelin herätä kiintolevyjä turhaan, sillä rsync vertaa aina kohde- ja lähdekansioiden rakenteita keskenään vaikkei muutoksia lähdekansiossa olisikaan tapahtunut herättäennäin nas-palvelimen.


## YHTEENSOPIVUUS
Scriptiä on ajettu vain Ubuntu 14.04 LTS järjestelmässä, mutta se toiminee myös muissa linux pohjaisissa järjestelmissä.


## KÄYTTÖÖNOTTO
1. Scripti tarvitsee kansiot flag, log ja symlink.
2. Kansioihin flag ja log on scriptiä ajavalla käyttäjällä oltava kirjoitusoikeudet.
3. Kansioiden on oltava samassa sijainnissa scriptin kanssa.
4. Scripti tarvitsee tiedoston rsync.pass 
5. rsync.pass tiedoston on oltava samassa sijainnisssa scriptin kanssa.
6. rsync.pass tiedostoon laitetaan kohdepalvelimen salasana. Katso scriptin rivi 80.
7. rsync.pass tiedoston tulee olla oikeuksiltaan vain scriptiä ajavan käyttäjän luettavissa ja muokattavissa.


## KANSIORAKENNE
* ./flag
* ./log
* ./symlink
* ./BackupHelper.sh
* ./rsync.pass
* ./README.md


## KÄYTTÖ
Symlink kansioon on tarkoitus kerätä symlinkein kaikki varmuuskopioitavat kansiot ja tiedostot.
Ensin on tarkoitus ajaa komento check mikä tarkistaa onko paikallisessa kansiorakenteessa muutoksia. Muutoksia verrataan aikaisempaan check ajoon joten ensimmäinen check tuottaa aina falsen.

```shell
./BackupHelper.sh check hourly daily
```

Hourly ja daily ovat vapaavalintaisia flaggejä joita tulee olla 1-n kappaletta.
Mikäli muutoksia löytyy niin scripti merkkaa kyseiset flagit flag-kansioon.
Seuraavaksi on tarkoitus ajaa komento rsync mikä tarkistaa onko annettu flaggi olemassa ja jos on, niin käynnistää varmuuskopioinnin annettuun kohteeseen.

```shell
./BackupHelper.sh rsync hourly user@server:BackupHourly/
```

Flaggien avulla pystytään versioimaan varmuuskopioita. Esimerkiksi yllä oleva check komento voitaisiin laittaa ajettavaksi tasatunnein ja hourly flaggiä vastaava rsync taas aina puolelta. Näiden lisäksi daily flaggiä vastaava rsync voitaisiin ajaa aina puolilta öin. Tällöin saadaan yksi päivittäinen versio ja tunneittain päivittyvä versio.

Esimerkki mahdollisesta crontabista
```shell
 0 * * * * ./BackupHelper.sh check hourly daily
30 * * * * ./BackupHelper.sh rsync hourly user@server:BackupHourly/
 5 0 * * * ./BackupHelper.sh rsync daily  user@server:BackupDaily/
```



