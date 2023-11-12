To add extra SSL certificates to the generated truststore, make sure you provide correct certificate file name in 'iam_config_vars.tpl' input file. The file should exist in current working directory (this is dictated by ncmtpl )  :
    # SERVER CERTIFICATES
    SERVER_EXTRA_SSL_CERTS: {{ if fileExists "servercerts.pem" }} {{ "servercerts.pem" | b64file }} {{ else }} "" {{ end }}
    
    #After running ncmptl command , the content of the cert file will get converted in base64 encoding and be available in iam_values.yml
    #ncmptl command for reference:
    ../ncmtpl -d bp_config_vars.yaml -d iam_config_vars.tpl iam_values.tpl -o iam_values.yml
    
Miscellaneous Notes: 
1) Place the certificate(s) in the directory from where you execute ncmptl or current directory.(certificates must be in PEM format, with .pem extension). You can put multiple files by appending the content in single file which is provided as input to the SERVER_EXTRA_SSL_CERTS.


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

