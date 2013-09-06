#!/bin/bash
#
# HS-BTC (Hot Shell Bitcoin)
# 
# A command line client fot BTC under scripts (bash). The super wallet
# for sysadmins - full featured and opensource. 
#
# libbitcoin + sx tools + gnupg
#
# Generate a new BTC seed or address and save the output at an
# encrypted file.gpg (with strong encryptation).
#
# Check balance and history of a single BTC address or all the BTC addresses
# of a especific MPKey.
#
# Send founds, generate automaticaly QRcodes.png, generate a txfile.tx 
# for asyncronous transactions. 
# 
# Insert and process BTC seeds and addreses from another clients.
#
# Multisigned operations.
#
# Clean info 
#
# Designed for a fairly standard Debian/Ubuntu desktop system.
#
# Require gpg:
# <sudo apt-get install gpg>
#
# Require libbitcoin and sx tolls:
# <wget http://sx.dyne.org/install-sx.sh> 
#
#   And execute the script:
#     <sudo bash ./install-sx.sh>
# 
# Require qrencode
# <sudo apt-get install qrencode>
#
#
# seed=`gpg -o- -d $seedID.seed.gpg`
# seedID=`echo $response | cut -f 1 -d "."`
#

showseed(){
	cat $SEEDFILES 
        cat $STRGFILES/showseed
        read response
        seedID=`ls $SEEDFILES | grep $response`
        sleep 0.3
        seed=$SEEDFILES/$seedID
        sleep 0.3
        cat $STRGFILES/showseed0
        sleep 0.3
        gpg -o- -d $seed
        echo
}

showpriv(){
        ls $SECRET/random
        cat $STRGFILES/showpriv
        read response
        privkeyID=`ls $SECRET/random | grep $response`
        sleep 0.3
        privkey=$SECRET/random/$privkeyID
        sleep 0.3
        cat $STRGFILES/showpriv0
        sleep 0.3
        gpg -o- -d $privkey
        echo
}

genaddr(){
	cat $STRGFILES/genaddr
        read response
        if [ "$response" ==  "0" ]; then
            cat $STRGFILES/genaddr4
            cat $MPKEYFILES/nmpkeys
            sleep 0.3
            cat $STRGFILES/genaddr0
            read mpkeyID
            sleep 0.3
            mpkey=`cat $MPKEYFILES/nmpkeys | grep $mpkeyID | cut -f 2 -d " "`
            sleep 0.3
            mpkeyID=`cat $MPKEYFILES/nmpkeys | grep $mpkey | cut -f 1 -d " "`
            cat $STRGFILES/genaddr1
            read accountID
            sleep 0.3
            btcaddr=`echo $mpkey | sx genaddr $accountID`
            sleep 0.3
            echo $version $btcaddr $accountID >> $BTCADDR/btcaddr_seed/$mpkeyID.addrbook
            cat $STRGFILES/genaddr2
            sleep 0.3
            cat $BTCADDR/btcaddr_seed/$mpkeyID.addrbook | grep $version
            cat $STRGFILES/genaddr3                        
            sleep 0.3
                cat $STRGFILES/sx_ok
            sx qrcode $btcaddr $QRFOLDER/qrbtcaddr/$version.png
            sleep 0.3
            cat $STRGFILES/ok
            cat $BTCADDR/btcaddr_seed/$mpkeyID.addrbook | grep $mpkeyID.addrbook
            echo
            ls $BTCADDR/btcaddr_seed/$mpkeyID.addrbook | grep $mpkeyID.addrbook 
            echo
            ls $QRFOLDER/qrbtcaddr/$version.png
            echo
        elif [ "$response" ==  "1" ]; then
            import_seed
            sleep 0.3
            version=`date +%s`
            genaddr
        fi     
}

balance(){
        book=$BTCADDR/btcaddr_seed/*.addrbook
        sleep 0.3
        random=$BTCADDR/btcaddr_random/random
        sleep 0.3
        cat $book
        echo
        cat $random
        echo
	cat $STRGFILES/balance0
        echo
        read response
        sleep 0.3
        accountID=`cat $book $random | grep $response | cut -f 1 -d " "`
        sleep 0.3
        btcaddr=`cat $book $random | grep $accountID | cut -f 2 -d " "`
        sleep 0.3
        echo $btcaddr | sx balance
        echo
}

hist(){
        book=$BTCADDR/btcaddr_seed/*.addrbook
        sleep 0.3
        random=$BTCADDR/btcaddr_random/random
        sleep 0.3
        cat $book
        echo
        cat $random
        echo
	cat $STRGFILES/balance0
        echo
        read response
        sleep 0.3
        accountID=`cat $book $random | grep $response | cut -f 1 -d " "`
        sleep 0.3
        btcaddr=`cat $book $random | grep $accountID | cut -f 2 -d " "`
        sleep 0.3
        echo $btcaddr | sx history
        echo
}

import_seed(){
	cat $STRGFILES/import_seed
        read btcnewseed
        sleep 0.3
        mpkey=`echo $btcnewseed | sx mpk`  #bug libbitcoin -> return 0 when the correct is 1 (error exit 1) --> FIXED BY GENJIX <--
        if test $? = 0 ; then 
            cat $STRGFILES/step2
            echo $btcnewseed $mpkey
            cat $STRGFILES/step3
            sleep 2
            checkgpg
            sleep 0.3
            echo $version $mpkey >> $MPKEYFILES/nmpkeys
            sleep 0.3
            echo $btcnewseed | gpg --yes -r $pkmail -e - > $SEEDFILES/$version.seed.gpg
            sleep 0.3
            sx qrcode $mpkey $QRFOLDER/qrmpkeys/$version.png
            cat $STRGFILES/ok
            cat $MPKEYFILES/nmpkeys | grep $version
            echo
            ls $SEEDFILES $QRFOLDER/qrmpkeys/$version.png
        elif test $? = 1 ; then
            cat $STRGFILES/error2
            import_seed
        fi
  
}


import_privkey(){
	cat $STRGFILES/import_privkey
        read btcprivkey
        sleep 0.3
        btcaddr=`echo $btcprivkey | sx addr`
        if test $? = 0 ; then
            cat $STRGFILES/step0
            echo $btcaddr
            cat $STRGFILES/step1
            sleep 2
            checkgpg
            echo $version $btcaddr >> $BTCADDR/btcaddr_random/random
            sleep 0.1
            echo $btcprivkey | gpg --yes -r $pkmail -e - > $RANDOMPRIV/$version.gpg
            sleep 0.2
            sx qrcode $btcaddr $QRFOLDER/qrbtcaddr/$version.png
            sleep 0.1
            cat $STRGFILES/ok
            cat $BTCADDR/btcaddr_random/random | grep $version
            echo
            ls $RANDOMPRIV/$version.gpg
            echo
            ls $QRFOLDER/qrbtcaddr/$version.png
        else
            cat $STRGFILES/import_fail
            import_privkey
        fi        
}

create_newseed(){
        btcnewseed=`sx newseed`
        sleep 0.3
        mpkey=`echo $btcnewseed | sx mpk`
        sleep 0.3
        mnemonic=`echo $btcnewseed | sx mnemonic`
        echo $btcnewseed $mpkey $mnemonic > /dev/null
        if test $? = 0 ; then
	    cat $STRGFILES/create_newseed
            sleep 2
            cat $STRGFILES/nseed 
            echo " --> $btcnewseed <--"
            cat $STRGFILES/nmpkey
            echo " --> $mpkey <--"
            cat $STRGFILES/nmnemonic
            echo " --> $mnemonic <--"
            cat $STRGFILES/create_newseed0
            sleep 3
            checkgpg
            sleep 0.3
            echo $version $mpkey >> $MPKEYFILES/nmpkeys
            sleep 0.3
            echo $btcnewseed | gpg --yes -r $pkmail -e - > $SEEDFILES/$version.seed.gpg
            sleep 0.3
            sx qrcode $mpkey $QRFOLDER/qrmpkeys/$version.png
            cat $STRGFILES/ok
            cat $MPKEYFILES/nmpkeys | grep $version
            echo
            ls $SEEDFILES $QRFOLDER/qrmpkeys/$version.png
            echo 
            ls  $SEEDFILES/$version.seed.gpg
        elif test $? = 1 ; then
            cat $STRGFILES/error2
            create_newseed
        fi
}

create_newprivkey(){
	sleep 1.2
        btcprivkey=`sx newkey
        sleep 0.3`
	btcaddr=`echo $btcprivkey | sx addr`
        echo $btcprivkey $btcaddr > /dev/null 
        if test $? = 0 ; then
	    cat $STRGFILES/create_newpriv
	    echo " --> $btcprivkey <--"
	    cat $STRGFILES/create_newpriv0
	    echo " --> $btcaddr <--"
	    sleep 2
	    cat $STRGFILES/create_newpriv1
	    echo $version $btcaddr >> $BTCADDR/btcaddr_random/random
            sleep 3
	    checkgpg
            sleep 0.1
 	    echo $btcprivkey | gpg --yes -r $pkmail -e - > $RANDOMPRIV/$version.gpg
	    sleep 0.2
            sx qrcode $btcaddr $QRBTCADDR/qrbtcaddr/$version.png
            sleep 0.1
            cat $STRGFILES/ok
            cat $BTCADDR/btcaddr_random/random | grep $version
            echo
            ls $RANDOMPRIV/$version.gpg 
            echo
            ls $QRBTCADDR/qrbtcaddr/$version.png
        elif test $? = 1; then
            cat $STRGFILES/error1
            create_newprivkey
        fi
}

newop(){
	cat $STRGFILES/newop
        read response
	if [ "$response" ==  "0" ]; then 
	    create_newprivkey
	elif [ "$response" == "1" ]; then
	    create_newseed
	elif [ "$response" == "2" ]; then
	    import_privkey
	elif [ "$response" == "3" ]; then
	    import_seed
	fi
}

creategpgkey(){
	sleep 0.1
	cat $STRGFILES/creating_gpg
        sleep 0.2
	gpg --gen-key
	    if $? = 0 ; then
	        pubkeymail
	    else
	        cat $STRGFILES/creating_gpg_fail
	        creategpgkey
	    fi
	echo
}

pubkeymail(){
	cat $STRGFILES/enter_uid0
        read pkmail
	echo
        echo " You choose to use the public key of $pkmail to encrypt the outputs of this script."
	cat $STRGFILES/select_options1
	read response
	if [ "$response" = "y" ]; then
	    echo
	    echo " Parameter accepted: $pkmail"
	    echo
	elif [ "$response" = "n" ]; then  
	    pubkeymail
	fi
}

checkgpg(){
        cat $STRGFILES/check0	
	sleep 1.5
	gpg --list-key | grep uid | tr -s "  "
	sleep 0.8
        cat $STRGFILES/select_options0
	read response
	if [ "$response" = "0" ]; then
	    pubkeymail
	elif [ "$response" = "1" ]; then
	    creategpgkey
	elif [ "$response" = "2" ]; then
	    cat $STRGFILES/error0
	fi
}

check(){
        cat $STRGFILES/hotshell_wellcome
	if test -d $SECRET ; then
            cd $HSBTC
	    if test $gpg_version = 1.4.12 || test -d $libbitcoin || test -d $sx ; then
                cat $STRGFILES/ok
            elif test $? = 1 ; then
                cat $STRGFILES/fail 1>&2
                exit 1
        elif test $? = 1 ; then  
            mkdir -p $HSBTC $QRFOLDER $SECRET $BTCADDR $STRGFILES $MPKEYFILES 
            sleep 0.3
            mkdir -p $QRFOLDER/mpkeys $SEEDFILES $TXFILES $QRMPKEY $QRBTCADDR $RANDOMPRIV $HSLANG
            sleep 0.3
            check
            fi
        fi
}

ready(){
	HSBTC=~/hotshellbtc 
	SECRET=$HSBTC/.secret
        BTCADDR=$HSBTC/btcaddr_all
	QRFOLDER=$HSBTC/qrcodes
        HSLANG=EN
        MPKEYFILES=$HSBTC/mpkeys
        STRGFILES=$HSBTC/.strings/$HSLANG
        QRMPKEY=$QRFOLDER/qrmpkeys
        QRBTCADDR=$QRFOLDER/qrbtcaddr
        RANDOMPRIV=$SECRET/btcaddr_random
        SEEDFILES=$SECRET/seeds
	TXFILES=$SECRET/txfiles
        version=`date +%s`
	gpg_version=`gpg --version | grep gpg | tr -s " " | cut -f 3 -d " "`
        libbitcoin=/usr/local/src/libbitcoin-git
        sx=/usr/local/src/sx-git
        if test $? = 0 ; then
            check
        elif test $? = 1 ; then
            cat $STRGFILES/error3 1>&2
            exit 1
        fi
}

	case "$1" in
	"newop") ready ; newop ;;
	"newseed") ready ; create_newseed ;;
	"newpriv") ready ; create_newprivkey ;;
	"addkey") ready ; import_privkey ;;
	"addseed") ready ; import_seed ;;
	"showseed") ready; showseed ;;
	"showpriv") ready; showpriv ;;
	"genaddr") ready ; genaddr ;;
	"balance") ready ; balance ;;
	"history") ready ; hist ;;
	"list") ready ; list ;; # random btcaddr | address book | MPKey | 
	"send") ready ; send ;; 
	"md5") ready ; md5sum ;; # to generate md5files for the seeds.
	"status") ready : status ;; # to check the integrity of my environment.
	"help") help ;; 
	*) echo " Please, use ./hsbtc.sh newop|newpriv|newseed|addkey|addseed|genaddr|list|balance|history|send|help"
	esac

# To do
# Add option to charge gnupg public key from a file ¿?.
# backup --> of all important info
# check if some seed desappear or if some boock address change...
#
# check doble registers...
# help - manual
