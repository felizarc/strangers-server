# Strangers Web Service

Search for phone numbers in emails.

## Install the application

`bundle install`

## Run the application

`foreman start`

## Run the tests

`rake`

## API endpoints

Here are a couple of example REST requests using `curl`:

    curl -i -H "Accept: application/json" http://localhost:4567/

    curl -i -H "Accept: application/json" -X POST -d "user[login]=toto&user[password]=XXX" http://localhost:4567/users/new
    curl -i -H "Accept: application/json" -X DELETE http://localhost:4567/user

    curl -i -H "Accept: application/json" -X POST -d "account[host]=imap.googlemail.com&account[username]=totothestranger&account[password]=XXX" http://localhost:4567/accounts/new
    curl -i -H "Accept: application/json" -X PATCH -d "account[password]=YYY" http://localhost:4567/accounts/1
    curl -i -H "Accept: application/json" -X DELETE http://localhost:4567/accounts/1

    curl -i -H "Accept: application/json" -X POST -d "number=000000000" http://localhost:4567/find

