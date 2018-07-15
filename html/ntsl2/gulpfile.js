/* Dependencies */

// Regular node dependencies
var child_process = require("child_process");
var fs = require("fs");
var path = require("path");

// Main compilers
var browserify = require("browserify");
var gulp = require("gulp");

// Extras
var del = require("del");
var concat = require("gulp-concat");
var flatten = require("gulp-flatten");
var source = require("vinyl-source-stream");

/* Configuration */
const watch_targets = [
	"./src/index.js",
	"./src/css/*",
	"./src/js/*",
	"./src/html/**/*"
]

const output = {
	"css": "bundle.css",
	"dest": "./dist/",
	"js": "bundle.js"
};

/* Helper functions */
const glob = function (path) {
	return `${path}/*`;
};

/* Clean out the dist directory to get rid of any old build artifacts. */
gulp.task("clean", function () {
	del(glob(output.dest));
});

/* This uses browserify to compress every single require() into a single javascript file. */
gulp.task("browserify", function () {
	var b = browserify("./src/index.js");
	b.bundle()
		.pipe(source(output.js))
		.pipe(gulp.dest(output.dest))
});


/* CSS concatenation and output. */
gulp.task("css", function () {
	gulp.src("./src/css/*.css")
		.pipe(concat(output.css))
		.pipe(gulp.dest(output.dest))
});

/* Basically just copy-paste the html files into the dest, but flatten the directory structure. */
gulp.task("etc", function () {
	gulp.src("./src/html/**/*.html")
		.pipe(flatten())
		.pipe(gulp.dest(output.dest));
	gulp.src("./src/img/*")
		.pipe(gulp.dest(output.dest));
});

// This runs all of the other defined tasks on "gulp"
gulp.task("default", ["clean", "browserify", "css", "etc"])

// Autoreload
gulp.task("reload", ["default"], function() {
	child_process.exec("reload.bat", function (err, stdout) {
		if (err)
			throw err;

		var byond_cache = path.join(stdout.trim(), "BYOND", "cache");
		var files = fs.readdirSync(byond_cache);
		for (let file of files) {
			let filepath = path.join(byond_cache, file);
			let stats = fs.statSync(filepath)
			if (file.startsWith("tmp") && stats.isDirectory()) {
				var tmpFiles = fs.readdirSync(filepath);
				if (tmpFiles.includes("bundle.js")) {
					setTimeout(function () {transfer_files(filepath)}, 500);
				}
			}
		}
	});
});

function transfer_files(target) {
	var filesToTransfer = fs.readdirSync(path.join(".", "dist"));
	for (let file of filesToTransfer) {
		console.log(file, path.join(target, file))
		let filepath = path.join(".", "dist", file);
		fs.createReadStream(filepath).pipe(fs.createWriteStream(path.join(target, file)))
	}
}

gulp.task("watch", function () {
	gulp.watch(watch_targets, ["reload"]);
});