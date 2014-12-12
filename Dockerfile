

FROM    dockerfile/java:oracle-java8


ENV     ELASTICSEARCH 1.4.0

ENV     CLOUD_AWS 2.4.0



# Install ElasticSearch.
RUN wget -qO-  https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-$ELASTICSEARCH.tar.gz | tar xvz --transform s/elasticsearch-$ELASTICSEARCH/elasticsearch/ -C /


WORKDIR /elasticsearch

RUN     bin/plugin -install elasticsearch/elasticsearch-cloud-aws/${CLOUD_AWS}
RUN     bin/plugin -install lukas-vlcek/bigdesk


# Expose ports.
#   - 9200: HTTP
#   - 9300: transport
EXPOSE 9200
EXPOSE 9300


COPY        elasticsearch.yml  /elasticsearch/config/elasticsearch.yml

ENTRYPOINT   /elasticsearch/bin/elasticsearch
