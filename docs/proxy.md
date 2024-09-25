# Challenge.Gov Cloud.Gov Proxy Configuration

The cloud.gov account is set up by the PMO. A space is created to be dedicated to the egress proxy configuration.

## HTTP Proxy

The HTTP(S) proxy is configured in two components. Both components use the Caddy server based on the work in [cg-egress-proxy](https://github.com/GSA-TTS/cg-egress-proxy).

The first component is a local sidecar to the running Ruby on Rails application. This proxy listens on HTTP and forwards all traffic to the proxy running in the proxy space.

The second component is the proxy running in the proxy space. This proxy managed the actual allow and deny lists of URLs. This two Caddy server setup is required as Ruby cannot support the remote proxy via container-to-container TLS directly, so Caddy from the sidecar to Caddy on the proxy space handles this.

The HTTP proxy must be connected to the running application via

```
cf target -s <APP_SPACE>
cf add-network-policy <APP_NAME> <PROXY_APP_NAME> --protocol tcp --port 61443 -s <PROXY_SPACE>
```

You must get the `vars.challenge-proxy.yml` file from a developer on the team.

The HTTP proxy is deployed via:

```
cf target -s <PROXY_SPACE>
push <PROXY_APP_NAME> --vars-file vars.challenge-proxy.yml -f manifest.proxy.yml
```

## SMTP Proxy

The SMTP proxy uses an nginx stream to connect a local SMTP request on port 8080 to the external SMTP server on port 587.

The SMTP proxy must be connected to the running application via

```
cf target -s <APP_SPACE>
cf add-network-policy <APP_NAME> <SMTP_PROXY_APP_NAME> --protocol tcp --port 8080 -s <PROXY_SPACE>
```

You must get the `vars.challenge-proxy.yml` file from a developer on the team.

The SMTP proxy is deployed via:

```
cf target -s <PROXY_SPACE>
push <SMTP_PROXY_APP_NAME> --vars-file vars.challenge-proxy.yml -f manifest.proxy.yml
```

