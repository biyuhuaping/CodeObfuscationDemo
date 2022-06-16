#!/bin/sh

#  confuse.sh
#  demo
#
#  Created by ZB on 2022/6/16.
#  
TABLENAME=symbols
#混淆时生成的数据库文件
SYMBOL_DB_FILE="$PROJECT_DIR/CodeObfuscation/symbols"
#需要混淆的方法名称
STRING_SYMBOL_FILE="$PROJECT_DIR/CodeObfuscation/func.list"
#单词库文件，一行1个单词
HEAD_FILE="$PROJECT_DIR/CodeObfuscation/codeObfuscation.h"
#单词库文件，一行1个单词
WORDS_FILE="$PROJECT_DIR/CodeObfuscation/words.txt"
export LC_CTYPE=C

 
#维护数据库方便日后作排重
createTable(){
    echo "create table $TABLENAME(src text, des text);" | sqlite3 $SYMBOL_DB_FILE
}

insertValue(){
    echo "insert into $TABLENAME values('$1' ,'$2');" | sqlite3 $SYMBOL_DB_FILE
}

query(){
    echo "select * from $TABLENAME where src='$1';" | sqlite3 $SYMBOL_DB_FILE
}

#随机字符串
ramdomString(){
    openssl rand -base64 64 | tr -cd 'a-zA-Z' |head -c 16
}

#字符串首字母大写
capitalizedString() {
  str=$1
  firstLetter=`echo ${str:0:1} | awk '{print toupper($0)}'`
  otherLetter=${str:1}
  result=$firstLetter$otherLetter
  echo $result
}

#从单词库中获取随机字符串
ramdomString2(){
    list=(`cat $WORDS_FILE`)
    #1000为单词库中的单词个数，不能超过总数
    randomIndex1=$[$RANDOM%1000+1]
    words1=${list[$randomIndex1]}
    #取出来第2个单词并将首字母大写
    randomIndex2=$[$RANDOM%1000+1]
    words2=${list[$randomIndex2]}
    newWords2=$(capitalizedString $words2)
    #将2个单词拼接，也可以3个、4个等更多
    totalWords=$words1$newWords2
    echo $totalWords
}

rm -f $SYMBOL_DB_FILE
rm -f $HEAD_FILE
createTable
 
 
touch $HEAD_FILE
echo '#ifndef Demo_codeObfuscation_h
#define Demo_codeObfuscation_h' >> $HEAD_FILE
echo "//confuse string at `date`" >> $HEAD_FILE
cat "$STRING_SYMBOL_FILE" | while read -ra line; do
if [[ ! -z "$line" ]]; then
ramdom=$(ramdomString2)
#ramdom=`ramdomString2`
insertValue $line $ramdom
echo "#define $line $ramdom" >> $HEAD_FILE
fi
done
echo "#endif" >> $HEAD_FILE

sqlite3 $SYMBOL_DB_FILE .dump

