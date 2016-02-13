# Rsync Backup Helper v0.2
A simple script that launches rsync only when there are file or folder changes in the source location. This script also supports basic versioning and multiple target locations via "flags".

This script was made because the default behavior of rsync is to compare source location to target locations. This might be inconvenient in some cases such as when target servers are trying to save power by hibernating their hard drives.


## Compatibility
This script has only been run in Ubuntu 14.04 LTS system, but it should work on other Linux-based systems as well.


## Installation
1. The script needs folders called flag, log and symlink.
2. The user has to have write permissions to folders flag and log.
3. Folders must be in the same location with the script.
4. The script needs a file called rsync.pass
5. rsync.pass file must be in the same location with the script.
6. rsync.pass file includes the password for the target server. See line 80 of the script.
7. rsync.pass file must be readable only by the same user that runs the script.


## Folder structure
* ./flag
* ./log
* ./symlink
* ./BackupHelper.sh
* ./LICENSE
* ./README.md
* ./rsync.pass


## Usage
Symlink kansioon on tarkoitus kerätä symlinkein kaikki varmuuskopioitavat kansiot ja tiedostot.
Ensin on tarkoitus ajaa komento check mikä tarkistaa onko paikallisessa kansiorakenteessa muutoksia. Muutoksia verrataan aikaisempaan check ajoon joten ensimmäinen check tuottaa aina falsen.

```
./BackupHelper.sh check hourly daily
```

Hourly ja daily ovat vapaavalintaisia flaggejä joita tulee olla 1-n kappaletta.
Mikäli muutoksia löytyy niin scripti merkkaa kyseiset flagit flag-kansioon.
Seuraavaksi on tarkoitus ajaa komento rsync mikä tarkistaa onko annettu flaggi olemassa ja jos on, niin käynnistää varmuuskopioinnin annettuun kohteeseen.

```
./BackupHelper.sh rsync hourly user@server:BackupHourly/
```

Flaggien avulla pystytään versioimaan varmuuskopioita. Esimerkiksi yllä oleva check komento voitaisiin laittaa ajettavaksi tasatunnein ja hourly flaggiä vastaava rsync taas aina puolelta. Näiden lisäksi daily flaggiä vastaava rsync voitaisiin ajaa aina puolilta öin. Tällöin saadaan yksi päivittäinen versio ja tunneittain päivittyvä versio.

Esimerkki mahdollisesta crontabista
```
 0 * * * * ./BackupHelper.sh check hourly daily
30 * * * * ./BackupHelper.sh rsync hourly user@server:BackupHourly/
 5 0 * * * ./BackupHelper.sh rsync daily  user@server:BackupDaily/
```



