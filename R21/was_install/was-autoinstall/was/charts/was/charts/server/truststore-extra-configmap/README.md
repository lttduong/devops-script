This configmap supports adding extra SSL certificates to the generated truststore.jks file.

To add extra SSL certificates to the generated truststore use utility script `install-cert.sh` located at the top-level of the application package (`/opt/bcmt/storage/app/netguard_<appname>-<app_version>`) or follow these instructions for manual installation:

1) Change useTruststoreExtraCerts to true in the server's values.yaml file (note: the version will be different than in this example):

    vi /opt/bcmt/storage/app/netguard_networkaccess-0.0.176/files/charts/na/charts/server/values.yaml

Find useTruststoreExtraCerts and change to:

    useTruststoreExtraCerts: true


2) Place the certificate(s) in the truststore-extra-configmap/ directory (certificates must be in PEM format, with .pem extension)

Use this openssl command to get a certificate from a running server:

    openssl s_client -connect <host>:<port> </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > cert.pem
    # Note: change <host>:<port> to the hostname and port of the server whose certificate you want to include

Check the certificate contents:

     openssl x509 -noout -text -in cert.pem

Now copy it to the truststore-extra-configmap directory:

    cp cert.pem /opt/bcmt/storage/app/netguard_networkaccess-0.0.176/files/charts/na/charts/server/truststore-extra-configmap/


3) Install via ncms as normal

The truststore-extra-configmap will be created on install, and the .pem file(s) will be added to the truststore.jks

To check the contents of the truststore, first you need to get a shell inside the pod (in this case, server-0):

    kubectl exec -it -n netguard-networkaccess server-0 bash

Now, use keytool to view the contents. Verify that your certificate has been included:

    cd /opt/nokia/config/certs-generated
    keytool -list -storepass changeit -keystore ./truststore.jks  # use -v for a more verbose listing

