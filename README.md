### Retiqueta API [![Codeship Status for rafael/retiqueta-api](https://codeship.com/projects/bff80d60-477d-0133-5250-066ef9c7f962/status?branch=master)](https://codeship.com/projects/105041)


Version 0.1 of the Retiqueta API. All the endpoints necessary for the Minimum Viable Product
will live under this repo.

#### Development

You must have docker and docker-compose installed. If you use OSX you also need docker-machine

In order to configure Kong you need to set the variable `DOCKER_HOST_IP` to the IP of the docker host machine

If you're using docker-machine, this example shows you how to run all services.
```
$ DOCKER_HOST_IP=$(docker-machine ip DOCKER_MACHINE_NAME) docker-compose up
```

#### Testing

To run tests within the containers, first start all services with docker-compose and then run

```
$ docker-compose run api bundle exec rspec
```

or

```
$ docker exec retiquetaapi_api_1 bundle exec rspec
```

test 5
