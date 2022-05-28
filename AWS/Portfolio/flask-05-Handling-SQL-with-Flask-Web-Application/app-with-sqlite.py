from flask import Flask, render_template, request
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__) # app objemizi olusturuyoruz

# SQL icin gerekli environmentleri configure edecegiz https://flask-sqlalchemy.palletsprojects.com/en/2.x/config/
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///./email.db' # burada bir path tanimladik /ekstra database ye baglanmaya gerek yok. / calistirinca email.db dosyasi olusacak
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False # her degisiklikte bizi ikaz etmesin diye false olarak gecirdik. ikaz istiyorsak true olmali
db = SQLAlchemy(app) # database SQLAlchemy degerine ataniyor

# users tablosu olusturacagiz
drop_table = 'DROP TABLE IF EXISTS users;' # users isimli bir tablo olusturmak istiyoruz. Eger bu isimde bir tablo varsa silsin diyoruz (bir defa icra edilir
# cunku tekrar icra edilirse eskiler silinir)
users_table = """  
CREATE TABLE users(
username VARCHAR NOT NULL PRIMARY KEY,
email VARCHAR);
""" # sql komutlariyla bir tablo olusturmaya calisiyoruz. varchar ==> sayi tanimlamasi
data= """
INSERT INTO users
VALUES
    ("Firuz", "firuzhakan@amazon.com"),
    ("Fatma", "fatma@google.com"),
    ("Nezih", "nezih@tesla.com");
""" # tablo olusturduk icerisine veri giriyoruz

db.session.execute(drop_table) # yukarida tanimladigimiz verileri icra et demekteyiz.
db.session.execute(users_table)
db.session.execute(data) # icerisine yazilacak degerleri belirledik ve execute ediyor
db.session.commit() # yukaridaki execute edilen degerler commit edilmektedir(github gibi)

# email arama islemini halletmemiz gerekmektedir. kutucuga girecegimiz degerleri verilmesini saglayacaktir.

def find_email(keyword): 
    query = f"""
    SELECT * FROM users WHERE username like '%{keyword}%'; 
    """ # yuzdelerin anlami degisken icin basi ve sonu / nez yazdigimizda nezihi bize cikaracak
    result = db.session.execute(query) # yukarida tanimladigim degiskeni icra et/calistir
    user_emails = [(row[0], row[1]) for row in result] 
    if not any(user_emails):
        user_emails = [("Not Found", "Not Found")]
    return user_emails


def insert_email(name,email): # fonksiyon tanimladik 2 degiskenli / email ekleyecegiz / email ekleme fonksiyonu
    query = f""" 
    SELECT * FROM users WHERE username like '{name}'
    """ # yeni bir degisken tanimladik
    result = db.session.execute(query)
    response = ''
    if name == None or email == None: # eger deger bos girersek
        response = 'Username or email can not be empty!!'
    elif not any(result): 
        insert = f"""
        INSERT INTO users
        VALUES ('{name}', '{email}');
        """
        result = db.session.execute(insert)
        db.session.commit() # yeni veri girisi oldugu icin commit ediliyor
        response = f"User {name} and {email} have been added successfully" # ekleme yapildigini gostermektedir.
    else:
        response = f"User {name} already exist" 
    return response


@app.route('/', methods = ['POST', 'GET']) # root sayfanin dekore edilmesi
def emails():
    if request.method == 'POST': # eger bir veri girisi varsa 
        user_app_name = request.form['user_keyword']
        user_emails = find_email(user_app_name)
        return render_template('emails.html', show_result = True, keyword = user_app_name, name_emails = user_emails)
    else:
        return render_template('emails.html', show_result = False)
    
    
@app.route('/add', methods=['GET', 'POST'])
def add_email():
    if request.method == 'POST':
        user_app_name = request.form['username']
        user_app_email = request.form['useremail']
        result_app = insert_email(user_app_name, user_app_email)
        return render_template('add-email.html', result_html=result_app, show_result=True)
    else:
        return render_template('add-email.html', show_result=False)

if __name__ == '__main__':
    app.run(debug=True)
    # app.run(host='0.0.0.0', port=80)
    
# python koduna sql lite gommus olduk bu sebeple email.db dosyasi olustu

