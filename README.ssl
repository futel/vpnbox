## set up openvpn keys with openvpn's easy-rsa

# this is where ubuntu easy-rsa 2.2.2 puts it, other distros differ
cp -r /usr/share/easy-rsa/ .
cd easy-rsa
ln -s openssl-1.0.0.cnf openssl.cnf
source ./vars

# set up ca and server, do this once for vpnbox
# some of these are interactive, can we set up args beforehand?
source ./vars
./build-ca
./build-key-server server
cp keys/ca.crt keys/ca.key keys/dh1024.pem keys/server.crt keys/server.csr keys/server.key ~/Documents/futel-vpnbox/creds

# set up creds named 'client-foo', do this for each client
source ./vars
cp ../creds/ca.crt ../creds/ca.key keys # if not there from last step
./build-key client-foo # hit return for all questions, confirm sign and commit
cp keys/client-foo.* ../creds/client
# give keys/client-foo.* to the client, which must rename them
