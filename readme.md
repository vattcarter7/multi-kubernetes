### Travis CI config

Travis Login Issues, "iv undefined" or "repository not known"
updated 1-8-2021

In the upcoming lecture, we will be encrypting a service account file in the Travis container we created in the previous lecture. Travis is finalizing its transition from .org to .com, and you may end up getting errors when attempting to log in or during deployment.

The Travis login now requires a Github Token. Please follow these instructions to create a Personal Token for Travis to use here:

https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token

This will also require setting the scope. Travis requires the permissions noted here:

https://docs.travis-ci.com/user/github-oauth-scopes/#repositories-on-httpstravis-cicom-private-and-public

The login command will now look like this:

travis login --github-token YOUR_PERSONAL_TOKEN --com

or

travis login --github-token YOUR_PERSONAL_TOKEN --pro

When you encrypt the file, you must pass the same --com or --pro flag you used to log in:

travis encrypt-file service-account.json -r USERNAME/REPO --com

or

travis encrypt-file service-account.json -r USERNAME/REPO --pro

If you are getting iv undefined errors, you may have missed passing the --com or --pro flags to both the login and encryption commands. Also, if you still have a .org Travis account these old accounts will need to be migrated to .com ASAP.

Please visit the migration guide here:

https://docs.travis-ci.com/user/migrate/open-source-repository-migration#migrating-a-repository

You can also get an iv undefined error if you've passed the wrong repo to the file encryption or passed a repo name with a typo in it. Please note, after the migration, or after fixing a typo, you'll need to run through the entire encryption process again.



In the upcoming lecture, we will be adding a script to our .travis.yml file. Similar to our previous projects that ran tests using Travis, we need to make sure that the tests exit after running and don't cause our builds to fail.

Make sure to change this script:

script:
  - docker run USERNAME/react-test npm test -- --coverage
To use the CI flag and remove coverage:

script:
  - docker run -e CI=true USERNAME/react-test npm test






Helm v3 Update
updated 9-22-2020

In the next lecture, we will be installing Helm. Helm v3 has since been released which is a major update, as it removes the use of Tiller. Please follow the updated instructions for this version below:

1. Install Helm v3:

In your Google Cloud Console run the following:

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
 
link to the docs:

https://helm.sh/docs/intro/install/#from-script

2. Skip the commands run in the following lectures:

Helm Setup, Kubernetes Security with RBAC, Assigning Tiller a Service Account, and Ingress-Nginx with Helm. You should still watch these lectures and they contain otherwise useful info.

3. Install Ingress-Nginx:

In your Google Cloud Console run the following:

> helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
> helm install my-release ingress-nginx/ingress-nginx
 
IMPORTANT: If you get an error such as chart requires kubeVersion: >=1.16.0-0.....

You may need to manually upgrade your cluster to at least the version specified:

gcloud container clusters upgrade  YOUR_CLUSTER_NAME --master --cluster-version 1.16

This should not be a long term issue since Google Cloud should handle this automatically:

https://cloud.google.com/kubernetes-engine/docs/how-to/upgrading-a-cluster



Link to the docs:

https://kubernetes.github.io/ingress-nginx/deploy/#using-helm

Fullscreen
Go to Previous lecture292. Creating a Secret on Google Cloud
Go to Next lecture294. Helm Setup






Quick Note about the Default Backend
In the next lecture, you will see the Services dashboard showing an ingress controller and default backend. A default backend no longer ships with ingress-nginx, so, if you only see a controller and you get a 404 Not Found when visiting the IP address, this is perfectly expected.





Required Updates for Cert Manager Install
In the upcoming lecture, we will be installing the Cert Manager using Helm on Google Cloud. There have been some breaking changes introduced with the latest versions of Cert Manager, so we will need to do a few things differently.

Instead of the installation instructions given at around 1:20 in the video, we will complete these steps in the GCP Cloud Shell:

1. Create the namespace for cert-manager:

> kubectl create namespace cert-manager

2. Add the Jetstack Helm repository

> helm repo add jetstack https://charts.jetstack.io

3. Update your local Helm chart repository cache:

> helm repo update

4. Install the cert-manager Helm chart:

> helm install \
    cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --version v1.2.0 \
    --create-namespace
5. Install the CRDs:
> kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.2.0/cert-manager.crds.yaml

Official docs for reference:

https://cert-manager.io/docs/installation/kubernetes/#installing-with-helm






Required Update for Issuer
In the upcoming lecture, the Issuer manifest will need a few small changes per these docs:

https://docs.cert-manager.io/en/latest/tasks/issuers/setup-acme/index.html#creating-a-basic-acme-issuer

1. Update apiVersion:

apiVersion: cert-manager.io/v1

2. Add a solvers property:

    solvers:
      - http01:
          ingress:
            class: nginx
The full issuer.yaml manifest can be found below:

apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: "test@test.com"
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
      - http01:
          ingress:
            class: nginx





Required Update for the Certificate
In the upcoming lecture, a few minor changes are required per the official docs:

1. Update the API version used:

apiVersion: cert-manager.io/v1

2. Remove the acme challenge from the certificate spec.

The full updated Certificate manifest can be found below:

apiVersion: cert-manager.io/v1
 
kind: Certificate
metadata:
  name: yourdomain-com-tls
spec:
  secretName: yourdomain-com
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  commonName: yourdomain.com
  dnsNames:
    - yourdomain.com
    - www.yourdomain.com


QA thread for reference with some troubleshooting steps (see Joseph's post near the bottom)

https://www.udemy.com/course/docker-and-kubernetes-the-complete-guide/learn/lecture/11628364#questions/8558842/







No Resources Found?
If you have deployed your issuer and certificate manifests to GCP and you are getting No Resources Found when running kubectl get certificates, then continue on to the next lecture to create and deploy the Ingress manifest. Deploying the updated Ingress should trigger the certificate to be issued.


Required Update for the HTTPS Ingress
In the upcoming lecture, we need to make one small change to one of the annotations:

> certmanager.k8s.io/cluster-issuer: "letsencrypt-prod"

change to:

> cert-manager.io/cluster-issuer: "letsencrypt-prod"