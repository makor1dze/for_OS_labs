#!/bin/bash

if [ $# -lt 1 ]
then
    echo -e "Не заданы входные параметры для работы программы!\nЗапустите программу заново."
    exit
fi
group=$1

file=students/groups/$group
while [ ! -f "$file" ]
do 
    echo "Группа не указана или указана неверно."
    read -p "Введите правильный номер группы: " group
    file=students/groups/$group
done
echo Номер группы: $group

list_of_students=$(cat ./students/groups/$group)
all_tests="./*/tests/*"

for student in $list_of_students
do
	quantity_of_attempts=$(egrep -rh "^$group;$student.*2$" $all_tests | wc -l)
	echo "$student $quantity_of_attempts" >> attempts
done
	
max_quantity=0
while IFS=' ' read -r student_FIO quantity_of_attempts
do
	if [ $quantity_of_attempts -gt $max_quantity ]
	then
		student_with_max_quantity_of_mark=$student_FIO
		max_quantity=$quantity_of_attempts
	fi
done < attempts

if [ $max_quantity -eq 0 ]
then
	echo -e "\nНикто из студентов группы \"$group\" не получал оценку 2"
else
	echo -e "\nПо вашему запросу найден студент $student_with_max_quantity_of_mark \nс максимальным количеством оценки "2", равным $max_quantity!"
	echo -e "\nНиже представлена сводка по его попыткам сдачи тестов на данную оценку.\n"
	egrep -rH "^$group;$student_with_max_quantity_of_mark.*2$" ./Криптозоология/tests/* > res1.txt
	sed -s "s/\(^.\/\)\([А-Яа-я]*\)\(\/.*\/\)\(.*\)\(:.*;\)\([A-Za-z\-]*\)\(;.*;\)\(.*\)\(.\)\(2$\)/  \2 -> \4 -> Количество баллов — \8/g" res1.txt
	echo
	egrep -rH "^$group;$student_with_max_quantity_of_mark.*2$" ./Пивоварение/tests/* > res2.txt
	sed -s "s/\(^.\/\)\([А-Яа-я]*\)\(\/.*\/\)\(.*\)\(:.*;\)\([A-Za-z\-]*\)\(;.*;\)\(.*\)\(.\)\(2$\)/  \2 -> \4 -> Количество баллов — \8/g" res2.txt
	rm res1.txt res2.txt
fi
rm attempts	
