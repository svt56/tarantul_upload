#!/bin/bash
# задаем перменны
put="test/"
ext=".txt"
good="good"
log="log"
token=$(cat token) #токен харинтся в файле token
# создаем тестовые файлы
echo $put
rm -f test/*
rm -f good/*
for i in {1..10}
do
touch "imput/test$i.csv"
done
# функция отправки оповещения по телеграмм
function sendtlg {
id=(501055007) #6130402384) #телеграмм id принимающих отчеты в строчку разделитель пробел
url="https://api.telegram.org/bot$token/sendMessage"
for i in ${!id[@]};do
curl -s -X POST $url -d chat_id=${id[$i]} -d text="$1" -d protect_content="1"
done
}
# функция запуска скрипта
function runn {
sendtlg "start%20$1"
again=yes
python3 csv2tar.py "$1" > log/$1.log
while [ "$again" = "yes" ]
#while true
 do
  ok=$(grep -i "All ok" log/$1.log | wc -l)
  err=$(grep -i "error" log/$1.log | wc -l)
if [[ $ok == 1 ]]; then
    mv $1 /home/tamtam/kkk_csv/good/
#    str=$(tail -n 2 /home/tamtam/log/$1.log)
    str=$(cat /home/tamtam/log/$1.log)
    sendtlg "$str"
    again=no
   fi
   if [[ $err == 1 ]]; then
    str=$(tail -n 1 /home/tamtam/log/$1.log)
    sendtlg "$str"
   again=no
   fi
done
return
}
# Определим функции для обработки файла
function process_one {
    local file=$1
    local param=$2
    sendtlg "Processing%20with%20function%20one:%20$file"
#    mv test/$file test/"1.work."$file
#    python3 csv2tar.py "$1" > /home/tamtam/log/$1.log
#       sleep 20  # Симуляция времени обработки
     python3 csv2tar.py "$file" > log/$file.log
     mv imput/$file good/"1"$file
    return 1;
}

function process_two {
    local file=$1
    local param=$2
    sendtlg "Processing%20with%20function%20two:%20$file"
#    mv test/$file test/".2.work"$file
    sleep 8  # Симуляция времени обработки
    mv test/$file good/"2"$file
    return 2;
}

function process_three {
    local file=$1
    local param=$2
    sendtlg "Processing%20with%20function%20three:%20$file"
#    mv test/$file test/".3.work"$file
    sleep 12  # Симуляция времени обработки
    mv test/$file good/"3"$file
    return 3;
}

function process_four {
    local file=$1
    local param=$2
    sendtlg "Processing%20with%20function%20four:%20$file"
#    mv test/$file test/".4.work"$file
    sleep 3  # Симуляция времени обработки
    mv test/$file good/"4"$file
    return 4;
}

function process_five {
    local file=$1
    local param=$2
    sendtlg "Processing%20with%20function%20five:%20$file"
#    mv test/$file test/".5.work"$file
    sleep 17 # Симуляция времени обработки
    mv test/$file good/"5"$file
    return 5;
}
#возвращаем имя файла или маркер, что файлы закончились
function name_fille {
files=(input/*.csv)
#echo ${#files[@]}
if [ "${#files[@]}" -gt "0" ]
  then
     if [ "${files[0]}" != "input/*.csv" ]
     then
     echo ${files[0]:5}
     else
     echo "0"
     fi
  else
  echo "0"
fi
}

# основная часть
# считаем первые 5 файлов csv расширения
LsArr=($(ls input/))
# Запуск 5 функций параллельно
process_one ${LsArr[0]} & pid1=$!
process_two ${LsArr[1]} & pid2=$!
process_three ${LsArr[2]} & pid3=$!
process_four ${LsArr[3]} & pid4=$!
process_five ${LsArr[4]} & pid5=$!

# стратуем цикл до последнего файла
again=yes # маркер выхода их безконечного цикла
while [ "$again" = "yes" ]
 do
 wait -n
 res=$?
 case "$res" in
 1)
#   echo "end 1"
#   echo $(name_fille)
   if [ $(name_fille) != "0" ]; then
   process_one $(name_fille) & pid1=$!
   else
   again=stop
   fi
 ;;
 2)
#   echo "end 2"
#   echo $(name_fille)
   if [ $(name_fille) != "0" ]; then
   process_two $(name_fille) & pid2=$!
   else
   again=stop
   fi
 ;;
 3)
#   echo "end 3"
#   echo $(name_fille)
   if [ $(name_fille) != "0" ]; then
   process_three $(name_fille) & pid3=$!
   else
   again=stop
   fi
 ;;
 4)
#   echo "end 4"
#   echo $(name_fille)
   if [ $(name_fille) != "0" ]; then
   process_four $(name_fille) & pid4=$!
   else
   again=stop
   fi
 ;;
 5)
#   echo "end 5"
   if [ $(name_fille) != "0" ]; then
   echo $(name_fille)
   process_five $(name_fille) & pid5=$!
   else
   again=stop
   fi
 ;;
 esac

done
sendtlg "Все%20функции%20завершены."
echo "Все функции завершены."
