FROM debian:stretch-slim

ENV BITCOIN_VERSION 0.16.1
ENV BITCOIN_URL https://download.bitcoinabc.org/$BITCOIN_VERSION/linux/bitcoin-abc-$BITCOIN_VERSION-x86_64-linux-gnu.tar.gz

RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu gpg wget nginx supervisor \
	&& rm -rf /var/lib/apt/lists/*

RUN sed -i 's/^\(\[supervisord\]\)$/\1\nnodaemon=true/' /etc/supervisor/supervisord.conf

COPY supervisord.conf /etc/supervisor/conf.d/programs.conf

RUN bash -c 'echo alias bitcoin-cli="bitcoin-cli" >> /etc/profile.d/bitcoin-cash.sh'
RUN chmod 777 /etc/profile.d/bitcoin-cash.sh

# install bitcoin binaries
RUN set -ex \
	&& cd /tmp \
	&& wget -qO bitcoin.tar.gz "$BITCOIN_URL" \
	&& tar -xzvf bitcoin.tar.gz -C /usr/local --strip-components=1 --exclude=*-qt \
	&& rm -rf /tmp/*

VOLUME /home/bitcoin

EXPOSE 443

CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
