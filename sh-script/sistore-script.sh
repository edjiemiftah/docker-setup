#!/bin/bash

getArray() {
    array=()
    while IFS= read -r line
    do
        array+=("$line")
    done < "$1"
};

PS3="Please enter your choice: "
options=("Insert Domain" "Remove Domain" "Update Database" "Rollback Database" "Export all database" "Import all database" "Reset password" "DNS Record WITH MX Record" "Quit")
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
            curl http://sishop.com/g3n3r4t3-d0m41n/$email/$vardomain
            echo "$vardomain" >> domain.txt
            echo "$vardomain" >> database.txt
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
            sed "/$vardomain/d" ./database.txt > ./tmp-db.txt
            rm ./domain.txt
            mv ./tmp.txt ./domain.txt
            rm ./database.txt
            mv ./tmp-db.txt ./database.txt
            echo "Domain $vardomain remove done\n"

            break
            ;;
        "Update Database")
            clear
            getArray "database.txt"
            for i in "${array[@]}"
            do
              docker exec -i cn_mysql_sistore mysql -uroot -proot -e "use $i; 
                CREATE TABLE order_details (
                    id int(11) NOT NULL,
                    order_id int(11) NOT NULL,
                    product_id int(11) NOT NULL,
                    qty tinyint(3) NOT NULL,
                    price float(17,2) NOT NULL,
                    status enum('pending','waiting verification','on process','on delivery','done','rejected','complain','returned') NOT NULL DEFAULT 'pending',
                    created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    updated_at timestamp NULL DEFAULT NULL
                ) ENGINE=InnoDB DEFAULT CHARSET=latin1;

                CREATE TABLE returs (
                    id int(11) NOT NULL,
                    product_id int(11) NOT NULL,
                    order_number varchar(255) NOT NULL,
                    qty tinyint(3) NOT NULL,
                    price float(17,2) NOT NULL,
                    amount float(17,2) NOT NULL,
                    payment_gateway_id int(11) NOT NULL,
                    account_bank varchar(100) DEFAULT NULL,
                    account_name varchar(100) DEFAULT NULL,
                    account_number varchar(100) DEFAULT NULL,
                    payment_status enum('pending','paid','canceled') NOT NULL DEFAULT 'pending',
                    evidence varchar(255) DEFAULT NULL,
                    sender_bank varchar(30) DEFAULT NULL,
                    sender_name varchar(100) DEFAULT NULL,
                    sender_number varchar(50) DEFAULT NULL,
                    created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    updated_at timestamp NULL DEFAULT NULL,
                    created_by int(11) NOT NULL,
                    updated_by int(11) DEFAULT NULL
                ) ENGINE=InnoDB DEFAULT CHARSET=latin1;

                ALTER TABLE order_details ADD PRIMARY KEY (id);
                ALTER TABLE returs ADD PRIMARY KEY (id);
                ALTER TABLE order_details MODIFY id int(11) NOT NULL AUTO_INCREMENT;
                ALTER TABLE returs MODIFY id int(11) NOT NULL AUTO_INCREMENT;
                ALTER TABLE generalsettings  ADD is_whatsapp TINYINT(1) NOT NULL DEFAULT '1'  AFTER is_secure,  ADD whatsapp TEXT NULL  AFTER is_whatsapp;
                "
              echo "domain $i update done";
            done

            echo "you chose choice $REPLY which is $opt"
            break
            ;;
        "Rollback Database")
            clear
            getArray "database.txt"
            for i in "${array[@]}"
            do
              docker exec -i cn_mysql_sistore mysql -uroot -proot -e "use $i; 
                    DROP TABLE order_details;
                    DROP TABLE returs;
                    ALTER TABLE generalsettings DROP is_whatsapp;
                    ALTER TABLE generalsettings DROP whatsapp; 
                "
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
        "DNS Record WITH MX Record")
            clear
            echo "Please insert domain name: "
            read vardomain
            sed "s/sistore.com/$vardomain/g" ./dns.txt > ./dns-$vardomain.txt
            echo "DNS $vardomain making done \n"
            cat dns-$vardomain.txt

            break
            ;;
        "Quit")
            clear
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done