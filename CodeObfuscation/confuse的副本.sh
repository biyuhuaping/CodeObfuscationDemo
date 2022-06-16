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
 
rm -f $SYMBOL_DB_FILE
rm -f $HEAD_FILE
createTable
 
touch $HEAD_FILE
echo '#ifndef Demo_codeObfuscation_h
#define Demo_codeObfuscation_h' >> $HEAD_FILE
echo "//confuse string at `date`" >> $HEAD_FILE
cat "$STRING_SYMBOL_FILE" | while read -ra line; do
if [[ ! -z "$line" ]]; then
ramdom=`ramdomString`
echo $line $ramdom
insertValue $line $ramdom
echo "#define $line $ramdom" >> $HEAD_FILE
fi
done
echo "#endif" >> $HEAD_FILE
 
sqlite3 $SYMBOL_DB_FILE .dump
