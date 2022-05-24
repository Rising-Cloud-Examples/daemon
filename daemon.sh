start=$SECONDS

while true; do
    duration=$((SECONDS - start));
    echo "Time since start: $duration" > time.txt;
    sleep 1;
done
