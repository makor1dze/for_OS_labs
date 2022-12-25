#!/bin/bash
LB='\033[1;34m' # Light Blue
RED='\033[0;31m' # Red
NC='\033[0m' # No Color
Bold='\033[1m' # Bold
UWhite='\033[4;37m' # White Underline
# Помощь
Help(){
echo
echo -e "${LB}Синтаксис:${NC}" 
echo -e "	./`basename $0` [ключ] [номер группы]\n" 
echo -e "${LB}Список ключей:${NC}"
echo -e "	-a\n		Вывод имени студента, не сдавшего хотя бы один тест\n"
echo -e "	-b\n		Вывод имени студента с максимальным количеством\n	  	пятерок/четверок/троек по тестам\n"
echo -e "	-c\n		Вывод списка группы, упорядоченного по количеству\n	  	попыток сдачи теста\n"
echo
echo -e "				${RED}! ВНИМАНИЕ !${NC}"
echo -e "	       ${Bold}! Следующие ключи вводятся без номера группы !${NC}"
echo
echo -e "	-d\n		Вывод студентов с наилучшей и наихудшей посещаемостью\n	  	среди множества групп\n"
echo -e "	-e\n		Вывод по фамилиям студентов их досье\n"
echo -e "	-f\n		Вывод средней посещаемости для заданных групп"
exit
}

# Если скрипт запущен без ключа или ключ передан без аргумента
if [ -z "$1" ]
then
	Help
fi

# Если не была найдена группа, введенная пользователем
Group_Not_Found(){
echo "Возможно, такой группы нет. Для поиска доступны следующие группы:"
echo
ls ./students/groups/ | sort
}

# Если группа введена не в формате, например "A-09-19" (для ключей а-с)
Bad_Group_Input(){
echo -e "${RED}Произошла ошибка при вводе группы!${NC}"
echo "Введите правильный формат. Например, А-06-04 (буква А — латинская!)"
}


# Опции:
# Ключ -a для вывода имени студента, не сдавшего хотя бы один тест (с указанием номера теста)
# Ключ -b для вывода имени студента с максимальным количеством пятерок/четверок/троек по тестам (+ вывод таких результатов)
# Ключ -с для вывода списка группы, упорядоченного по количеству попыток сдачи теста
# Ключ -d для вывода студентов с наилучшей и наихудшей посещаемостью среди множества групп"
# Ключ -e для вывода по фамилиям студентов их досье"
# Ключ -f для вывода средней посещаемости для заданных групп"



# Функция для ключа -a
Student_Failed_Test_Search(){
grep -rH "$group.*2$" ./Криптозоология/tests/*  ./Пивоварение/tests/* > res.txt
sed -s 's/\(^.\/\)\([А-Яа-я]*\)\(\/.*\/\)\(.*\)\(:.*;\)\([A-Za-z\-]*\)\(;.*;\)\(2$\)/  \2 -> \4 -> \6/g' res.txt | uniq
rm res.txt
}

#Функция для ключа -b
Student_max_quantity_of_mark_search(){

while ! [ "$mark" == 3 -o "$mark" == 4 -o "$mark" == 5 ]
do
	read -p "Укажите оценку для поиска (3/4/5): " mark
done

list_of_students=$(cat ./students/groups/$group)
all_tests="./*/tests/*"

for student in $list_of_students
do
	quantity_of_attempts=$(egrep -rh "^$group;$student.*($mark)$" $all_tests | wc -l)
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
	echo -e "\nНикто из студентов группы \"$group\" не получал оценку \"$mark\""
else
	echo -e "\nПо вашему запросу найден студент ${Bold}$student_with_max_quantity_of_mark${NC} \nс максимальным количеством оценки \"$mark\", равным $max_quantity!"
	echo -e "\nНиже представлена сводка по его попыткам сдачи тестов на данную оценку.\n"
	egrep -rH "^$group;$student_with_max_quantity_of_mark.*($mark)$" ./Криптозоология/tests/* > res1.txt
	sed -s "s/\(^.\/\)\([А-Яа-я]*\)\(\/.*\/\)\(.*\)\(:.*;\)\([A-Za-z\-]*\)\(;.*;\)\(.*\)\(.\)\($mark$\)/  \2 -> \4 -> Количество баллов — \8 -> Оценка — $mark/g" res1.txt
	echo
	egrep -rH "^$group;$student_with_max_quantity_of_mark.*($mark)$" ./Пивоварение/tests/* > res2.txt
	sed -s "s/\(^.\/\)\([А-Яа-я]*\)\(\/.*\/\)\(.*\)\(:.*;\)\([A-Za-z\-]*\)\(;.*;\)\(.*\)\(.\)\($mark$\)/  \2 -> \4 -> Количество баллов — \8 -> Оценка — $mark/g" res2.txt
	rm res1.txt res2.txt
fi
rm attempts	
}

#Функция для ключа -c
Sorted_Group_List(){

if [ -f attempts ]
then 
	rm attempts
fi

while ! [ "$subj" == 1 -o "$subj" == 2 ]
do
	echo -e "Введите 1 для поиска по предмету Криптозоология или 2 для"
	read -p "поиска по предмету Пивоварение: " subj
	echo
done

if [ $subj == "1" ]
then
	subj=Криптозоология
	echo -e "Для поиска был выбран предмет ${UWhite}Криптозоология${NC}\n"
elif [ $subj == "2" ]
then
	subj=Пивоварение
	echo -e "Для поиска был выбран предмет ${UWhite}Пивоварение${NC}\n"
fi

list_of_students=$(cat ./students/groups/$group)

for student in $list_of_students
do
	quantity_of_attempts=$(egrep -rh "^$group;$student.*" ./$subj/tests/* | wc -l)
	echo "$student $quantity_of_attempts" >> attempts
done

echo -e "Список группы ${Bold}\"$group\"${NC}, упорядоченный по количеству попыток\nсдачи тестов по предмету ${Bold}\"$subj\"${NC}:\n"
echo "Студент      | Кол-во попыток"
echo "-------------------------------"
sort -n -t " " -k2 attempts | column -t -o "| "
rm attempts
}

#Функция для ключа -d
Student_best_worst_attendance_search(){

if [[ -f ./temp && -f ./attendances ]]
then 
	rm temp attendances
fi

group_array=()

read -a input_array -p "Укажите через пробел номера групп для поиска: "
for n in ${input_array[*]}
do
	if [[ "$n" =~ A-[0-1][0-9]-[0-9][0-9]$ ]]
	then
		if ! [ -f ./students/groups/$n ]
		then
			echo -e "\n${RED}>>> Произошла ошибка при вводе группы \"$n\"${NC}"
			Group_Not_Found
		else
			group_array+=($n)
		fi
	else
		echo -e "\n${RED}>>> Произошла ошибка при вводе группы \"$n\"${NC}"
		echo "Введите правильный формат группы. Например, А-06-04 (буква А — латинская!)"
	fi
done

if ((${#group_array[@]}))
then
	echo -e "\nДля поиска были указаны следующие группы: ${Bold}${group_array[*]}${NC}"
	for group in ${group_array[*]}
	do
		cat ./*/$group-attendance | while IFS=' ' read -r student_FIO attendance
		do
			quantity_of_attendances=0
			for ((i=1; i <= ${#attendance}; i++))
			do
				if [ ${attendance:i-1:1} -eq 1 ]
				then
					((quantity_of_attendances++))
				fi
			done
		echo "$student_FIO $quantity_of_attendances" >> temp
		done  
	done

	for group in ${group_array[*]}
	do
		list_of_students=$(cat ./students/groups/$group)
		for student in $list_of_students
		do
			grep -h "$student" temp | awk '{s+=int($2)}END{print $1" "s}' >> attendances
		done
	done

	max_quantity=0
	while IFS=' ' read -r student_FIO quantity_of_attendances
	do
		if [ $quantity_of_attendances -gt $max_quantity ]
		then
			student_with_best_attendance=$student_FIO
			max_quantity=$quantity_of_attendances
		fi	
	done < attendances

	min_quantity=$max_quantity
	while IFS=' ' read -r student_FIO quantity_of_attendances
	do
		if [ $quantity_of_attendances -lt $min_quantity ]
		then
			student_with_worst_attendance=$student_FIO
			min_quantity=$quantity_of_attendances
		fi	
	done < attendances

	echo -e "\nНайден студент ${Bold}$student_with_best_attendance${NC} с лучшей посещаемостью $max_quantity по двум предметам!\n"
	echo -e "Найден студент ${Bold}$student_with_worst_attendance${NC} с худшей посещаемостью $min_quantity по двум предметам!"

	rm temp attendances	
else
  exit
fi
}

#Функция для ключа -e
Student_dossier_search(){

if [ -f temp ]
then 
	rm temp
fi

surname_array=()

read -a input_array -p "Укажите через пробел фамилии студентов для поиска (на английском языке): "
for n in ${input_array[*]}
do
	if [[ $n =~ ^[A-Za-z-]* ]] 
	then
		grep -i "$n" ./students/general/notes/* > temp
		if [ -s temp ]
		then
			surname_array+=($n)
		else
			echo -e "\n${RED}>>> Фамилия \"$n\" вызвала ошибку${NC}\nЛибо студента с такой фамилией нет, либо фамилия неверно введена."
		fi
	fi
	[ -s temp ] && rm temp
done

if ((${#surname_array[@]}))
then
	echo -e "\nДля поиска были указаны следующие фамилии студентов: ${Bold}${surname_array[*]}${NC}\n"
	echo -e "Ниже представлены искомые досье\n"
	for student in ${surname_array[*]}
	do
		find ./students/general/notes/* -type f -iname "${student:0:1}*" | xargs grep -B1 -A1 -i "$student"
		echo
	done
else
	exit
fi
}

#Функция для ключа -f
Average_attendance_search(){

if [[ -f ./temp && -f ./attendances-* ]]
then 
	rm temp attendances-*
fi

group_array=()

read -a input_array -p "Укажите через пробел номера групп для поиска: "
for n in ${input_array[*]}
do
	if [[ "$n" =~ A-[0-1][0-9]-[0-9][0-9]$ ]]
	then
		if ! [ -f ./students/groups/$n ]
		then
			echo -e "\n${RED}>>> Произошла ошибка при вводе группы \"$n\"${NC}"
			Group_Not_Found
		else
			group_array+=($n)
		fi
	else
		echo -e "\n${RED}>>> Произошла ошибка при вводе группы \"$n\"${NC}"
		echo "Введите правильный формат группы. Например, А-06-04 (буква А — латинская!)"
	fi
done

if ((${#group_array[@]}))
then
	for group in ${group_array[*]}
	do
		cat ./*/$group-attendance | while IFS=' ' read -r student_FIO attendance
		do
			quantity_of_attendances=0
			for ((i=1; i <= ${#attendance}; i++))
			do
				if [ ${attendance:i-1:1} -eq 1 ]
				then
					((quantity_of_attendances++))
				fi
			done
		echo "$student_FIO $quantity_of_attendances" >> temp
		done  
	done

	echo -e "\nДля поиска были указаны следующие группы: ${Bold}${group_array[*]}${NC}"

	for group in ${group_array[*]}
	do
		list_of_students=$(cat ./students/groups/$group)
		for student in $list_of_students
		do
			grep -h "$student" temp | awk '{s+=int($2)}END{print $1" "s}' >> attendances-$group
		done
		echo
		awk '{ total+=$2; count++ } END { print int(total/count) }' attendances-$group | sed "s/\(.*\)/Группа ${group} по двум предметам имеет среднюю посещаемость \1/" 
	done
	rm attendances-* temp
else
	exit
fi


}


while getopts ":a:b:c:def" Option
do
	case $Option in
		a	)
			echo -e "\nБыла выбрана опция:\n	${Bold}Вывод имени студента, не сдавшего хотя бы один тест${NC}\n"
			group=$OPTARG
			echo -e "Для поиска указана группа ${UWhite}$group${NC}"
				if [[ "$group" =~ A-[0-1][0-9]-[0-9][0-9]$ ]]
				then
					if ! [ -f ./students/groups/$group ]
					then
						Group_Not_Found
					else
						echo
						Student_Failed_Test_Search
					fi	
				else
					Bad_Group_Input
					exit
				fi
		;;
		
		b 	)
			echo -e "\nБыла выбрана опция:\n	${Bold}Вывод имени студента с максимальным количеством\n	пятерок/четверок/троек по тестам${NC}\n"
			group=$OPTARG
			echo -e "Для поиска указана группа ${UWhite}$group${NC}"
				if [[ "$group" =~ A-[0-1][0-9]-[0-9][0-9]$ ]]
				then
					if ! [ -f ./students/groups/$group ]
					then
						Group_Not_Found
					else	
						Student_max_quantity_of_mark_search
					fi
				else
					Bad_Group_Input
					exit
				fi
		;;
		
		c 	)
			echo -e "\nБыла выбрана опция:\n	${Bold}Вывод списка группы, упорядоченного по количеству\n	попыток сдачи тестов по предмету${NC}\n"
			group=$OPTARG
			echo -e "Для поиска указана группа ${UWhite}$group${NC}\n"
				if [[ "$group" =~ A-[0-1][0-9]-[0-9][0-9]$ ]]
				then
					if ! [ -f ./students/groups/$group ]
					then
						Group_Not_Found
					else
						Sorted_Group_List
					fi
				else
					Bad_Group_Input
					exit
				fi
		;;
		
		d 	)
			echo -e "\nБыла выбрана опция:\n	${Bold}Вывод студентов с наилучшей и наихудшей посещаемостью\n	среди множества групп${NC}\n"
			Student_best_worst_attendance_search
		;;
		
		e	)
			echo -e "\nБыла выбрана опция:\n	${Bold}Вывод по фамилиям студентов их досье${NC}\n"
			Student_dossier_search
		;;
		
		f	)
			echo -e "\nБыла выбрана опция:\n	${Bold}Вывод средней посещаемости для заданных групп${NC}\n"
			Average_attendance_search
		;;
		
		:	) 
			echo -e "\nКлюч "-$OPTARG" вызван без аргумента. ${Bold}Вы не ввели номер группы!${NC}\n"
			Help
			exit
		;;
		
		\?  )
            echo -e "\nНеизвестный ключ :(\n"
			echo -e "Не забывайте о том, что все ключи следует вводить на ${UWhite}латинице${NC}!\n"
			Help
            exit
        ;;
  esac
done
shift $((OPTIND -1))
