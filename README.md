# Strangers Web Service

Search for phone numbers in emails.

## API endpoints

### Unauthenticated requests

- GET /
- POST /users/new

### Authenticated requests

You must pass the current user credentials using [HTTP basic access authentication](https://en.wikipedia.org/wiki/Basic_access_authentication) for these requests.

- GET /accounts
- POST /accounts/new
- PUT /accounts/:id
- DELETE /accounts/:id
- POST /find
- DELETE /user

### Examples

Here are a couple of example REST requests using `curl`:

    curl -i -H "Accept: application/json" http://localhost:4567/

    curl -i -H "Accept: application/json" -X POST -d "user[login]=toto&user[password]=XXX" http://localhost:4567/users/new
    curl -i -H "Accept: application/json" -X DELETE -u 'toto:super toto' http://localhost:4567/user

    curl -i -H "Accept: application/json" -X POST -u 'toto:super toto' -d "account[host]=imap.googlemail.com&account[username]=totothestranger&account[password]=XXX" http://localhost:4567/accounts/new
    curl -i -H "Accept: application/json" -X POST -u 'toto:super toto' -d "account[host]=imap.googlemail.com&account[port]=993&account[description]=blah&account[username]=totothestranger&account[password]=XXX" http://localhost:4567/accounts/new
    curl -i -H "Accept: application/json" -X PATCH -u 'toto:super toto' -d "account[password]=YYY" http://localhost:4567/accounts/1
    curl -i -H "Accept: application/json" -X DELETE -u 'toto:super toto' http://localhost:4567/accounts/1

    curl -i -H "Accept: application/json" -X POST -u 'toto:super toto' -d "number=000000000" http://localhost:4567/find

## Install the application

`bundle install`

## Run the application

`foreman start`

## Run the tests

`rake`

