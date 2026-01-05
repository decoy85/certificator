#!/usr/bin/env bash

echo "#######################################"
echo "          ---CERTIFICATOR ---"
echo "#######################################"

echo "Enter name for your authority [ENTER]:"
read CA_NAME

echo "Enter your domain name [ENTER]:"
read DOMAIN



if [ -z "$CA_NAME" ] || [ -z "$DOMAIN" ] ; then
	echo "missing authority and/or domain name."
	echo "exit."
else
	# Create the extfile.ext
	cat <<- EOF > extfile.ext
		basicConstraints=CA:FALSE
		keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
        extendedKeyUsage = serverAuth
		subjectAltName = @alt_names
		[alt_names]
		DNS.1 = $DOMAIN
	EOF
	

	# Generate CA Key.
	openssl genrsa -aes256 -out $CA_NAME.key 4096

	# Generate Root Certificate for the CA.
	openssl req -x509 -new -nodes -key $CA_NAME.key -sha256 -days 1825 -out $CA_NAME.pem

	# Generate Private Key
	openssl genrsa -out $DOMAIN.key 4096

	# Generate Certificate Signing Request (CSR) with the new private key.
	openssl req -new -key $DOMAIN.key -out $DOMAIN.csr

	# Generate a certificate using:
	# - our CSR
	# - our Private Key
	# - our Certificate
	# - ext file (to define our SAN's)
	openssl x509 -req -in $DOMAIN.csr \
			-CA $CA_NAME.pem \
			-CAkey $CA_NAME.key -CAcreateserial -out $DOMAIN.crt -days 825 -sha256 \
			-extfile extfile.ext

	echo "#######################################"
	echo " You have to add the $CA_NAME.pem file "
	echo "    to Authorities in your browser.    "
	echo "#######################################"
	echo "exit."
fi
