#!/bin/sh

getArray() {
    array=() # Create array
    while IFS= read -r line # Read a line
    do
        array+=("$line") # Append line to the array
    done < "$1"
}

PS3="Please enter your choice: "
options=("Insert Domain" "Remove Domain" "Update Database" "Rollback Database" "Export all database" "Import all database" "Reset password" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Insert Domain")
            clear
            echo "Please insert new domain: "
            read vardomain
            echo "Please insert email buyer: "
            read email

            PS3="Please enter your package: "
            pakets=("Paket 3 bulan" "Paket 6 bulan" "Paket 12 bulan" "Quit")
            select pkg in "${pakets[@]}"
            do
                case $pkg in
                    "Paket 3 bulan")
                        paket=1
                        echo "Paket Paket $paket bulan berhasil dipilih"
                    break
                ;;
                    "Paket 6 bulan")
                        paket=2
                        echo "Paket Paket $paket bulan berhasil dipilih"
                    break
                ;;
                    "Paket 12 bulan")
                        paket=3
                        echo "Paket Paket $paket bulan berhasil dipilih"
                    break
                ;;
                    "Quit")
                    clear
                    break
                    ;;
                *) echo "invalid option $REPLY";;
                esac
            done

            docker exec -i cn_mysql_sistore mysql -uroot -proot -e 'CREATE DATABASE `'$vardomain'`;' && \
            docker exec -i cn_mysql_sistore sh -c "exec mysql -uroot -proot $vardomain" < ./masterdb_sistore_for_client.sql
            docker exec -i cn_mysql_sistore mysql -uroot -proot -e 'use `'$vardomain'`;' -e 'UPDATE admins SET email = "'$email'";'
            docker exec -i cn_mysql_sistore mysql -uroot -proot -e 'use sistoreid_db; INSERT INTO domain VALUES (NULL, "'$vardomain'", "'$vardomain'", "'$email'", "'$paket'", "'1'", NOW(), NULL);'
            curl http://sishop.com/g3n3r4t3-d0m41n/$email
            echo "$vardomain" >> domain.txt
            echo "Domain $vardomain insert done \n"

            break
            ;;
        "Remove Domain")
            clear
            echo "Please insert domain name to remove: "
            read vardomain

            docker exec -i cn_mysql_sistore mysql -uroot -proot -e 'DROP DATABASE `'$vardomain'`;'
            docker exec -i cn_mysql_sistore mysql -uroot -proot -e 'use sistoreid_db; UPDATE domain SET status = "'0'", updated_at = NOW() WHERE domain_name = "'$vardomain'";'
            sed "/$vardomain/d" ./domain.txt > ./tmp.txt
            rm ./domain.txt
            mv ./tmp.txt ./domain.txt
            echo "Domain $vardomain remove done\n"

            break
            ;;
        "Update Database")
            clear
            getArray "domain.txt"
            for i in "${array[@]}"
            do
              docker exec -i cn_mysql_sistore mysql -uroot -proot -e "use $i; ALTER TABLE products ADD status INT(191) NULL AFTER price;"
              echo "domain $i update done";
            done

            echo "you chose choice $REPLY which is $opt"
            break
            ;;
        "Rollback Database")
            clear
            getArray "domain.txt"
            for i in "${array[@]}"
            do
              docker exec -i cn_mysql_sistore mysql -uroot -proot -e "use $i; ALTER TABLE products DROP status;"
              echo "domain $i rollback done";
            done

            echo "you chose choice $REPLY which is $opt"
            break
            ;;
        "Export all database")
            docker exec cn_mysql_sistore sh -c "exec mysqldump --all-databases -uroot -proot" > ./all-databases.sql
            clear
            echo "you chose choice $REPLY which is $opt \n"
            echo "Export all database done"
            break
            ;;
        "Import all database")
            clear
            docker exec -i cn_mysql_sistore sh -c "exec mysql -uroot -proot" < ./all-databases.sql
            
            echo "you chose choice $REPLY which is $opt \n"
            echo "Export all database done"
            break
            ;;
        "Reset password")
            clear
            echo "Please insert domain name: "
            read vardomain
            curl http://sishop.com/r3s3t-p455w0rd/$vardomain
            break
            ;;
        "Quit")
            clear
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done