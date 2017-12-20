require 'date'
require 'pstore'
DATEBASE_NAME = 'worknote.db'
modo=0
miru=0
mirukekka=0
fruits=[1]
ruby ="y"
hizuke=Date.today.strftime("%Y%m%d")
mokuji=[]
ireru=[]
kaisuu=0
a=[]
while true do
puts "1=今日の記録を書く"
puts "2=過去の記録を日付で見る"
puts "3=検索"
puts "4=error番号検索"
puts "5=終了"
modo=gets
if modo.to_i==1
  puts "どんなworkした？"
  kyou=gets
  puts "今日はいい仕事はできましたか？★〜★★★★★で入力してください。"
  star=gets
db=PStore.new(DATEBASE_NAME)
db.transaction do
  db["#{hizuke}"]={date: "#{hizuke}" , text: "#{kyou}" , star: "#{star}"}
end
elsif modo.to_i==2
  puts "いつのものを見ますか？（２０１５年１０月１０日の場合は２０１５−１０−１０）"
  miru=gets.chomp
db=PStore.new(DATEBASE_NAME)
db.transaction do
  if db.root?("#{miru}")
    print "\n日付:"
    puts db.fetch("#{miru}")[:date]
    print "\n内容:"
    puts db.fetch("#{miru}")[:text]
    print "\n評価:"
    puts db.fetch("#{miru}")[:star]
    print "\n"
  end
end
elsif modo.to_i==3
#使った変数
#kensaku 検索したい内容を記録した。
#mokuji　indexのデータベースを入れた
#mokujinaiyou 目次の内容を取り出した変数
#[naiyou]
#toridasi tureなどを入れる
#ittan いったん入れる

#1.検索したい文字列を取得する
  puts "なんて検索しますか？"
  kensaku=gets.chomp
  db=PStore.new(DATEBASE_NAME)
  db.transaction do
    db.roots.each do |item|
        if db[item][:text].include?(kensaku)==true
          #5.4の内容が検索で一致した内容を取得する。
          #6.表示する。
          puts db[item][:date]
          puts db[item][:text]
          puts db[item][:star]
        end
      end
    end
#7.終了
elsif modo.to_i==4
  puts "エラー番号を入力してください。"
  eraa=gets.chomp
  if eraa=="5h"
    puts "「入力した番号がありません」とエラーが出ています。有効な番号を入力してください。"
  else
    puts "そんなerror番号はありません。"
  end
elsif modo.to_i==5
  puts "-------------------------------------------------------"
  exit
else
  puts ""
puts "error"
puts "error number:5h"
end
puts "-------------------------------------------------------"
end

#1.検索したい文字列を取得する
#2.mokujiに入っている、データベースを取り出す。
#3.取り出した日付のファイル名のデータベースの内容を取り出す。
#4.内容の中を検索する。
#5.4の内容が検索で一致した内容を取得する。
#6.表示する。
#7.終了
