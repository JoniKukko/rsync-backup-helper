#!/bin/sh

# https://github.com/JoniKukko/rsync-backup-helper
# BackupHelper v0.2
#
# ./BackupHelper.sh check flag1 flag2 flag3..
# ./BackupHelper.sh rsync checkflag destination


# Helpperi pvm muodon laittamisessa logiin
BackupHelperLog()
{
    echo "$(date +'%T') $1"
}


# funktio jos tarkistetaan muutoksia
BackupHelperCheck()
{
    BackupHelperLog 'ACTION CHECK START'

    FLAGS="$@"
    BASEPATH="$(dirname $0)"

    # etsitään tiedosto/kansio jolla on viimeisin muokkausaika
    # -L on pakollinen koska backup-kansio sisältää vain symlinkkejä oikeisiin varmuuskopioitaviin kohteisiin
    # http://stackoverflow.com/questions/4561895/how-to-recursively-find-the-latest-modified-file-in-a-directory
    LASTMOD=$(find -L "$BASEPATH/symlink/" -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d' ')

    # päivitetään backup-kansion modified time
    touch "$BASEPATH/symlink/"

    BackupHelperLog "FLAGS='$FLAGS'"
    BackupHelperLog "BASEPATH='$BASEPATH'"
    BackupHelperLog "LASTMOD='$LASTMOD'"


    # jos viimeisimmän muokkausajan omaava tiedosto/kansio ei ole sama kuin backup-kansio
    # niin silloin backup-kansion sisällä on tapahtunut muutoksia
    if [ "$BASEPATH/symlink/" != "$LASTMOD" ]
    then
        BackupHelperLog 'CHANGES DETECTED'

        for FLAG in $FLAGS
        do
            BackupHelperLog "CREATE FLAG '$FLAG'"
            touch "$BASEPATH/flag/$FLAG.flag"
        done

    else
        BackupHelperLog 'NO CHANGES DETECTED'
    fi

    BackupHelperLog 'ACTION CHECK STOP'
}


# funktio jos varmuuskopioidaan muutoksia
BackupHelperRsync()
{
    BackupHelperLog 'ACTION RSYNC STAR'

    FLAG="$1"
    DESTINATION="$2"
    BASEPATH="$(dirname $0)"

    BackupHelperLog "FLAG='$FLAG'"
    BackupHelperLog "DESTINATION='$DESTINATION'"
    BackupHelperLog "BASEPATH='$BASEPATH'"

    # jos flaggi on olemassa niin varmuuskopioidaan
    if [ -e "$BASEPATH/flag/$FLAG.flag" ]
    then
        BackupHelperLog "FLAG '$FLAG' EXISTS"

        # poistetaan flaggi ettei turhaa tehdä
        # uudestaan ellei check löydä sillä välin uusia muutoksia
        BackupHelperLog "REMOVE FLAG '$FLAG'"
        rm "$BASEPATH/flag/$FLAG.flag"

        # kutsutaan rsynkkiä
        # TODO jokin ilmoitus failesta
        BackupHelperLog 'CALL RSYNC'
        rsync -aqL --delete --password-file="$BASEPATH/rsync.pass" "$BASEPATH/symlink/" "$DESTINATION"

    else
        BackupHelperLog "FLAG '$FLAG' NOT FOUND"
    fi

    BackupHelperLog 'ACTION RSYNC STOP'
}



BackupHelper()
{
    BackupHelperLog 'START'

    # otetaan actioni ja muut parametrit talteen
    ACTION="$1"
    shift 1
    VARS="$@"

    BackupHelperLog "ACTION='$ACTION'"
    BackupHelperLog "VARS='$VARS'"

    # kutsutaan actionia vastaavaa funktiota ja annetaan parametrit
    case "$ACTION" in
        'check')
            BackupHelperCheck $VARS
            ;;
        'rsync')
            BackupHelperRsync $VARS
            ;;
        *)
            BackupHelperLog "ACTION '$ACTION' NOT FOUND"
            ;;
    esac

    BackupHelperLog 'STOP\n'
}


# apumuuttujat
BASEPATH="$(dirname $0)"
TODAY="$(date +'%Y-%m-%d')"

# poistetaan yli kymmenen paivaa vanhat lokit
find "$BASEPATH/log" -name '*.log' -type f -mtime +10 -delete

# itse backuphelpperin startti
# kirjoitetaan tulostukset lokitiedostoon
BackupHelper $@ >> "$BASEPATH/log/$TODAY.log"
