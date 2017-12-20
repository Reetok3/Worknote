require "mail"
require "rubygems"
require "sqlite3"
require "date"
while true do
 p Time.now.strftime("%H:%M:%S")
 if "18:00:00" == Time.now.strftime("%H:%M:%S")
  include SQLite3
  db=Database.new("worknote.db")
  t = db.execute("SELECT * FROM mail")
  db.close
  mail = Mail.new do
    from    "Worknote"
    to      "#{t[0][0]}"
    subject 'Worknote'
    body    "This is worknote reminder. \nMake sure to write todays work! \n"
  end

  mail.delivery_method :smtp, { address:   'smtp.gmail.com',
    port:      587,
    domain:    'gmail',
    user_name: "#{t[0][0]}",
    password:  "#{t[0][1]}"}
    mail.deliver!
  end
end

