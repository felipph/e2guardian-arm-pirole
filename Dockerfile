FROM ubuntu:jammy

ENV conf=/etc/e2guardian
ENV ssl=${conf}/ssl
ENV servercerts=${ssl}/servercerts
ENV generatedcerts=${ssl}/generatedcerts
ENV caprivkey=${servercerts}/caprivatekey.pem
ENV capubkeycrt=${servercerts}/cacertificate.crt
ENV capubkeyder=${servercerts}/my_rootCA.der
ENV upstreamprivkey=${servercerts}/certprivatekey.pem


RUN apt-get update && apt-get install -y e2guardian vim

## criar as pastas de certificados:
RUN mkdir -p $ssl
RUN mkdir -p $servercerts
RUN mkdir -p $generatedcerts
RUN chown e2guardian:e2guardian $ssl -R


##gerar os certificados:

RUN openssl genrsa 4096 > $caprivkey &&\
    openssl req -new -x509 -subj "/CN=e2guardian/O=e2guardian/C=US" -days 3650 -sha256 -key $caprivkey -out $capubkeycrt &&\
    openssl x509 -in $capubkeycrt -outform DER -out $capubkeyder &&\
    openssl genrsa 4096 > $upstreamprivkey &&\
    echo -e "INFO: Created the following certs: \n$(md5sum $servercerts/*.*)"

## configurando o arquivo

RUN sed -i -E 's|(caprivatekeypath = )(.*)|\1 '$caprivkey' |g' $conf/e2guardian.conf
RUN sed -i -E 's|(cacertificatepath = )(.*)|\1 '$capubkeycrt' |g' $conf/e2guardian.conf
RUN sed -i -E 's|(generatedcertpath = )(.*)|\1 '$generatedcerts' |g' $conf/e2guardian.conf
RUN sed -i -E 's|(certprivatekeypath = )(.*)|\1 '$upstreamprivkey' |g' $conf/e2guardian.conf
RUN sed -i s/"enablessl = off"/"enablessl = on"/g $conf/e2guardian.conf

ENTRYPOINT [ "e2guardian","-Q","-N"]