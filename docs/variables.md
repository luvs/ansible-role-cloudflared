## Role Variables

* `cloudflared_base_url`: `"https://bin.equinox.io/c/VdrWdbjqyF/"` - upstream url to download cloudflared from



* `cloudflared_amd64_apt`: `"cloudflared-stable-linux-amd64.deb"` - the name of the deb package to install



* `cloudflared_bin_location`: `/usr/local/bin` - the location the cloudflared binary will be placed



* `cloudflared_enable_service`: `true` - whether the cloudflared argo tunnel service will be started



* `cloudflared_tunnels`: `[]` - the tunnels to create


  cloudflared_tunnels:
   - tunnel_name: foo
     tunnel_hostname: yourapp.foo.com
     tunnel_upstream: 127.0.0.1:8001

* `cloudflared_argo_provision_enabled`: `false` - Whether to provision the argo cert automatically



* `cloudflare_origin_ca_key`: `undefined` - Used to provision the argo tunnel cert.



* `cloudflare_auth_key`: `undefined` - Used to provision the argo tunnel cert.



* `cloudflare_auth_email`: `undefined` - Used to provision the argo tunnel cert.



* `cloudflare_zone_id`: `undefined` - Used to provision the argo tunnel cert.


