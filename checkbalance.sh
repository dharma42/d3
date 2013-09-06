#!/bin/bash
#
# Check PLN Node providers balance
#
#
check(){
        cd $prana
        python $prana/checkbalance.py > $prana/$date.$version
	cat $prana/$date.$version | ccze -A
}

ready(){
	prana=~/dharmasastra/PLN/pln_tools
        date=`date +%e%b%g`
        version=`date +%s`
        check
}

case $1 in
*) ready ;;
esac
