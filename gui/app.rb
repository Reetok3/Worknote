# sinatraとサーバーを一回一回立ち上げ直さなくても済むように、sinatra/reloader
require "sinatra"
require "sinatra/reloader"
# Workに日付を入れるために、dateを定義。
require 'date'
# sqlite3のためには、rubygemsを定義しなければいけないらしい。
require "rubygems"
require "sqlite3"
# SQLiteを省略できるように。
include SQLite3
# DATEBASEの名前を定数で定義。
DATEBASE_NAME = 'worknote.db'
# sessionsが使えるようにする。
enable :seesions

# table一覧

# wwork → Workを保存するためのTable
# id | hizuke | work | star | tag | group

# grp   → Groupの名前とidを保存するTable
#  id  |  name

# mail  → mailのパスワードとメールアドレスを保存。
# mail | pass


# Homeにアクセスした時。
get '/' do
  erb :index
end

# 記録の新規作成画面。
get '/new' do
  session[:error]=""
  @error=session[:error]
  # 最初に入力されている値を設定。
  @text = ""
  @star = "1"
  @tag = ""
  erb :new
end

# 新規作成画面のformで送信を押した時に、
post '/newform' do
    db=Database.new(DATEBASE_NAME)
    t = db.execute("SELECT * FROM wwork")
    db.close
    # 140文字以内かどうか判定
    if params[:text].size <= 140
      #140文字以内だった場合。
      db=Database.new(DATEBASE_NAME)
      # 時刻をday変数に入れる。
      day=Time.now
      # 書き込む
      db.execute("insert into wwork values('#{t.size + 1}','#{day}' , '#{params[:text]}' , '#{params[:star]}' , '#{params[:tag]}' , 0);")
    db.close
    # 一覧画面にリダイレクト。
    redirect "/kensaku"
  else
    # もし、140文字否でなかった場合。

    # sessionのerrorに注意を記入。
    session[:error] = "１４０文字以下にしてください。"
    @error = session[:error]
    # 書き直しにならないように。
    @text = "#{params[:text]}"
    @star = "#{params[:star]}"
    @tag = "#{params[:tag]}"
    # もう一度、new.erbに行く。
    erb :new
  end
end

# 一覧画面
get '/kensaku' do
  db=Database.new(DATEBASE_NAME)
  t = db.execute("SELECT * FROM wwork")
  db.close
  # 検索条件を空（なし）にして、検索。
  # → すべてのWorkがでてくる。
  @kensaku=""
  db=Database.new(DATEBASE_NAME)
  @id1   = []
  @date1 = []
  @text1 = []
  @star1 = []
  @tag1 = []
  i=0
  while i != t.size
  if t[i][2].include?(@kensaku)==true
    # 重なりがあった場合に取り除く。
    if @date1.include?(t[i][1])==false
      @id1  .push(t[i][0])
      @date1.push(t[i][1])
      @date1.last.slice!("+0900")
      @text1.push(t[i][2])
      @star1.push(t[i][3])
      @tag1 .push(t[i][4])
    end
  end
    i += 1
  end
  db.close
  erb :kensaku
end

# search された時、にここに来る。
get '/search' do
  db=Database.new(DATEBASE_NAME)
  t = db.execute("SELECT * FROM wwork")

  db.close
  @kensaku=params[:text]
  db=Database.new(DATEBASE_NAME)
  # 検索結果を入れる、配列
  @id1 = []
  @date1 = []
  @text1 = []
  @star1 = []
  @tag1 = []
  i=0
  # workから検索
  while i != t.size
  if t[i][2].include?(@kensaku)==true
    # 二つ表示されるのを防止するために、重なっている場合は、配列に入れない。
    if @date1.include?(t[i][1])==false
      @id1  .push(t[i][0])
      @date1.push(t[i][1])
      @date1.last.slice!("+0900")
      @text1.push(t[i][2])
      @star1.push(t[i][3])
      @tag1 .push(t[i][4])
    end
  end
    if t[i][4].include?(@kensaku)==true
    # 二つ表示されるのを防止するために、重なっている場合は、配列に入れない。
      if @date1.include?(t[i][1])==false
        @id1  .push(t[i][0])
        @date1.push(t[i][1])
        @text1.push(t[i][2])
        @star1.push(t[i][3])
        @tag1 .push(t[i][4])
      end
    end
    i += 1
  end
  db.close
  erb :search
end

# delete
get '/delete/:where' do |where|
  db=Database.new(DATEBASE_NAME)
  # 指定されている、idのWorkを削除
  db.execute("delete from wwork where id='#{where}';");
  db.close
  redirect "/kensaku"
end

# groupの初期化
get '/gsyokika' do
  db=Database.new(DATEBASE_NAME)
  db.execute("drop table grp;")
  db.execute("create table grp(id integer , name text);")
  db.close
  redirect '/all'
end


get '/all' do
  db=Database.new(DATEBASE_NAME)
  @t = db.execute("SELECT * FROM wwork;")
  @g = db.execute("SELECT * FROM grp;")
  @g1 = []
  @g2 = []
  @g3 = []
  @g4 = []
  @tt = []
  i = 0
  while @g.size != i
    i += 1
  end
  i=0
  while @t.size != i
    if @t[i][5] == 0
      @tt.push(@t[i])
      @tt.last[1].slice!("+0900")
    elsif @t[i][5] == 1
      @g1.push(@t[i])
      @g1.last[1].slice!("+0900")
    elsif @t[i][5] == 2
      @g2.push(@t[i])
      @g2.last[1].slice!("+0900")
    elsif @t[i][5] == 3
      @g3.push(@t[i])
      @g3.last[1].slice!("+0900")
    elsif @t[i][5] == 4
      @g4.push(@t[i])
      @g4.last[1].slice!("+0900")
    end
    i += 1
  end
  if @g.size == 0
    @g.push([1 , ""] , [2 , ""] , [3 , ""] , [4 , ""])
  elsif @g.size == 1
    @g.push([2 , ""] , [3 , ""] , [4 , ""])
  elsif @g.size == 2
    @g.push([3 , ""] , [4 , ""])
  elsif @g.size == 3
    @g.push([4 , ""])
  end
  db.close
  erb :all
end

get '/modosu' do
  wakerukey = params[:wakeru]

  i = 0
  db = Database.new(DATEBASE_NAME)
  @t = db.execute("SELECT * FROM wwork;")
  @g = db.execute("SELECT * FROM grp;")

  while wakerukey.size != i
  db.execute("update wwork set groupid =  '0' where id = '#{wakerukey[i]}'")

  i += 1
 end
 gname=params[:gname]

 if gname == ""
  gname = "グループ#{@g.size + 1}"
 end
 db.close

 redirect '/all'
end

get '/wakeru' do
  wakerukey = params[:wakeru]
  i = 0
  db = Database.new(DATEBASE_NAME)
  @t = db.execute("SELECT * FROM wwork;")
  @g = db.execute("SELECT * FROM grp;")

  while wakerukey.size != i
  db.execute("update wwork set groupid =  '#{@g.size + 1}' where id = '#{wakerukey[i]}'")

  i += 1
 end
 gname=params[:gname]

 if gname == ""
  gname = "グループ#{@g.size + 1}"
 end
 db.execute("insert into grp values('#{@g.size+1}' , '#{gname}');")
 db.close
 redirect '/all'
end




get '/delete/:where' do |where|
  db=Database.new(DATEBASE_NAME)
  db.execute("delete from wwork where id='#{where}';");
  db.close
  redirect "/kensaku"
end

get '/kensaku' do
  db=Database.new(DATEBASE_NAME)
  t = db.execute("SELECT * FROM wwork")
  db.close
  @kensaku=""
  db=Database.new(DATEBASE_NAME)
  @id1   = []
  @date1 = []
  @text1 = []
  @star1 = []
  @tag1 = []
  i=0
  while i != t.size
  if t[i][2].include?(@kensaku)==true
    if @date1.include?(t[i][1])==false
      @id1  .push(t[i][0])
      @date1.push(t[i][1])
      @date1.last.slice!("+0900")
      @text1.push(t[i][2])
      @star1.push(t[i][3])
      @tag1 .push(t[i][4])
    end
  end
    #search for tag
    i += 1
  end
  db.close
  erb :kensaku
end


get '/mail' do
  erb :mail
end

post '/mail-setting' do
  db=Database.new(DATEBASE_NAME)
  db.execute("insert into mail values('#{params[:mail]}' , '#{params[:pass]}');")
    db.close
    redirect '/'
end
