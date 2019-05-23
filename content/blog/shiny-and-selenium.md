---
title: "Shiny and Selenium"
date: 2019-05-23T14:17:06+01:00
draft: true
---

There may be better guides to this but I could not find one so I am documenting our approach to testing packaged shiny applications with `RSelenium`.

**Our situation**: we have a shiny application that exists in a package that we want to test, and we want this integrated into the usual `R CMD check` approach to testing and QA, on travis, automatically.

1. Start a selenium server (before running tests)
2. Create a re-usable remote driver (once per test suite as this seems to be quite slow - too slow to do once per test)
3. Start a shiny app on a known port
4. Connect the selenium driver to the application
5. Run the tests!
6. Ensure the application stops

The Selenium server and each shiny application will need to run in different processes. We also want to have the tests be opt-in because they’ll be slow and require significant external resources (we would not want to run them on CRAN for example) so we need failure to start running tests to be OK even if test failures are not. There’s a bit of setup to be done to make this all work!

To test this separtely from the details of a real package, I am going to create a toy package [`shinysel`](https://github.com/reside-ic/shinysel) to try and set this up. The starting point is the [setup tag](https://github.com/reside-ic/shinysel/tree/setup/), by which point we have a basic package structure that passes `R CMD check` on travis and [reports coverage to codecov](https://codecov.io/gh/reside-ic/shinysel/src/f925765/R/shinysel.R) though this is currently only ~50% at this point because none of the server code can be tested (unfortunately we won't be going any higher)

## Start a selenium server

As suggested [here](https://github.com/ropensci/RSelenium/issues/86) we are going to use docker for the server. To do this I have created two small scripts that [start](https://github.com/reside-ic/shinysel/blob/4c6bf52/scripts/selenium-start) and [stop](https://github.com/reside-ic/shinysel/blob/4c6bf52/scripts/selenium-stop) the server, along with [changes to the `.travis.yml`](https://github.com/reside-ic/shinysel/commit/4c6bf52) to enable docker and to start the server up when the travis job begins.

When developing locally, the idea is that one runs

```
./scripts/selenium-start
```

to start the server (in the background) and later on stop it with

```
./scripts/selenium-stop
```

## Connect to the selenium server

To connect to a running server, we need to do:


```
dr <- RSelenium::remoteDriver()
dr$open(silent = TRUE)
```

but this takes ~3s to run for me so that won’t do for testing. Furthermore, we want the tests to gracefully not run if we can’t make a connection to the selenium server.

The solution to this was to wrap up the driver in a function that caches the function and skips if it can’t be created [like this](https://github.com/reside-ic/shinysel/commit/4d42a29).

With that in place, if the selenium server is not running, I see:

```
Loading shinysel
Testing shinysel
✔ | OK F W S | Context
✔ |  1     1 | shinysel [0.2 s]
────────────────────────────────────────────────────────────────────────────────
test-shinysel.R:11: skip: test shiny application
Undefined error in httr call. httr output: Failed to connect to localhost port 4444: Connection refused
────────────────────────────────────────────────────────────────────────────────

══ Results ═════════════════════════════════════════════════════════════════════
Duration: 0.2 s

OK:       1
Failed:   0
Warnings: 0
Skipped:  1
```

but after the server is running we get:

```
Testing shinysel
✔ | OK F W S | Context
✔ |  2       | shinysel [3.9 s]

══ Results ═════════════════════════════════════════════════════════════════════
Duration: 3.9 s

OK:       2
Failed:   0
Warnings: 0
Skipped:  0
```

Note the Skipped test moving to OK and the fairly large increase in the time taken.

## Start a shiny app within a test

This is the most fiddly bit - we want to start a shiny application within a test in a separate process. We’re going to want to do this many times with different arguments, etc (for each test) so it needs to be easy to send these requirements to whatever separate process runs things. In my previous experience, ports don’t always close immediately so we should not use the same port for each test instance.

Suppose we had an application as a single file `myapp.R` containing:

```
shinysel::shinysel("mytitle")
```

We can run this on port 8001 from the command line with

```
Rscript -e 'shiny::runApp("myapp.R", port = 8001)'
```

And then from another R session we could connect to it with

```
dr <- selenium_driver()
dr$navigate("http://localhost:8001")
dr$getTitle()[[1]]
## [1] "mytitle"
```

but we need to do all that from a test.

To do this, we will use [`callr`](https://callr.r-lib.org/) to safely create a second, backgrounded, R process that will run the shiny app. When the object that represents this process goes out of scope and is garbage collected it will termniate the process so we don’t need to worry about clean up (step 6 in the list at the top of the post).

The final tweak made in [this commmit](https://github.com/reside-ic/shinysel/commit/84c3d04) is to make the port used auto-increment so that we don’t need to worry about ports closing slowly between tests or passing ports around.

At this point we have the core working; the selenium server can be started and stopped on demand locally and on travis, and our tests can use it and gracefully fail when it is not available, as seen on travis here.

## Coverage?

However, despite running the tests, we’re not seeing any coverage reported for them, as seen on [codecov](https://codecov.io/gh/reside-ic/shinysel/tree/5c47d34).

Because we’ve set things up to gracefully fail if selenium is not found it’s a bit of a faff to work out if the selenium tests are actually running (hence printing the output of the tests above). Better would be to enforce using selenium on travis, which this commmit enforces by defining and checking an environment variable `SHINYSEL_REQUIRE_SELENIUM`.

I had a go at following Jim Hester's suggestions in [this issue](https://github.com/r-lib/covr/issues/277) but could not get the coverage to be reported.
