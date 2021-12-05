FROM debian:bullseye-slim

LABEL maintainer="markaperdue@gmail.com"

RUN groupadd -g 1000 utadmin && \
        useradd -Ms /bin/bash -d /opt/ut-server -u 1000 -g utadmin utadmin

RUN apt-get update && \
        apt-get install -y bzip2 lib32gcc-s1 lib32z1 vim wget && \
        wget http://ut-files.com/Entire_Server_Download/ut-server-436.tar.gz -O /tmp/ut-server-436.tar.gz && \
        tar -xzf /tmp/ut-server-436.tar.gz -C /opt/ && \
        rm -f /tmp/ut-server-436.tar.gz && \
        wget https://github.com/OldUnreal/UnrealTournamentPatches/releases/download/v469b/OldUnreal-UTPatch469b-Linux.tar.bz2 -O /tmp/OldUnreal-UTPatch469b-Linux.tar.bz2 && \
        tar -xf /tmp/OldUnreal-UTPatch469b-Linux.tar.bz2 -C /opt/ut-server/ && \
        rm -f /tmp/OldUnreal-UTPatch469b-Linux.tar.bz2 && \
        chown -R 1000:1000 /opt/ut-server

COPY media/UnrealTournament.ini /opt/ut-server/System/UnrealTournament.ini
RUN chown utadmin:utadmin /opt/ut-server/System/UnrealTournament.ini

COPY /media/docker-entrypoint.sh /usr/local/bin/

WORKDIR /opt/ut-server/System/
EXPOSE 5080 7777-7781/udp 27900/udp

USER utadmin
ENTRYPOINT ["sh"]
CMD ["/usr/local/bin/docker-entrypoint.sh"]
