application rgbank (
  $db_username = 'test',
  $db_password = 'test',
  $listen_port = 8060,
  $use_docker  = false,
  $lb_port     = '80',
) {

  $db_component = collect_component_titles($nodes, Rgbank::Db)[0] #Assume we only have one
  $web_components = collect_component_titles($nodes, Rgbank::Web)
  $load_component = collect_component_titles($nodes, Rgbank::Load)[0] #Assume we only have one

  rgbank::db { $db_component:
    user     => $db_username,
    password => $db_password,
    export   => Database[$db_component],
  }

  $web_https = $web_components.map |$comp_name| {

    rgbank::web { $comp_name:
      use_docker  => $use_docker,
      listen_port => $listen_port,
      consume     => Database[$db_component],
      export      => Http["rgbank-web-${comp_name}"],
    }

    #Return HTTP service resource
    $http = Http["rgbank-web-${comp_name}"]
    $http
  }

  rgbank::load { $load_component:
    balancermembers => $web_https,
    port            => $lb_port,
    require         => $web_https,
    export          => Http[$load_component],
