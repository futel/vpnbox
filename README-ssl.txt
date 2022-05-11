## set up creds for openvpn server and client on ubuntu

We will create credentials for a certificate authority, OpenVPN server, and OpenVPN client.
We will create all credentials on the same local machine, although this is not recommended.

## set up openvpn server and certificate authority creds with easy-rsa

# create certificate authority: ca.crt, ca.key
# start at vpnbox directory
mkdir ca
cd ca
# copy easy-rsa source for ca
cp -r /usr/share/easy-rsa/ .
cd easy-rsa
./easyrsa init-pki
# create the ca creds
./easyrsa build-ca nopass
# creds are at pki/ca.crt, pki/ca.key

# create server request and key
# start at vpnbox directory
mkdir server
cd server
# copy easy-rsa source for server
cp -r /usr/share/easy-rsa/ .
cd easy-rsa
./easyrsa init-pki
# create the server creds
./easyrsa gen-req server nopass
# request and key are at pki/reqs/server.req, pki/private/server.key

# sign server certificate request with certificate authority
# start at vpnbox directory
cd ca
cd easy-rsa
./easyrsa import-req ../../server/easy-rsa/pki/reqs/server.req server
# type "yes" to confirm
./easyrsa sign-req server server
# server cert is at pki/issued/server.crt

# create pre-shared key
# start at vpnbox directory
cd ca
cd easy-rsa
openvpn --genkey --secret ta.key
# pre-shared key is at ./ta.key

# create diffie-helman key paramaters file
# note that we need this because we are not using elliptic curve
# start at vpnbox directory
cd server
openssl dhparam -out dh.pem 2048

CA key must be kept by the CA to enable certificate signing.
server cert and CA cert must be given to the server. These are not secret.
pre-shared key must be given to the server, this is secret.
diffie-helman key paramaters file must be given to the server, this is not secret.
CA cert must be given to the client, this is not secret.
pre-shared key must be given to the client, this is secret.

## set up openvpn client creds with easy-rsa

# create client request and key
# start at vpnbox directory
cd server
cd easy-rsa
# create the client creds
./easyrsa gen-req client-foo nopass
# request and key are at pki/reqs/client-foo.req, pki/private/client-foo.key

# sign client certificate request with certificate authority
# start at vpnbox directory
cd ca
cd easy-rsa
./easyrsa import-req ../../server/easy-rsa/pki/reqs/client-foo.req client-foo
# type "yes" to confirm
./easyrsa sign-req client client-foo
# client cert is at pki/issued/client-foo.crt

client cert must be given to the client, this is not secret.
client key must be given to the client, this is secret.
