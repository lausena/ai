from flask import Flask, render_template
import os

def create_app():
    app = Flask(__name__)
    
    @app.route('/')
    def home():
        return render_template('home.html')
    
    @app.route('/about')
    def about():
        return render_template('about.html')
    
    @app.route('/services')
    def services():
        return render_template('services.html')
    
    @app.route('/strategy-call')
    def strategy_call():
        return render_template('strategy_call.html')
    
    @app.route('/contact')
    def contact():
        return render_template('contact.html')
    
    return app

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser(description='EvalPoint Flask App')
    parser.add_argument('--port', type=int, default=8080, help='Port to run the app on')
    parser.add_argument('--debug', action='store_true', help='Run in debug mode')
    
    args = parser.parse_args()
    
    app = create_app()
    app.run(host='0.0.0.0', port=args.port, debug=args.debug)