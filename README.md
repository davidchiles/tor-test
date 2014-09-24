# TOR-Test

This is simple app for testing background fetch and TOR. The app opens up in the background connects to TOR and attempts to download the NY Times rss feed. It records how long each step takes.

## Setup

`git clone git@github.com:davidchiles/tor-test.git`

`cd tor-test`

`pod install`

## Running
For this to work it has to be run on device. In order to manually trigger a background fetch go to Debug → Simulate Background Fetch. That should create a new record.
