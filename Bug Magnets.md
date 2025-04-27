#Gourt Neighbour References
Gourts keep track of their neighbours in the stack, however there no gaurentee that these references are correct and if they are not correct it could cause all manner if weird behaviour inlcuding startup crashes
# Global Position Craziness
so much code only works reliably among siblings. And because we use tranfroms to flip ourselves, transform.to_local doesn't relaibly work
