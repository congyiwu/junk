sudo md5deep -o f -r /data/ > /tmp/datamd5.txt
sort -k 2 /tmp/datamd5.txt > datamd5.txt.sorted
