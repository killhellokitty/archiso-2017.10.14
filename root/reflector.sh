# Reflector for Pacman Mirrorlist Updating

if [ -e "/etc/pacman.d/mirrorlist" ]
    then
		/usr/bin/reflector --protocol https --latest 100 --number 60 --age 12 --sort rate --save /etc/pacman.d/mirrorlist
elif [ -e "/etc/pacman.d/mirrorlist.pacnew" ]
    then
    	cd '/etc/pacman.d/
    	mv mirrorlist.pacnew mirrorlist
    	/usr/bin/reflector --protocol https --latest 100 --number 60 --age 12 --sort rate --save /etc/pacman.d/mirrorlist
elif [ !-e "/etc/pacman.d/{mirrorlist,mirrorlist.pacnew}" ]
    then
    	pacman -S mirrorlist
    	cd '/etc/pacman.d/
    	/usr/bin/reflector --protocol https --latest 100 --number 60 --age 12 --sort rate --save /etc/pacman.d/mirrorlist
fi

exit
