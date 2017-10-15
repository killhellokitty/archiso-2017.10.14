#!/bin/bash

# Run each installation script in sequence, logging the results
mkdir logs
cd arch-install/install-scripts
for i in *.sh
do
	echo $i
	bash -x $i &>> ~/logs/${i%.sh}.out
done
