FROM centos:7
RUN yum install -y epel-release && yum install -y python-pip

COPY requirements.txt /
RUN pip install -r /requirements.txt

COPY validator /validator

ENV SCHEMAS_ROOT /validator

ENTRYPOINT [ "/validator/validate.py" ]
# ENTRYPOINT [ "/validator/test.sh" ]

