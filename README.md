# RoR API
## Introduction to API using Ruby on Rails

This API exercise is based on the video series https://youtu.be/gnymlh4Ljvw
The target is to build a simple book store application using
 - RoR as an API back end
 - VueJS for the front end

<img width="1272" alt="Screenshot 2021-07-02 at 16 19 25" src="https://user-images.githubusercontent.com/33062224/124288579-9f841700-db51-11eb-9746-d943bf014b38.png">

## Starting with basic models and controllers

### Rails new

Let's start by creating a new Rails app with only api features
In the terminal
```
rails new to_do_backend --api

cd to_do_backend
git add . && git commit -m "To Do api"
gh repo create
git push origin master