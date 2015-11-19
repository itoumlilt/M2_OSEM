#! /bin/bash
# execSim

source SourceMe
export SOCLIB_TTY=FILES

# Compiler pour $nbClusters*4 coeurs
cd apps/dwc/
make clean
# make NB_WORKERS=$nbCores TARGET=tsar BIN=woco$nbClusters
make TARGET=tsar

# Installer sur HDD
#make install BIN=woco$nbClusters OVERWRITE="-D o"
make install OVERWRITE="-D o"

cd ../../

for nbClusters in 1 4 16 64
do
    for nbWords in 1 2 4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384
    do
        
        # créer le script de lancement
        cd test/pf1/
        cat <<EOF > shrc
echo started
echo going to exec /bin/dwc $nbWords
exec /bin/dwc $nbWords
echo dwc ended
EOF

        mcopy -D o -i hdd-img.bin ./shrc ::/etc/.

        # Lancer le simulateur
        echo "Hello tty1" > tty1

        echo "[INFO] Going to make sim$nbClusters"
        make sim$nbClusters &

        # Arrêter le simulateur
        while [ `grep -qE "\[MainDwc\] Finished" tty1; echo $?` -eq 1 ]
        do
            sleep 5
        done
        # killall tsar-sim$nbClusters soclib-fb
        killall make
        
        # Copie des logs
        for j in {0..3}
        do
            cp tty$j tty$j.$nbClusters.$nbWords
        done
        cd ../../
    done
done

exit 0