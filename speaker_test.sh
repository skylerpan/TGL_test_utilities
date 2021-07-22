#!/bin/bash
for ((hz = 220; hz < 8000; hz+=220))
do
   timeout 0.1 speaker-test -t sine -p 10 -P 2 -f $hz
done
