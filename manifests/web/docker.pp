define rgbank::web::docker(
  $db_name,
  $db_host,
  $db_user,
  $db_password,
  $docker_image,
  $image_tag = 'latest',
  $listen_port = '80',
) {
  include docker

  # Only need one instance of the image per docker host
  if ! defined(Docker::Image[$docker_image]) {
    docker::image { $docker_image: }
  }

  docker::run { $name:
    image   => $docker_image,
    ports   => ["${listen_port}:80"],
    env     => [
      "DB_NAME=${db_name}",
      "DB_PASSWORD=${db_password}",
      "DB_USER=${db_user}",
      "DB_HOST=${db_host}",
    ],
    command => 'apachectl -DFOREGROUND',
  }
}

Rgbank::Web produces Http {
  name => $name,
  ip   => $::networking['interfaces'][$::networking['interfaces'].keys[0]]['ip'],
  port => $listen_port,
  host => $::hostname,
}

Rgbank::Web consumes Database {
  db_name     => $database,
  db_host     => $host,
  db_user     => $user,
  db_password => $password,
}

Rgbank::Web consumes Vinfrastructure { }
