#!/bin/bash
# This script used for add BackupPC's ssh key to client.

IP="203.162.121.115"
for i in $IP
        do
    ssh root@$i "echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAxu0zYrJOlKYQQ+IA6cbCR2sAkvnQCLrNJTtM5qmIKIGpL8XqykxuFtAWmdlEVKWRi9bgG0HPhY/dygrvuw06pBeVGk52FFQpY0ieEb0x7ujvjX6P6IlLR95nbYFxKRw9JlGj5MMVW24khemiiaZKQ1kAGSw/aoZSr4FuJmp6tY3qKLU+GCCm5Q9tQhsaJfEd5VJC/qwu4hY+AELmPOaRNLOAQLKW5ZifhpwQXaKYLsFsPd5ChXS44mOD5pJx9EcPitANP/KO3S5F0bEsi6oyMvu0nNl1p4VcTU1TPlVMh3MvPQJP/pD2B3nKv23PIBZms7CvQL/v0QTwd5akzEekvw== backuppc@BackupPC' >> /root/.ssh/authorized_keys"
    if [ $? == 0 ]
        then
            echo "Added Complete."
        else
            echo "$i is still not add key from backuppc." >> /tmp/addkey-$(date +%Y%m%d_%H%M%S).log
    fi
done

