timestr=$( cat time.txt )
echo "{\"time\": \"$timestr\"}" > response.json
