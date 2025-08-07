# How to Deploy a Flask App Using Gunicorn to App Platform

*Source: https://www.digitalocean.com/community/tutorials/how-to-deploy-a-flask-app-using-gunicorn-to-app-platform*

## Introduction

In this guide, you will build a Python application using the Flask microframework on DigitalOcean's App Platform. Flask is a Python-based microframework that is popular with web developers, given its lightweight nature and ease of use.

This tutorial will focus on deploying a Flask app to App Platform using gunicorn. Gunicorn is a Python WSGI HTTP Server that uses a pre-fork worker model. By using gunicorn, you'll be able to serve your Flask application on more than one thread.

## Prerequisites

To complete this tutorial, you'll need:

* A DigitalOcean account.
* A GitHub account.
* Python3 installed on your local machine.
* A text editor.

## Step 1 — Creating a Python Virtual Environment for your Project

Before you get started, you need to set up your Python developer environment. You will install your Python requirements within a virtual environment for easier management.

First, let's create a project directory for our code and `requirements.txt` file to be stored in and change into that directory. Run the following commands:

```bash
mkdir flask-app
cd flask-app
```

Next, create a directory in your home directory that you can use to store all of your virtual environments:

```bash
mkdir ~/.venvs
```

Now create your virtual environment using Python:

```bash
python3 -m venv ~/.venvs/flask
```

This will create a directory called `flask` within your `.venvs` directory. Inside, it will install a local version of Python and a local version of `pip`. You can use this to install and configure an isolated Python environment for your project.

Before you install your project's Python requirements, you need to activate the virtual environment.

Use the following command:

```bash
source ~/.venvs/flask/bin/activate
```

Your prompt will change to indicate that you are now operating within a Python virtual environment. It will look something like this: `(flask)user@host:~$`.

With your virtual environment active, install Flask and gunicorn using the local instance of `pip`:

```bash
pip install Flask gunicorn
```

**Note:** When the virtual environment is activated (when your prompt has `(flask)` preceding it), use `pip` instead of `pip3`, even if you are using Python 3. The virtual environment's copy of the tool is always named `pip`, regardless of the Python version.

Now that you have the flask package installed, you will need to save this requirement and its dependencies so App Platform can install them later.

Do this now using `pip` and then saving the information to a `requirements.txt` file:

```bash
pip freeze > requirements.txt
```

You now have all of the software needed to start a Flask app. You are almost ready to deploy.

## Step 2 — Creating a Minimal Flask App

In this step, you will build a standard *Hello Sammy!* Flask application. You won't focus on the mechanics of Flask outside of how to deploy it to App Platform. If you wish to deploy another application, the following steps will work for a wide range of Flask applications.

Using your favorite text editor, open a file named `app.py`:

```bash
nano app.py
```

Now add the following code to the file:

**app.py**
```python
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello Sammy!'
```

This code is the standard *Hello World* example for Flask with a slight modification to say hello to your favorite shark. For more information about this file and Flask, visit the official Flask documentation.

You have written your application code. Now you will configure the Gunicorn server.

## Step 3 — Setting Up Your Gunicorn Configuration

Gunicorn is a Python WSGI HTTP server that many developers use to deploy their Python applications. This WSGI (Web Server Gateway Interface) is necessary because traditional web servers do not understand how to run Python applications. For your purposes, a WSGI allows you to deploy your Python applications consistently. You can also configure multiple threads to serve your Python application, should you need them. In this example, you will make your application accessible on port `8080`, the standard App Platform port. You will also configure two worker-threads to serve your application.

Open a file named `gunicorn_config.py`:

```bash
nano gunicorn_config.py
```

Now add the following code to the file:

**gunicorn_config.py**
```python
bind = "0.0.0.0:8080"
workers = 2
```

This is all you need to do to have your app run on App Platform using Gunicorn. Next, you'll commit your code to GitHub and then deploy it.

## Step 4 — Pushing the Site to GitHub

DigitalOcean's App Platform deploys your code from GitHub repositories. This means that you must get your site in a `git` repository and then push that repository to GitHub.

First, initialize your project directory containing your files as a `git` repository:

```bash
git init
```

When you work on your Flask app locally, certain files get added that are unnecessary for deployment. Let's exclude those files using Git's ignore list. Create a new file called `.gitignore`:

```bash
nano .gitignore
```

Add the following code to the file:

**.gitignore**
```
*.pyc
```

Save and close the file.

Now execute the following command to add files to your repository:

```bash
git add app.py gunicorn_config.py requirements.txt .gitignore
```

Make your initial commit:

```bash
git commit -m "Initial Flask App"
```

Open your browser and navigate to GitHub, log in with your profile, and create a new repository called `flask-app`. Create an empty repository without a `README` or license file.

Once you've created the repository, return to the command line and push your local files to GitHub.

First, add GitHub as a remote repository:

```bash
git remote add origin https://github.com/your_username/flask-app
```

Next, rename the default branch `main`, to match what GitHub expects:

```bash
git branch -M main
```

Finally, push your `main` branch to GitHub's `main` branch:

```bash
git push -u origin main
```

Your code is now on GitHub and accessible through a web browser. Now you will deploy your app to DigitalOcean's App Platform.

## Step 5 — Deploying to DigitalOcean with App Platform

Once you push the code, visit The App Platform Homepage and click **Launch Your App**. A prompt will request that you connect your GitHub account.

Connect your account and allow DigitalOcean to access your repositories. You can choose to let DigitalOcean access all of your repositories or just to the ones you wish to deploy.

Click **Install and Authorize**. GitHub will return you to your DigitalOcean dashboard.

Once you've connected your GitHub account, select the `your_account/flask-app` repository and click **Next**.

Next, provide your app's name, choose a region, and ensure the `main` branch is selected. Then ensure that **Autodeploy code changes** is checked. Click **Next** to continue.

DigitalOcean will detect that your project is a Python app and will automatically populate a partial **Run** command.

Click the **Edit** link next to the **Build** and **Run** commands to complete the build command.

Your completed build command needs to reference your project's WSGI file. In this example, this is at `app:app`.

Replace the existing command with the following:

```bash
gunicorn --worker-tmp-dir /dev/shm app:app
```

Click **Next**, and App Platform will direct you to the **Finalize and Launch** screen. Here you'll choose your plan. Be sure to select the plan that fits your needs, whether in **Basic App** or **Professional App**. Click **Launch App** at the bottom. Your app will build and deploy.

Once your app finishes deploying, click on the link to your app provided by App Platform. This link will take you to your *Hello Sammy* page.

You now have a Flask app deployed to App Platform. Make and push any changes to GitHub, and App Platform will automatically deploy them.

## Conclusion

In this tutorial, you set up a Flask app and deployed it using DigitalOcean's App Platform. Any changes you commit and push to your repository will trigger a new deployment. This means you can spend more time focusing on your code and expanding your application.

You can find the example code for this tutorial in the DigitalOcean Sample Images Repository.

The example in this tutorial is a minimal Flask app. Your project might have more applications and features, but the deployment process will be the same.

## Key Files Required

- `app.py` - Main Flask application
- `gunicorn_config.py` - Gunicorn server configuration
- `requirements.txt` - Python dependencies
- `.gitignore` - Git ignore file

## Important Commands

- **Run Command for App Platform**: `gunicorn --worker-tmp-dir /dev/shm app:app`
- **Port Configuration**: App Platform uses port 8080
- **Worker Configuration**: 2 workers recommended for basic setup