from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return "<h1>Pandora's box awaits.</h1>"

@app.route('/health')
def health():
    return {'status': 'healthy'}

def main():
    app.run(debug=True, host='0.0.0.0', port=8080)

if __name__ == "__main__":
    main()
