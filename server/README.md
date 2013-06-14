shared cinema rest server.

* git clone
* npm install
* cake test
* node server.js

You'll also need to update the keys.js file to include your Google API key, and your mongodb url if you want to run this in production.

Make sure you use `git update-index --assume-unchanged keys.js` to make sure you don't commit your keys to a public repo.
