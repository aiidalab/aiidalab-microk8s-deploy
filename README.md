# AiiDAlab deployment for MSD (PSI)

This repository contains documentation and scripts for the AiiDAlab
 deployment for the MSD group at PSI.

The deployment is currently hosted on the dev-aiidalab virtual machine.

## Instructions to setup a new deployment

To create a new deployment on an Ubuntu Linux virtual machine
(tested with Ubuntu 20.04):

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
sudo git clone https://github.com/csadorf/aiidalab-microk8s-deploy.git
```

### Deploy AiiDAlab with

```console
cd /var/aiidalab-microk8s-deploy
./install.sh
```

### Configure nginx as reverse proxy to make AiiDAlab accessible.

First, obtain the external ip address of the public proxy with
```console
microk8s.kubectl get svc proxy-public
```

Then, install nginx, with
```console
sudo apt install nginx
```
Next, remove the default config and replace it with the aiidalab config:
```console
rm /etc/nginx/sites-enabled/default
sudo cp /var/aiidalab-for-theos/etc/nginx/aiidalab-for-psi /etc/nginx/sites-enabled/
```
If needed, replace the IP address in the
`/etc/nginx/sites-enabled/aiidalab-for-psi` config file on the line that
states `proxy_pass` with the IP address you obtained for the public proxy.

Finally, restart the proxy with
```console
sudo systemctl restart nginx
```

**Congratulations! The AiiDAlab server should now be accessible at
http://dev-aiidalab.psi.ch !**

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

The `microk8s` command use ip that can not be access, the solution is put the hostname of the machine into `/etc/hosts`.
https://stackoverflow.com/questions/50468354/kubedns-error-server-misbehaving
