from flask import Flask 

app = Flask(__name__)

@app.route('/')
def head():
    return "This is my first try with FLASK"

@app.route('/second')
def second():
    return "This is the second page- I like Flask"

@app.route('/third/subthird')
def third():
    return "This is the subpage of third page"

@app.route('/forth/<string:id>') # Write id number to be entered
def forth(id):
    return f"Id of this page is {id}" 

if __name__=="__main__":
    app.run(host='0.0.0.0', port=80) # It must be written to run on ec2.
    # app.run(debug=True) # If debug mode is turned off, we will not receive an error warning.
