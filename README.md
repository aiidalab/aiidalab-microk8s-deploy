# AiiDAlab deployment for small group using Microk8s

This repository contains documentation and scripts for the AiiDAlab
 deployment using Microk8s.
It is a suitable deployment for small size group with around 10-50 people.

The deployment is currently used by:
- AiiDAlab deployment for EPFL THEOS group (http://theos7.epfl.ch)
- AiiDAlab deployment for PSI MSD group (https://dev-aiidalab.psi.ch)
- AiiDAlab deployment for EU-MarketPlace project (https://materials-marketplace.aiidalab.net/)

## Instructions to setup a new deployment

To create a new deployment on an Ubuntu Linux virtual machine
(tested with Ubuntu 20.04LTS and 22.04LTS):

### Install microk8s with the following steps

_Adapted from the official [Zero-to-JH instructions][ztjh-microk8s]._
```console
sudo snap install microk8s --classic --channel=1.22/stable
sudo microk8s enable dns helm3 openebs metallb:10.64.140.43-10.64.140.49
```
Instructions were tested with Kubernetes version 1.25, but newer version
might work as well.
### Create the deployment directory with the following commands:
```console
cd /var/
sudo git clone https://github.com/aiidalab/aiidalab-microk8s-deploy.git
```

### Deploy AiiDAlab with

```console
cd /var/aiidalab-microk8s-deploy
./install.sh
```

### HTTPS cert and configure nginx

If your machine is in the internal network, you probably don't need the HTTPS setup for security.
Please skip the HTTPS setup and go to reverse proxy using the http-only setup.

If you really want to set the HTTPS for the internal machine, you can have a look at [set-up-lets-encrypt-on-intranet-website](https://davidaugustat.com/web/set-up-lets-encrypt-on-intranet-website).

#### HTTPS with Let’s Encrypt SSL

Open a terminal and execute the below command to install certbot:

```
sudo snap install --classic certbot 
```

Now, You can request SSL certificates from Let’s encrypt based on the web server.
You can use `--standalone` option to complete the domain validation by stating a dummy web server. This option needs to bind to port 80 in order to perform domain validation.

> **Warning**
> Before generate the SSL certificate please remember to stop the service running on port 80.
> Here in all our deployment we run `sudo systemctl stop nginx`.

Running following command to generate the SSL cert,

```bash
sudo certbot certonly --standalone 
```

#### Nginx as reverse proxy to make AiiDAlab accessible.

Obtain the external ip address of the public proxy with
```console
microk8s.kubectl get svc proxy-public
```

We hardcode the loaderbalance ip for proxy so the ip should be `10.64.140.44`.

Then, install nginx, with
```console
sudo apt install nginx
```

Next, replace all `aiidalab.example.net` with your own domain name.

If only http is enough running

```console
sudo cp /var/aiidalab-microk8s-deploy/etc/nginx/aiidalab-microk8s-http-only /etc/nginx/sites-available/
sudo ln -sf /etc/nginx/sites-available/aiidalab-microk8s-http-only /etc/nginx/sites-enabled/default
```

For HTTPS access,

```console
sudo cp /var/aiidalab-microk8s-deploy/etc/nginx/aiidalab-microk8s-https /etc/nginx/sites-available/
sudo ln -sf /etc/nginx/sites-available/aiidalab-microk8s-https /etc/nginx/sites-enabled/default
```

If needed, replace the IP address in the
`/etc/nginx/sites-enabled/default` config file on the line that
states `proxy_pass` with the IP address you obtained for the public proxy.

Finally, restart the proxy with
```console
sudo systemctl restart nginx
```

**Congratulations! The AiiDAlab server should now be accessible at
your domain !**

## Additional notes

- You can adjust the deployment by directly editing the
`/var/aiidalab-microk8s-deploy/aiidalab/values.yml` file and then applying the changes
by executing the `/var/aiidalab-microk8s-deploy/install.sh` script from within the
same directory.
- The deployment uses the NativeAuthenticator which enables users to create
their own user profiles, however profiles must be approved by an administrator.
Please see the [documentation][native-authenticator-docs] for more details on
user management with the native authenticator.
- The user storage can be found at /var/aiidalab-microk8s-deploy/storage and is currently not automatically backed up.

[ztjh-microk8s]: https://zero-to-jupyterhub.readthedocs.io/en/stable/kubernetes/other-infrastructure/step-zero-microk8s.html
[native-authenticator-docs]: https://native-authenticator.readthedocs.io/en/latest/

## Troubleshooting

On some machine is the localhost name not properly set when first time the machine setup, the `microk8s` command use ip that may not accessable. 
The solution is putting the hostname of the machine into `/etc/hosts`.
Check https://stackoverflow.com/questions/50468354/kubedns-error-server-misbehaving for more.

