keywords=("map" "samba" "snmp" "telnet" "trace" "john" "hydra" "meta" "ploit" "nginx" "dns" "ftp" "nfs" "vnc" "wire" "crack" "ripper") 

for (( i=0; i<${#keywords}; i++ ));
do
    dpkg -l | grep ${keywords[i]} >> ProgramCheck.txt
done