rec {
  hosts.cardanow = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILjo9j58l2GbQlyc0pd7MIg6roEEUpdKiS8DnBOdLlJA root@cardanow";
  users = {
    aciceri = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCzCmDCtlGscpesHuoiruVWD2IjYEFtaIl9Y2JZGiOAyf3V17KPx0MikcknfmxSHi399SxppiaXQHxo/1wjGxXkXNTTv6h1fBuqwhJE6C8+ZSV+gal81vEnXX+/9w2FQqtVgnG2/mO7oJ0e3FY+6kFpOsGEhYexoGt/UxIpAZoqIN+CWNhJIASUkneaZWtgwiL8Afb59kJQ2E7WbBu+PjYZ/s5lhPobhlkz6s8rkhItvYdiSHT0DPDKvp1oEbxsxd4E4cjJFbahyS8b089NJd9gF5gs0b74H/2lUUymnl63cV37Mp4iXB4rtE69MbjqsGEBKTPumLualmc8pOGBHqWIdhAqGdZQeBajcb6VK0E3hcU0wBB+GJgm7KUzlAHGdC3azY0KlHMrLaZN0pBrgCVR6zBNWtZz2B2qMBZ8Cw+K4vut8GuspdXZscID10U578GxQvJAB9CdxNUtrzSmKX2UtZPB1udWjjIAlejzba4MG73uXgQEdv0NcuHNwaLuCWxTUT5QQF18IwlJ23Mg8aPK8ojUW5A+kGHAu9wtgZVcX1nS5cmYKSgLzcP1LA1l9fTJ1vqBSuy38GTdUzfzz7AbnkRfGPj2ALDgyx17Rc5ommjc1k0gFoeIqiLaxEs5FzDcRyo7YvZXPsGeIqNCYwQWw3+U+yUEJby8bxGb2d/6YQ==";
    albertodvp = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFcH6SFgp2hFog79YE0T3eft/Fq3gciYJi+msTCgZMtO";
    albertoefg = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDEt36fOS6dEl6eiA38jR2TSc1zZqELSsICUFRShJUvN alberto@mlabs.city";
    nazrhom = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOLsYeYRKOMKKzTrsMpMLgJ70hgfldtaGOF8P1qA5JDS giovanni@mlabs.city";
  };
  secret-managers = builtins.attrValues users;
  hercules-ci = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDwwUbxrT2m14x27CoAUV10VIGuKpgYp/49//gbhfzf2 hercules-ci-effects-devops@ci.staging.mlabs.city";
}
