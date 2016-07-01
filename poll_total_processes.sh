usage() {
    echo "Usage: poll_total_processes.sh <process name>"
    exit 1
}

if [ $# -eq 0 ]; then 
    usage
    exit 1
fi

while (true)
do
 ps -ef | grep $1 | wc
 sleep 1s
done