# QuarkBTCwallet
Matlab scripts for the whole process of creating a BTC paper wallet offline. From generating entropy to QR codes 

The main functions (BTCwallet and QuarkBTCwallet) perform all the operations required for the generation of a bitcoin 
"cold wallet", from a simple "entropy pump" dependent on mouse movement to the offline generation of QR codes for the 
bitcoin address and secret key. The included scripts, which can be invoked individually, perform the SHA256 and ripemd160
hashes, the ECDSA cryptography in the secp256k1 curve as well as the bi-directional hex to base58 conversion.

QuarkBTCwallet assigns, for each bitcoin address, three paper "Quark" wallets each containing two-thirds of the private key.
This minimizes the risk, because even if one of the three paper wallets is lost or stolen, we don't lose our bitcoins as long
as we keep two out of three cold wallets.

The inclusion of QRencoder.m and the detailed explanations in the "Entropy bomb" section of BTCwallet.m are intended to make 
everything transparent and secure, by not relying on third party applications or online connections.
