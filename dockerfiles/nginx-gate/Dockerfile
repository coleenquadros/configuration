FROM quay.io/openshiftio/rhel-base-nginx-redirector

COPY nginx.conf auth.htpasswd docker-entrypoint.sh ./

CMD ["./launch.sh"]
