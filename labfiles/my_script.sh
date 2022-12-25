#!/bin/bash

if [ $# -lt 1 ]
then
    echo -e "Не заданы входные параметры!"
    exit
fi

max=0
all_tests="./*/tests/*"
my_group=$1
my_file=students/groups/$my_group

while [ ! -f "$my_file" ]
do 
    read -p "Введите правильный номер группы: " my_group
    my_file=students/groups/$my_group
done

students_list=$(cat ./students/groups/$my_group)


for student in $students_list
do
	attempts_quantity=$(egrep -rh "^$my_group;$student.*2$" $all_tests | wc -l)
	echo "$student $attempts_quantity" >> attempts
done

while IFS=' ' read -r student_FIO attempts_quantity
do
	if [ $attempts_quantity -gt $max ]
	then
		student_with_max_quantity_of_mark=$student_FIO
		max=$attempts_quantity
	fi
done < attempts

if [ $max -eq 0 ]
then
	echo -e "\nНикто из студентов группы \"$my_group\" не получал оценку 2"
else
	echo -e "\nНайден студент $student_with_max_quantity_of_mark с максимальным количеством неудачных попыток, а именно: $max!"
	echo -e "\nСводка:"
	egrep -rH "^$my_group;$student_with_max_quantity_of_mark.*2$" ./Криптозоология/tests/* > res1.txt
	sed -s "s/\(^.\/\)\([А-Яа-я]*\)\(\/.*\/\)\(.*\)\(:.*;\)\([A-Za-z\-]*\)\(;.*;\)\(.*\)\(.\)\(2$\)/  \2|\4|Набрано баллов — \8/g" res1.txt
	egrep -rH "^$my_group;$student_with_max_quantity_of_mark.*2$" ./Пивоварение/tests/* > res2.txt
	sed -s "s/\(^.\/\)\([А-Яа-я]*\)\(\/.*\/\)\(.*\)\(:.*;\)\([A-Za-z\-]*\)\(;.*;\)\(.*\)\(.\)\(2$\)/  \2|\4|Набрано баллов — \8/g" res2.txt
	rm res1.txt res2.txt
fi
rm attempts	
