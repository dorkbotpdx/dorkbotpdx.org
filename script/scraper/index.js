const rimraf = require("rimraf");

const SAVE_DIR = "./save";

rimraf.sync(SAVE_DIR);

const scrape = require('website-scraper');
const options = {
  urls: ['http://dorkbotpdx.org/'],
  directory: SAVE_DIR,
};

// with async/await
//const result = await scrape(options);

// with promise
scrape(options).then((result) => {
	console.log("result:", result);
});

// or with callback
//scrape(options, (error, result) => {});
