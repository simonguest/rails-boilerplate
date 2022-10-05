# Rails Boilerplate

Boilerplate project for running Rails 6.0.6 using Ruby 2.7.5 with MySQL 5.7. The project runs as two docker containers (web and db).

## Building the Containers

`docker compose build`

## Running the Containers

`docker compose up`

## Configuring RubyMine Remote SDK

* Ensure containers are running
* Create remote Ruby SDK
* Select docker compose and reference the docker-compose.yml file
* Select web service
* Use `/home/dev/.rbenv/versions/2.7.5/bin/ruby` as path to ruby bin

## Configuring Rails Project Structure

* In RubyMine, right click on src folder and mark as "Ruby Project Root"
* Go into Ruby SDK preferences. Ensure Remote SDK is default for both root and src projects.
* Edit run/debug configurations. Ensure docker up is default. (Docker exec also works, but won't terminate the rails process on stop.)

## Seed New DB

* Services / Right Click on web container and create terminal.
* Enter:
`rake db:create`
`rake db:seed`

## Test

* Run Development:src project and browse to http://localhost:3000