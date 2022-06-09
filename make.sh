./run.sh /bin/bash -c 'cd build ; make -j $CORES && cd ..  && python scripts/run.py --mode --scene data/nerf/fox/ --load_snapshot ./xx.msgpack --n_steps 500 --vdb_save xx.vdb'
