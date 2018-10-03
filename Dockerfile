FROM centos:7
RUN yum install -y epel-release && yum install -y python-pip

COPY requirements.txt /
RUN pip install -r /requirements.txt

ENV SCHEMAS_ROOT /validator

COPY validator ${SCHEMAS_ROOT}

ENTRYPOINT [ "/validator/validate.py" ]
