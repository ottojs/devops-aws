FROM node:22.14.0-alpine3.21

USER node
WORKDIR /home/node

RUN cat <<EOF > /home/node/package.json
{
  "name": "express",
  "version": "1.0.0",
  "main": "index.js",
  "scripts": {
    "test": "echo none"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "description": "",
  "dependencies": {
    "express": "4.21.2"
  }
}
EOF
RUN npm install --ignore-scripts
RUN cat <<EOF > /home/node/index.js
const express = require('express');
const app = express();
app.get("/", function (req, res) {
  res.status(200).send("SECRET: " + process.env.MY_SECRET);
});
app.listen(8080, "0.0.0.0", function () {
  console.log("Server Listening");
  console.log("SECRET:", process.env.MY_SECRET);
});
EOF

CMD ["node", "index.js"]
