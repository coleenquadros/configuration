FROM quay.io/openshiftio/rhel-base-nginx-redirector

ENV HTPASSWD='foo:$apr1$odHl5EJN$KbxMfo86Qdve2FH4owePn.' \
    FORWARD_HOST=web

COPY nginx.conf auth.htpasswd docker-entrypoint.sh ./

CMD ["./launch.sh"]
