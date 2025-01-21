apk add openssl-util shadow-useradd

useradd --user-group --system --create-home \
--home-dir /etc/step-ca \
--shell /bin/false step
