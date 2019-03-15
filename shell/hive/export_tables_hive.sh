#!/bin/bash


#With Zookeeper
url_zoo="jdbc:hive2://8.8.8.8:2181,8.8.8.9:2181,8.8.8.10:2181/;serviceDiscoveryMode=zooKeeper;zooKeeperNamespace=hive"
url="jdbc:hive2://<host>:<port>/<db>;auth=noSasl"

##########################################
# erease all files
rm -R ddl
mkdir -p ddl
##########################################

function export_all_ddl {
	echo  "#####  export_all_ddl  #####"
   
	beeline -u $url -n bla -p bla --silent=true --outputformat=csv2 --showHeader=false >>ddl/all_databases.csv -e 'show databases;'
   
	while read -r line 
	do	
		export_all_tables $line
		export_all_create_table_DDL $line
	done <ddl/all_databases.csv
}

function export_all_tables {
    echo  "#####  export_all_tables  #####"   
    hiveDBName=$1
	echo " $hiveDBName"
	mkdir -p "ddl/${hiveDBName}/"
	all_tables_file_name="ddl/${hiveDBName}/all_table_partition_DDL.csv"
	
	beeline -u $url -n bla -p bla --silent=true --showHeader=false --outputformat=csv2 >>"ddl/${hiveDBName}/all_table.csv" -e 'use '${hiveDBName}'; show tables;'	
}

function export_all_create_table_DDL {	
	echo "export_all_create_table"
	hiveDBName=$1
	
	while read -r table_name 
	do	
		echo "  $table_name"
		beeline -u $url -n bla -p bla --silent=true --showHeader=false --outputformat=csv2 >>"ddl/${hiveDBName}/${table_name}.sql" -e 'SHOW CREATE TABLE '${hiveDBName}'.'${table_name}';'
	done <ddl/${hiveDBName}/all_table.csv
}

export_all_ddl