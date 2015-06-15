# caddy-install-script

A script to install caddy server.

Install
=======

On OS X and most *nixes

```bash
curl -fsSL bit.ly/install-caddy | bash
```

On Ubuntu and minimal *nix installations

```bash
wget -nv bit.ly/install-caddy -O - | bash
```

Run
===

If you want to quickly share a file with a friend or do some web development over http (don't worry, https forthcoming)

1. Go into the directory where the files are

```bash
pushd /path/to/directory
```

2. Run `caddy-browse` (or just `caddy` if you already have a `Caddyfile` there)

```bash
caddy-browse

# or if you have a Caddyfile
caddy
```

3. Enjoy http at your IP address

<http://192.168.1.101:2015/>
