sudo mkdir ${NFS_PATH}
sudo chmod 0777 ${NFS_PATH}
echo "${NFS_PATH} ${NFS_ACCESS}(rw,sync,no_subtree_check,no_root_squash)" |sudo tee -a /etc/exports
sudo exportfs -ra
