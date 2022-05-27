from flask import Flask, render_template # Import Flask and render_template modules.

app = Flask(__name__) # we create an object

@app.route('/')
def head():
    return render_template('index.html', number1=12, number2=15)

@app.route('/mult')
def mult():
    num1 , num2 = 27, 15
    return render_template('body.html', value1=num1, value2=num2, value3=num1*num2)


if __name__=="__main__":
    app.run(host='0.0.0.0', port=80)
    # app.run(debug=True)