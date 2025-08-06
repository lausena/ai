from flask import Flask, render_template
import os

app = Flask(__name__, 
           template_folder='templates',
           static_folder='static')

@app.route('/')
def home():
    return render_template('home.html')

@app.route('/about')
def about():
    return render_template('about.html')

@app.route('/services')
def services():
    return render_template('services.html')

@app.route('/contact')
def contact():
    return render_template('contact.html')

@app.route('/health')
def health():
    return {'status': 'healthy'}

def main():
    app.run(debug=True, host='0.0.0.0', port=8080)

if __name__ == "__main__":
    main()
