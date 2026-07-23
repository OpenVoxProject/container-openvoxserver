# Example catalog for CI testing

host { 'test.example.com':
  ensure => present,
  ip     => '10.0.0.1',
}

cron { 'nightly-job':
  ensure  => present,
  command => '/bin/true',
  user    => 'root',
  hour    => '2',
  minute  => '0',
}
