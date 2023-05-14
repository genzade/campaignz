# Campaignz

notes here

## Prerequisites

Make sure you have the following installed on your system:

- Ruby `3.1.2`
- Rails `7.0.4`
- Bundler `2.3.15`
- PostgreSQL
  - Ensure you have the [pg gem](https://github.com/ged/ruby-pg) installed
    successfully before continuing (unless you want to run in docker container)
- Docker (optional)
- Docker-Compose (optional)

## Getting Started

Clone this repo

```shell
$ git clone https://github.com/YOUR-USERNAME/RAILS-APP.git path/to/app
$ cd path/to/app
$ bin/setup
```

### Start the App

```shell
$ bin/rails s
```

If you have docker and docker-compose installed, you can run the following instead;

```shell
$ docker-compose up --build --renew-anon-volumes
```

go to `localhost:3000`

## Running Tests

```shell
$ bundle exec rspec spec
```
